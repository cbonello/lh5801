import 'package:lh5801/lh5801.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('LH5801CPU', () {
    test('should be serialized/deserialized successfully', () {
      final LH5801CPU cpu1 = LH5801CPU(
        pins: LH5801Pins(),
        clockFrequency: 1300000,
        memRead: memRead,
        memWrite: memWrite,
      )
        ..a.value = 0x79
        ..u.low = 0x12
        ..ie = true;

      final LH5801CPU cpu2 = LH5801CPU.fromJson(
        pins: LH5801Pins(),
        clockFrequency: 1300000,
        memRead: memRead,
        memWrite: memWrite,
        json: cpu1.toJson(),
      );

      expect(cpu1, equals(cpu2));
      expect(cpu1.hashCode, equals(cpu2.hashCode));
    });
  });
}
