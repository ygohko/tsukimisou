import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukimisou/markdown_parser.dart';

Future<void> init(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(
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
      final _ = MarkdownParser(context, '# Hello, World!');
    });

    testWidgets('MarkdownParser should be executable.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final parser = MarkdownParser(context, '# Hello, World!');
      parser.execute();
    });

    testWidgets('MarkdownParser should create widgets for body texts.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final parser = MarkdownParser(context, 'Hello, World!');
      parser.execute();
      final textTheme = parser.textTheme;
      final contents = parser.contents;
      final column = contents as Column;
      final widget = column.children[0];
      final richText = widget as RichText;
      final span = richText.text as TextSpan;
      expect(span.style, textTheme.bodyMedium);
      expect(span.toPlainText(), 'Hello, World!');
    });

    testWidgets('MarkdownParser should create widgets for large healines.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final parser = MarkdownParser(context, '# Hello, World!');
      parser.execute();
      final textTheme = parser.textTheme;
      final contents = parser.contents;
      final column = contents as Column;
      final widget = column.children[0];
      final container = widget as Container;
      final richText = container.child as RichText;
      final span = richText.text as TextSpan;
      expect(span.style, textTheme.headlineLarge);
      expect(span.toPlainText(), 'Hello, World!');
    });

    testWidgets('MarkdownParser should create widgets for medium headlines.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final parser = MarkdownParser(context, '## Hello, World!');
      parser.execute();
      final textTheme = parser.textTheme;
      final contents = parser.contents;
      final column = contents as Column;
      final widget = column.children[0];
      final container = widget as Container;
      final richText = container.child as RichText;
      final span = richText.text as TextSpan;
      expect(span.style, textTheme.headlineMedium);
      expect(span.toPlainText(), 'Hello, World!');
    });

    testWidgets('MarkdownParser should create widgets for small headlines.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final parser = MarkdownParser(context, '### Hello, World!');
      parser.execute();
      final textTheme = parser.textTheme;
      final contents = parser.contents;
      final column = contents as Column;
      final widget = column.children[0];
      final container = widget as Container;
      final richText = container.child as RichText;
      final span = richText.text as TextSpan;
      expect(span.style, textTheme.headlineSmall);
      expect(span.toPlainText(), 'Hello, World!');
    });

    testWidgets('MarkdownParser should create widgets for unordered lists 1.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final parser = MarkdownParser(context, '* Hello, World!');
      parser.execute();
      final contents = parser.contents;
      final column = contents as Column;
      final widget = column.children[0];
      final row = widget as Row;
      expect(row.children[0] is SizedBox, true);
      expect(row.children[1] is Flexible, true);
    });

    testWidgets('MarkdownParser should create widgets for unordered lists 2.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final parser = MarkdownParser(context, '    * Hello, World!');
      parser.execute();
      final contents = parser.contents;
      final column = contents as Column;
      final widget = column.children[0];
      final row = widget as Row;
      expect(row.children[0] is SizedBox, true);
      expect(row.children[1] is Flexible, true);
    });

    testWidgets('MarkdownParser should create widgets for unordered lists 3.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final parser = MarkdownParser(context, '        * Hello, World!');
      parser.execute();
      final contents = parser.contents;
      final column = contents as Column;
      final widget = column.children[0];
      final row = widget as Row;
      expect(row.children[0] is SizedBox, true);
      expect(row.children[1] is Flexible, true);
    });

    testWidgets('MarkdownParser should create widgets for ordered lists.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final parser = MarkdownParser(context, '1. Hello, World!');
      parser.execute();
      final contents = parser.contents;
      final column = contents as Column;
      final widget = column.children[0];
      final row = widget as Row;
      expect(row.children[0] is SizedBox, true);
      expect(row.children[1] is Flexible, true);
    });

    testWidgets('MarkdownParser should create widgets for link texts.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final textTheme = Theme.of(context).textTheme;
      final parser =
          MarkdownParser(context, '[Hello, World!](https://www.google.com)');
      parser.execute();
      final contents = parser.contents;
      final column = contents as Column;
      final widget = column.children[0];
      final richText = widget as RichText;
      final span = richText.text as TextSpan;
      expect(span.style, textTheme.bodyMedium);
      expect(span.toPlainText(), 'Hello, World!');
    });

    testWidgets('MarkdownParser should create widgets for autolinks.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final textTheme = Theme.of(context).textTheme;
      final parser = MarkdownParser(context, '<https://www.google.com>');
      parser.execute();
      final contents = parser.contents;
      final column = contents as Column;
      final widget = column.children[0];
      final richText = widget as RichText;
      final span = richText.text as TextSpan;
      expect(span.style, textTheme.bodyMedium);
      expect(span.toPlainText(), 'https://www.google.com');
    });

    testWidgets('MarkdownParser should create widgets for thematic breaks.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final parser = MarkdownParser(context, '---');
      parser.execute();
      final contents = parser.contents;
      final column = contents as Column;
      final widget = column.children[0];
      final richText = widget as RichText;
      final span = richText.text as TextSpan;
      final children = span.children!;
      final widgetSpan = children[0] as WidgetSpan;
      final row = widgetSpan.child as Row;
      expect(row.children[0] is SizedBox, true);
      expect(row.children[1] is Expanded, true);
      expect(row.children[2] is SizedBox, true);
    });

    testWidgets('MarkdownParser should create widgets for paragraphs.',
        (WidgetTester tester) async {
      await init(tester);
      final context = tester.element(find.text('This is a test.'));
      final parser = MarkdownParser(context, 'Hello, World!\n\nHello, World!');
      parser.execute();
      final contents = parser.contents;
      final column = contents as Column;
      expect(column.children.length, 3);
      expect(column.children[1] is SizedBox, true);
    });
  });
}
