import 'package:test/test.dart';

import 'package:lh5801/lh5801.dart';

void main() {
  group('LH5801Pins', () {
    test('should be initialized properly', () {
      final LH5801Pins pins = LH5801Pins();

      expect(pins.resetPin, isFalse);
      expect(pins.nmiPin, isFalse);
      expect(pins.miPin, isFalse);
      expect(pins.puFlipflop, isFalse);
      expect(pins.pvFlipflop, isFalse);
      expect(pins.dispFlipflop, isFalse);
      expect(pins.bfFlipflop, true);
    });

    test('reset() should reset all pins to their default value', () {
      final LH5801Pins pins = LH5801Pins();

      pins.resetPin = true;
      pins.pvFlipflop = true;
      pins.reset();

      expect(pins.resetPin, isFalse);
      expect(pins.nmiPin, isFalse);
      expect(pins.miPin, isFalse);
      expect(pins.puFlipflop, isFalse);
      expect(pins.pvFlipflop, isFalse);
      expect(pins.dispFlipflop, isFalse);
      expect(pins.bfFlipflop, true);
    });

    test('clone() should return an identical LH5801Pins instance', () {
      final LH5801Pins pins1 = LH5801Pins()
        ..miPin = true
        ..inputPorts = 0x49;
      final LH5801Pins pins2 = pins1.clone();

      expect(pins1.miPin, equals(pins2.miPin));
      expect(pins1.miPin.hashCode, equals(pins2.miPin.hashCode));

      expect(pins1, equals(pins2));
      expect(pins1.hashCode, equals(pins2.hashCode));
    });
  });
}
