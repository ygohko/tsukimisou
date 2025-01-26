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
        'MemoStoreMerger should keep memos in toMemoStore if it is modified after last merged.',
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
        'MemoStoreMerger should not remove memos in toMemoStore if it is synchronized and modified before last merged.',
        () {
      final toMemoStore = MemoStore();
      final fromMemoStore = MemoStore();
      final memo = Memo();
      memo.text = 'This is a to memo.';
      sleep(const Duration(milliseconds: 1));
      toMemoStore.lastMerged = DateTime.now().millisecondsSinceEpoch;
      sleep(const Duration(milliseconds: 1));
      fromMemoStore.lastMerged = DateTime.now().millisecondsSinceEpoch;
      toMemoStore.addMemo(memo);
      expect(toMemoStore.memos.length, 1);
      final memoStoreMerger = MemoStoreMerger(toMemoStore, fromMemoStore);
      memoStoreMerger.execute();
      expect(toMemoStore.memos.length, 1);
    });

    test(
        'MemoStoreMerger should not remove memos in toMemoStore if it is not synchronized.',
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
      expect(toMemoStore.memos.length, 1);
    });

    test('MemoStoreMerger should move memos that are only in fromMemoStore.',
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
      final toMemo = Memo();
      toMemo.text = "This is a to memo.";
      toMemo.lastMergedRevision = toMemo.revision;
      toMemoStore.addMemo(toMemo);
      final fromMemoStore = toMemoStore.copy();
      final fromMemo = fromMemoStore.memoFromId(toMemo.id)!;
      fromMemo.beginModification();
      fromMemo.text = "This is a from memo.";
      expect(toMemoStore.memos.length, 1);
      final memoStoreMerger = MemoStoreMerger(toMemoStore, fromMemoStore);
      memoStoreMerger.execute();
      expect(toMemoStore.memos.length, 1);
      expect(toMemo.text.contains('This is a from memo.'), true);
    });

    test('MemoStoreMerger should not update memos if toMemos are modified.',
        () {
      final toMemoStore = MemoStore();
      final toMemo = Memo();
      toMemo.text = "This is a to memo.";
      toMemo.lastMergedRevision = toMemo.revision;
      toMemo.beginModification();
      toMemo.text = "This is a to memo.";
      toMemoStore.addMemo(toMemo);
      final fromMemoStore = toMemoStore.copy();
      expect(toMemoStore.memos.length, 1);
      final memoStoreMerger = MemoStoreMerger(toMemoStore, fromMemoStore);
      memoStoreMerger.execute();
      expect(toMemoStore.memos.length, 1);
      expect(toMemo.text.contains('This is a to memo.'), true);
    });

    test(
        'MemoStoreMerger should make conficted memos if both memos in fromMemoStore and toMemoStore are modified.',
        () {
      final toMemoStore = MemoStore();
      final toMemo = Memo();
      toMemo.text = "This is a to memo.";
      toMemo.lastMergedRevision = toMemo.revision;
      toMemo.beginModification();
      toMemo.text = "This is a to memo.";
      toMemoStore.addMemo(toMemo);
      final fromMemoStore = toMemoStore.copy();
      final fromMemo = fromMemoStore.memoFromId(toMemo.id)!;
      fromMemo.beginModification();
      fromMemo.text = "This is a from memo.";
      expect(toMemoStore.memos.length, 1);
      final memoStoreMerger = MemoStoreMerger(toMemoStore, fromMemoStore);
      memoStoreMerger.execute();
      expect(toMemoStore.memos.length, 1);
      expect(toMemo.text.contains('Local'), true);
    });

    test(
        'MemoStoreMerger should not make conficted memos if both memos in fromMemoStore and toMemoStore are modified but these texts are same.',
        () {
      final toMemoStore = MemoStore();
      final fromMemoStore = MemoStore();
      final toMemo = Memo();
      toMemo.text = "This is a memo.";
      toMemoStore.addMemo(toMemo);
      final fromMemo = Memo();
      fromMemo.text = "This is a memo.";
      fromMemo.id = toMemo.id;
      fromMemoStore.addMemo(fromMemo);
      expect(toMemoStore.memos.length, 1);
      final memoStoreMerger = MemoStoreMerger(toMemoStore, fromMemoStore);
      memoStoreMerger.execute();
      expect(toMemoStore.memos.length, 1);
      expect(toMemo.text.contains('This memo is conflicted.'), false);
    });

    test(
        'MemoStoreMerger should update memo\'s tags if from memos are modified.',
        () {
      final toMemoStore = MemoStore();
      final fromMemoStore = MemoStore();
      final toMemo = Memo();
      toMemo.text = "This is a to memo.";
      toMemoStore.addMemo(toMemo);
      final fromMemo = Memo();
      fromMemo.text = "This is a from memo.";
      fromMemo.text = "This is a from memo.";
      fromMemo.tags = ['a', 'b', 'c'];
      fromMemo.id = toMemo.id;
      fromMemoStore.addMemo(fromMemo);
      expect(toMemoStore.memos.length, 1);
      final memoStoreMerger = MemoStoreMerger(toMemoStore, fromMemoStore);
      memoStoreMerger.execute();
      expect(toMemoStore.memos.length, 1);
      expect(toMemo.text.contains('This is a from memo.'), true);
      expect(toMemo.tags.length, 3);
    });

    test(
        'MemoStoreMerger should merge memo\'s tags if both memos in fromMemoStore and toMemoStore are modified.',
        () {
      final toMemoStore = MemoStore();
      final fromMemoStore = MemoStore();
      final toMemo = Memo();
      toMemo.text = "This is a memo.";
      toMemo.tags = ['a', 'b', 'c'];
      toMemoStore.addMemo(toMemo);
      final fromMemo = Memo();
      fromMemo.text = "This is a memo.";
      fromMemo.tags = ['a', 'd', 'e', 'f'];
      fromMemo.id = toMemo.id;
      fromMemoStore.addMemo(fromMemo);
      expect(toMemoStore.memos.length, 1);
      final memoStoreMerger = MemoStoreMerger(toMemoStore, fromMemoStore);
      memoStoreMerger.execute();
      expect(toMemoStore.memos.length, 1);
      expect(toMemo.tags.length, 6);
    });
  });
}
