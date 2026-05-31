import 'package:flutter_test/flutter_test.dart';
import 'package:tsukimisou/diff_generator.dart';

void main() {
  group('DiffGenerator', () {
    test('should return input text when texts are identical', () {
      final generator = DiffGenerator('''hello
world
''', '''hello
world
''');
      generator.execute();
      const expected = '''hello
world
''';
      expect(generator.result, expected);
    });

    test('should generate diff for insertion', () {
      final generator = DiffGenerator('''hello
world
''', '''hello
new
world
''');
      generator.execute();
      const expected = '''This memo has conflicts.

hello
<<< Cloud <<<
new
<<<<<<<<<<
world
''';
      expect(generator.result, equals(expected));
    });

    test('should generate diff for insertion (no trailing LF)', () {
      final generator = DiffGenerator('''hello
world''', '''hello
new
world''');
      generator.execute();
      const expected = '''This memo has conflicts.

hello
<<< Cloud <<<
new
<<<<<<<<<<
world''';
      expect(generator.result, equals(expected));
    });

    test('should generate diff for deletion', () {
      final generator = DiffGenerator('''hello
new
world
''', '''hello
world
''');
      generator.execute();
      const expected = '''This memo has conflicts.

hello
>>> Local >>>
new
>>>>>>>>>>
world
''';
      expect(generator.result, equals(expected));
    });

    test('should generate diff for replacement', () {
      final generator = DiffGenerator('''hello
old
world
''', '''hello
new
world
''');
      generator.execute();
      const expected = '''This memo has conflicts.

hello
<<< Cloud <<<
new
<<<<<<<<<<
>>> Local >>>
old
>>>>>>>>>>
world
''';
      expect(generator.result, equals(expected));
    });

    test('should generate diff for complex changes', () {
      final generator = DiffGenerator('''first
second
third
''', '''first
-second-
third
fourth
''');
      generator.execute();
      const expected = '''This memo has conflicts.

first
<<< Cloud <<<
-second-
<<<<<<<<<<
>>> Local >>>
second
>>>>>>>>>>
third
<<< Cloud <<<
fourth
<<<<<<<<<<
''';
      expect(generator.result, equals(expected));
    });

    test('should handle texts without trailing newline', () {
      final generator = DiffGenerator('''hello
world''', '''hello
new
world''');
      generator.execute();
      const expected = '''This memo has conflicts.

hello
<<< Cloud <<<
new
<<<<<<<<<<
world''';
      expect(generator.result, equals(expected));
    });
  });
}
