import "dart:convert";
import 'dart:io';

import 'package:test/test.dart';
import 'package:tsukimisou/memo.dart';
import 'package:tsukimisou/memo_store.dart';
import 'package:tsukimisou/memo_store_saver.dart';

void main() {
  group('MemoStoreSaver', () {
    test('MemoStoreSaver should be created from memo store and path', () {
      expect(MemoStoreSaver(MemoStore(), './test.json'), isNotNull);
    });

    test('MemoStoreSaver should save memos as JSON.', () async {
      final memoStore = MemoStore();
      final memo = Memo();
      memo.text = 'This is a test.';
      memoStore.addMemo(memo);
      final memoStoreSaver = MemoStoreSaver(memoStore, './test.json');
      await memoStoreSaver.execute();
      final file = File('./test.json');
      final exists = await file.exists();
      expect(exists, true);
      final string = await file.readAsString();
      final deserialized = jsonDecode(string);
      expect(deserialized['memos'][0]['text'], 'This is a test.');
      await file.delete();
    });

    test('MemoStoreSaver.fromFile() should return memo store saver.', () async {
      expect(MemoStoreSaver.fromFileName(MemoStore(), 'test.json'), isNotNull);
    });
  });
}
