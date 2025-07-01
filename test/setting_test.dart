import 'package:flutter_test/flutter_test.dart';
import 'package:tsukimisou/settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Settings', () {
    test('Settings should be created', () {
      expect(Settings(), isNotNull);
    });

    // TODO: Add tests for getters and setters.
  });
}
