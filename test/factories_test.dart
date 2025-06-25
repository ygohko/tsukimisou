import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_linux/path_provider_linux.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_windows/path_provider_windows.dart';
import 'package:tsukimisou/factories.dart';
import 'package:tsukimisou/memo_store.dart';
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
    test('Factories should create test factories.', () async {
      final factories = Factories.instance();
      expect(factories.runtimeType, TestFactories);
    });
  });
}
