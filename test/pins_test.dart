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
  });
}
