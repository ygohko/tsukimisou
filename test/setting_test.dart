import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsukimisou/settings.dart';

class MockSharedPreferencesWithCache implements SharedPreferencesWithCache {
  bool? getBool(String key) {
    return true;
  }

  Future<void> setBool(String key, bool value) async {
  }

  noSuchMethod(Invocation invocation) {
    assert(false);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Settings', () {
    test('Settings should be created', () {
      expect(Settings(), isNotNull);
    });

    test('Settings.getSynchronizing() should whether synchronizing is hidden', () async {
        Settings.sharedPreferencesCreatorHook = () async {
          return MockSharedPreferencesWithCache();
        };

        final settings = Settings();
        final hidden = await settings.getSynchronizingHidden();
        expect(hidden, true);
    });

    test('Settings.getSynchronizing() should whether synchronizing is hidden', () async {
        Settings.sharedPreferencesCreatorHook = () async {
          return MockSharedPreferencesWithCache();
        };

        final settings = Settings();
        await settings.setSynchronizingHidden(false);
    });


    

    // TODO: Add tests for getters and setters.
  });
}
