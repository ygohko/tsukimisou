import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsukimisou/settings.dart';

class MockSharedPreferencesWithCache implements SharedPreferencesWithCache {
  var _hidden = false;

  bool? getBool(String key) {
    return _hidden;
  }

  Future<void> setBool(String key, bool value) async {
    _hidden = value;
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

    test('Settings.getSynchronizing() should get whether synchronizing is hidden', () async {
        Settings.sharedPreferencesCreatorHook = () async {
          return MockSharedPreferencesWithCache();
        };

        final settings = Settings();
        final hidden = await settings.getSynchronizingHidden();
        expect(hidden, false);
    });

    test('Settings.setSynchronizing() should set whether synchronizing is hidden', () async {
        Settings.sharedPreferencesCreatorHook = () async {
          return MockSharedPreferencesWithCache();
        };

        final settings = Settings();
        await settings.setSynchronizingHidden(true);
        final hidden = await settings.getSynchronizingHidden();
        expect(hidden, true);
    });


    

    // TODO: Add tests for getters and setters.
  });
}
