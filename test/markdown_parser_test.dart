import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tsukimisou/markdown_parser.dart';
import 'package:tsukimisou/memo.dart';
import 'package:tsukimisou/memo_store.dart';
import 'package:tsukimisou/viewing_page.dart';

void main() {
  group('MarkdownParser', () {
      testWidgets('MarkdownParser should be created.',
        (WidgetTester tester) async {
          final memo = Memo();
          memo.text = 'This is a test.';
          await tester.pumpWidget(
            ChangeNotifierProvider(
              create: (context) => MemoStore(),
              child: MaterialApp(
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                ],
                home: ViewingPage(memo: memo),
              ),
            ),
          );
          final context = tester.element(find.byWidgetPredicate(
              (widget) => widget is RichText && widget.text.toPlainText() == 'This is a test.',
            )
          );
          final parser = MarkdownParser(context, '# Hello, World!');
      });
  });
}
