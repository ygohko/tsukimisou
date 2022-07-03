import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukimisou/memo.dart';
import 'package:tsukimisou/viewing_page.dart';

void main() {
  testWidgets('ViewingPage widget smoke test', (WidgetTester tester) async {
    final memo = Memo();
    memo.text = 'This is a test.';
    await tester.pumpWidget(MaterialApp(
      home: ViewingPage(memo: memo),
    ));
    expect(find.text('This is a test.'), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsOneWidget);
  });
}
