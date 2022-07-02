import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukimisou/home_page.dart';

void main() {
  testWidgets('HomePage widget smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: const HomePage(),
    ));
    expect(find.text('Tsukimisou'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
  });
}
