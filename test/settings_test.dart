import 'package:flutter_test/flutter_test.dart';
import 'package:tsukimisou/settings.dart';

import 'mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Settings', () {
    test('Settings should be created', () {
      expect(Settings(), isNotNull);
    });

    test(
        'Settings.getSynchronizingHidden() should get whether synchronizing is hidden',
        () async {
      Settings.sharedPreferencesCreatorHook = () async {
        return MockSharedPreferencesWithCache();
      };

      final settings = Settings();
      await settings.init();
      final hidden = settings.getSynchronizingHidden();
      expect(hidden, false);

      Settings.sharedPreferencesCreatorHook = null;
    });

    test(
        'Settings.setSynchronizingHidden() should set whether synchronizing is hidden',
        () async {
      Settings.sharedPreferencesCreatorHook = () async {
        return MockSharedPreferencesWithCache();
      };

      final settings = Settings();
      await settings.init();
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
      await settings.init();
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
      await settings.init();
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
