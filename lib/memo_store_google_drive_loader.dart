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

import 'google_drive_file.dart';
import 'memo_store.dart';
import 'memo_store_loader.dart';

typedef MemoStoreGoogleDriveLoaderConstructorHook = MemoStoreGoogleDriveLoader
    Function(MemoStore memoStore, String fileName);

class MemoStoreGoogleDriveLoader extends MemoStoreLoader {
  final String _fileName;

  static MemoStoreGoogleDriveLoaderConstructorHook? _constructorHook;

  /// Creates a memo store loader.
  factory MemoStoreGoogleDriveLoader(MemoStore memoStore, String fileName) {
    final hook = _constructorHook;
    if (hook != null) {
      return hook(memoStore, fileName);
    }

    return MemoStoreGoogleDriveLoader._private(memoStore, fileName);
  }

  /// Executes this memo store loader.
  Future<void> execute() async {
    final file = GoogleDriveFile(_fileName);
    final string = await file.readAsStringLocked();
    deserialize(string);
  }

  /// Hook for cobstructor of memo store loader.
  static set constructorHook(MemoStoreGoogleDriveLoaderConstructorHook? hook) {
    _constructorHook = hook;
  }

  MemoStoreGoogleDriveLoader._private(MemoStore memoStore, this._fileName)
      : super(memoStore);
}

class MemoStoreMockGoogleDriveLoader extends MemoStoreLoader
    implements MemoStoreGoogleDriveLoader {
  @override
  final String _fileName;

  /// Creates a memo store loader.
  MemoStoreMockGoogleDriveLoader(MemoStore memoStore, this._fileName)
      : super(memoStore);

  /// Executes this memo store loader.
  @override
  Future<void> execute() async {
    // TODO: Load test data.
  }
}
