import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsukimisou/app_state.dart';
import 'package:tsukimisou/memo_store.dart';
import 'package:tsukimisou/searching_page.dart';
import 'package:tsukimisou/settings.dart';
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
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MemoStore>(create: (context) => MemoStore()),
        ChangeNotifierProvider<AppState>(create: (context) => AppState()),
        ChangeNotifierProvider<Settings>(create: (context) => Settings()),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
        ],
        home: SearchingPage(),
      ),
    ),
  );
}

void main() {
  group('SearchingPage', () {
    testWidgets('SearchingPage shoud have specified widgets.',
        (WidgetTester tester) async {
      Settings.sharedPreferencesCreatorHook = () async {
        return MockSharedPreferencesWithCache();
      };

      await init(tester);
      expect(find.text('Search memos'), findsWidgets);

      Settings.sharedPreferencesCreatorHook = null;
    });
  });
}
