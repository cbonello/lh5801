import 'dart:io';
import 'dart:typed_data';

import 'package:lh5801/lh5801.dart';

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
  final LH5801 emulator = LH5801(
    clockFrequency: 1300000,
    memRead: memRead,
    memWrite: memWrite,
  );

  // Invert LCD screen of a Sharp PC-1500 pocket computer.
  final List<int> program = <int>[
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
  ];

  memLoad(emulator.cpu.p.value, program);

  final LH5801DASM dasm = LH5801DASM(memRead: memRead);
  Instruction instruction;

  emulator.cpu.p.value = 0x0000;
  do {
    instruction = dasm.dump(emulator.cpu.p.value);
    stdout.write(
      '${emulator.cpu.p.value.toUnsigned(16).toRadixString(16).toUpperCase().padLeft(4, '0')}H  ',
    );
    stdout.write(formatOpcodes(instruction.descriptor.opcodes));
    stdout.writeln(instruction.descriptor);
    emulator.cpu.p.value += instruction.descriptor.size;
  } while (emulator.cpu.p.value < program.length);
  stdout.writeln();

  int cycles = 0;
  emulator.cpu.p.value = 0x0000;
  while (emulator.cpu.hlt == false) {
    cycles += emulator.step();
  }
  stdout.write('#CPU cycles: $cycles');
}

String formatOpcodes(List<int> opcodes) {
  final StringBuffer output = StringBuffer();

  for (int i = 0; i < opcodes.length; i++) {
    output.write(
      '${opcodes[i].toUnsigned(8).toRadixString(16).toUpperCase().padLeft(2, '0')} ',
    );
  }

  // An instruction has at most 4 bytes.
  return output.toString().padRight(12);
}
