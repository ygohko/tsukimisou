// Copyright (c) 2026 Yasuaki Gohko
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE ABOVE LISTED COPYRIGHT HOLDER(S) BE LIABLE FOR ANY CLAIM, DAMAGES OR
// OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.

import 'package:flutter_test/flutter_test.dart';
import 'package:tsukimisou/diff_generator.dart';

void main() {
  group('DiffGenerator', () {
      /*
      test('should return input text when texts are identical', () {
      final generator = DiffGenerator('''hello
world
''', '''hello
world
''');
      generator.execute();
      final expected = '''hello
world
''';
      expect(generator.result, expected);
    });

    test('should generate diff for insertion', () {
      final generator =
          DiffGenerator('''hello
world
''', '''hello
new
world
''');
      generator.execute();
      final expected = '''This memo has conflicts.

hello
<<< Cloud <<<
new
<<<<<<<<<<
world
''';
      expect(generator.result, equals(expected));
    });

    test('should generate diff for deletion', () {
      final generator =
          DiffGenerator('''hello
new
world
''', '''hello
world
''');
      generator.execute();
      final expected = '''This memo has conflicts.

hello
>>> Local >>>
new
>>>>>>>>>>
world
''';
      expect(generator.result, equals(expected));
    });

    test('should generate diff for replacement', () {
      final generator =
          DiffGenerator('''hello
old
world
''', '''hello
new
world
''');
      generator.execute();
      final expected = '''This memo has conflicts.

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
    */

    test('should generate diff for complex changes', () {
      final generator = DiffGenerator(
          '''first
second
third
''', '''first
-second-
third
fourth
''');
      generator.execute();
      final expected = '''This memo has conflicts.

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

    /*
    test('should handle texts without trailing newline', () {
      final generator = DiffGenerator('''hello
world''', '''hello
new
world''');
      generator.execute();
      final expected = '''This memo has conflicts.

hello
<<< Cloud <<<
new
<<<<<<<<<<
world''';
      expect(generator.result, equals(expected));
    });
    */
  });
}
