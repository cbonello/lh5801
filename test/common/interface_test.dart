import 'package:lh5801/lh5801.dart';
import 'package:test/test.dart';

void main() {
  group('LH5801Error', () {
    test('should record the expected error message', () {
      const String message = "It's not working";
      final LH5801Error error = LH5801Error(message);

      expect(error.message, equals(message));
    });
  });
}
