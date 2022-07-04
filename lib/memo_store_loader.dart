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

import "dart:convert";
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'memo.dart';
import 'memo_store.dart';

class MemoStoreLoader {
  MemoStore? _memoStore = null;
  var _path = '';

  /// Creates a memo store loader.
  MemoStoreLoader(MemoStore memoStore, String path) {
    _memoStore = memoStore;
    _path = path;
  }

  /// Executes this memo store loader.
  Future<void> execute() async {
    final memoStore = _memoStore;
    if (memoStore == null) {
      return;
    }
    final file = File(_path);
    final string = await file.readAsString();
    final decoded = jsonDecode(string);
    print('aDecoded: ${decoded}');
    final version = decoded['version'];
    memoStore.clearMemos();
    memoStore.lastMerged = decoded['lastMerged'];
    // TODO: Load removed memo IDs.
    final deserializedMemos = decoded['memos'];
    for (var deserializedMemo in deserializedMemos) {
      final memo = Memo();
      memo.id = deserializedMemo['id'];
      memo.lastModified = deserializedMemo['lastModified'];
      memo.text = deserializedMemo['text'];
      final deserializedTags = deserializedMemo['tags'];
      final tags = <String>[];
      for (var tag in deserializedTags) {
        if (tag is String) {
          tags.add(tag);
        }
      }
      memo.tags = tags;
      memo.revision = deserializedMemo['revision'];
      memo.lastMergedRevition = deserializedMemo['lastMergedRevision'];
      memoStore.addMemo(memo);
    }
  }

  /// Creates a memo store loader from file name.
  static Future<MemoStoreLoader> fromFileName(
      MemoStore memoStore, String fileName) async {
    final applicationDocumentsDirectory =
        await getApplicationDocumentsDirectory();
    var path = applicationDocumentsDirectory.path;
    print('path: ${path}\n');
    path = path + Platform.pathSeparator + fileName;
    print('path: ${path}\n');

    return MemoStoreLoader(memoStore, path);
  }
}
