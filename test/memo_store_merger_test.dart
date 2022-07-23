import 'dart:io';

import 'package:test/test.dart';
import 'package:tsukimisou/memo.dart';
import 'package:tsukimisou/memo_store.dart';
import 'package:tsukimisou/memo_store_merger.dart';

void main() {
  group('MemoStoreMerger', () {
    test('MemoStoreMerger can create the instances.', () {
      final toMemoStore = MemoStore();
      final fromMemoStore = MemoStore();
      final memoStoreMerger = MemoStoreMerger(toMemoStore, fromMemoStore);
      expect(memoStoreMerger, isNotNull);
    });

    test(
        'MemoStoreMerger should keep memos in to memo store if it is modified after last merged.',
        () {
      final toMemoStore = MemoStore();
      final fromMemoStore = MemoStore();
      fromMemoStore.lastMerged = DateTime.now().millisecondsSinceEpoch;
      sleep(const Duration(milliseconds: 1));
      final memo = Memo();
      memo.text = 'This is a to memo.';
      toMemoStore.addMemo(memo);
      expect(toMemoStore.memos.length, 1);
      final memoStoreMerger = MemoStoreMerger(toMemoStore, fromMemoStore);
      memoStoreMerger.execute();
      expect(toMemoStore.memos.length, 1);
    });

    test(
        'MemoStoreMerger should remove memos in to memo store if it is modified before last merged.',
        () {
      final toMemoStore = MemoStore();
      final fromMemoStore = MemoStore();
      final memo = Memo();
      memo.text = 'This is a to memo.';
      sleep(const Duration(milliseconds: 1));
      fromMemoStore.lastMerged = DateTime.now().millisecondsSinceEpoch;
      toMemoStore.addMemo(memo);
      expect(toMemoStore.memos.length, 1);
      final memoStoreMerger = MemoStoreMerger(toMemoStore, fromMemoStore);
      memoStoreMerger.execute();
      expect(toMemoStore.memos.length, 0);
    });

    test('MemoStoreMerger should move memos that are only in from memo store.',
        () {
      final toMemoStore = MemoStore();
      final fromMemoStore = MemoStore();
      final memo = Memo();
      fromMemoStore.addMemo(memo);
      expect(toMemoStore.memos.length, 0);
      final memoStoreMerger = MemoStoreMerger(toMemoStore, fromMemoStore);
      memoStoreMerger.execute();
      expect(toMemoStore.memos.length, 1);
    });

    test(
        'MemoStoreMerger should not move memos that its ID is in removed memo IDs.',
        () {
      final toMemoStore = MemoStore();
      final fromMemoStore = MemoStore();
      final memo = Memo();
      fromMemoStore.addMemo(memo);
      toMemoStore.removedMemoIds.add(memo.id);
      expect(toMemoStore.memos.length, 0);
      final memoStoreMerger = MemoStoreMerger(toMemoStore, fromMemoStore);
      memoStoreMerger.execute();
      expect(toMemoStore.memos.length, 0);
    });

    test('MemoStoreMerger should update memos if from memos are modified.', () {
      final toMemoStore = MemoStore();
      final fromMemoStore = MemoStore();
      final toMemo = Memo();
      toMemo.text = "This is a to memo.";
      toMemoStore.addMemo(toMemo);
      final fromMemo = Memo();
      fromMemo.text = "This is a from memo.";
      fromMemo.text = "This is a from memo.";
      fromMemo.id = toMemo.id;
      fromMemoStore.addMemo(fromMemo);
      expect(toMemoStore.memos.length, 1);
      final memoStoreMerger = MemoStoreMerger(toMemoStore, fromMemoStore);
      memoStoreMerger.execute();
      expect(toMemoStore.memos.length, 1);
      expect(toMemo.text.contains('This is a from memo.'), true);
    });

    test('MemoStoreMerger should not update memos if to memos are modified.',
        () {
      final toMemoStore = MemoStore();
      final fromMemoStore = MemoStore();
      final toMemo = Memo();
      toMemo.text = "This is a to memo.";
      toMemo.text = "This is a to memo.";
      toMemoStore.addMemo(toMemo);
      final fromMemo = Memo();
      fromMemo.text = "This is a from memo.";
      fromMemo.id = toMemo.id;
      fromMemoStore.addMemo(fromMemo);
      expect(toMemoStore.memos.length, 1);
      final memoStoreMerger = MemoStoreMerger(toMemoStore, fromMemoStore);
      memoStoreMerger.execute();
      expect(toMemoStore.memos.length, 1);
      expect(toMemo.text.contains('This is a to memo.'), true);
    });

    test(
        'MemoStoreMerger should make conficted memos if both memos in from and to memo store are modified.',
        () {
      final toMemoStore = MemoStore();
      final fromMemoStore = MemoStore();
      final toMemo = Memo();
      toMemo.text = "This is a to memo.";
      toMemoStore.addMemo(toMemo);
      final fromMemo = Memo();
      fromMemo.text = "This is a from memo.";
      fromMemo.id = toMemo.id;
      fromMemoStore.addMemo(fromMemo);
      expect(toMemoStore.memos.length, 1);
      final memoStoreMerger = MemoStoreMerger(toMemoStore, fromMemoStore);
      memoStoreMerger.execute();
      expect(toMemoStore.memos.length, 1);
      expect(toMemo.text.contains('This memo is conflicted.'), true);
    });
  });
}
