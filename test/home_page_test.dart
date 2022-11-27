import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tsukimisou/factories.dart';
import 'package:tsukimisou/home_page.dart';
import 'package:tsukimisou/memo_store.dart';

void main() {
  Factories.init(FactoriesType.test);

  testWidgets('HomePage widget smoke test', (WidgetTester tester) async {
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
    expect(find.text('Tsukimisou'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
  });
}
