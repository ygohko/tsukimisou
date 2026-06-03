import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:test/test.dart';
import 'package:tsukimisou/memo.dart';
import 'package:tsukimisou/memo_store.dart';

void main() {
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

    test('copy should create a deep copy of the memo store', () {
      final memoStore = MemoStore();
      final memo = Memo();
      memo.text = 'Original memo';
      memoStore.addMemo(memo);
      memoStore.removedMemoIds.add('removed-id');
      memoStore.lastMerged = 12345;
      memoStore.archiveHashes['test_archive'] = 'testhash';
      final archivedMemoStore = MemoStore();
      final archivedMemo = Memo();
      archivedMemo.text = 'archived';
      archivedMemoStore.addMemo(archivedMemo);
      memoStore.archiveMemoStores['test_archive'] = archivedMemoStore;

      final newMemoStore = memoStore.copy();

      // Check original properties
      expect(newMemoStore.memos.length, 1);
      expect(newMemoStore.memos[0].text, 'Original memo');
      expect(identical(newMemoStore.memos[0], memo), isFalse);
      expect(newMemoStore.removedMemoIds.length, 1);
      expect(newMemoStore.removedMemoIds[0], 'removed-id');
      expect(newMemoStore.lastMerged, 12345);

      // Check new archive properties
      expect(newMemoStore.archiveHashes.length, 1);
      expect(newMemoStore.archiveHashes['test_archive'], 'testhash');
      expect(newMemoStore.archiveMemoStores.length, 1);
      expect(newMemoStore.archiveMemoStores['test_archive'], isNotNull);
      expect(
          newMemoStore.archiveMemoStores['test_archive']!.memos.length, 1);
      expect(newMemoStore.archiveMemoStores['test_archive']!.memos[0].text,
          'archived');
      expect(
          identical(
              newMemoStore.archiveMemoStores['test_archive'], archivedMemoStore),
          isFalse);

      // Modify original and check if copy is unaffected
      memoStore.memos[0].text = 'Modified memo';
      memoStore.archiveMemoStores['test_archive']!.memos[0].text =
          'modified archived';
      expect(newMemoStore.memos[0].text, 'Original memo');
      expect(newMemoStore.archiveMemoStores['test_archive']!.memos[0].text,
          'archived');
    });

    test('toSerializable should include archiveHashes and version 4', () {
      final memoStore = MemoStore();
      memoStore.archiveHashes['test_archive'] = 'testhash';
      final serializable = memoStore.toSerializable();
      expect(serializable['version'], 4);
      expect(serializable['archiveHashes'], isNotNull);
      expect(serializable['archiveHashes']['test_archive'], 'testhash');
    });

    test('hash should return a SHA-256 hash string', () {
      final memoStore = MemoStore();
      final memo = Memo();
      memo.text = 'This is a test memo';
      memoStore.addMemo(memo);

      final Map<String, dynamic> serializable = {
        'version': 4,
        'memos': [memo.toSerializable()],
        'lastMerged': 0,
        'removedMemoIds': [],
        'archiveHashes': <String, String>{},
      };
      final jsonString = json.encode(serializable);
      final bytes = utf8.encode(jsonString);
      final expectedHash = sha256.convert(bytes).toString();

      expect(memoStore.hash, expectedHash);
      // SHA-256 hash string is 64 characters long
      expect(memoStore.hash.length, 64);
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

    test('MemoStore.memoFromId should return memo that has given name.', () {
      final memoStore = MemoStore();
      final memo = Memo();
      memo.text = 'This is a memo.';
      memo.name = 'TestMemo';
      memoStore.addMemo(memo);
      final aMemo = memoStore.memoFromName('TestMemo');
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
  });
}
