import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tsukimisou/settings.dart';
import 'package:tsukimisou/settings_page.dart';
import 'package:tsukimisou/gen_l10n/app_localizations.dart';

import 'mocks.dart';

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
      setUpAll(() {
          Settings.sharedPreferencesCreatorHook = () async {
            return MockSharedPreferencesWithCache();
          };
      });

      tearDownAll(() {
          Settings.sharedPreferencesCreatorHook = null;
      });

      testWidgets('SettinsPage should have specified widgets.',
        (WidgetTester tester) async {
          await init(tester);
          expect(find.text('Settings'), findsOneWidget);
          expect(find.text('Hide Google Drive synchronization'), findsOneWidget);
      });
  });
}
