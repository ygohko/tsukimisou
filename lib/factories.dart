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

import 'memo_store.dart';
import 'memo_store_local_loader.dart';
import 'memo_store_local_saver.dart';

enum FactriesType {
  App,
  Test,
}

abstract class Factories {
  static var _type = FactriesType.App;
  static Factories? _instance = null;

  Future<MemoStoreAbstractLocalLoader> memoStoreLocalLoaderFromFileName(MemoStore memoStore, String fileName);
  Future<MemoStoreAbstractLocalSaver> memoStoreLocalSaverFromFileName(MemoStore memoStore, String fileName);

  static void init(FactriesType type) {
    _type = type;
  }

  static Factories instance() {
    if (_instance == null) {
      if (_type == FactriesType.App) {
        _instance = AppFactories();
      } else {
        _instance = TestFactories();
      }
    }

    return _instance!;
  }
}

class AppFactories extends Factories {
  @override
  Future<MemoStoreAbstractLocalLoader> memoStoreLocalLoaderFromFileName(MemoStore memoStore, String fileName) async {
    return MemoStoreLocalLoader.fromFileName(memoStore, fileName);
  }

  @override
  Future<MemoStoreAbstractLocalSaver> memoStoreLocalSaverFromFileName(MemoStore memoStore, String fileName) async {
    return MemoStoreLocalSaver.fromFileName(memoStore, fileName);
  }
}

class TestFactories extends Factories {
  @override
  Future<MemoStoreAbstractLocalLoader> memoStoreLocalLoaderFromFileName(MemoStore memoStore, String fileName) async {
    return MemoStoreMockLocalLoader.fromFileName(memoStore, fileName);
  }

  @override
  Future<MemoStoreAbstractLocalSaver> memoStoreLocalSaverFromFileName(MemoStore memoStore, String fileName) async {
    return MemoStoreMockLocalSaver.fromFileName(memoStore, fileName);
  }
}
