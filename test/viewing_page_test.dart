import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tsukimisou/memo.dart';
import 'package:tsukimisou/memo_store.dart';
import 'package:tsukimisou/memo_store_local_saver.dart';
import 'package:tsukimisou/viewing_page.dart';
import 'package:tsukimisou/gen_l10n/app_localizations.dart';

Future<void> init(WidgetTester tester, Memo memo) async {
  memo.text = 'This is a test.';
  memo.name = 'Test';
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (context) => MemoStore(),
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
        ],
        home: ViewingPage(memo: memo),
      ),
    ),
  );
}

void main() {
  MemoStoreLocalSaver.constructorHook = (memoStore, path) {
    return MemoStoreMockLocalSaver(memoStore, path);
  };

  group('ViewingPage', () {
    // TODO: Add tests fo TinyMarkdown viewing mode.
    testWidgets('ViewingPage should have specified widgets.',
        (WidgetTester tester) async {
      final memo = Memo();
      await init(tester, memo);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.textContaining('Test'), findsWidgets);
      expect(find.textContaining('This is a test.'), findsOneWidget);
      expect(find.textContaining('Updated:'), findsOneWidget);
      expect(find.textContaining('Tags:'), findsOneWidget);
    });

    testWidgets(
        'ViewingPage should show confirmation dialog when user taps delete button.',
        (WidgetTester tester) async {
      final memo = Memo();
      await init(tester, memo);
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();
      expect(find.text('Delete this memo?'), findsOneWidget);
    });

    testWidgets(
        'ViewingPage should show EditingPage when user taps edit button.',
        (WidgetTester tester) async {
      final memo = Memo();
      await init(tester, memo);
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();
      expect(find.text('Edit a memo'), findsOneWidget);
    });

    testWidgets(
        'ViewingPage should show EditingPage when user taps edit button.',
        (WidgetTester tester) async {
      final memo = Memo();
      await init(tester, memo);
      await tester.tap(find.textContaining('Tags:'));
      await tester.pump();
      expect(find.text('Bind tags'), findsOneWidget);
    });

    MemoStoreLocalSaver.constructorHook = null;
  });
}
