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

import 'memo_store.dart';

class MemoStoreLoader {
  MemoStore? _memoStore = null;
  var _path = '';

  MemoStoreLoader(MemoStore memoStore, String path) {
    _memoStore = memoStore;
    _path = path;
  }

  Future<void> execute() async {
    if (_memoStore == null) {
        return;
    }
    final file = File(_path);
    // TODO: Synced version will be needed
    var string = await file.readAsString();
    final decoded = jsonDecode(string);
    _memoStore?.clear();
    for (var i = 0; i < decoded.length; i++) {
      _memoStore?.addMemo(decoded[i]);
    }
  }

static Future<MemoStoreLoader> getFromFileName(MemoStore memoStore, String fileName) async {
    final applicationDocumentsDirectory = await getApplicationDocumentsDirectory();
    var path = applicationDocumentsDirectory.path;
    print('path: ${path}\n');
    path = path + Platform.pathSeparator + fileName;
    print('path: ${path}\n');

    return MemoStoreLoader(memoStore, path);
  }
}
