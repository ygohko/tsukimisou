import 'dart:io';

import 'package:test/test.dart';
import 'package:tsukimisou/memo_store.dart';
import 'package:tsukimisou/memo_store_local_loader.dart';

void main() {
  group('MemoStoreLocalLoader', () {
    test('MemoStoreLocalLoader should be created from memo store and path', () {
      expect(MemoStoreLocalLoader(MemoStore(), './test.json'), isNotNull);
    });

    test('MemoStoreLocalLoader should load memos from JSON.', () async {
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

    test('MemoStoreLocalLoader.fromFile() should return memo store loader.',
        () async {
      expect(MemoStoreLocalLoader.fromFileName(MemoStore(), 'test.json'), isNotNull);
    });
  });
}
