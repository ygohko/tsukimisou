import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsukimisou/app_state.dart';
import 'package:tsukimisou/home_page.dart';
import 'package:tsukimisou/memo_store.dart';
import 'package:tsukimisou/memo_store_google_drive_loader.dart';
import 'package:tsukimisou/memo_store_google_drive_saver.dart';
import 'package:tsukimisou/memo_store_local_loader.dart';
import 'package:tsukimisou/memo_store_local_saver.dart';
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
        home: HomePage(),
      ),
    ),
  );
}

void main() {
  MemoStoreLocalLoader.constructorHook = (memoStore, path) {
    return MemoStoreMockLocalLoader(memoStore, path);
  };
  MemoStoreLocalSaver.constructorHook = (memoStore, path) {
    return MemoStoreMockLocalSaver(memoStore, path);
  };
  MemoStoreGoogleDriveLoader.constructorHook = (memoStore, fileName) {
    return MemoStoreMockGoogleDriveLoader(memoStore, fileName);
  };
  MemoStoreGoogleDriveSaver.constructorHook = (memoStore, fileName) {
    return MemoStoreMockGoogleDriveSaver(memoStore, fileName);
  };
  
  group('HomePage', () {


      testWidgets('HomePage shoud have specified widgets.',
        (WidgetTester tester) async {
          Settings.sharedPreferencesCreatorHook = () async {
            return MockSharedPreferencesWithCache();
          };


          await init(tester);
          expect(find.text('Tsukimisou'), findsOneWidget);
          expect(find.byIcon(Icons.add), findsOneWidget);

          Settings.sharedPreferencesCreatorHook = null;


      });

      testWidgets('HomePage shoud show EditingPage when user taps add button.',
        (WidgetTester tester) async {
          Settings.sharedPreferencesCreatorHook = () async {
            return MockSharedPreferencesWithCache();
          };
          await init(tester);
          await tester.tap(find.byIcon(Icons.add));
          await tester.pump();
          expect(find.textContaining('Add a new memo'), findsOneWidget);
          expect(find.byIcon(Icons.done), findsOneWidget);
          expect(find.byIcon(Icons.close), findsOneWidget);

          Settings.sharedPreferencesCreatorHook = null;


      });

  });

  MemoStoreGoogleDriveSaver.constructorHook = null;
  MemoStoreGoogleDriveLoader.constructorHook = null;
  MemoStoreLocalSaver.constructorHook = null;
  MemoStoreLocalLoader.constructorHook = null;
}
