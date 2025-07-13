import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tsukimisou/editing_page.dart';
import 'package:tsukimisou/memo.dart';
import 'package:tsukimisou/memo_store.dart';
import 'package:tsukimisou/memo_store_local_saver.dart';
import 'package:tsukimisou/gen_l10n/app_localizations.dart';

Future<void> init(WidgetTester tester, Memo? memo) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (context) => MemoStore(),
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
        ],
        home: EditingPage(memo: memo),
      ),
    ),
  );
}

void main() {
  group('EditingPage', () {
    setUpAll(() {
      MemoStoreLocalSaver.constructorHook = (memoStore, path) {
        return MemoStoreMockLocalSaver(memoStore, path);
      };
    });

    tearDownAll(() {
      MemoStoreLocalSaver.constructorHook = null;
    });

    testWidgets(
        'EditingPage should have specified widgets when adding a new memo.',
        (WidgetTester tester) async {
      await init(tester, null);
      expect(find.text('Add a new memo'), findsOneWidget);
      expect(find.byIcon(Icons.done), findsOneWidget);
    });

    testWidgets(
        'EditingPage should have specified widgets when editing a memo.',
        (WidgetTester tester) async {
      final memo = Memo();
      memo.text = 'This is a test.';
      await init(tester, memo);
      expect(find.text('Edit a memo'), findsOneWidget);
      expect(find.text('This is a test.'), findsOneWidget);
      expect(find.byIcon(Icons.done), findsOneWidget);
    });

    testWidgets(
        'EditingPage should update memo text when done button is pressed.',
        (WidgetTester tester) async {
      final memo = Memo();
      await init(tester, memo);
      await tester.enterText(find.byType(TextField), 'This is a text');
      await tester.tap(find.byIcon(Icons.done));
      await tester.pump();
      expect(memo.text, 'This is a text');
    });
  });
}
