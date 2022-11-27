import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukimisou/editing_page.dart';
import 'package:tsukimisou/factories.dart';
import 'package:tsukimisou/memo.dart';

void main() {
  Factories.init(FactoriesType.test);

  group('Memo', () {
    testWidgets('EditingPage widget smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
        ],
        home: const EditingPage(),
      ));
      expect(find.text('Add a new memo'), findsOneWidget);
      expect(find.byIcon(Icons.done), findsOneWidget);
    });

    testWidgets('EditingPage widget smoke test', (WidgetTester tester) async {
      final memo = Memo();
      memo.text = 'This is a test.';
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
        ],
        home: EditingPage(memo: memo),
      ));
      expect(find.text('Edit a memo'), findsOneWidget);
      expect(find.text('This is a test.'), findsOneWidget);
      expect(find.byIcon(Icons.done), findsOneWidget);
    });
  });
}
