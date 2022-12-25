import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tsukimisou/factories.dart';
import 'package:tsukimisou/memo_store.dart';
import 'package:tsukimisou/searching_page.dart';

Future<void> init(WidgetTester tester) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (context) => MemoStore(),
      child: MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
        ],
        home: const SearchingPage(),
      ),
    ),
  );
}

void main() {
  Factories.init(FactoriesType.test);

  group('SearchingPage', () {
    testWidgets('SearchingPage shoud have specified widgets.',
      (WidgetTester tester) async {
        await init(tester);
        expect(find.text('Search memos'), findsWidgets);
      });
  });
}
