import 'package:test/test.dart';
import 'package:tsukimisou/memo.dart';
import 'package:tsukimisou/memo_store.dart';

void main() {
  // TODO: Fix test failure.
  group('MemoStore', () {
    test('MemoStore should have zero memos when created.', () {
      expect(MemoStore().memos.length, 0);
    });

    test('MemoStore should have a memo when memo is added.', () {
      final memoStore = MemoStore();
      expect(memoStore.memos.length, 0);
      final memo = Memo();
      memo.text = 'This is a memo.';
      memoStore.addMemo(memo);
      expect(memoStore.memos.length, 1);
    });

    test('MemoStore should have zero memos when memo is removed.', () {
      final memoStore = MemoStore();
      final memo = Memo();
      memo.text = 'This is a memo.';
      memoStore.addMemo(memo);
      memoStore.removeMemo(memo);
      expect(memoStore.memos.length, 0);
    });

    test('MemoStore should store removed memo IDs when memo is removed.', () {
      final memoStore = MemoStore();
      final memo = Memo();
      memo.text = 'This is a memo.';
      memoStore.addMemo(memo);
      memoStore.removeMemo(memo);
      expect(memoStore.removedMemoIds.length, 1);
      expect(memoStore.removedMemoIds[0], memo.id);
    });

    test('MemoStore should have zero memos when cleared.', () {
      final memoStore = MemoStore();
      final memo = Memo();
      memo.text = 'This is a memo.';
      memoStore.addMemo(memo);
      memoStore.clearMemos();
      expect(memoStore.memos.length, 0);
    });

    test('MemoStore.memoFromId should return memo that has given ID.', () {
      final memoStore = MemoStore();
      final memo = Memo();
      memo.text = 'This is a memo.';
      final id = memo.id;
      memoStore.addMemo(memo);
      final aMemo = memoStore.memoFromId(id);
      expect(identical(aMemo, memo), true);
    });

    test(
        'MemoStore.memos should return and accept memos that is stored by memo store.',
        () {
      final memoStore = MemoStore();
      final memo = Memo();
      memo.text = 'This is a memo.';
      memoStore.addMemo(memo);
      final memos = memoStore.memos;
      expect(memos.length, 1);
      expect(memos[0].text, 'This is a memo.');
      memos.clear();
      memoStore.memos = memos;
      expect(memos.length, 0);
    });

    test(
        'MemoStore.memos should return tags that bound for memos in memo store.',
        () {
      final memoStore = MemoStore();
      final memo = Memo();
      memo.text = 'This is a memo.';
      memoStore.addMemo(memo);
      var tags = memoStore.tags;
      expect(tags.length, 0);
      memo.tags.add('test');
      tags = memoStore.tags;
      expect(tags.length, 1);
      expect(tags[0], 'test');
    });

    test(
        'MemoStore should create singleton instance when first time MemoStore.instance() called.',
        () {
      expect(MemoStore.instance(), isNotNull);
    });
  });
}
