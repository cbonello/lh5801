import '../../lh5801.dart';

class OpcodeEntry {
  const OpcodeEntry(this.descriptor);
  final InstructionDescriptor descriptor;

  List<int> get opcodeBytes => descriptor.bytes;
  int get size => descriptor.size;
}

class OpcodeLookup {
  OpcodeLookup() {
    _build(instructionTable);
    _build(instructionTableFD);
  }

  final Map<String, OpcodeEntry> _table = {};

  OpcodeEntry? lookup(String signature) => _table[signature];

  void _build(List<InstructionDescriptor> table) {
    for (final InstructionDescriptor desc in table) {
      if (desc.category == InstructionCategory.illegal) continue;

      final String sig = signatureOf(desc.mnemonic, desc.operands);
      _table[sig] = OpcodeEntry(desc);
    }
  }

  static String signatureOf(String mnemonic, List<Operand> operands) {
    final StringBuffer buf = StringBuffer(mnemonic);
    for (final Operand op in operands) {
      final String part = switch (op) {
        OperandNone() => '',
        OperandReg(:final registerName) => '|reg:$registerName',
        OperandMem0Reg(:final registerName) => '|mem0reg:$registerName',
        OperandMem0Imm16() => '|mem0imm16',
        OperandMem1Reg(:final registerName) => '|mem1reg:$registerName',
        OperandMem1Imm16() => '|mem1imm16',
        OperandImm8() => '|imm8',
        OperandDispPlus() => '|dispplus',
        OperandDispMinus() => '|dispminus',
        OperandMem0Cst8(:final constant) =>
          '|mem0cst8:${constant.toRadixString(16).toUpperCase()}',
        OperandImm16() => '|imm16',
      };
      buf.write(part);
    }
    return buf.toString();
  }
}
