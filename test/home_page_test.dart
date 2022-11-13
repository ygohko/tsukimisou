import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukimisou/home_page.dart';

void main() {
  // TODO: Fix test failure.
  testWidgets('HomePage widget smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
      ],
      home: const HomePage(),
    ));
    expect(find.text('Tsukimisou'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
  });
}
