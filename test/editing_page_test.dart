import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukimisou/editing_page.dart';

void main() {
  testWidgets('EditingPage widget smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const EditingPage(),
      )
    );
    expect(find.text('Add a new memo'), findsOneWidget);
    expect(find.byIcon(Icons.done), findsOneWidget);
  });
}
