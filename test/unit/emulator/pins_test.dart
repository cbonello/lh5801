import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:lh5801/lh5801.dart';

class MockLH5801PinsObserver extends Mock implements LH5801PinsObserver {}

void main() {
  setUpAll(() {
    registerFallbackValue<LH5801Pins>(LH5801Pins());
  });

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

    test(
      'is...Updated()/areInputPortspUpdated() should detected pins update',
      () {
        final LH5801Pins pins1 = LH5801Pins();
        final LH5801Pins pins2 = pins1.clone();

        pins1.resetPin = true;
        expect(pins1.isResetUpdated(pins2), isTrue);
        pins1.nmiPin = true;
        expect(pins1.isNMIUpdated(pins2), isTrue);
        pins1.miPin = true;
        expect(pins1.isMIUpdated(pins2), isTrue);
        pins1.puFlipflop = true;
        expect(pins1.isPUUpdated(pins2), isTrue);
        pins1.pvFlipflop = true;
        expect(pins1.isPVUpdated(pins2), isTrue);
        pins1.bfFlipflop = false;
        expect(pins1.isBFUpdated(pins2), isTrue);
        pins1.dispFlipflop = true;
        expect(pins1.isDispUpdated(pins2), isTrue);
        pins1.inputPorts = 8;
        expect(pins1.areInputPortspUpdated(pins2), isTrue);
      },
    );

    test('should call the registered observers after each pin update', () {
      final MockLH5801PinsObserver observer = MockLH5801PinsObserver();
      final LH5801Pins pins1 = LH5801Pins();
      pins1.registerPinsObserver(observer);

      pins1.resetPin = true;
      verify(() => observer.update(any())).called(1);
      pins1.nmiPin = true;
      verify(() => observer.update(any())).called(1);
      pins1.miPin = true;
      verify(() => observer.update(any())).called(1);
      pins1.puFlipflop = true;
      verify(() => observer.update(any())).called(1);
      pins1.pvFlipflop = true;
      verify(() => observer.update(any())).called(1);
      pins1.bfFlipflop = true;
      verify(() => observer.update(any())).called(1);
      pins1.dispFlipflop = true;
      verify(() => observer.update(any())).called(1);
      pins1.inputPorts = 8;
      verify(() => observer.update(any())).called(1);
      pins1.reset();
      verify(() => observer.update(any())).called(1);

      final LH5801Pins _ = pins1.clone();
      verifyNever(() => observer.update(any()));
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

    test('toString() should return the expected value', () {
      final LH5801Pins pins = LH5801Pins();
      expect(
        pins.toString(),
        equals(
          'LH5801Pins(reset: false, NMI: false, MI: false, PU: false, PV: false, BF: true, DISP: false, inputPorts: 00)',
        ),
      );
    });
  });
}
