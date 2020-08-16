import 'package:lh5801/lh5801.dart';
import 'package:test/test.dart';

void main() {
  group('OperandDump', () {
    group('op8()', () {
      test('should print an hexadecimal value without suffix by default', () {
        expect(
          OperandDump.op8(0x15),
          equals('15'),
        );
      });

      test('should print a binary value without suffix', () {
        expect(
          OperandDump.op8(0xF5, radix: const Radix.binary()),
          equals('11110101'),
        );
      });

      test("should print a binary value with the 'B' suffix", () {
        expect(
          OperandDump.op8(0x5, radix: const Radix.binary(), suffix: true),
          equals('00000101B'),
        );
      });

      test('should print a decimal value without suffix', () {
        expect(
          OperandDump.op8(21, radix: const Radix.decimal()),
          equals(' 21'),
        );
        expect(
          OperandDump.op8(234, radix: const Radix.decimal(), suffix: true),
          equals('234'),
        );
      });

      test('should print an hexadecimal value without suffix', () {
        expect(
          OperandDump.op8(0x47),
          equals('47'),
        );
      });

      test("should print an hexadecimal value with the 'H' suffix", () {
        expect(
          OperandDump.op8(0x5, suffix: true),
          equals('05H'),
        );
      });
    });

    group('op16()', () {
      test('should print an hexadecimal value without suffix by default', () {
        expect(
          OperandDump.op16(0x415),
          equals('0415'),
        );
      });

      test('should print a binary value without suffix', () {
        expect(
          OperandDump.op16(0xF0FF, radix: const Radix.binary()),
          equals('1111000011111111'),
        );
      });

      test("should print a binary value with the 'B' suffix", () {
        expect(
          OperandDump.op16(0x124, radix: const Radix.binary(), suffix: true),
          equals('0000000100100100B'),
        );
      });

      test('should print a decimal value without suffix', () {
        expect(
          OperandDump.op16(21, radix: const Radix.decimal()),
          equals('   21'),
        );
        expect(
          OperandDump.op16(65534, radix: const Radix.decimal(), suffix: true),
          equals('65534'),
        );
      });

      test('should print an hexadecimal value without suffix', () {
        expect(
          OperandDump.op16(0x457),
          equals('0457'),
        );
      });

      test("should print an hexadecimal value with the 'H' suffix", () {
        expect(
          OperandDump.op16(0xFEDC, suffix: true),
          equals('FEDCH'),
        );
      });
    });
  });
}
