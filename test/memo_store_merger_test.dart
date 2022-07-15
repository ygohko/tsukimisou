import 'package:test/test.dart';
import 'package:tsukimisou/memo_store.dart';
import 'package:tsukimisou/memo_store_merger.dart';

void main() {
  group('Memo', () {
      test('MemoStoreMerger can create the instances.', () {
          final toMemoStore = MemoStore();
          final fromMemoStore = MemoStore();
          final memoStoreMerger = MemoStoreMerger(toMemoStore, fromMemoStore);
          expect(memoStoreMerger, isNotNull);
      });
  });
}
