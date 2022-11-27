import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tsukimisou/factories.dart';
import 'package:tsukimisou/home_page.dart';
import 'package:tsukimisou/memo_store.dart';

Future<void> init(WidgetTester tester) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (context) => MemoStore(),
      child: MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
        ],
        home: const HomePage(),
      ),
    ),
  );
}

void main() {
  Factories.init(FactoriesType.test);

  testWidgets('HomePage shoud have specified widgets.', (WidgetTester tester) async {
    await init(tester);
    expect(find.text('Tsukimisou'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('HomePage shoud show EditingPage when user taps add button.', (WidgetTester tester) async {
    await init(tester);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.textContaining('Add a new memo'), findsOneWidget);
    expect(find.byIcon(Icons.done), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });
}
