import 'package:test/test.dart';

import 'package:lh5801/lh5801.dart';

void main() {
  group('LH5801State', () {
    group('Register8', () {
      test('should be initialized properly', () {
        Register8 reg = Register8();
        expect(reg.value, equals(0));

        reg = Register8(128);
        expect(reg.value, equals(128));

        reg = Register8(0x1234);
        expect(reg.value, equals(0x34));
      });

      test('reset() should set the register value to zero', () {
        final Register8 reg = Register8(128);
        reg.reset();
        expect(reg.value, equals(0));
      });

      test('clone() should return an identical Register8 instance', () {
        final Register8 reg1 = Register8(128);
        final Register8 reg2 = reg1.clone();
        expect(reg1, equals(reg2));
      });
    });

    group('Register16', () {
      test('should be initialized properly', () {
        Register16 reg = Register16();
        expect(reg.value, equals(0));

        reg = Register16(0x1234);
        expect(reg.value, equals(0x1234));

        reg = Register16(0x123456);
        expect(reg.value, equals(0x3456));
      });

      test('value getter should return the 16-bit register value', () {
        final Register16 reg = Register16(0x123456);
        expect(reg.value, equals(0x3456));
      });

      test('value setter update the 16-bit register value ', () {
        final Register16 reg = Register16();
        reg.value = 0x3456;
        expect(reg.value, equals(0x3456));
      });

      test('high and low getters should return the proper bytes', () {
        final Register16 reg = Register16();
        reg.value = 0x1234;
        expect(reg.high, equals(0x12));
        expect(reg.low, equals(0x34));
      });

      test('high and low setters should overwrite the proper bytes', () {
        final Register16 reg = Register16(0x1234);
        reg.low = 0x78;
        reg.high = 0x56;
        expect(reg.high, equals(0x56));
        expect(reg.low, equals(0x78));
      });

      test('reset() should set the register value to zero', () {
        final Register16 reg = Register16(256);
        reg.reset();
        expect(reg.value, equals(0));
      });

      test('clone() should return an identical Register16 instance', () {
        final Register16 reg1 = Register16(128);
        final Register16 reg2 = reg1.clone();
        expect(reg1, equals(reg2));
      });
    });
  });
}
