import 'dart:convert';

import 'package:test/test.dart';
import 'package:tsukimisou/memo_store.dart';
import 'package:tsukimisou/memo_store_google_drive_loader.dart';

void main() {
  group('MemoStoreGoogleDriveLoader', () {
    test(
        'MemoStoreGoogleDriveLoader should be created from memo store and file name',
        () {
      expect(MemoStoreGoogleDriveLoader(MemoStore(), 'test.json'), isNotNull);
    });

    test('should load from version 3 JSON', () {
      final memoStore = MemoStore();
      memoStore.archiveHashes['dummy'] = 'dummy_hash';
      final loader = MemoStoreGoogleDriveLoader(memoStore, 'test.json');
      final json =
          '{"version":3,"memos":[{"id":"123","lastModified":1656491551473,"text":"This is a test.","tags":[],"name":"Hello, World","viewingMode":"Plain","revision":1,"lastMergedRevision":0,"beforeModifiedHash":"12345"}],"lastMerged":1656491551473,"removedMemoIds":[]}';
      loader.deserialize(json);
      expect(memoStore.memos.length, 1);
      expect(memoStore.memos[0].text, 'This is a test.');
      expect(memoStore.archiveHashes.isEmpty, isTrue);
    });

    test('should load from version 4 JSON', () {
      final memoStore = MemoStore();
      final loader = MemoStoreGoogleDriveLoader(memoStore, 'test.json');
      final json =
          '{"version":4,"memos":[{"id":"123","lastModified":1656491551473,"text":"This is a test.","tags":[],"name":"Hello, World","viewingMode":"Plain","revision":1,"lastMergedRevision":0,"beforeModifiedHash":"12345"}],"lastMerged":1656491551473,"removedMemoIds":[],"archiveHashes":{"test_archive":"testhash"}}';
      loader.deserialize(json);
      expect(memoStore.memos.length, 1);
      expect(memoStore.memos[0].text, 'This is a test.');
      expect(memoStore.archiveHashes.length, 1);
      expect(memoStore.archiveHashes['test_archive'], 'testhash');
    });
  });
}
