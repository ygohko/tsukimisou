import 'dart:io';

import 'package:test/test.dart';
import 'package:tsukimisou/memo_store.dart';
import 'package:tsukimisou/memo_store_loader.dart';

void main() {
  group('MemoStoreLoader', () {
      test('MemoStoreLoader should be created from memo store and path', () {
          expect(MemoStoreLoader(MemoStore(), './test.json'), isNotNull);
      });

      test('MemoStoreSaver should save memos as JSON.', () async {
          var file = File('./test.json');
          await file.writeAsString('["This is a test."]');
          final memoStore = MemoStore();
          final memoStoreLoader = MemoStoreLoader(memoStore, './test.json');
          await memoStoreLoader.execute();
          final memos = memoStore.getMemos();
          expect(memos.length, 1);
          expect(memos[0], 'This is a test.');
          file = File('./test.json');
          await file.delete();
      });

      test('MemoStoreLoader.getFromFile() should return memo store loader.', () async {
          expect(MemoStoreLoader.getFromFileName(MemoStore(), 'test.json'), isNotNull);
      });
  });
}
