import 'package:test/test.dart';
import 'package:tsukimisou/memo.dart';

void main() {
  group('Memo', () {
    test('Memo should be created.', () {
      final memo = Memo();
      expect(memo, isNotNull);
    });

    test('Memo.id should be get and set.', () {
      final memo = Memo();
      expect(memo.id, isNot(''));
      memo.id = '12345';
      expect(memo.id, '12345');
    });

    test('Memo.lastModified should be get and set.', () {
      final memo = Memo();
      expect(memo.lastModified, 0);
      memo.lastModified = 1;
      expect(memo.lastModified, 1);
    });

    test('Memo.text should be get and set.', () {
      final memo = Memo();
      expect(memo.text, '');
      memo.text = 'This is a test.';
      expect(memo.text, 'This is a test.');
    });

    test('Memo.tags should be get and set.', () {
      final memo = Memo();
      expect(memo.tags, []);
      memo.tags = ['This is a test.'];
      expect(memo.tags, ['This is a test.']);
    });

    test('Memo.name should be get and set.', () {
      final memo = Memo();
      expect(memo.name, '');
      memo.name = 'Hello, World!';
      expect(memo.name, 'Hello, World!');
    });

    test('Memo.viewingMode should be get and set.', () {
      final memo = Memo();
      expect(memo.viewingMode, 'Plain');
      memo.viewingMode = 'TinyMarkdown';
      expect(memo.viewingMode, 'TinyMarkdown');
    });

    test('Memo.revision should be get and set.', () {
      final memo = Memo();
      expect(memo.revision, 0);
      memo.revision = 1;
      expect(memo.revision, 1);
    });

    test('Memo.lastMergedRevision should be get and set.', () {
      final memo = Memo();
      expect(memo.lastMergedRevision, 0);
      memo.lastMergedRevision = 1;
      expect(memo.lastMergedRevision, 1);
    });

    test('Memo.beforeModifiedHash should be get and set.', () {
      final memo = Memo();
      expect(memo.beforeModifiedHash, '');
      memo.beforeModifiedHash = 'abc123';
      expect(memo.beforeModifiedHash, 'abc123');
    });
  });
}
