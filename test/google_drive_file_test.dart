import 'package:test/test.dart';

import 'package:tsukimisou/google_drive_file.dart';

void main() {
  group('GoogleDriveFile', () {
    test('GoogleDriveFile should be created from file name', () {
      expect(GoogleDriveFile('test.txt'), isNotNull);
    });
  });
}
