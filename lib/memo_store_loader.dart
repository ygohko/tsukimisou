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

import "dart:convert";

import 'memo.dart';
import 'memo_store.dart';

class MemoStoreLoader {
  final MemoStore _memoStore;

  /// Creates a memo store loader base.
  MemoStoreLoader(this._memoStore);

  /// Deserializes memo store.
  void deserialize(String serialized) {
    final decoded = jsonDecode(serialized);
    final version = decoded['version'];
    if (version > 2) {
      throw FileNotCompatibleException('File not compatible.');
    }
    _memoStore.clearMemos();
    _memoStore.lastMerged = decoded['lastMerged'];
    final deserializedIds = decoded['removedMemoIds'];
    final removedMemoIds = <String>[];
    for (var removedMemoId in deserializedIds) {
      if (removedMemoId is String) {
        removedMemoIds.add(removedMemoId);
      }
    }
    _memoStore.removedMemoIds = removedMemoIds;
    final deserializedMemos = decoded['memos'];
    for (var deserializedMemo in deserializedMemos) {
      final memo = Memo();
      memo.id = deserializedMemo['id'];
      memo.text = deserializedMemo['text'];
      final deserializedTags = deserializedMemo['tags'];
      final tags = <String>[];
      for (var tag in deserializedTags) {
        if (tag is String) {
          tags.add(tag);
        }
      }
      memo.tags = tags;
      memo.lastModified = deserializedMemo['lastModified'];
      memo.revision = deserializedMemo['revision'];
      memo.lastMergedRevision = deserializedMemo['lastMergedRevision'];
      if (version > 1) {
        memo.beforeModifiedHash = deserializedMemo['beforeModifiedHash'];
      }
      _memoStore.addMemo(memo);
    }
  }
}

class FileNotCompatibleException implements Exception {
  final String message;

  FileNotCompatibleException(this.message);
}
