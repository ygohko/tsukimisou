import 'package:test/test.dart';
import 'package:tsukimisou/memo_store.dart';
import 'package:tsukimisou/memo_store_google_drive_saver.dart';

void main() {
  group('MemoStoreGoogleDriveSaver', () {
    test('MemoStoreGoogleDriveSaver should be created from memo store and file name', () {
      expect(MemoStoreGoogleDriveSaver(MemoStore(), 'test.json'), isNotNull);
    });
  });
}
