import 'package:test/test.dart';

import 'package:lh5801/lh5801.dart';

void main() {
  group('LH5801Flags', () {
    test('should be initialized properly', () {
      LH5801Flags flags = LH5801Flags();
      expect(flags.h, isFalse);
      expect(flags.v, isFalse);
      expect(flags.z, isFalse);
      expect(flags.ie, isFalse);
      expect(flags.c, isFalse);

      flags = LH5801Flags(h: true, ie: true);
      expect(flags.h, isTrue);
      expect(flags.v, isFalse);
      expect(flags.z, isFalse);
      expect(flags.ie, isTrue);
      expect(flags.c, isFalse);
    });

    test('should be serialized/deserialized successfully', () {
      final LH5801Flags flags1 = LH5801Flags(h: true, ie: true);
      final LH5801Flags flags2 = LH5801Flags.fromJson(flags1.toJson());
      expect(flags1, equals(flags2));
    });

    test('"statusegister" should get/set the 8-bit status register', () {
      final LH5801Flags flags = LH5801Flags(h: true, c: true);
      expect(flags.statusRegister, equals(LH5801Flags.H | LH5801Flags.C));

      flags.statusRegister = LH5801Flags.Z;
      expect(flags.statusRegister, equals(LH5801Flags.Z));
    });

    test('reset() should set all flags to false', () {
      final LH5801Flags flags1 = LH5801Flags(h: true, ie: true)..reset();
      expect(flags1.statusRegister, equals(0x00));
    });
  });
}
