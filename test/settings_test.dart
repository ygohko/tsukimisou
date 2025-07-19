import 'package:flutter_test/flutter_test.dart';
import 'package:tsukimisou/settings.dart';

import 'mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Settings', () {
    setUpAll(() {
      Settings.sharedPreferencesCreatorHook = () async {
        return MockSharedPreferencesWithCache();
      };
    });

    tearDownAll(() {
      Settings.sharedPreferencesCreatorHook = null;
    });

    test('Settings should be created', () {
      expect(Settings(), isNotNull);
    });

    test(
        'Settings.getSynchronizationHidden() should get whether synchronization is hidden',
        () async {
      final settings = Settings();
      await settings.init();
      final hidden = settings.getSynchronizationHidden();
      expect(hidden, false);
    });

    test(
        'Settings.setSynchronizationHidden() should set whether synchronization is hidden',
        () async {
      final settings = Settings();
      await settings.init();
      await settings.setSynchronizationHidden(true);
      final hidden = settings.getSynchronizationHidden();
      expect(hidden, true);
    });

    test('Settings.getTagScores() should get tag scores', () async {
      final settings = Settings();
      await settings.init();
      final scores = settings.getTagScores();
      expect(scores['a'], 1.0);
      expect(scores['b'], 0.5);
    });

    test('Settings.setTagScores() should set tag scores', () async {
      final settings = Settings();
      await settings.init();
      await settings.setTagScores({
        'c': 1.0,
        'd': 0.5,
      });
      final scores = settings.getTagScores();
      expect(scores['c'], 1.0);
      expect(scores['d'], 0.5);
    });
  });
}
