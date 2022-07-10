import 'package:test/test.dart';
import 'package:tsukimisou/memo.dart';

void main() {
  group('Memo', () {
    test('Memo can create the instances.', () {
      final memo = Memo();
      expect(memo, isNotNull);
    });

    test('Memo.id should get and set id.', () {
      final memo = Memo();
      expect(memo.id, isNot(''));
      memo.id = '12345';
      expect(memo.id, '12345');
    });

    test('Memo.lastModified should get and set lastModified.', () {
      final memo = Memo();
      expect(memo.lastModified, 0);
      memo.lastModified = 1;
      expect(memo.lastModified, 1);
    });

    test('Memo.text should get and set text.', () {
      final memo = Memo();
      expect(memo.text, '');
      memo.text = 'This is a test.';
      expect(memo.text, 'This is a test.');
    });

    test('Memo.tags should get and set tags.', () {
      final memo = Memo();
      expect(memo.tags, []);
      memo.tags = ['This is a test.'];
      expect(memo.tags, ['This is a test.']);
    });

    test('Memo.revision should get and set revision.', () {
      final memo = Memo();
      expect(memo.revision, 0);
      memo.revision = 1;
      expect(memo.revision, 1);
    });

    test('Memo.lastMergedRevision should get and set lastMergedRevision.', () {
      final memo = Memo();
      expect(memo.lastMergedRevision, 0);
      memo.lastMergedRevision = 1;
      expect(memo.lastMergedRevision, 1);
    });
  });
}
