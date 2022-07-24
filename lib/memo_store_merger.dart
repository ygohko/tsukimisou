/*
 * Copyright (c) 2022 Yasuaki Gohko
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
    // Remove memos if it is removed in from memo store.
    final newMemos = <Memo>[];
    for (var memo in toMemoStore.memos) {
      final fromMemo = _getMemoFromId(fromMemoStore, memo.id);
      if (fromMemo != null) {
        // Memo is in from memo store. Do not remove.
        newMemos.add(memo);
      } else {
        final toLastModified =
            DateTime.fromMillisecondsSinceEpoch(memo.lastModified).toUtc();
        final fromLastMerged =
            DateTime.fromMillisecondsSinceEpoch(fromMemoStore.lastMerged)
                .toUtc();
        if (fromLastMerged.isBefore(toLastModified)) {
          // Memo is updated after last merged. Do not remove.
          newMemos.add(memo);
        } else {
          // Memo is not updated after last merged. Do nothing.
        }
      }
    }
    toMemoStore.memos = newMemos;

    // Update memos if needed.
    for (final memo in toMemoStore.memos) {
      final fromMemo = _getMemoFromId(fromMemoStore, memo.id);
      if (fromMemo != null) {
        if (fromMemo.revision <= memo.lastMergedRevision) {
          // From memo is not modified. Do nothing.
        } else if (memo.revision <= memo.lastMergedRevision) {
          // From memo is modified and to memo is not modified. Update to memo.
          memo.text = fromMemo.text;
          memo.tags = [...fromMemo.tags];
          memo.lastModified = fromMemo.lastModified;
        } else {
          // Both modified. Mark as Conflicted.
          var text = 'This memo is conflicted.\nMine --------\n';
          text += memo.text;
          text += '\nTheirs --------\n';
          text += fromMemo.text;
          memo.text = text;
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

    // Copy memos that are only in from memo store.
    for (var memo in fromMemoStore.memos) {
      final toMemo = _getMemoFromId(toMemoStore, memo.id);
      if (toMemo == null && toMemoStore.removedMemoIds.indexOf(memo.id) == -1) {
        toMemoStore.addMemo(memo);
      }
    }

    // Update information.
    for (var memo in toMemoStore.memos) {
      memo.lastMergedRevision = memo.revision;
    }
    toMemoStore.removedMemoIds = <String>[];
    toMemoStore.lastMerged = DateTime.now().millisecondsSinceEpoch;
  }

  Memo? _getMemoFromId(MemoStore memoStore, String id) {
    // TODO: Move to MemoStore.
    for (var memo in memoStore.memos) {
      if (memo.id == id) {
        return memo;
      }
    }

    return null;
  }
}
