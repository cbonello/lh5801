import 'package:test/test.dart';

import 'package:lh5801/lh5801.dart';

import 'helpers.dart';

void main() {
  group('LH5801Emulator', () {
    test('should be initialized properly', () {
      final LH5801Emulator emulator = LH5801Emulator(
        clockFrequency: 1300000,
        memRead: memRead,
        memWrite: memWrite,
      );

      expect(emulator.cpu.runtimeType, equals(LH5801CPU));
    });

    test('should be serialized/deserialized successfully', () {
      final LH5801Emulator emulator1 = LH5801Emulator(
        clockFrequency: 1300000,
        memRead: memRead,
        memWrite: memWrite,
      );
      final LH5801Emulator emulator2 = LH5801Emulator.fromJson(
        clockFrequency: 1300000,
        memRead: memRead,
        memWrite: memWrite,
        json: emulator1.toJson(),
      );

      expect(emulator1, equals(emulator2));
      expect(emulator1.hashCode, equals(emulator2.hashCode));
    });
  });
}
