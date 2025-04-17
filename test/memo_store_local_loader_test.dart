import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tsukimisou/memo_store.dart';
import 'package:tsukimisou/memo_store_local_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MemoStoreLocalLoader', () {
    test('MemoStoreLocalLoader should be created from memo store and path', () {
      expect(MemoStoreLocalLoader(MemoStore(), './test.json'), isNotNull);
    });

    test('MemoStoreLocalLoader should load memos from version 1 JSON.',
        () async {
      var file = File('./test.json');
      await file.writeAsString(
          '{"version":1,"memos":[{"id":"123","lastModified":1656491551473,"text":"This is a test.","tags":[],"revision":1,"lastMergedRevision":0}],"lastMerged":1656491551473,"removedMemoIds":[]}');
      final memoStore = MemoStore();
      final memoStoreLoader = MemoStoreLocalLoader(memoStore, './test.json');
      await memoStoreLoader.execute();
      final memos = memoStore.memos;
      expect(memos.length, 1);
      expect(memos[0].text, 'This is a test.');
      file = File('./test.json');
      await file.delete();
    });

    test('MemoStoreLocalLoader should load memos from version 2 JSON.',
        () async {
      var file = File('./test.json');
      await file.writeAsString(
          '{"version":2,"memos":[{"id":"123","lastModified":1656491551473,"text":"This is a test.","tags":[],"revision":1,"lastMergedRevision":0,"beforeModifiedHash":"12345"}],"lastMerged":1656491551473,"removedMemoIds":[]}');
      final memoStore = MemoStore();
      final memoStoreLoader = MemoStoreLocalLoader(memoStore, './test.json');
      await memoStoreLoader.execute();
      final memos = memoStore.memos;
      expect(memos.length, 1);
      expect(memos[0].text, 'This is a test.');
      file = File('./test.json');
      await file.delete();
    });

    test('MemoStoreLocalLoader should load memos from version 3 JSON.',
        () async {
      var file = File('./test.json');
      await file.writeAsString(
          '{"version":3,"memos":[{"id":"123","lastModified":1656491551473,"text":"This is a test.","tags":[],"name":"Hello, World","viewingMode":"Plain","revision":1,"lastMergedRevision":0,"beforeModifiedHash":"12345"}],"lastMerged":1656491551473,"removedMemoIds":[]}');
      final memoStore = MemoStore();
      final memoStoreLoader = MemoStoreLocalLoader(memoStore, './test.json');
      await memoStoreLoader.execute();
      final memos = memoStore.memos;
      expect(memos.length, 1);
      expect(memos[0].text, 'This is a test.');
      file = File('./test.json');
      await file.delete();
    });

    test('MemoStoreLocalLoader.fromFile() should return memo store loader.',
        () async {
      expect(MemoStoreLocalLoader.fromFileName(MemoStore(), 'test.json'),
          isNotNull);
    });
  });
}
