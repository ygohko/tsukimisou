import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsukimisou/settings.dart';
import 'package:tsukimisou/settings_page.dart';
import 'package:tsukimisou/gen_l10n/app_localizations.dart';

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

Future<void> init(WidgetTester tester) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (context) => Settings(),
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
        ],
        home: SettingsPage(fullScreen: false),
      ),
    ),
  );
}

void main() {
  group('SettingsPage', () {
      Settings.sharedPreferencesCreatorHook = () async {
        return MockSharedPreferencesWithCache();
      };

      testWidgets(
        'SettinsPage should have specified widgets.',
        (WidgetTester tester) async {
          await init(tester);
          expect(find.text('Settings'), findsOneWidget);
          expect(find.text('Hide Google Drive synchronization'), findsOneWidget);
      });

      Settings.sharedPreferencesCreatorHook = null;
  });
}
