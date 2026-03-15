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

  group('Operand', () {
    test('hashCode should be consistent with equality', () {
      expect(
        const Operand.none().hashCode,
        equals(const Operand.none().hashCode),
      );
      expect(
        const Operand.reg('X').hashCode,
        equals(const Operand.reg('X').hashCode),
      );
      expect(
        const Operand.mem0Reg('X').hashCode,
        equals(const Operand.mem0Reg('X').hashCode),
      );
      expect(
        const Operand.mem0Imm16(0x1234).hashCode,
        equals(const Operand.mem0Imm16(0x1234).hashCode),
      );
      expect(
        const Operand.mem1Reg('Y').hashCode,
        equals(const Operand.mem1Reg('Y').hashCode),
      );
      expect(
        const Operand.mem1Imm16(0x5678).hashCode,
        equals(const Operand.mem1Imm16(0x5678).hashCode),
      );
      expect(
        const Operand.imm8(0x42).hashCode,
        equals(const Operand.imm8(0x42).hashCode),
      );
      expect(
        const Operand.dispPlus(0x10).hashCode,
        equals(const Operand.dispPlus(0x10).hashCode),
      );
      expect(
        const Operand.dispMinus(0x08).hashCode,
        equals(const Operand.dispMinus(0x08).hashCode),
      );
      expect(
        const Operand.mem0Cst8(0xC0).hashCode,
        equals(const Operand.mem0Cst8(0xC0).hashCode),
      );
      expect(
        const Operand.imm16(0xABCD).hashCode,
        equals(const Operand.imm16(0xABCD).hashCode),
      );
    });

    test('Operands should work in sets', () {
      final Set<Operand> operands = {
        const Operand.none(),
        const Operand.reg('X'),
        const Operand.mem0Reg('Y'),
        const Operand.mem0Imm16(0x1234),
        const Operand.mem1Reg('U'),
        const Operand.mem1Imm16(0x5678),
        const Operand.imm8(0x42),
        const Operand.dispPlus(0x10),
        const Operand.dispMinus(0x08),
        const Operand.mem0Cst8(0xC0),
        const Operand.imm16(0xABCD),
      };
      expect(operands.length, equals(11));
      expect(operands.contains(const Operand.none()), isTrue);
      expect(operands.contains(const Operand.reg('X')), isTrue);
    });
  });

  group('InstructionDescriptor', () {
    test('copyWith should preserve original values when args are null', () {
      const InstructionDescriptor desc = InstructionDescriptor(
        InstructionCategory.logicalOperation,
        <int>[0x01],
        1,
        'ADC',
        <Operand>[Operand.reg('X'), Operand.none()],
        CyclesCount(6, 0),
      );

      final InstructionDescriptor copy = desc.copyWith();
      expect(copy.bytes, same(desc.bytes));
      expect(copy.operands, same(desc.operands));
      expect(copy.mnemonic, equals('ADC'));
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
