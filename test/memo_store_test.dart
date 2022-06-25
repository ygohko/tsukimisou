import 'package:tsukimisou/memo_store.dart';
import 'package:test/test.dart';

void main() {
  group('MemoStore', () {
      test('MemoStore should have zero memos when created.', () {
          expect(MemoStore().getMemos().length, 0);
      });

      test('MemoStore should have a memo when added a memo.', () {
          final memoStore = MemoStore();
          expect(memoStore.getMemos().length, 0);
          memoStore.addMemo('This is a memo.');
          expect(memoStore.getMemos().length, 1);
      });

      test('MemoStore should have zero memos when cleared.', () {
          final memoStore = MemoStore();
          memoStore.addMemo('This is a memo.');
          memoStore.clear();
          expect(memoStore.getMemos().length, 0);
      });

      test('MemoStore.getMemos() should return memos that is stored by memo store.', () {
          final memoStore = MemoStore();
          memoStore.addMemo('This is a memo.');
          final memos = memoStore.getMemos();
          expect(memos.length, 1);
          expect(memos[0], 'This is a memo.');
      });

      test('MemoStore should create singleton instance when first time MemoStore.getInstance() called.', () {
          expect(MemoStore.getInstance(), isNotNull);
      });
  });
}
