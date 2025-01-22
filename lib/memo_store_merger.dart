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
        late final bool fromModified;
        if (fromMemo.hash != fromMemo.lastMergedHash) {
          fromModified = true;
        } else {
          fromModified = false;
        }
        if (!fromModified) {
          // fromMemo is not modified. Do nothing.
        } else if (fromMemo.lastMergedHash == memo.hash) {
          // fromMmemo is modified and toMemo is not modified. Update toMemo.
          memo.text = fromMemo.text;
          memo.tags = [...fromMemo.tags];
          memo.lastModified = fromMemo.lastModified;
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
          } else {
            // Both same. Do nothing.
          }
          var tags = [...memo.tags];
          for (final tag in fromMemo.tags) {
            if (!memo.tags.contains(tag)) {
              tags.add(tag);
            }
          }
          memo.tags = tags;
        }
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
      memo.updateLastMergedhash();
    }
    final count = removedMemoIds.length;
    if (count > 100) {
      removedMemoIds = removedMemoIds.sublist(count - 100);
    }
    toMemoStore.removedMemoIds = removedMemoIds;
    toMemoStore.lastMerged = DateTime.now().millisecondsSinceEpoch;
    toMemoStore.markAsChanged();
  }
}
