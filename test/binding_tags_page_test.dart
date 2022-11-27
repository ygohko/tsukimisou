import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukimisou/binding_tags_page.dart';
import 'package:tsukimisou/factories.dart';
import 'package:tsukimisou/memo.dart';

void main() {
  Factories.init(FactoriesType.test);

  testWidgets('BindingTagsPage widget smoke test', (WidgetTester tester) async {
    final memo = Memo();
    memo.text = 'This is a test.';
    memo.tags = ['a', 'b', 'c'];
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
      ],
      home: BindingTagsPage(memo: memo, additinalTags: ['d', 'e', 'f']),
    ));
    expect(find.text('a'), findsOneWidget);
    expect(find.text('b'), findsOneWidget);
    expect(find.text('c'), findsOneWidget);
    expect(find.text('d'), findsOneWidget);
    expect(find.text('e'), findsOneWidget);
    expect(find.text('f'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsNWidgets(3));
    expect(find.byIcon(Icons.check_circle_outline), findsNWidgets(3));
  });
}
