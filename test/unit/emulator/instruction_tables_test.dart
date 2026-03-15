import 'package:lh5801/lh5801.dart';
import 'package:test/test.dart';

final Map<String, InstructionCategory> expectedCategories =
    <String, InstructionCategory>{
  'ILL': InstructionCategory.illegal,
  'ADC': InstructionCategory.logicalOperation,
  'ADI': InstructionCategory.logicalOperation,
  'ADR': InstructionCategory.logicalOperation,
  'AND': InstructionCategory.logicalOperation,
  'ANI': InstructionCategory.logicalOperation,
  'DCA': InstructionCategory.logicalOperation,
  'DCS': InstructionCategory.logicalOperation,
  'DEC': InstructionCategory.logicalOperation,
  'EAI': InstructionCategory.logicalOperation,
  'EOR': InstructionCategory.logicalOperation,
  'INC': InstructionCategory.logicalOperation,
  'ORA': InstructionCategory.logicalOperation,
  'ORI': InstructionCategory.logicalOperation,
  'SBC': InstructionCategory.logicalOperation,
  'SBI': InstructionCategory.logicalOperation,
  'BII': InstructionCategory.comparisonBitTest,
  'BIT': InstructionCategory.comparisonBitTest,
  'CPA': InstructionCategory.comparisonBitTest,
  'CPI': InstructionCategory.comparisonBitTest,
  'ATT': InstructionCategory.loadStore,
  'LDA': InstructionCategory.loadStore,
  'LDE': InstructionCategory.loadStore,
  'LDI': InstructionCategory.loadStore,
  'LDX': InstructionCategory.loadStore,
  'LIN': InstructionCategory.loadStore,
  'POP': InstructionCategory.loadStore,
  'PSH': InstructionCategory.loadStore,
  'SDE': InstructionCategory.loadStore,
  'SIN': InstructionCategory.loadStore,
  'STA': InstructionCategory.loadStore,
  'STX': InstructionCategory.loadStore,
  'TTA': InstructionCategory.loadStore,
  'AEX': InstructionCategory.blockTransferSearch,
  'CIN': InstructionCategory.blockTransferSearch,
  'DRL': InstructionCategory.blockTransferSearch,
  'DRR': InstructionCategory.blockTransferSearch,
  'ROL': InstructionCategory.blockTransferSearch,
  'ROR': InstructionCategory.blockTransferSearch,
  'SHL': InstructionCategory.blockTransferSearch,
  'SHR': InstructionCategory.blockTransferSearch,
  'TIN': InstructionCategory.blockTransferSearch,
  'AM0': InstructionCategory.inputOutput,
  'AM1': InstructionCategory.inputOutput,
  'ATP': InstructionCategory.inputOutput,
  'CDV': InstructionCategory.inputOutput,
  'HLT': InstructionCategory.inputOutput,
  'ITA': InstructionCategory.inputOutput,
  'NOP': InstructionCategory.inputOutput,
  'OFF': InstructionCategory.inputOutput,
  'RDP': InstructionCategory.inputOutput,
  'REC': InstructionCategory.inputOutput,
  'RIE': InstructionCategory.inputOutput,
  'RPU': InstructionCategory.inputOutput,
  'RPV': InstructionCategory.inputOutput,
  'SDP': InstructionCategory.inputOutput,
  'SEC': InstructionCategory.inputOutput,
  'SIE': InstructionCategory.inputOutput,
  'SPU': InstructionCategory.inputOutput,
  'SPV': InstructionCategory.inputOutput,
  'BCH': InstructionCategory.branch,
  'BCR': InstructionCategory.branch,
  'BCS': InstructionCategory.branch,
  'BHR': InstructionCategory.branch,
  'BHS': InstructionCategory.branch,
  'BVR': InstructionCategory.branch,
  'BVS': InstructionCategory.branch,
  'BZR': InstructionCategory.branch,
  'BZS': InstructionCategory.branch,
  'JMP': InstructionCategory.jump,
  'LOP': InstructionCategory.lop,
  'SJP': InstructionCategory.call,
  'VCR': InstructionCategory.call,
  'VCS': InstructionCategory.call,
  'VEJ': InstructionCategory.call,
  'VHR': InstructionCategory.call,
  'VHS': InstructionCategory.call,
  'VMJ': InstructionCategory.call,
  'VVS': InstructionCategory.call,
  'VZR': InstructionCategory.call,
  'VZS': InstructionCategory.call,
  'RTI': InstructionCategory.ret,
  'RTN': InstructionCategory.ret,
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
    expect(descriptor.bytes.length, greaterThanOrEqualTo(1));
    expect(descriptor.bytes.length, lessThanOrEqualTo(2));
    if (descriptor.bytes.length == 2) {
      expect(descriptor.bytes[0], equals(0xFD));
    }

    expect(
      descriptor.mnemonic,
      equals(descriptor.mnemonic.trim().toUpperCase()),
    );
  }

  for (final InstructionDescriptor instruction in table) {
    expect(
      instruction.category,
      equals(expectedCategories[instruction.mnemonic]),
    );
    expect(instruction.operands.length, equals(2));
  }
}
