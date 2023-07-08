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
import 'memo_store_google_drive_loader.dart';
import 'memo_store_google_drive_saver.dart';
import 'memo_store_local_loader.dart';
import 'memo_store_local_saver.dart';

enum FactoriesType {
  app,
  test,
}

abstract class Factories {
  static var _type = FactoriesType.app;
  static Factories? _instance;

  /// Ceates memo store local loader.
  Future<MemoStoreAbstractLocalLoader> memoStoreLocalLoaderFromFileName(
      MemoStore memoStore, String fileName);

  /// Ceates memo store local saver.
  Future<MemoStoreAbstractLocalSaver> memoStoreLocalSaverFromFileName(
      MemoStore memoStore, String fileName);

  /// Ceates memo store Google Drive loader.
  MemoStoreAbstractGoogleDriveLoader memoStoreGoogleDriveLoader(
      MemoStore memoStore, String fileName);

  /// Ceates memo store Google Drive saver.
  MemoStoreAbstractGoogleDriveSaver memoStoreGoogleDriveSaver(
      MemoStore memoStore, String fileName);

  /// Initializes this class.
  static void init(FactoriesType type) {
    _type = type;
  }

  /// Instance of this class.
  static Factories instance() {
    if (_instance == null) {
      if (_type == FactoriesType.app) {
        _instance = AppFactories();
      } else {
        _instance = TestFactories();
      }
    }

    return _instance!;
  }
}

class AppFactories extends Factories {
  /// Ceates memo store local loader.
  @override
  Future<MemoStoreAbstractLocalLoader> memoStoreLocalLoaderFromFileName(
      MemoStore memoStore, String fileName) async {
    return MemoStoreLocalLoader.fromFileName(memoStore, fileName);
  }

  /// Ceates memo store local saver.
  @override
  Future<MemoStoreAbstractLocalSaver> memoStoreLocalSaverFromFileName(
      MemoStore memoStore, String fileName) async {
    return MemoStoreLocalSaver.fromFileName(memoStore, fileName);
  }

  /// Ceates memo store Google Drive loader.
  @override
  MemoStoreAbstractGoogleDriveLoader memoStoreGoogleDriveLoader(
      MemoStore memoStore, String fileName) {
    return MemoStoreGoogleDriveLoader(memoStore, fileName);
  }

  /// Ceates memo store Google Drive saver.
  @override
  MemoStoreAbstractGoogleDriveSaver memoStoreGoogleDriveSaver(
      MemoStore memoStore, String fileName) {
    return MemoStoreGoogleDriveSaver(memoStore, fileName);
  }
}

class TestFactories extends Factories {
  /// Ceates memo store local loader.
  @override
  Future<MemoStoreAbstractLocalLoader> memoStoreLocalLoaderFromFileName(
      MemoStore memoStore, String fileName) async {
    return MemoStoreMockLocalLoader.fromFileName(memoStore, fileName);
  }

  /// Ceates memo store local saver.
  @override
  Future<MemoStoreAbstractLocalSaver> memoStoreLocalSaverFromFileName(
      MemoStore memoStore, String fileName) async {
    return MemoStoreMockLocalSaver.fromFileName(memoStore, fileName);
  }

  /// Ceates memo store Google Drive loader.
  @override
  MemoStoreAbstractGoogleDriveLoader memoStoreGoogleDriveLoader(
      MemoStore memoStore, String fileName) {
    return MemoStoreMockGoogleDriveLoader(memoStore, fileName);
  }

  /// Ceates memo store Google Drive saver.
  @override
  MemoStoreAbstractGoogleDriveSaver memoStoreGoogleDriveSaver(
      MemoStore memoStore, String fileName) {
    return MemoStoreMockGoogleDriveSaver(memoStore, fileName);
  }
}
