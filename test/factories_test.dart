import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_linux/path_provider_linux.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_windows/path_provider_windows.dart';
import 'package:tsukimisou/factories.dart';
import 'package:tsukimisou/memo_store.dart';
import 'package:tsukimisou/memo_store_local_loader.dart';
import 'package:tsukimisou/memo_store_local_saver.dart';
import 'package:tsukimisou/memo_store_google_drive_loader.dart';
import 'package:tsukimisou/memo_store_google_drive_saver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  if (Platform.isLinux) {
    PathProviderLinux.registerWith();
  }
  if (Platform.isWindows) {
    PathProviderWindows.registerWith();
  }
  Factories.init(FactoriesType.test);

  group('Factories', () {
    test('Factories should create test factoreis.', () async {
      final factories = Factories.instance();
      expect(factories.runtimeType, TestFactories);
    });

    test('Factories should create local loader for app.', () async {
      final memoStore = MemoStore();
      final factories = Factories.instance();
      final loader = await factories.memoStoreLocalLoaderFromFileName(
          memoStore, 'test.json');
      expect(loader.runtimeType, MemoStoreMockLocalLoader);
    });

    test('Factories should create local saver for app.', () async {
      final memoStore = MemoStore();
      final factories = Factories.instance();
      final saver = await factories.memoStoreLocalSaverFromFileName(
          memoStore, 'test.json');
      expect(saver.runtimeType, MemoStoreMockLocalSaver);
    });

    test('Factories should create Google Drive loader for app.', () {
      final memoStore = MemoStore();
      final factories = Factories.instance();
      final loader =
          factories.memoStoreGoogleDriveLoader(memoStore, 'test.json');
      expect(loader.runtimeType, MemoStoreMockGoogleDriveLoader);
    });

    test('Factories should create Google Drive saver for app.', () {
      final memoStore = MemoStore();
      final factories = Factories.instance();
      final saver = factories.memoStoreGoogleDriveSaver(memoStore, 'test.json');
      expect(saver.runtimeType, MemoStoreMockGoogleDriveSaver);
    });
  });
}
