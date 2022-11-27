import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tsukimisou/factories.dart';
import 'package:tsukimisou/memo.dart';
import 'package:tsukimisou/memo_store.dart';
import 'package:tsukimisou/viewing_page.dart';

Future<void> init(WidgetTester tester, Memo memo) async {
  memo.text = 'This is a test.';
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (context) => MemoStore(),
      child: MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
        ],
        home: ViewingPage(memo: memo),
      ),
    ),
  );;
}

void main() {
  Factories.init(FactoriesType.test);

  group('ViewingPage', () {
    testWidgets('ViewingPage should have specified widgets.', (WidgetTester tester) async {
      final memo = Memo();
      await init(tester, memo);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.textContaining('Memo at'), findsOneWidget);
      expect(find.text('This is a test.'), findsOneWidget);
      expect(find.textContaining('Updated:'), findsOneWidget);
      expect(find.textContaining('Tags:'), findsOneWidget);
    });

    testWidgets('ViewingPage should show confirmation dialog when user taps delete button.', (WidgetTester tester) async {
      final memo = Memo();
      await init(tester, memo);
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('ViewingPage should show EditingPage when user taps edit button.', (WidgetTester tester) async {
      final memo = Memo();
      await init(tester, memo);
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();
      expect(find.text('Edit a memo'), findsOneWidget);
    });

    testWidgets('ViewingPage should show EditingPage when user taps edit button.', (WidgetTester tester) async {
      final memo = Memo();
      await init(tester, memo);
      await tester.tap(find.textContaining('Tags:'));
      await tester.pump();
      expect(find.text('Bind tags'), findsOneWidget);
    });
  });
}
