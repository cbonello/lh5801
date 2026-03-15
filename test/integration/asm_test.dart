import 'dart:typed_data';

import 'package:lh5801/lh5801.dart';
import 'package:test/test.dart';

final Uint8ClampedList me0 = Uint8ClampedList(64 * 1024);

int memRead(int address) => me0[address & 0xFFFF];

void main() {
  group('Integration test', () {
    test('LH5801ASM should round-trip with LH5801DASM', () {
      // Original bytes for LCD inversion program.
      final List<int> originalBytes = [
        0x48, 0x76, 0x4A, 0x00, 0x05, 0xBD, 0xFF, 0x41,
        0x4E, 0x4E, 0x99, 0x08, 0x4C, 0x77, 0x8B, 0x06,
        0x48, 0x77, 0x4A, 0x00, 0x9E, 0x12, 0xFD, 0xB1,
      ];

      // Load into memory and disassemble.
      me0.setRange(0, originalBytes.length, originalBytes);
      final LH5801DASM dasm = LH5801DASM(memRead: memRead);
      final StringBuffer source = StringBuffer();
      int addr = 0;
      while (addr < originalBytes.length) {
        final Instruction instruction = dasm.dump(addr);
        source.writeln(instruction.instructionToString());
        addr += instruction.descriptor.size;
      }

      // Re-assemble the disassembled source.
      final LH5801ASM asm = LH5801ASM();
      final AsmResult result = asm.assemble(source.toString());

      expect(result.hasErrors, isFalse, reason: result.errors.join('\n'));
      expect(result.bytes, equals(originalBytes));
    });
  });
}
