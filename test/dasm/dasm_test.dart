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
  final int value = address & 0x10000 != 0 ? me1[address & 0xFFFF] : me0[address];
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
        memLoad(0x0000, <int>[0xFC]);

        instruction = dasm.dump(0x0000);
        expect(instruction.address, equals(0x0000));
        check(instruction.descriptor, expectedDescriptor);
        expect(instruction.descriptor.toString(), equals('ILL'));
      });

      test('OperandType.none()', () {
        final InstructionDescriptor expectedDescriptor = instructionTableFD[0x4C];
        memLoad(0x0000, <int>[0xFD, 0x4C]);

        instruction = dasm.dump(0x0000);
        expect(instruction.address, equals(0x0000));
        check(instruction.descriptor, expectedDescriptor);
        expect(instruction.descriptor.toString(), equals('OFF'));
      });

      test('OperandType.reg()', () {
        final InstructionDescriptor expectedDescriptor = instructionTableFD[0x08];
        memLoad(0x0000, <int>[0xFD, 0x08]);

        instruction = dasm.dump(0x0000);
        expect(instruction.address, equals(0x0000));
        check(instruction.descriptor, expectedDescriptor);
        expect(instruction.descriptor.toString(), equals('LDX X'));
      });

      test('OperandType.mem0Reg()', () {
        final InstructionDescriptor expectedDescriptor = instructionTable[0x2D];
        memLoad(0x0000, <int>[0x2D]);

        instruction = dasm.dump(0x0000);
        expect(instruction.address, equals(0x0000));
        check(instruction.descriptor, expectedDescriptor);
        expect(instruction.descriptor.toString(), equals('EOR (U)'));
      });

      test('OperandType.mem0Imm16()', () {
        final InstructionDescriptor expectedDescriptor = instructionTable[0xA1];
        memLoad(0x0000, <int>[0xA1, 0x12, 0x34]);

        instruction = dasm.dump(0x0000);
        expect(instruction.address, equals(0x0000));
        check(instruction.descriptor, expectedDescriptor);
        expect(instruction.descriptor.toString(), equals('SBC (1234H)'));
      });

      test('OperandType.mem1Reg()', () {
        final InstructionDescriptor expectedDescriptor = instructionTableFD[0x0E];
        memLoad(0x0000, <int>[0xFD, 0x0E]);

        instruction = dasm.dump(0x0000);
        expect(instruction.address, equals(0x0000));
        check(instruction.descriptor, expectedDescriptor);
        expect(instruction.descriptor.toString(), equals('STA #(X)'));
      });

      test('OperandType.mem1Imm16()', () {
        final InstructionDescriptor expectedDescriptor = instructionTableFD[0xAF];
        memLoad(0x0000, <int>[0xFD, 0xAF, 0x34, 0x56]);

        instruction = dasm.dump(0x0000);
        expect(instruction.address, equals(0x0000));
        check(instruction.descriptor, expectedDescriptor);
        expect(instruction.descriptor.toString(), equals('BIT #(3456H)'));
      });

      test('OperandType.imm8()', () {
        final InstructionDescriptor expectedDescriptor = instructionTable[0xEF];
        memLoad(0x0000, <int>[0xEF, 0x34, 0x56, 0x78]);

        instruction = dasm.dump(0x0000);
        expect(instruction.address, equals(0x0000));
        check(instruction.descriptor, expectedDescriptor);
        expect(instruction.descriptor.toString(), equals('ADI (3456H), 78H'));
      });

      test('OperandType.dispPlus()', () {
        final InstructionDescriptor expectedDescriptor = instructionTable[0x8F];
        memLoad(0x0000, <int>[0x8F, 0x05]);

        instruction = dasm.dump(0x0000);
        expect(instruction.address, equals(0x0000));
        check(instruction.descriptor, expectedDescriptor);
        expect(instruction.descriptor.toString(), equals('BVS +05H'));
      });

      test('OperandType.dispMinus()', () {
        final InstructionDescriptor expectedDescriptor = instructionTable[0x99];
        memLoad(0x0000, <int>[0x99, 0x26]);

        instruction = dasm.dump(0x0000);
        expect(instruction.address, equals(0x0000));
        check(instruction.descriptor, expectedDescriptor);
        expect(instruction.descriptor.toString(), equals('BZR -26H'));
      });

      test('OperandType.mem0Cst8()', () {
        final InstructionDescriptor expectedDescriptor = instructionTable[0xF6];
        memLoad(0x0000, <int>[0xF6]);

        instruction = dasm.dump(0x0000);
        expect(instruction.address, equals(0x0000));
        check(instruction.descriptor, expectedDescriptor);
        expect(instruction.descriptor.toString(), equals('VEJ (F6H)'));
      });

      test('OperandType.imm16()', () {
        final InstructionDescriptor expectedDescriptor = instructionTable[0xAA];
        memLoad(0x0000, <int>[0xAA, 0x13, 0x57]);

        instruction = dasm.dump(0x0000);
        expect(instruction.address, equals(0x0000));
        check(instruction.descriptor, expectedDescriptor);
        expect(instruction.descriptor.toString(), equals('LDI S, 13H, 57H'));
      });
    });
  });
}
