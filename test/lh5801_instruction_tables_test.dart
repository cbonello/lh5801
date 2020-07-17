import 'package:test/test.dart';

import 'package:lh5801/lh5801.dart';

final Map<String, InstructionCategory> expectedCategories = <String, InstructionCategory>{
  'ILL': const InstructionCategory.illegal(),
  'ADC': const InstructionCategory.logicalOperation(),
  'ADI': const InstructionCategory.logicalOperation(),
  'ADR': const InstructionCategory.logicalOperation(),
  'AND': const InstructionCategory.logicalOperation(),
  'ANI': const InstructionCategory.logicalOperation(),
  'DCA': const InstructionCategory.logicalOperation(),
  'DCS': const InstructionCategory.logicalOperation(),
  'DEC': const InstructionCategory.logicalOperation(),
  'EAI': const InstructionCategory.logicalOperation(),
  'EOR': const InstructionCategory.logicalOperation(),
  'INC': const InstructionCategory.logicalOperation(),
  'ORA': const InstructionCategory.logicalOperation(),
  'ORI': const InstructionCategory.logicalOperation(),
  'SBC': const InstructionCategory.logicalOperation(),
  'SBI': const InstructionCategory.logicalOperation(),
  'BII': const InstructionCategory.comparisonBitTest(),
  'BIT': const InstructionCategory.comparisonBitTest(),
  'CPA': const InstructionCategory.comparisonBitTest(),
  'CPI': const InstructionCategory.comparisonBitTest(),
  'ATT': const InstructionCategory.loadStore(),
  'LDA': const InstructionCategory.loadStore(),
  'LDE': const InstructionCategory.loadStore(),
  'LDI': const InstructionCategory.loadStore(),
  'LDX': const InstructionCategory.loadStore(),
  'LIN': const InstructionCategory.loadStore(),
  'POP': const InstructionCategory.loadStore(),
  'PSH': const InstructionCategory.loadStore(),
  'SDE': const InstructionCategory.loadStore(),
  'SIN': const InstructionCategory.loadStore(),
  'STA': const InstructionCategory.loadStore(),
  'STX': const InstructionCategory.loadStore(),
  'TTA': const InstructionCategory.loadStore(),
  'AEX': const InstructionCategory.blockTransferSearch(),
  'CIN': const InstructionCategory.blockTransferSearch(),
  'DRL': const InstructionCategory.blockTransferSearch(),
  'DRR': const InstructionCategory.blockTransferSearch(),
  'ROL': const InstructionCategory.blockTransferSearch(),
  'ROR': const InstructionCategory.blockTransferSearch(),
  'SHL': const InstructionCategory.blockTransferSearch(),
  'SHR': const InstructionCategory.blockTransferSearch(),
  'TIN': const InstructionCategory.blockTransferSearch(),
  'AM0': const InstructionCategory.inputOutput(),
  'AM1': const InstructionCategory.inputOutput(),
  'ATP': const InstructionCategory.inputOutput(),
  'CDV': const InstructionCategory.inputOutput(),
  'HLT': const InstructionCategory.inputOutput(),
  'ITA': const InstructionCategory.inputOutput(),
  'NOP': const InstructionCategory.inputOutput(),
  'OFF': const InstructionCategory.inputOutput(),
  'RDP': const InstructionCategory.inputOutput(),
  'REC': const InstructionCategory.inputOutput(),
  'RIE': const InstructionCategory.inputOutput(),
  'RPU': const InstructionCategory.inputOutput(),
  'RPV': const InstructionCategory.inputOutput(),
  'SDP': const InstructionCategory.inputOutput(),
  'SEC': const InstructionCategory.inputOutput(),
  'SIE': const InstructionCategory.inputOutput(),
  'SPU': const InstructionCategory.inputOutput(),
  'SPV': const InstructionCategory.inputOutput(),
  'BCH': const InstructionCategory.branch(),
  'BCR': const InstructionCategory.branch(),
  'BCS': const InstructionCategory.branch(),
  'BHR': const InstructionCategory.branch(),
  'BHS': const InstructionCategory.branch(),
  'BVR': const InstructionCategory.branch(),
  'BVS': const InstructionCategory.branch(),
  'BZR': const InstructionCategory.branch(),
  'BZS': const InstructionCategory.branch(),
  'JMP': const InstructionCategory.jump(),
  'LOP': const InstructionCategory.lop(),
  'SJP': const InstructionCategory.call(),
  'VCR': const InstructionCategory.call(),
  'VCS': const InstructionCategory.call(),
  'VEJ': const InstructionCategory.call(),
  'VHR': const InstructionCategory.call(),
  'VHS': const InstructionCategory.call(),
  'VMJ': const InstructionCategory.call(),
  'VVS': const InstructionCategory.call(),
  'VZR': const InstructionCategory.call(),
  'VZS': const InstructionCategory.call(),
  'RTI': const InstructionCategory.ret(),
  'RTN': const InstructionCategory.ret(),
};

void main() {
  group('Instruction Tables', () {
    test('extended 0xFD table should be valid', () {
      testTable(0xFD, instructionTableFD);
    });

    test('regular table should be valid', () {
      testTable(0x00, instructionTable);
    });
  });
}

void testTable(int opcode, List<InstructionDescriptor> table) {
  final String prefix = opcode == 0x00 ? 'xx' : 'FDxx';

  expect(
    table.length,
    equals(256),
    reason:
        '$prefix instruction table: expected length=256; actual length=${table.length}',
  );

  for (int i = 0; i < table.length; i++) {
    final InstructionDescriptor descriptor = table[i];
    expect(descriptor.opcode, equals((opcode << 8) | i));
  }

  for (final InstructionDescriptor instruction in table) {
    expect(instruction.category, equals(expectedCategories[instruction.mnemonic]));
    expect(instruction.operands.length, equals(2));
  }
}
