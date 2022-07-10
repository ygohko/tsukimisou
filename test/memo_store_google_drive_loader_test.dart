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
  });
}
