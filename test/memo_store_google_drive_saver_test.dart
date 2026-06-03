import 'dart:convert';

import 'package:test/test.dart';
import 'package:tsukimisou/memo_store.dart';
import 'package:tsukimisou/memo_store_google_drive_saver.dart';
import 'package:tsukimisou/memo.dart';

void main() {
  group('MemoStoreGoogleDriveSaver', () {
    test(
        'MemoStoreGoogleDriveSaver should be created from memo store and file name',
        () {
      expect(MemoStoreGoogleDriveSaver(MemoStore(), 'test.json'), isNotNull);
    });

    test('serialize should return a JSON string with version 4', () {
      final memoStore = MemoStore();
      final memo = Memo();
      memo.text = 'This is a test.';
      memoStore.addMemo(memo);
      memoStore.archiveHashes['test_archive'] = 'testhash';
      final saver = MemoStoreGoogleDriveSaver(memoStore, 'test.json');
      final jsonString = saver.serialize();
      final deserialized = jsonDecode(jsonString);

      expect(deserialized['version'], 4);
      expect(deserialized['memos'][0]['text'], 'This is a test.');
      expect(deserialized['archiveHashes']['test_archive'], 'testhash');
    });
  });
}
