import 'package:platform/platform.dart';
import 'package:test/test.dart';
import 'package:tsukimisou/extensions.dart';

void main() {
  group('StringConverting', () {
    test('DateTime should convert to detailed string.', () {
      final dateTime = DateTime(2000, 1, 2, 3, 4);
      expect(dateTime.toDetailedString(), '2000/01/02 03:04');
    });

    test('DateTime should convert to smart string.', () {
      final now = DateTime.now();
      var dateTime = DateTime(now.year, now.month, now.day, 3, 4);
      expect(dateTime.toSmartString(), '03:04');

      dateTime = DateTime(now.year, 1, 2, 3, 4);
      expect(dateTime.toSmartString(), '01/02 03:04');

      dateTime = DateTime(2000, 1, 2, 3, 4);
      expect(dateTime.toSmartString(), '2000/01/02');
    });
  });

  group('AbstructProviding', () {
    test('Platform should return whether platform is desktop or not.', () {
      final platform = LocalPlatform();
      expect(platform.isDesktop, true);
    });

    test('Platform should return whether platform is mobile or not.', () {
      final platform = LocalPlatform();
      expect(platform.isMobile, false);
    });
  });
}
