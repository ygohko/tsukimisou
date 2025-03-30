import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukimisou/markdown_parser.dart';

Future<void> init(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Text('This is a test.'),
    ),
  );
}

void main() {
  group('MarkdownParser', () {
      testWidgets('MarkdownParser should be created.',
        (WidgetTester tester) async {
          await init(tester);
          final context = tester.element(find.text('This is a test.'));
          final parser = MarkdownParser(context, '# Hello, World!');
      });

      testWidgets('MarkdownParser should be executable.',
        (WidgetTester tester) async {
          await init(tester);
          final context = tester.element(find.text('This is a test.'));
          final parser = MarkdownParser(context, '# Hello, World!');
          parser.execute();
      });

      testWidgets('MarkdownParser should create widgets for healines large.',
        (WidgetTester tester) async {
          await init(tester);
          final context = tester.element(find.text('This is a test.'));
          final textTheme = Theme.of(context).textTheme;
          final parser = MarkdownParser(context, '# Hello, World!');
          parser.execute();
          final contents = parser.contents;
          final column = contents as Column;
          final widget = column.children[0];
          final richText = widget as RichText;
          final span = richText.text as TextSpan;
          expect(span.style, textTheme.headlineLarge);
          expect(span.toPlainText(), 'Hello, World!');
      });
  });
}
