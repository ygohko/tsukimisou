import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukimisou/binding_tags_page.dart';
import 'package:tsukimisou/factories.dart';
import 'package:tsukimisou/memo.dart';

Future<void> init(WidgetTester tester, Memo memo) async {
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
    ],
    home: BindingTagsPage(memo: memo, additinalTags: const ['d', 'e', 'f']),
  ));
}

void main() {
  Factories.init(FactoriesType.test);

  group('BindingTagsPage', () {
    testWidgets('BindingTagsPage should have specified widgets.',
        (WidgetTester tester) async {
      final memo = Memo();
      memo.text = 'This is a test.';
      memo.tags = ['a', 'b', 'c'];
      await init(tester, memo);
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
      expect(find.text('c'), findsOneWidget);
      expect(find.text('d'), findsOneWidget);
      expect(find.text('e'), findsOneWidget);
      expect(find.text('f'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNWidgets(3));
      expect(find.byIcon(Icons.check_circle_outline), findsNWidgets(3));
    });

    testWidgets('BindingTagsPage should add tags to memo.',
        (WidgetTester tester) async {
      final memo = Memo();
      memo.text = 'This is a test.';
      memo.tags = ['a', 'b', 'c'];
      await init(tester, memo);
      await tester.tap(find.text('d'));
      await tester.pump();
      expect(find.byIcon(Icons.check_circle), findsNWidgets(4));
      expect(find.byIcon(Icons.check_circle_outline), findsNWidgets(2));
    });

    testWidgets('BindingTagsPage should remove tags from memo.',
        (WidgetTester tester) async {
      final memo = Memo();
      memo.text = 'This is a test.';
      memo.tags = ['a', 'b', 'c'];
      await init(tester, memo);
      await tester.tap(find.text('a'));
      await tester.pump();
      expect(find.byIcon(Icons.check_circle), findsNWidgets(2));
      expect(find.byIcon(Icons.check_circle_outline), findsNWidgets(4));
    });
  });
}
