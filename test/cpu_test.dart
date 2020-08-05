import 'package:lh5801/lh5801.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('LH5801CPU', () {
    test('should raise an exception for invalid arguments', () {
      expect(
        () => LH5801CPU(
          pins: null,
          clockFrequency: 1300000,
          memRead: memRead,
          memWrite: memWrite,
        ),
        throwsA(const TypeMatcher<AssertionError>()),
      );

      expect(
        () => LH5801CPU(
          pins: LH5801Pins(),
          clockFrequency: 1300000,
          memRead: null,
          memWrite: memWrite,
        ),
        throwsA(const TypeMatcher<AssertionError>()),
      );

      expect(
        () => LH5801CPU(
          pins: LH5801Pins(),
          clockFrequency: 1300000,
          memRead: memRead,
          memWrite: null,
        ),
        throwsA(const TypeMatcher<AssertionError>()),
      );
    });

    test('should be serialized/deserialized successfully', () {
      final LH5801CPU cpu1 = LH5801CPU(
        pins: LH5801Pins(),
        clockFrequency: 1300000,
        memRead: memRead,
        memWrite: memWrite,
      )
        ..a.value = 0x79
        ..u.low = 0x12
        ..ir0 = true;

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

    test('should detect invalid opcodes', () {
      final LH5801CPU cpu = LH5801CPU(
        pins: LH5801Pins(),
        clockFrequency: 1300000,
        memRead: memRead,
        memWrite: memWrite,
      );

      cpu.p.value = 0x1234;
      memLoad(cpu.p.value, <int>[0xFF]);
      expect(() => cpu.step(), throwsA(const TypeMatcher<LH5801Error>()));

      cpu.p.value = 0x4321;
      memLoad(cpu.p.value, <int>[0xFD, 0xFF]);
      expect(() => cpu.step(), throwsA(const TypeMatcher<LH5801Error>()));
    });
  });
}
