import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsukimisou/settings.dart';

// ignore: must_be_immutable
class MockSharedPreferencesWithCache implements SharedPreferencesWithCache {
  var _hidden = false;
  var _tagScores = '{"a": 1.0, "b": 0.5}';

  @override
  bool? getBool(String key) {
    return _hidden;
  }

  @override
  String? getString(String key) {
    return _tagScores;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _hidden = value;
  }

  @override
  Future<void> setString(String key, String value) async {
    _tagScores = value;
  }

  @override
  noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Settings', () {
    test('Settings should be created', () {
      expect(Settings(), isNotNull);
    });

    test('Settings.getSynchronizingHidden() should get whether synchronizing is hidden', () async {
        Settings.sharedPreferencesCreatorHook = () async {
          return MockSharedPreferencesWithCache();
        };

        final settings = Settings();
        final hidden = settings.getSynchronizingHidden();
        expect(hidden, false);

        Settings.sharedPreferencesCreatorHook = null;
    });

    test('Settings.setSynchronizingHidden() should set whether synchronizing is hidden', () async {
        Settings.sharedPreferencesCreatorHook = () async {
          return MockSharedPreferencesWithCache();
        };

        final settings = Settings();
        await settings.setSynchronizingHidden(true);
        final hidden = settings.getSynchronizingHidden();
        expect(hidden, true);

        Settings.sharedPreferencesCreatorHook = null;
    });

    test('Settings.getTagScores() should get tag scores', () async {
        Settings.sharedPreferencesCreatorHook = () async {
          return MockSharedPreferencesWithCache();
        };

        final settings = Settings();
        final scores = settings.getTagScores();
        expect(scores['a'], 1.0);
        expect(scores['b'], 0.5);

        Settings.sharedPreferencesCreatorHook = null;
    });

    test('Settings.setTagScores() should set tag scores', () async {
        Settings.sharedPreferencesCreatorHook = () async {
          return MockSharedPreferencesWithCache();
        };

        final settings = Settings();
        await settings.setTagScores({
            'c': 1.0,
            'd': 0.5,            
        });
        final scores = settings.getTagScores();
        expect(scores['c'], 1.0);
        expect(scores['d'], 0.5);

        Settings.sharedPreferencesCreatorHook = null;
    });
  });
}
