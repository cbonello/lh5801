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
  group('Integration test', () {
    group('LH5801DASM', () {
      test('should disassemble a valid program successfully', () {
        final LH5801Emulator emulator = LH5801Emulator(
          clockFrequency: 1300000,
          memRead: memRead,
          memWrite: memWrite,
        );

        // Invert LCD screen of a Sharp PC-1500 pocket computer.
        memLoad(emulator.cpu.p.value, <int>[
          // LDI XH, 76H
          0x48, 0x76,
          // LDI XL, 00H
          0x4A, 0x00,
          // LDA (X)
          0x05,
          // EAI FFH
          0xBD, 0xFF,
          // SIN X
          0x41,
          // CPI XL, 4EH
          0x4E, 0x4E,
          // BZR -08H
          0x99, 0x08,
          // CPI XH, 77H
          0x4C, 0x77,
          // BZS +06H
          0x8B, 0x06,
          // LDI XH, 77H
          0x48, 0x77,
          // LDI XL, 00H
          0x4A, 0x00,
          // BCH -12H
          0x9E, 0x12,
          // HLT
          0xFD, 0xB1
        ]);

        final LH5801DASM dasm = LH5801DASM(memRead: memRead);
        final StringBuffer output = StringBuffer();
        Instruction instruction;

        emulator.cpu.p.value = 0x0000;
        do {
          instruction = dasm.dump(emulator.cpu.p.value);
          output.writeln(instruction.descriptor);
          emulator.cpu.p.value += instruction.descriptor.size;
        } while (instruction.descriptor.opcode != 0xFDB1);

        const String expected = 'LDI XH, 76H\n'
            'LDI XL, 00H\n'
            'LDA (X)\n'
            'EAI FFH\n'
            'SIN X\n'
            'CPI XL, 4EH\n'
            'BZR -08H\n'
            'CPI XH, 77H\n'
            'BZS +06H\n'
            'LDI XH, 77H\n'
            'LDI XL, 00H\n'
            'BCH -12H\n'
            'HLT\n';
        expect(output.toString(), equals(expected));
      });
    });
  });
}
