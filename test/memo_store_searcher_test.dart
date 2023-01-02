import 'package:test/test.dart';
import 'package:tsukimisou/memo.dart';
import 'package:tsukimisou/memo_store.dart';
import 'package:tsukimisou/memo_store_searcher.dart';

void main() {
  group('MemoStoreSearcher', () {
    test('MemoStoreSearcher should find a memo that its text contains keywords.', () {
      final memoStore = MemoStore();
      final memo = Memo();
      memo.text = 'This is a test. これはテストです。';
      memoStore.addMemo(memo);
      var searcher = MemoStoreSearcher(memoStore, 'test');
      searcher.execute();
      expect(searcher.results.length, 1);

      searcher = MemoStoreSearcher(memoStore, 'TEST');
      searcher.execute();
      expect(searcher.results.length, 1);

      searcher = MemoStoreSearcher(memoStore, 'テスト');
      searcher.execute();
      expect(searcher.results.length, 1);
    });

    test('MemoStoreSearcher should find a memo that its text contains keywords.', () {
      final memoStore = MemoStore();
      final memo = Memo();
      memo.text = '';
      memo.tags = ['test', 'テスト'];
      memoStore.addMemo(memo);
      var searcher = MemoStoreSearcher(memoStore, 'test');
      searcher.execute();
      expect(searcher.results.length, 1);

      searcher = MemoStoreSearcher(memoStore, 'TEST');
      searcher.execute();
      expect(searcher.results.length, 1);

      searcher = MemoStoreSearcher(memoStore, 'テスト');
      searcher.execute();
      expect(searcher.results.length, 1);
    });

    test('MemoStoreSearcher should parse a query as keywords.', () {
      final memoStore = MemoStore();
      final memo = Memo();
      memo.text = 'This is a test. これはテストです。';
      memoStore.addMemo(memo);
      var searcher = MemoStoreSearcher(memoStore, 'test テスト');
      searcher.execute();
      expect(searcher.results.length, 1);

      searcher = MemoStoreSearcher(memoStore, 'test　テスト');
      searcher.execute();
      expect(searcher.results.length, 1);
    });
  });
}
