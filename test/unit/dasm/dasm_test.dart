import 'dart:typed_data';

import 'package:lh5801/lh5801.dart';
import 'package:test/test.dart';

final Uint8ClampedList me0 = Uint8ClampedList(64 * 1024);
final Uint8ClampedList me1 = Uint8ClampedList(64 * 1024);

void memLoad(int address, List<int> data) {
  if (address & 0x10000 != 0) {
    final int a = address & 0xFFFF;
    me1.setRange(a, a + data.length, data);
  } else {
    me0.setRange(address, address + data.length, data);
  }
}

int memRead(int address) {
  final int value =
      address & 0x10000 != 0 ? me1[address & 0xFFFF] : me0[address];
  return value;
}

void memWrite(int address, int value) {
  if (address & 0x10000 != 0) {
    me1[address & 0xFFFF] = value;
  } else {
    me0[address] = value;
  }
}

void main() {
  group('LH5801DASM', () {
    test('should raise an exception for invalid arguments', () {
      expect(
        () => LH5801DASM(memRead: null),
        throwsA(const TypeMatcher<AssertionError>()),
      );
    });

    test('should be intialized successfully', () {
      expect(LH5801DASM(memRead: memRead), isA<LH5801DASM>());
    });

    group('dump()', () {
      final LH5801DASM dasm = LH5801DASM(memRead: memRead);
      Instruction instruction;

      setUp(() {
        me0.setRange(0, 64 * 1024, List<int>.filled(64 * 1024, 0));
        me1.setRange(0, 64 * 1024, List<int>.filled(64 * 1024, 0));
        instruction = null;
      });

      void check(InstructionDescriptor actual, InstructionDescriptor expected) {
        expect(actual.category, equals(expected.category));
        expect(actual.size, equals(expected.size));
        expect(actual.mnemonic, equals(expected.mnemonic));
        expect(actual.cycles, equals(expected.cycles));
      }

      test('should detect illegal instructions', () {
        final InstructionDescriptor expectedDescriptor = instructionTable[0xFC];
        memLoad(0x1234, <int>[0xFC]);

        instruction = dasm.dump(0x1234);
        expect(instruction.address, equals(0x1234));
        check(instruction.descriptor, expectedDescriptor);
        expect(
          instruction.addressToString(radix: const Radix.binary()),
          equals('0001001000110100'),
        );
        expect(
          instruction.addressToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('0001001000110100B'),
        );
        expect(
          instruction.addressToString(radix: const Radix.decimal()),
          equals(' 4660'),
        );
        expect(
          instruction.addressToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals(' 4660'),
        );
        expect(
          instruction.addressToString(),
          equals('1234'),
        );
        expect(
          instruction.addressToString(suffix: true),
          equals('1234H'),
        );
        expect(
          instruction.bytesToString(radix: const Radix.binary()),
          equals('11111100                                    '),
        );
        expect(
          instruction.bytesToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('11111100B                                        '),
        );
        expect(
          instruction.bytesToString(radix: const Radix.decimal()),
          equals('252                '),
        );
        expect(
          instruction.bytesToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals('252                '),
        );
        expect(
          instruction.bytesToString(),
          equals('FC            '),
        );
        expect(
          instruction.bytesToString(suffix: true),
          equals('FCH                '),
        );
        expect(
          instruction.instructionToString(radix: const Radix.binary()),
          equals('ILL'),
        );
        expect(
          instruction.instructionToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('ILL'),
        );
        expect(
          instruction.instructionToString(radix: const Radix.decimal()),
          equals('ILL'),
        );
        expect(
          instruction.instructionToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals('ILL'),
        );
        expect(
          instruction.instructionToString(),
          equals('ILL'),
        );
        expect(
          instruction.instructionToString(suffix: true),
          equals('ILL'),
        );
        expect(instruction.toString(), equals('1234  FC              ILL'));
        expect(instruction.descriptor.toString(), equals('ILL'));
      });

      test('Operand.none()', () {
        final InstructionDescriptor expectedDescriptor =
            instructionTableFD[0x4C];
        memLoad(0x1234, <int>[0xFD, 0x4C]);

        instruction = dasm.dump(0x1234);
        expect(instruction.address, equals(0x1234));
        expect(
          instruction.descriptor.operands[0],
          equals(const Operand.none()),
        );
        expect(
          instruction.addressToString(radix: const Radix.binary()),
          equals('0001001000110100'),
        );
        expect(
          instruction.addressToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('0001001000110100B'),
        );
        expect(
          instruction.addressToString(radix: const Radix.decimal()),
          equals(' 4660'),
        );
        expect(
          instruction.addressToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals(' 4660'),
        );
        expect(
          instruction.addressToString(),
          equals('1234'),
        );
        expect(
          instruction.addressToString(suffix: true),
          equals('1234H'),
        );
        expect(
          instruction.bytesToString(radix: const Radix.binary()),
          equals('11111101 01001100                           '),
        );
        expect(
          instruction.bytesToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('11111101B 01001100B                              '),
        );
        expect(
          instruction.bytesToString(radix: const Radix.decimal()),
          equals('253  76            '),
        );
        expect(
          instruction.bytesToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals('253  76            '),
        );
        expect(
          instruction.bytesToString(),
          equals('FD 4C         '),
        );
        expect(
          instruction.bytesToString(suffix: true),
          equals('FDH 4CH            '),
        );
        expect(
          instruction.instructionToString(radix: const Radix.binary()),
          equals('OFF'),
        );
        expect(
          instruction.instructionToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('OFF'),
        );
        expect(
          instruction.instructionToString(radix: const Radix.decimal()),
          equals('OFF'),
        );
        expect(
          instruction.instructionToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals('OFF'),
        );
        expect(
          instruction.instructionToString(),
          equals('OFF'),
        );
        expect(
          instruction.instructionToString(suffix: true),
          equals('OFF'),
        );
        expect(instruction.toString(), equals('1234  FD 4C           OFF'));
        check(instruction.descriptor, expectedDescriptor);
        expect(instruction.descriptor.toString(), equals('OFF'));
      });

      test('Operand.reg()', () {
        final InstructionDescriptor expectedDescriptor =
            instructionTableFD[0x08];
        memLoad(0x1234, <int>[0xFD, 0x08]);

        instruction = dasm.dump(0x1234);
        expect(instruction.address, equals(0x1234));
        expect(
          instruction.descriptor.operands[0],
          equals(const Operand.reg('X')),
        );
        expect(
          instruction.addressToString(radix: const Radix.binary()),
          equals('0001001000110100'),
        );
        expect(
          instruction.addressToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('0001001000110100B'),
        );
        expect(
          instruction.addressToString(radix: const Radix.decimal()),
          equals(' 4660'),
        );
        expect(
          instruction.addressToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals(' 4660'),
        );
        expect(
          instruction.addressToString(),
          equals('1234'),
        );
        expect(
          instruction.addressToString(suffix: true),
          equals('1234H'),
        );
        expect(
          instruction.bytesToString(radix: const Radix.binary()),
          equals('11111101 00001000                           '),
        );
        expect(
          instruction.bytesToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('11111101B 00001000B                              '),
        );
        expect(
          instruction.bytesToString(radix: const Radix.decimal()),
          equals('253   8            '),
        );
        expect(
          instruction.bytesToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals('253   8            '),
        );
        expect(
          instruction.bytesToString(),
          equals('FD 08         '),
        );
        expect(
          instruction.bytesToString(suffix: true),
          equals('FDH 08H            '),
        );
        expect(
          instruction.instructionToString(radix: const Radix.binary()),
          equals('LDX X'),
        );
        expect(
          instruction.instructionToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('LDX X'),
        );
        expect(
          instruction.instructionToString(radix: const Radix.decimal()),
          equals('LDX X'),
        );
        expect(
          instruction.instructionToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals('LDX X'),
        );
        expect(
          instruction.instructionToString(),
          equals('LDX X'),
        );
        expect(
          instruction.instructionToString(suffix: true),
          equals('LDX X'),
        );
        expect(instruction.toString(), equals('1234  FD 08           LDX X'));
        check(instruction.descriptor, expectedDescriptor);
        expect(instruction.descriptor.toString(), equals('LDX X'));
      });

      test('Operand.mem0Reg()', () {
        final InstructionDescriptor expectedDescriptor = instructionTable[0x2D];
        memLoad(0x1234, <int>[0x2D]);

        instruction = dasm.dump(0x1234);
        expect(instruction.address, equals(0x1234));
        expect(
          instruction.descriptor.operands[0],
          equals(const Operand.mem0Reg('U')),
        );
        expect(
          instruction.addressToString(radix: const Radix.binary()),
          equals('0001001000110100'),
        );
        expect(
          instruction.addressToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('0001001000110100B'),
        );
        expect(
          instruction.addressToString(radix: const Radix.decimal()),
          equals(' 4660'),
        );
        expect(
          instruction.addressToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals(' 4660'),
        );
        expect(
          instruction.addressToString(),
          equals('1234'),
        );
        expect(
          instruction.addressToString(suffix: true),
          equals('1234H'),
        );
        expect(
          instruction.bytesToString(radix: const Radix.binary()),
          equals('00101101                                    '),
        );
        expect(
          instruction.bytesToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('00101101B                                        '),
        );
        expect(
          instruction.bytesToString(radix: const Radix.decimal()),
          equals(' 45                '),
        );
        expect(
          instruction.bytesToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals(' 45                '),
        );
        expect(
          instruction.bytesToString(),
          equals('2D            '),
        );
        expect(
          instruction.bytesToString(suffix: true),
          equals('2DH                '),
        );
        expect(
          instruction.instructionToString(radix: const Radix.binary()),
          equals('EOR (U)'),
        );
        expect(
          instruction.instructionToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('EOR (U)'),
        );
        expect(
          instruction.instructionToString(radix: const Radix.decimal()),
          equals('EOR (U)'),
        );
        expect(
          instruction.instructionToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals('EOR (U)'),
        );
        expect(
          instruction.instructionToString(),
          equals('EOR (U)'),
        );
        expect(
          instruction.instructionToString(suffix: true),
          equals('EOR (U)'),
        );
        expect(instruction.toString(), equals('1234  2D              EOR (U)'));
        check(instruction.descriptor, expectedDescriptor);
        expect(instruction.descriptor.toString(), equals('EOR (U)'));
      });

      test('Operand.mem0Imm16()', () {
        final InstructionDescriptor expectedDescriptor = instructionTable[0xA1];
        memLoad(0x1234, <int>[0xA1, 0x13, 0x57]);

        instruction = dasm.dump(0x1234);
        expect(instruction.address, equals(0x1234));
        expect(
          instruction.descriptor.operands[0],
          equals(const Operand.mem0Imm16(0x1357)),
        );
        expect(
          instruction.addressToString(radix: const Radix.binary()),
          equals('0001001000110100'),
        );
        expect(
          instruction.addressToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('0001001000110100B'),
        );
        expect(
          instruction.addressToString(radix: const Radix.decimal()),
          equals(' 4660'),
        );
        expect(
          instruction.addressToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals(' 4660'),
        );
        expect(
          instruction.addressToString(),
          equals('1234'),
        );
        expect(
          instruction.addressToString(suffix: true),
          equals('1234H'),
        );
        expect(
          instruction.bytesToString(radix: const Radix.binary()),
          equals('10100001 00010011 01010111                  '),
        );
        expect(
          instruction.bytesToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('10100001B 00010011B 01010111B                    '),
        );
        expect(
          instruction.bytesToString(radix: const Radix.decimal()),
          equals('161  19  87        '),
        );
        expect(
          instruction.bytesToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals('161  19  87        '),
        );
        expect(
          instruction.bytesToString(),
          equals('A1 13 57      '),
        );
        expect(
          instruction.bytesToString(suffix: true),
          equals('A1H 13H 57H        '),
        );
        expect(
          instruction.instructionToString(radix: const Radix.binary()),
          equals('SBC (0001001101010111)'),
        );
        expect(
          instruction.instructionToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('SBC (0001001101010111B)'),
        );
        expect(
          instruction.instructionToString(radix: const Radix.decimal()),
          equals('SBC (4951)'),
        );
        expect(
          instruction.instructionToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals('SBC (4951)'),
        );
        expect(
          instruction.instructionToString(),
          equals('SBC (1357)'),
        );
        expect(
          instruction.instructionToString(suffix: true),
          equals('SBC (1357H)'),
        );
        expect(
          instruction.toString(),
          equals('1234  A1 13 57        SBC (1357)'),
        );
        check(instruction.descriptor, expectedDescriptor);
        expect(instruction.descriptor.toString(), equals('SBC (1357)'));
      });

      test('Operand.mem1Reg()', () {
        final InstructionDescriptor expectedDescriptor =
            instructionTableFD[0x0E];
        memLoad(0x1234, <int>[0xFD, 0x0E]);

        instruction = dasm.dump(0x1234);
        expect(instruction.address, equals(0x1234));
        expect(
          instruction.descriptor.operands[0],
          equals(const Operand.mem1Reg('X')),
        );
        expect(
          instruction.addressToString(radix: const Radix.binary()),
          equals('0001001000110100'),
        );
        expect(
          instruction.addressToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('0001001000110100B'),
        );
        expect(
          instruction.addressToString(radix: const Radix.decimal()),
          equals(' 4660'),
        );
        expect(
          instruction.addressToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals(' 4660'),
        );
        expect(
          instruction.addressToString(),
          equals('1234'),
        );
        expect(
          instruction.addressToString(suffix: true),
          equals('1234H'),
        );
        expect(
          instruction.bytesToString(radix: const Radix.binary()),
          equals('11111101 00001110                           '),
        );
        expect(
          instruction.bytesToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('11111101B 00001110B                              '),
        );
        expect(
          instruction.bytesToString(radix: const Radix.decimal()),
          equals('253  14            '),
        );
        expect(
          instruction.bytesToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals('253  14            '),
        );
        expect(
          instruction.bytesToString(),
          equals('FD 0E         '),
        );
        expect(
          instruction.bytesToString(suffix: true),
          equals('FDH 0EH            '),
        );
        expect(
          instruction.instructionToString(radix: const Radix.binary()),
          equals('STA #(X)'),
        );
        expect(
          instruction.instructionToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('STA #(X)'),
        );
        expect(
          instruction.instructionToString(radix: const Radix.decimal()),
          equals('STA #(X)'),
        );
        expect(
          instruction.instructionToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals('STA #(X)'),
        );
        expect(
          instruction.instructionToString(),
          equals('STA #(X)'),
        );
        expect(
          instruction.instructionToString(suffix: true),
          equals('STA #(X)'),
        );
        expect(
          instruction.toString(),
          equals('1234  FD 0E           STA #(X)'),
        );
        check(instruction.descriptor, expectedDescriptor);
        expect(instruction.descriptor.toString(), equals('STA #(X)'));
      });

      test('Operand.mem1Imm16()', () {
        final InstructionDescriptor expectedDescriptor =
            instructionTableFD[0xED];
        memLoad(0x1234, <int>[0xFD, 0xED, 0x34, 0x56, 0x78]);

        instruction = dasm.dump(0x1234);
        expect(instruction.address, equals(0x1234));
        expect(
          instruction.descriptor.operands[0],
          equals(const Operand.mem1Imm16(0x3456)),
        );
        expect(
          instruction.addressToString(radix: const Radix.binary()),
          equals('0001001000110100'),
        );
        expect(
          instruction.addressToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('0001001000110100B'),
        );
        expect(
          instruction.addressToString(radix: const Radix.decimal()),
          equals(' 4660'),
        );
        expect(
          instruction.addressToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals(' 4660'),
        );
        expect(
          instruction.addressToString(),
          equals('1234'),
        );
        expect(
          instruction.addressToString(suffix: true),
          equals('1234H'),
        );
        expect(
          instruction.bytesToString(radix: const Radix.binary()),
          equals('11111101 11101101 00110100 01010110 01111000'),
        );
        expect(
          instruction.bytesToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('11111101B 11101101B 00110100B 01010110B 01111000B'),
        );
        expect(
          instruction.bytesToString(radix: const Radix.decimal()),
          equals('253 237  52  86 120'),
        );
        expect(
          instruction.bytesToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals('253 237  52  86 120'),
        );
        expect(
          instruction.bytesToString(),
          equals('FD ED 34 56 78'),
        );
        expect(
          instruction.bytesToString(suffix: true),
          equals('FDH EDH 34H 56H 78H'),
        );
        expect(
          instruction.instructionToString(radix: const Radix.binary()),
          equals('BII #(0011010001010110), 01111000'),
        );
        expect(
          instruction.instructionToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('BII #(0011010001010110B), 01111000B'),
        );
        expect(
          instruction.instructionToString(radix: const Radix.decimal()),
          equals('BII #(13398), 120'),
        );
        expect(
          instruction.instructionToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals('BII #(13398), 120'),
        );
        expect(
          instruction.instructionToString(),
          equals('BII #(3456), 78'),
        );
        expect(
          instruction.instructionToString(suffix: true),
          equals('BII #(3456H), 78H'),
        );
        expect(
          instruction.toString(),
          equals('1234  FD ED 34 56 78  BII #(3456), 78'),
        );
        check(instruction.descriptor, expectedDescriptor);
        expect(instruction.descriptor.toString(), equals('BII #(3456), 78'));
      });

      test('Operand.imm8()', () {
        final InstructionDescriptor expectedDescriptor = instructionTable[0xEF];
        memLoad(0x1234, <int>[0xEF, 0x34, 0x56, 0x78]);

        instruction = dasm.dump(0x1234);
        expect(instruction.address, equals(0x1234));
        expect(
          instruction.descriptor.operands[1],
          equals(const Operand.imm8(0x78)),
        );
        expect(
          instruction.addressToString(radix: const Radix.binary()),
          equals('0001001000110100'),
        );
        expect(
          instruction.addressToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('0001001000110100B'),
        );
        expect(
          instruction.addressToString(radix: const Radix.decimal()),
          equals(' 4660'),
        );
        expect(
          instruction.addressToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals(' 4660'),
        );
        expect(
          instruction.addressToString(),
          equals('1234'),
        );
        expect(
          instruction.addressToString(suffix: true),
          equals('1234H'),
        );
        expect(
          instruction.bytesToString(radix: const Radix.binary()),
          equals('11101111 00110100 01010110 01111000         '),
        );
        expect(
          instruction.bytesToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('11101111B 00110100B 01010110B 01111000B          '),
        );
        expect(
          instruction.bytesToString(radix: const Radix.decimal()),
          equals('239  52  86 120    '),
        );
        expect(
          instruction.bytesToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals('239  52  86 120    '),
        );
        expect(
          instruction.bytesToString(),
          equals('EF 34 56 78   '),
        );
        expect(
          instruction.bytesToString(suffix: true),
          equals('EFH 34H 56H 78H    '),
        );
        expect(
          instruction.instructionToString(radix: const Radix.binary()),
          equals('ADI (0011010001010110), 01111000'),
        );
        expect(
          instruction.instructionToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('ADI (0011010001010110B), 01111000B'),
        );
        expect(
          instruction.instructionToString(radix: const Radix.decimal()),
          equals('ADI (13398), 120'),
        );
        expect(
          instruction.instructionToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals('ADI (13398), 120'),
        );
        expect(
          instruction.instructionToString(),
          equals('ADI (3456), 78'),
        );
        expect(
          instruction.instructionToString(suffix: true),
          equals('ADI (3456H), 78H'),
        );
        expect(
          instruction.toString(),
          equals('1234  EF 34 56 78     ADI (3456), 78'),
        );
        check(instruction.descriptor, expectedDescriptor);
        expect(instruction.descriptor.toString(), equals('ADI (3456), 78'));
      });

      test('Operand.dispPlus()', () {
        final InstructionDescriptor expectedDescriptor = instructionTable[0x8F];
        memLoad(0x1234, <int>[0x8F, 0x05]);

        instruction = dasm.dump(0x1234);
        expect(instruction.address, equals(0x1234));
        expect(
          instruction.descriptor.operands[0],
          equals(const Operand.dispPlus(0x05)),
        );
        expect(
          instruction.addressToString(radix: const Radix.binary()),
          equals('0001001000110100'),
        );
        expect(
          instruction.addressToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('0001001000110100B'),
        );
        expect(
          instruction.addressToString(radix: const Radix.decimal()),
          equals(' 4660'),
        );
        expect(
          instruction.addressToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals(' 4660'),
        );
        expect(
          instruction.addressToString(),
          equals('1234'),
        );
        expect(
          instruction.addressToString(suffix: true),
          equals('1234H'),
        );
        expect(
          instruction.bytesToString(radix: const Radix.binary()),
          equals('10001111 00000101                           '),
        );
        expect(
          instruction.bytesToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('10001111B 00000101B                              '),
        );
        expect(
          instruction.bytesToString(radix: const Radix.decimal()),
          equals('143   5            '),
        );
        expect(
          instruction.bytesToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals('143   5            '),
        );
        expect(
          instruction.bytesToString(),
          equals('8F 05         '),
        );
        expect(
          instruction.bytesToString(suffix: true),
          equals('8FH 05H            '),
        );
        expect(
          instruction.instructionToString(radix: const Radix.binary()),
          equals('BVS +00000101'),
        );
        expect(
          instruction.instructionToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('BVS +00000101B'),
        );
        expect(
          instruction.instructionToString(radix: const Radix.decimal()),
          equals('BVS +5'),
        );
        expect(
          instruction.instructionToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals('BVS +5'),
        );
        expect(
          instruction.instructionToString(),
          equals('BVS +05'),
        );
        expect(
          instruction.instructionToString(suffix: true),
          equals('BVS +05H'),
        );
        expect(
          instruction.toString(),
          equals('1234  8F 05           BVS +05'),
        );
        check(instruction.descriptor, expectedDescriptor);
        expect(instruction.descriptor.toString(), equals('BVS +05'));
      });

      test('Operand.dispMinus()', () {
        final InstructionDescriptor expectedDescriptor = instructionTable[0x99];
        memLoad(0x1234, <int>[0x99, 0x26]);

        instruction = dasm.dump(0x1234);
        expect(instruction.address, equals(0x1234));
        expect(
          instruction.descriptor.operands[0],
          equals(const Operand.dispMinus(0x26)),
        );
        expect(
          instruction.addressToString(radix: const Radix.binary()),
          equals('0001001000110100'),
        );
        expect(
          instruction.addressToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('0001001000110100B'),
        );
        expect(
          instruction.addressToString(radix: const Radix.decimal()),
          equals(' 4660'),
        );
        expect(
          instruction.addressToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals(' 4660'),
        );
        expect(
          instruction.addressToString(),
          equals('1234'),
        );
        expect(
          instruction.addressToString(suffix: true),
          equals('1234H'),
        );
        expect(
          instruction.bytesToString(radix: const Radix.binary()),
          equals('10011001 00100110                           '),
        );
        expect(
          instruction.bytesToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('10011001B 00100110B                              '),
        );
        expect(
          instruction.bytesToString(radix: const Radix.decimal()),
          equals('153  38            '),
        );
        expect(
          instruction.bytesToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals('153  38            '),
        );
        expect(
          instruction.bytesToString(),
          equals('99 26         '),
        );
        expect(
          instruction.bytesToString(suffix: true),
          equals('99H 26H            '),
        );
        expect(
          instruction.instructionToString(radix: const Radix.binary()),
          equals('BZR -00100110'),
        );
        expect(
          instruction.instructionToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('BZR -00100110B'),
        );
        expect(
          instruction.instructionToString(radix: const Radix.decimal()),
          equals('BZR -38'),
        );
        expect(
          instruction.instructionToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals('BZR -38'),
        );
        expect(
          instruction.instructionToString(),
          equals('BZR -26'),
        );
        expect(
          instruction.instructionToString(suffix: true),
          equals('BZR -26H'),
        );
        expect(
          instruction.toString(),
          equals('1234  99 26           BZR -26'),
        );
        check(instruction.descriptor, expectedDescriptor);
        expect(instruction.descriptor.toString(), equals('BZR -26'));
      });

      test('Operand.mem0Cst8()', () {
        final InstructionDescriptor expectedDescriptor = instructionTable[0xF6];
        memLoad(0x1234, <int>[0xF6]);

        instruction = dasm.dump(0x1234);
        expect(instruction.address, equals(0x1234));
        expect(
          instruction.descriptor.operands[0],
          equals(const Operand.mem0Cst8(0xF6)),
        );
        expect(
          instruction.addressToString(radix: const Radix.binary()),
          equals('0001001000110100'),
        );
        expect(
          instruction.addressToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('0001001000110100B'),
        );
        expect(
          instruction.addressToString(radix: const Radix.decimal()),
          equals(' 4660'),
        );
        expect(
          instruction.addressToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals(' 4660'),
        );
        expect(
          instruction.addressToString(),
          equals('1234'),
        );
        expect(
          instruction.addressToString(suffix: true),
          equals('1234H'),
        );
        expect(
          instruction.bytesToString(radix: const Radix.binary()),
          equals('11110110                                    '),
        );
        expect(
          instruction.bytesToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('11110110B                                        '),
        );
        expect(
          instruction.bytesToString(radix: const Radix.decimal()),
          equals('246                '),
        );
        expect(
          instruction.bytesToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals('246                '),
        );
        expect(
          instruction.bytesToString(),
          equals('F6            '),
        );
        expect(
          instruction.bytesToString(suffix: true),
          equals('F6H                '),
        );
        expect(
          instruction.instructionToString(radix: const Radix.binary()),
          equals('VEJ (11110110)'),
        );
        expect(
          instruction.instructionToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('VEJ (11110110B)'),
        );
        expect(
          instruction.instructionToString(radix: const Radix.decimal()),
          equals('VEJ (246)'),
        );
        expect(
          instruction.instructionToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals('VEJ (246)'),
        );
        expect(
          instruction.instructionToString(),
          equals('VEJ (F6)'),
        );
        expect(
          instruction.instructionToString(suffix: true),
          equals('VEJ (F6H)'),
        );
        expect(
          instruction.toString(),
          equals('1234  F6              VEJ (F6)'),
        );
        check(instruction.descriptor, expectedDescriptor);
        expect(instruction.descriptor.toString(), equals('VEJ (F6)'));
      });

      test('Operand.imm16()', () {
        final InstructionDescriptor expectedDescriptor = instructionTable[0xAA];
        memLoad(0x1234, <int>[0xAA, 0x13, 0x57]);

        instruction = dasm.dump(0x1234);
        expect(instruction.address, equals(0x1234));
        expect(
          instruction.descriptor.operands[1],
          equals(const Operand.imm16(0x1357)),
        );
        expect(
          instruction.addressToString(radix: const Radix.binary()),
          equals('0001001000110100'),
        );
        expect(
          instruction.addressToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('0001001000110100B'),
        );
        expect(
          instruction.addressToString(radix: const Radix.decimal()),
          equals(' 4660'),
        );
        expect(
          instruction.addressToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals(' 4660'),
        );
        expect(
          instruction.addressToString(),
          equals('1234'),
        );
        expect(
          instruction.addressToString(suffix: true),
          equals('1234H'),
        );
        expect(
          instruction.bytesToString(radix: const Radix.binary()),
          equals('10101010 00010011 01010111                  '),
        );
        expect(
          instruction.bytesToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('10101010B 00010011B 01010111B                    '),
        );
        expect(
          instruction.bytesToString(radix: const Radix.decimal()),
          equals('170  19  87        '),
        );
        expect(
          instruction.bytesToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals('170  19  87        '),
        );
        expect(
          instruction.bytesToString(),
          equals('AA 13 57      '),
        );
        expect(
          instruction.bytesToString(suffix: true),
          equals('AAH 13H 57H        '),
        );
        expect(
          instruction.instructionToString(radix: const Radix.binary()),
          equals('LDI S, 00010011, 01010111'),
        );
        expect(
          instruction.instructionToString(
            radix: const Radix.binary(),
            suffix: true,
          ),
          equals('LDI S, 00010011B, 01010111B'),
        );
        expect(
          instruction.instructionToString(radix: const Radix.decimal()),
          equals('LDI S, 19, 87'),
        );
        expect(
          instruction.instructionToString(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals('LDI S, 19, 87'),
        );
        expect(
          instruction.instructionToString(),
          equals('LDI S, 13, 57'),
        );
        expect(
          instruction.instructionToString(suffix: true),
          equals('LDI S, 13H, 57H'),
        );
        expect(
          instruction.toString(),
          equals('1234  AA 13 57        LDI S, 13, 57'),
        );
        check(instruction.descriptor, expectedDescriptor);
        expect(instruction.descriptor.toString(), equals('LDI S, 13, 57'));
      });
    });

    group('Instruction', () {
      test('addressLength() should return the expected length', () {
        expect(
          Instruction.addressLength(radix: const Radix.binary()),
          equals(16),
        );
        expect(
            Instruction.addressLength(
              radix: const Radix.binary(),
              suffix: true,
            ),
            equals(17));
        expect(
          Instruction.addressLength(radix: const Radix.decimal()),
          equals(5),
        );
        expect(
          Instruction.addressLength(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals(5),
        );
        expect(Instruction.addressLength(), equals(4));
        expect(Instruction.addressLength(suffix: true), equals(5));
      });

      test('bytesLength() should return the expected length', () {
        expect(
          Instruction.bytesLength(radix: const Radix.binary()),
          equals(44),
        );
        expect(
            Instruction.bytesLength(
              radix: const Radix.binary(),
              suffix: true,
            ),
            equals(49));
        expect(
          Instruction.bytesLength(radix: const Radix.decimal()),
          equals(19),
        );
        expect(
          Instruction.bytesLength(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals(19),
        );
        expect(Instruction.bytesLength(), equals(14));
        expect(Instruction.bytesLength(suffix: true), equals(19));
      });

      test('instructionLength() should return the expected length', () {
        expect(
          Instruction.instructionLength(radix: const Radix.binary()),
          equals(33),
        );
        expect(
            Instruction.instructionLength(
              radix: const Radix.binary(),
              suffix: true,
            ),
            equals(35));
        expect(
          Instruction.instructionLength(radix: const Radix.decimal()),
          equals(17),
        );
        expect(
          Instruction.instructionLength(
            radix: const Radix.decimal(),
            suffix: true,
          ),
          equals(17),
        );
        expect(Instruction.instructionLength(), equals(15));
        expect(Instruction.instructionLength(suffix: true), equals(17));
      });
    });
  });
}
