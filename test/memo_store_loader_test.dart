import 'dart:io';

import 'package:test/test.dart';
import 'package:tsukimisou/memo_store.dart';
import 'package:tsukimisou/memo_store_loader.dart';

void main() {
  group('MemoStoreLoader', () {
    test('MemoStoreLoader should be created from memo store and path', () {
      expect(MemoStoreLoader(MemoStore(), './test.json'), isNotNull);
    });

    test('MemoStoreLoader should load memos from JSON.', () async {
      var file = File('./test.json');
      await file.writeAsString(
          '{"version":1,"memos":[{"id":"123","lastModified":1656491551473,"text":"This is a test.","tags":[],"revision":1,"lastMergedRevision":0}],"lastMerged":1656491551473}');
      final memoStore = MemoStore();
      final memoStoreLoader = MemoStoreLoader(memoStore, './test.json');
      await memoStoreLoader.execute();
      final memos = memoStore.memos;
      expect(memos.length, 1);
      expect(memos[0].text, 'This is a test.');
      file = File('./test.json');
      await file.delete();
    });

    test('MemoStoreLoader.fromFile() should return memo store loader.',
        () async {
      expect(MemoStoreLoader.fromFileName(MemoStore(), 'test.json'), isNotNull);
    });
  });
}
