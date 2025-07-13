import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tsukimisou/app_state.dart';
import 'package:tsukimisou/home_page.dart';
import 'package:tsukimisou/memo_store.dart';
import 'package:tsukimisou/memo_store_google_drive_loader.dart';
import 'package:tsukimisou/memo_store_google_drive_saver.dart';
import 'package:tsukimisou/memo_store_local_loader.dart';
import 'package:tsukimisou/memo_store_local_saver.dart';
import 'package:tsukimisou/settings.dart';
import 'package:tsukimisou/gen_l10n/app_localizations.dart';

import 'mocks.dart';

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
  group('HomePage', () {
    setUpAll(() {
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
      Settings.sharedPreferencesCreatorHook = () async {
        return MockSharedPreferencesWithCache();
      };
    });

    tearDownAll(() {
      Settings.sharedPreferencesCreatorHook = null;
      MemoStoreGoogleDriveSaver.constructorHook = null;
      MemoStoreGoogleDriveLoader.constructorHook = null;
      MemoStoreLocalSaver.constructorHook = null;
      MemoStoreLocalLoader.constructorHook = null;
    });

    testWidgets('HomePage shoud have specified widgets.',
        (WidgetTester tester) async {
      await init(tester);
      expect(find.text('Tsukimisou'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('HomePage shoud show EditingPage when user taps add button.',
        (WidgetTester tester) async {
      await init(tester);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.textContaining('Add a new memo'), findsOneWidget);
      expect(find.byIcon(Icons.done), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}
