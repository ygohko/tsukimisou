import "dart:convert";
import 'dart:io';

import 'package:test/test.dart';
import 'package:tsukimisou/memo.dart';
import 'package:tsukimisou/memo_store.dart';
import 'package:tsukimisou/memo_store_local_saver.dart';

void main() {
  group('MemoStoreLocalSaver', () {
    test('MemoStoreLocalSaver should be created from memo store and path', () {
      expect(MemoStoreLocalSaver(MemoStore(), './test.json'), isNotNull);
    });

    test('MemoStoreLocalSaver should save memos as JSON.', () async {
      final memoStore = MemoStore();
      final memo = Memo();
      memo.text = 'This is a test.';
      memoStore.addMemo(memo);
      final memoStoreSaver = MemoStoreLocalSaver(memoStore, './test.json');
      await memoStoreSaver.execute();
      final file = File('./test.json');
      final exists = await file.exists();
      expect(exists, true);
      final string = await file.readAsString();
      final deserialized = jsonDecode(string);
      expect(deserialized['memos'][0]['text'], 'This is a test.');
      await file.delete();
    });

    test('MemoStoreLocalSaver.fromFile() should return memo store saver.', () async {
      expect(MemoStoreLocalSaver.fromFileName(MemoStore(), 'test.json'), isNotNull);
    });
  });
}
