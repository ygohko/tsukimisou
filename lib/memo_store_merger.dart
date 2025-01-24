/*
 * Copyright (c) 2022, 2025 Yasuaki Gohko
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE ABOVE LISTED COPYRIGHT HOLDER(S) BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

import 'memo.dart';
import 'memo_store.dart';

enum _Operation {
  keep,
  overwrite,
  makeConflict,
}

class MemoStoreMerger {
  final MemoStore toMemoStore;
  final MemoStore fromMemoStore;

  /// Creates a memo store manager.
  MemoStoreMerger(this.toMemoStore, this.fromMemoStore);

  /// Executes this memo store manager.
  void execute() {
    // Update memos if needed.
    for (final memo in toMemoStore.memos) {
      final fromMemo = fromMemoStore.memoFromId(memo.id);
      if (fromMemo != null) {
        final operation = _operation(memo, fromMemo);

        // ADHOC
        if (memo.text.startsWith('abcde')) {
          print('operation $operation');
        }

        switch (operation) {
          case _Operation.keep:
          // Do nothing.
          break;

          case _Operation.overwrite:
          memo.text = fromMemo.text;
          memo.tags = [...fromMemo.tags];
          memo.lastModified = fromMemo.lastModified;
          memo.revision = fromMemo.revision;
          break;

          case _Operation.makeConflict:
          if (memo.text != fromMemo.text) {
            // Mark as conflicted.
            // TODO: Make more smarter diff text.
            var text = 'This memo is conflicted.\nMine --------\n';
            text += memo.text;
            text += '\nTheirs --------\n';
            text += fromMemo.text;
            memo.text = text;
          }
          var tags = [...memo.tags];
          for (final tag in fromMemo.tags) {
            if (!memo.tags.contains(tag)) {
              tags.add(tag);
            }
          }
          memo.tags = tags;
          memo.lastModified = fromMemo.lastModified;
          if (memo.revision > fromMemo.revision) {
            memo.revision++;
          } else {
            memo.revision = fromMemo.revision + 1;
          }
          break;
        }

        /*
        late final bool fromModified;
        // FIXME: This code does not work because lastMergedHash was updated when previous merging.
        // TODO: Use revision to detect it?
        if (fromMemo.hash != fromMemo.beforeModifiedHash) {
          fromModified = true;
        } else {
          fromModified = false;
        }
        if (!fromModified) {
          // fromMemo is not modified. Do nothing.

          if (memo.text[0] == 'a') {
            print('1. ${memo.text}');
          }
          
        } else if (fromMemo.beforeModifiedHash == memo.hash) {
          // fromMmemo is modified and toMemo is not modified. Update toMemo.
          memo.text = fromMemo.text;
          memo.tags = [...fromMemo.tags];
          memo.lastModified = fromMemo.lastModified;
          // TODO: Do not update beforeModifiedHash?
          memo.beforeModifiedHash = memo.hash;
          
          if (memo.text[0] == 'a') {
            print('2. ${memo.text}');
          }

        } else {
          // Both modified.
          if (memo.text != fromMemo.text) {
            // Mark as conflicted.
            // TODO: Make more smarter diff text.
            var text = 'This memo is conflicted.\nMine --------\n';
            text += memo.text;
            text += '\nTheirs --------\n';
            text += fromMemo.text;
            memo.text = text;

            if (memo.text[0] == 'a') {
              print('3. ${memo.text}');
            }

          } else {
            // Both same. Do nothing.

            if (memo.text[0] == 'a') {
              print('4. ${memo.text}');
            }

          }
          var tags = [...memo.tags];
          for (final tag in fromMemo.tags) {
            if (!memo.tags.contains(tag)) {
              tags.add(tag);
            }
          }
          memo.tags = tags;
          memo.lastModified = fromMemo.lastModified;
          // TODO: Do not update beforeModifiedHash?
          memo.beforeModifiedHash = memo.hash;
        }
        */
      }
    }

    // Merge removed memo IDs.
    var removedMemoIds = [...toMemoStore.removedMemoIds];
    for (final removedMemoId in fromMemoStore.removedMemoIds) {
      if (!removedMemoIds.contains(removedMemoId)) {
        removedMemoIds.add(removedMemoId);
      }
    }

    // Copy memos that are only in from memo store.
    for (final memo in fromMemoStore.memos) {
      final toMemo = toMemoStore.memoFromId(memo.id);
      if (toMemo == null) {
        toMemoStore.addMemo(memo);
      }
    }

    // Remove memos that are marked as removed.
    final removingMemos = <Memo>[];
    for (final memo in toMemoStore.memos) {
      if (removedMemoIds.contains(memo.id)) {
        removingMemos.add(memo);
      }
    }
    for (final memo in removingMemos) {
      toMemoStore.removeMemo(memo);
    }

    // Update information.
    for (final memo in toMemoStore.memos) {
      memo.lastMergedRevision = memo.revision;
      // TODO: Update lastMergedHash when first modification?
      // TODO: Renamed to beforeModifiedHash?
      // memo.updateLastMergedhash();
    }
    final count = removedMemoIds.length;
    if (count > 100) {
      removedMemoIds = removedMemoIds.sublist(count - 100);
    }
    toMemoStore.removedMemoIds = removedMemoIds;
    toMemoStore.lastMerged = DateTime.now().millisecondsSinceEpoch;
    toMemoStore.markAsChanged();
  }

  _Operation _operation(Memo toMemo, Memo fromMemo) {
    if (toMemo.hash == fromMemo.hash) {
      return _Operation.keep;
    }

    if (toMemo.revision == toMemo.lastMergedRevision) {
      if (fromMemo.beforeModifiedHash == toMemo.hash) {
        return _Operation.overwrite;
      } else {
        return _Operation.makeConflict;
      }
    } else {
      if (toMemo.beforeModifiedHash == fromMemo.hash) {
        return _Operation.keep;
      } else {
        return _Operation.makeConflict;
      }
    }

    assert(false);
  }
}
