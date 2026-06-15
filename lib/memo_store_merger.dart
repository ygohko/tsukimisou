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

import 'diff_generator.dart';
import 'memo.dart';
import 'memo_store.dart';

enum _Operation {
  keep,
  overwrite,
  merge,
}

class MemoStoreMerger {
  /// Memo store that memos are merged to.
  final MemoStore toMemoStore;

  /// Memo store that memos are merged from.
  final MemoStore fromMemoStore;

  String _conflictWarningText = "This memo has conflicts.";
  String _localMarkerText = "Local";
  String _cloudMarkerText = "Cloud";

  /// Creates a memo store manager.
  MemoStoreMerger(this.toMemoStore, this.fromMemoStore);

  /// Executes this memo store manager.
  Future<void> execute() async {
    // Update memos if needed.
    for (final memo in toMemoStore.memos) {
      final fromMemo = fromMemoStore.memoFromId(memo.id);
      if (fromMemo != null) {
        final operation = _operation(memo, fromMemo);
        switch (operation) {
          case _Operation.keep:
            if (fromMemo.lastModified > memo.lastModified) {
              memo.lastModified = fromMemo.lastModified;
            }
            break;

          case _Operation.overwrite:
            memo.text = fromMemo.text;
            memo.tags = [...fromMemo.tags];
            memo.name = fromMemo.name;
            memo.viewingMode = fromMemo.viewingMode;
            memo.lastModified = fromMemo.lastModified;
            memo.revision = fromMemo.revision;
            break;

          case _Operation.merge:
            if (memo.text != fromMemo.text) {
              final generator = DiffGenerator(memo.text, fromMemo.text);
              generator.conflictWarningText = _conflictWarningText;
              generator.localMarkerText = _localMarkerText;
              generator.cloudMarkerText = _cloudMarkerText;
              generator.execute();
              final result = generator.result;
              if (result != null) {
                memo.text = result;
              }
            }
            var tags = [...memo.tags];
            for (final tag in fromMemo.tags) {
              if (!memo.tags.contains(tag)) {
                tags.add(tag);
              }
            }
            memo.tags = tags;
            memo.name = fromMemo.name;
            memo.viewingMode = fromMemo.viewingMode;
            memo.lastModified = fromMemo.lastModified;
            if (memo.revision > fromMemo.revision) {
              memo.revision++;
            } else {
              memo.revision = fromMemo.revision + 1;
            }
            break;
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
    }
    final count = removedMemoIds.length;
    if (count > 100) {
      removedMemoIds = removedMemoIds.sublist(count - 100);
    }
    toMemoStore.removedMemoIds = removedMemoIds;
    toMemoStore.lastMerged = DateTime.now().millisecondsSinceEpoch;

    // Get archives that need to be merged.
    final archiveNames = <String>{};
    archiveNames.addAll(toMemoStore.archiveHashes.keys);
    archiveNames.addAll(fromMemoStore.archiveHashes.keys);

    final archivesToMerge = <String>[];
    for (final name in archiveNames) {
      if (toMemoStore.archiveHashes[name] != fromMemoStore.archiveHashes[name]) {
        archivesToMerge.add(name);
      }
    }

    for (final name in archivesToMerge) {
      MemoStore toArchive;
      if (toMemoStore.archiveHashes.containsKey(name)) {
        toArchive = await toMemoStore.archiveMemoStore(name);
      } else {
        toArchive = MemoStore();
        toMemoStore.archiveMemoStores[name] = toArchive;
      }

      MemoStore fromArchive;
      if (fromMemoStore.archiveHashes.containsKey(name)) {
        fromArchive = await fromMemoStore.archiveMemoStore(name);
      } else {
        fromArchive = MemoStore();
        fromMemoStore.archiveMemoStores[name] = fromArchive;
      }

      final merger = MemoStoreMerger(toArchive, fromArchive);
      merger.conflictWarningText = _conflictWarningText;
      merger.localMarkerText = _localMarkerText;
      merger.cloudMarkerText = _cloudMarkerText;
      await merger.execute();

      toMemoStore.archiveHashes[name] = toArchive.hash;
    }

    toMemoStore.markAsChanged();
  }

  /// Conflict warning text.
  set conflictWarningText(String text) {
    _conflictWarningText = text;
  }

  /// Local marker text.
  set localMarkerText(String text) {
    _localMarkerText = text;
  }

  /// Cloud markger text.
  set cloudMarkerText(String text) {
    _cloudMarkerText = text;
  }

  _Operation _operation(Memo toMemo, Memo fromMemo) {
    if (toMemo.hash == fromMemo.hash) {
      return _Operation.keep;
    }

    if (toMemo.revision == toMemo.lastMergedRevision) {
      if (fromMemo.beforeModifiedHash == toMemo.hash) {
        return _Operation.overwrite;
      } else {
        return _Operation.merge;
      }
    }
    if (toMemo.beforeModifiedHash == fromMemo.hash) {
      return _Operation.keep;
    }

    return _Operation.merge;
  }
}
