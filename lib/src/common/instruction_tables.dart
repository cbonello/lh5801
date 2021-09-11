import 'package:freezed_annotation/freezed_annotation.dart';

import '../../lh5801.dart';

part 'instruction_tables.freezed.dart';

@freezed
class InstructionCategory with _$InstructionCategory {
  // An illegal or non-implemented instruction.
  const factory InstructionCategory.illegal() = _Illegal;
  // A logical instruction.
  const factory InstructionCategory.logicalOperation() = _LogicalOperation;
  // A comparison or bit test instruction.
  const factory InstructionCategory.comparisonBitTest() = _ComparisonBitTest;
  // A load or store instruction.
  const factory InstructionCategory.loadStore() = _LoadStore;
  // A block transfer or search instruction.
  const factory InstructionCategory.blockTransferSearch() =
      _BlockTransferSearch;
  // An input/output instruction.
  const factory InstructionCategory.inputOutput() = _InputOutput;
  // A branch.
  const factory InstructionCategory.branch() = _Branch;
  // A JMP instruction.
  const factory InstructionCategory.jump() = _Jump;
  // A LOP instruction.
  const factory InstructionCategory.lop() = _Lop;
  // A function call.
  const factory InstructionCategory.call() = _Call;
  // A return instruction.
  const factory InstructionCategory.ret() = _Return;
}

// An instruction operand.
@freezed
class Operand with _$Operand {
  const Operand._();

  // No operand.
  const factory Operand.none() = _None;
  // A register (i.e., 'U').
  const factory Operand.reg(String registerName) = _Reg;
  // Contents of the ME0 memory addressed by Reg (i.e., '(U)').
  const factory Operand.mem0Reg(String registerName) = _Mem0Reg;
  // Contents of the ME0 memory addressed by a 16-bit constant (i.e., '(ab)').
  const factory Operand.mem0Imm16(int value) = _Mem0Imm16;
  // Contents of the ME1 memory addressed by Reg (i.e., '(U)').
  const factory Operand.mem1Reg(String registerName) = _Mem1Reg;
  // Contents of the ME1 memory addressed by a 16-bit constant (i.e., '(ab)').
  const factory Operand.mem1Imm16(int value) = _Mem1Imm16;
  // An 8-bit constant (i.e., 'i').
  const factory Operand.imm8(int value) = _Imm8;
  // An 8-bit positive immediate displacement (i.e., '+i').
  const factory Operand.dispPlus(int offset) = _DispPlus;
  // An 8-bit negative immediate displacement (i.e., '-i').
  const factory Operand.dispMinus(int offset) = _DispMinus;
  // An 8-bit constant vector ID (i.e., '(i)').
  const factory Operand.mem0Cst8(int constant) = _Mem0Cst8;
  // A 16-bit constant.
  const factory Operand.imm16(int value) = _Imm16;

  String operandToString({
    Radix radix = const Radix.hexadecimal(),
    bool suffix = false,
  }) {
    return when<String>(
      none: () => '',
      reg: (String registerName) => registerName,
      mem0Reg: (String registerName) => '($registerName)',
      mem0Imm16: (int value) =>
          '(${OperandDump.op16(value, radix: radix, suffix: suffix).trim()})',
      mem1Reg: (String registerName) => '#($registerName)',
      mem1Imm16: (int value) =>
          '#(${OperandDump.op16(value, radix: radix, suffix: suffix).trim()})',
      imm8: (int value) => OperandDump.op8(
        value,
        radix: radix,
        suffix: suffix,
      ),
      dispPlus: (int offset) =>
          '+${OperandDump.op8(offset, radix: radix, suffix: suffix).trim()}',
      dispMinus: (int offset) =>
          '-${OperandDump.op8(offset, radix: radix, suffix: suffix).trim()}',
      mem0Cst8: (int constant) =>
          '(${OperandDump.op8(constant, radix: radix, suffix: suffix).trim()})',
      imm16: (int value) {
        final String op1 = OperandDump.op8(
          value >> 8,
          radix: radix,
          suffix: suffix,
        ).trim();
        final String op2 = OperandDump.op8(
          value & 0xFF,
          radix: radix,
          suffix: suffix,
        ).trim();

        return '$op1, $op2';
      },
    );
  }
}

// The number of CPU cycles required to execute an instruction.
@immutable
class CyclesCount {
  const CyclesCount(this.basic, this.additional);

  final int basic;
  final int additional;
}

// An instruction.
@immutable
class InstructionDescriptor {
  const InstructionDescriptor(
    this.category,
    this.bytes,
    this.size,
    this.mnemonic,
    this.operands,
    this.cycles,
  );

  final InstructionCategory category;
  final List<int> bytes;
  final int size;
  final String mnemonic;
  final List<Operand> operands;
  final CyclesCount cycles;

  InstructionDescriptor copyWith({
    List<int>? updatedBytes,
    List<Operand>? updatedOperands,
  }) {
    return InstructionDescriptor(
      category,
      updatedBytes ?? bytes,
      size,
      mnemonic,
      updatedOperands ?? operands,
      cycles,
    );
  }

  String instructionToString({
    Radix radix = const Radix.hexadecimal(),
    bool suffix = false,
  }) {
    final StringBuffer output = StringBuffer(mnemonic);

    if (operands[0] != const Operand.none()) {
      output.write(' ');

      for (int i = 0; i < operands.length; i++) {
        final Operand operand = operands[i];

        if (i > 0 &&
            operand != const Operand.none() &&
            operands[i - 1] != const Operand.none()) {
          output.write(', ');
        }

        output.write(operand.operandToString(radix: radix, suffix: suffix));
      }
    }

    return output.toString();
  }

  @override
  String toString() => instructionToString();
}

InstructionDescriptor _illegalInstruction(List<int> bytes) =>
    InstructionDescriptor(
      const InstructionCategory.illegal(),
      bytes,
      1,
      'ILL',
      const <Operand>[
        Operand.none(),
        Operand.none(),
      ],
      const CyclesCount(0, 0),
    );

final List<InstructionDescriptor> instructionTableFD = <InstructionDescriptor>[
  // 0x00
  _illegalInstruction(<int>[0xFD, 0x00]),
  const InstructionDescriptor(
    // SBC #(X)
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x01],
    2,
    'SBC',
    <Operand>[
      Operand.mem1Reg('X'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0x02]),
  const InstructionDescriptor(
    // ADC #(X)
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x03],
    2,
    'ADC',
    <Operand>[
      Operand.mem1Reg('X'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0x04]),
  const InstructionDescriptor(
    // LDA #(X)
    InstructionCategory.loadStore(),
    <int>[0xFD, 0x05],
    2,
    'LDA',
    <Operand>[
      Operand.mem1Reg('X'),
      Operand.none(),
    ],
    CyclesCount(10, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0x06]),
  const InstructionDescriptor(
    // CPA #(X)
    InstructionCategory.comparisonBitTest(),
    <int>[0xFD, 0x07],
    2,
    'CPA',
    <Operand>[
      Operand.mem1Reg('X'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  const InstructionDescriptor(
    // LDX X
    InstructionCategory.loadStore(),
    <int>[0xFD, 0x08],
    2,
    'LDX',
    <Operand>[
      Operand.reg('X'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  const InstructionDescriptor(
    // AND #(X)
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x09],
    2,
    'AND',
    <Operand>[
      Operand.mem1Reg('X'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  const InstructionDescriptor(
    // POP X
    InstructionCategory.loadStore(),
    <int>[0xFD, 0x0A],
    2,
    'POP',
    <Operand>[
      Operand.reg('X'),
      Operand.none(),
    ],
    CyclesCount(15, 0),
  ),
  const InstructionDescriptor(
    // ORA #(X)
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x0B],
    2,
    'ORA',
    <Operand>[
      Operand.mem1Reg('X'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  const InstructionDescriptor(
    // DCS #(X)
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x0C],
    2,
    'DCS',
    <Operand>[
      Operand.mem1Reg('X'),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // EOR #(X)
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x0D],
    2,
    'EOR',
    <Operand>[
      Operand.mem1Reg('X'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  const InstructionDescriptor(
    // STA #(X)
    InstructionCategory.loadStore(),
    <int>[0xFD, 0x0E],
    2,
    'STA',
    <Operand>[
      Operand.mem1Reg('X'),
      Operand.none(),
    ],
    CyclesCount(10, 0),
  ),
  const InstructionDescriptor(
    // BIT #(X)
    InstructionCategory.comparisonBitTest(),
    <int>[0xFD, 0x0F],
    2,
    'BIT',
    <Operand>[
      Operand.mem1Reg('X'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),

  // 0x10
  _illegalInstruction(<int>[0xFD, 0x10]),
  const InstructionDescriptor(
    // SBC #(Y)
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x11],
    2,
    'SBC',
    <Operand>[
      Operand.mem1Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0x12]),
  const InstructionDescriptor(
    // ADC #(Y)
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x13],
    2,
    'ADC',
    <Operand>[
      Operand.mem1Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0x14]),
  const InstructionDescriptor(
    // LDA #(Y)
    InstructionCategory.loadStore(),
    <int>[0xFD, 0x15],
    2,
    'LDA',
    <Operand>[
      Operand.mem1Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(10, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0x16]),
  const InstructionDescriptor(
    // CPA #(Y)
    InstructionCategory.comparisonBitTest(),
    <int>[0xFD, 0x17],
    2,
    'CPA',
    <Operand>[
      Operand.mem1Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  const InstructionDescriptor(
    // LDX Y
    InstructionCategory.loadStore(),
    <int>[0xFD, 0x18],
    2,
    'LDX',
    <Operand>[
      Operand.reg('Y'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  const InstructionDescriptor(
    // AND #(Y)
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x19],
    2,
    'AND',
    <Operand>[
      Operand.mem1Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  const InstructionDescriptor(
    // POP Y
    InstructionCategory.loadStore(),
    <int>[0xFD, 0x1A],
    2,
    'POP',
    <Operand>[
      Operand.reg('Y'),
      Operand.none(),
    ],
    CyclesCount(15, 0),
  ),
  const InstructionDescriptor(
    // ORA #(Y)
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x1B],
    2,
    'ORA',
    <Operand>[
      Operand.mem1Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  const InstructionDescriptor(
    // DCS #(Y)
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x1C],
    2,
    'DCS',
    <Operand>[
      Operand.mem1Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // EOR #(Y)
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x1D],
    2,
    'EOR',
    <Operand>[
      Operand.mem1Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  const InstructionDescriptor(
    // STA #(Y)
    InstructionCategory.loadStore(),
    <int>[0xFD, 0x1E],
    2,
    'STA',
    <Operand>[
      Operand.mem1Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(10, 0),
  ),
  const InstructionDescriptor(
    // BIT #(Y)
    InstructionCategory.comparisonBitTest(),
    <int>[0xFD, 0x1F],
    2,
    'BIT',
    <Operand>[
      Operand.mem1Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),

  // 0x20
  _illegalInstruction(<int>[0xFD, 0x20]),
  const InstructionDescriptor(
    // SBC #(U)
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x21],
    2,
    'SBC',
    <Operand>[
      Operand.mem1Reg('U'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0x22]),
  const InstructionDescriptor(
    // ADC #(U)
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x23],
    2,
    'ADC',
    <Operand>[
      Operand.mem1Reg('U'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0x24]),
  const InstructionDescriptor(
    // LDA #(U)
    InstructionCategory.loadStore(),
    <int>[0xFD, 0x25],
    2,
    'LDA',
    <Operand>[
      Operand.mem1Reg('U'),
      Operand.none(),
    ],
    CyclesCount(10, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0x26]),
  const InstructionDescriptor(
    // CPA #(U)
    InstructionCategory.comparisonBitTest(),
    <int>[0xFD, 0x27],
    2,
    'CPA',
    <Operand>[
      Operand.mem1Reg('U'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  const InstructionDescriptor(
    // LDX U
    InstructionCategory.loadStore(),
    <int>[0xFD, 0x28],
    2,
    'LDX',
    <Operand>[
      Operand.reg('U'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  const InstructionDescriptor(
    // AND #(U)
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x29],
    2,
    'AND',
    <Operand>[
      Operand.mem1Reg('U'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  const InstructionDescriptor(
    // POP U
    InstructionCategory.loadStore(),
    <int>[0xFD, 0x2A],
    2,
    'POP',
    <Operand>[
      Operand.reg('U'),
      Operand.none(),
    ],
    CyclesCount(15, 0),
  ),
  const InstructionDescriptor(
    // ORA #(U)
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x2B],
    2,
    'ORA',
    <Operand>[
      Operand.mem1Reg('U'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  const InstructionDescriptor(
    // DCS #(U)
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x2C],
    2,
    'DCS',
    <Operand>[
      Operand.mem1Reg('U'),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // EOR #(U)
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x2D],
    2,
    'EOR',
    <Operand>[
      Operand.mem1Reg('U'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  const InstructionDescriptor(
    // STA #(U)
    InstructionCategory.loadStore(),
    <int>[0xFD, 0x2E],
    2,
    'STA',
    <Operand>[
      Operand.mem1Reg('U'),
      Operand.none(),
    ],
    CyclesCount(10, 0),
  ),
  const InstructionDescriptor(
    // BIT #(U)
    InstructionCategory.comparisonBitTest(),
    <int>[0xFD, 0x2F],
    2,
    'BIT',
    <Operand>[
      Operand.mem1Reg('U'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),

  // 0x30
  _illegalInstruction(<int>[0xFD, 0x30]),
  _illegalInstruction(<int>[0xFD, 0x31]),
  _illegalInstruction(<int>[0xFD, 0x32]),
  _illegalInstruction(<int>[0xFD, 0x33]),
  _illegalInstruction(<int>[0xFD, 0x34]),
  _illegalInstruction(<int>[0xFD, 0x35]),
  _illegalInstruction(<int>[0xFD, 0x36]),
  _illegalInstruction(<int>[0xFD, 0x37]),
  _illegalInstruction(<int>[0xFD, 0x38]),
  _illegalInstruction(<int>[0xFD, 0x39]),
  _illegalInstruction(<int>[0xFD, 0x3A]),
  _illegalInstruction(<int>[0xFD, 0x3B]),
  _illegalInstruction(<int>[0xFD, 0x3C]),
  _illegalInstruction(<int>[0xFD, 0x3D]),
  _illegalInstruction(<int>[0xFD, 0x3E]),
  _illegalInstruction(<int>[0xFD, 0x3F]),

  // 0x40
  const InstructionDescriptor(
    // INC XH
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x40],
    2,
    'INC',
    <Operand>[
      Operand.reg('XH'),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0x41]),
  const InstructionDescriptor(
    // DEC XH
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x42],
    2,
    'DEC',
    <Operand>[
      Operand.reg('XH'),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0x43]),
  _illegalInstruction(<int>[0xFD, 0x44]),
  _illegalInstruction(<int>[0xFD, 0x45]),
  _illegalInstruction(<int>[0xFD, 0x46]),
  _illegalInstruction(<int>[0xFD, 0x47]),
  const InstructionDescriptor(
    // LDX S
    InstructionCategory.loadStore(),
    <int>[0xFD, 0x48],
    2,
    'LDX',
    <Operand>[
      Operand.reg('S'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  const InstructionDescriptor(
    // ANI #(X), i
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x49],
    3,
    'ANI',
    <Operand>[
      Operand.mem1Reg('X'),
      Operand.imm8(0x00),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // STX X
    InstructionCategory.loadStore(),
    <int>[0xFD, 0x4A],
    2,
    'STX',
    <Operand>[
      Operand.reg('X'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  const InstructionDescriptor(
    // ORI #(X), i
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x4B],
    3,
    'ORI',
    <Operand>[
      Operand.mem1Reg('X'),
      Operand.imm8(0x00),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // OFF
    InstructionCategory.inputOutput(),
    <int>[0xFD, 0x4C],
    2,
    'OFF',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(8, 0),
  ),
  const InstructionDescriptor(
    // BII #(X), i
    InstructionCategory.comparisonBitTest(),
    <int>[0xFD, 0x4D],
    3,
    'BII',
    <Operand>[
      Operand.mem1Reg('X'),
      Operand.imm8(0x00),
    ],
    CyclesCount(14, 0),
  ),
  const InstructionDescriptor(
    // STX S
    InstructionCategory.loadStore(),
    <int>[0xFD, 0x4E],
    2,
    'STX',
    <Operand>[
      Operand.reg('S'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  const InstructionDescriptor(
    // ADI #(X), i
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x4F],
    3,
    'ADI',
    <Operand>[
      Operand.mem1Reg('X'),
      Operand.imm8(0x00),
    ],
    CyclesCount(17, 0),
  ),

  // 0x50
  const InstructionDescriptor(
    // INC YH
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x50],
    2,
    'INC',
    <Operand>[
      Operand.reg('YH'),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0x51]),
  const InstructionDescriptor(
    // DEC YH
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x52],
    2,
    'DEC',
    <Operand>[
      Operand.reg('YH'),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0x53]),
  _illegalInstruction(<int>[0xFD, 0x54]),
  _illegalInstruction(<int>[0xFD, 0x55]),
  _illegalInstruction(<int>[0xFD, 0x56]),
  _illegalInstruction(<int>[0xFD, 0x57]),
  const InstructionDescriptor(
    // LDX P
    InstructionCategory.loadStore(),
    <int>[0xFD, 0x58],
    2,
    'LDX',
    <Operand>[
      Operand.reg('P'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  const InstructionDescriptor(
    // ANI #(Y), i
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x59],
    3,
    'ANI',
    <Operand>[
      Operand.mem1Reg('Y'),
      Operand.imm8(0x00),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // STX Y
    InstructionCategory.loadStore(),
    <int>[0xFD, 0x5A],
    2,
    'STX',
    <Operand>[
      Operand.reg('Y'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  const InstructionDescriptor(
    // ORI #(Y), i
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x5B],
    3,
    'ORI',
    <Operand>[
      Operand.mem1Reg('Y'),
      Operand.imm8(0x00),
    ],
    CyclesCount(17, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0x5C]),
  const InstructionDescriptor(
    // BII #(Y), i
    InstructionCategory.comparisonBitTest(),
    <int>[0xFD, 0x5D],
    3,
    'BII',
    <Operand>[
      Operand.mem1Reg('Y'),
      Operand.imm8(0x00),
    ],
    CyclesCount(14, 0),
  ),
  const InstructionDescriptor(
    // STX P
    InstructionCategory.loadStore(),
    <int>[0xFD, 0x5E],
    2,
    'STX',
    <Operand>[
      Operand.reg('P'),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // ADI #(Y), i
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x5F],
    3,
    'ADI',
    <Operand>[
      Operand.mem1Reg('Y'),
      Operand.imm8(0x00),
    ],
    CyclesCount(17, 0),
  ),

  // 0x60
  const InstructionDescriptor(
    // INC UH
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x60],
    2,
    'INC',
    <Operand>[
      Operand.reg('UH'),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0x61]),
  const InstructionDescriptor(
    // DEC UH
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x62],
    2,
    'DEC',
    <Operand>[
      Operand.reg('UH'),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0x63]),
  _illegalInstruction(<int>[0xFD, 0x64]),
  _illegalInstruction(<int>[0xFD, 0x65]),
  _illegalInstruction(<int>[0xFD, 0x66]),
  _illegalInstruction(<int>[0xFD, 0x67]),
  _illegalInstruction(<int>[0xFD, 0x68]),
  const InstructionDescriptor(
    // ANI #(U), i
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x69],
    3,
    'ANI',
    <Operand>[
      Operand.mem1Reg('U'),
      Operand.imm8(0x00),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // STX U
    InstructionCategory.loadStore(),
    <int>[0xFD, 0x6A],
    2,
    'STX',
    <Operand>[
      Operand.reg('U'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  const InstructionDescriptor(
    // ORI #(U), i
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x6B],
    3,
    'ORI',
    <Operand>[
      Operand.mem1Reg('U'),
      Operand.imm8(0x00),
    ],
    CyclesCount(17, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0x6C]),
  const InstructionDescriptor(
    // BII #(U), i
    InstructionCategory.comparisonBitTest(),
    <int>[0xFD, 0x6D],
    3,
    'BII',
    <Operand>[
      Operand.mem1Reg('U'),
      Operand.imm8(0x00),
    ],
    CyclesCount(14, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0x6E]),
  const InstructionDescriptor(
    // ADI #(U), i
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x6F],
    3,
    'ADI',
    <Operand>[
      Operand.mem1Reg('U'),
      Operand.imm8(0x00),
    ],
    CyclesCount(17, 0),
  ),

  // 0x70
  _illegalInstruction(<int>[0xFD, 0x70]),
  _illegalInstruction(<int>[0xFD, 0x71]),
  _illegalInstruction(<int>[0xFD, 0x72]),
  _illegalInstruction(<int>[0xFD, 0x73]),
  _illegalInstruction(<int>[0xFD, 0x74]),
  _illegalInstruction(<int>[0xFD, 0x75]),
  _illegalInstruction(<int>[0xFD, 0x76]),
  _illegalInstruction(<int>[0xFD, 0x77]),
  _illegalInstruction(<int>[0xFD, 0x78]),
  _illegalInstruction(<int>[0xFD, 0x79]),
  _illegalInstruction(<int>[0xFD, 0x7A]),
  _illegalInstruction(<int>[0xFD, 0x7B]),
  _illegalInstruction(<int>[0xFD, 0x7C]),
  _illegalInstruction(<int>[0xFD, 0x7D]),
  _illegalInstruction(<int>[0xFD, 0x7E]),
  _illegalInstruction(<int>[0xFD, 0x7F]),

  // 0x80
  _illegalInstruction(<int>[0xFD, 0x80]),
  const InstructionDescriptor(
    // SIE
    InstructionCategory.inputOutput(),
    <int>[0xFD, 0x81],
    2,
    'SIE',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(8, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0x82]),
  _illegalInstruction(<int>[0xFD, 0x83]),
  _illegalInstruction(<int>[0xFD, 0x84]),
  _illegalInstruction(<int>[0xFD, 0x85]),
  _illegalInstruction(<int>[0xFD, 0x86]),
  _illegalInstruction(<int>[0xFD, 0x87]),
  const InstructionDescriptor(
    // PSH X
    InstructionCategory.loadStore(),
    <int>[0xFD, 0x88],
    2,
    'PSH',
    <Operand>[
      Operand.reg('X'),
      Operand.none(),
    ],
    CyclesCount(14, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0x89]),
  const InstructionDescriptor(
    // POP A
    InstructionCategory.loadStore(),
    <int>[0xFD, 0x8A],
    2,
    'POP',
    <Operand>[
      Operand.reg('A'),
      Operand.none(),
    ],
    CyclesCount(12, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0x8B]),
  const InstructionDescriptor(
    // DCA #(X)
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x8C],
    2,
    'DCA',
    <Operand>[
      Operand.mem1Reg('X'),
      Operand.none(),
    ],
    CyclesCount(19, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0x8D]),
  const InstructionDescriptor(
    // CDV
    InstructionCategory.inputOutput(),
    <int>[0xFD, 0x8E],
    2,
    'CDV',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(8, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0x8F]),

  // 0x90
  _illegalInstruction(<int>[0xFD, 0x90]),
  _illegalInstruction(<int>[0xFD, 0x91]),
  _illegalInstruction(<int>[0xFD, 0x92]),
  _illegalInstruction(<int>[0xFD, 0x93]),
  _illegalInstruction(<int>[0xFD, 0x94]),
  _illegalInstruction(<int>[0xFD, 0x95]),
  _illegalInstruction(<int>[0xFD, 0x96]),
  _illegalInstruction(<int>[0xFD, 0x97]),
  const InstructionDescriptor(
    // PSH Y
    InstructionCategory.loadStore(),
    <int>[0xFD, 0x98],
    2,
    'PSH',
    <Operand>[
      Operand.reg('Y'),
      Operand.none(),
    ],
    CyclesCount(14, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0x99]),
  _illegalInstruction(<int>[0xFD, 0x9A]),
  _illegalInstruction(<int>[0xFD, 0x9B]),
  const InstructionDescriptor(
    // DCA #(Y)
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0x9C],
    2,
    'DCA',
    <Operand>[
      Operand.mem1Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(19, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0x9D]),
  _illegalInstruction(<int>[0xFD, 0x9E]),
  _illegalInstruction(<int>[0xFD, 0x9F]),

  // 0xA0
  _illegalInstruction(<int>[0xFD, 0xA0]),
  const InstructionDescriptor(
    // SBC #(ab)
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0xA1],
    4,
    'SBC',
    <Operand>[
      Operand.mem1Imm16(0x0000),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0xA2]),
  const InstructionDescriptor(
    // ADC #(ab)
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0xA3],
    4,
    'ADC',
    <Operand>[
      Operand.mem1Imm16(0x0000),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0xA4]),
  const InstructionDescriptor(
    // LDA #(ab)
    InstructionCategory.loadStore(),
    <int>[0xFD, 0xA5],
    4,
    'LDA',
    <Operand>[
      Operand.mem1Imm16(0x0000),
      Operand.none(),
    ],
    CyclesCount(16, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0xA6]),
  const InstructionDescriptor(
    // CPA #(ab)
    InstructionCategory.comparisonBitTest(),
    <int>[0xFD, 0xA7],
    4,
    'CPA',
    <Operand>[
      Operand.mem1Imm16(0x0000),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // PSH U
    InstructionCategory.loadStore(),
    <int>[0xFD, 0xA8],
    2,
    'PSH',
    <Operand>[
      Operand.reg('U'),
      Operand.none(),
    ],
    CyclesCount(14, 0),
  ),
  const InstructionDescriptor(
    // AND #(ab)
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0xA9],
    4,
    'AND',
    <Operand>[
      Operand.mem1Imm16(0x0000),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // TTA
    InstructionCategory.loadStore(),
    <int>[0xFD, 0xAA],
    2,
    'TTA',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  const InstructionDescriptor(
    // ORA #(ab)
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0xAB],
    4,
    'ORA',
    <Operand>[
      Operand.mem1Imm16(0x0000),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // DCA #(U)
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0xAC],
    2,
    'DCA',
    <Operand>[
      Operand.mem1Reg('U'),
      Operand.none(),
    ],
    CyclesCount(19, 0),
  ),
  const InstructionDescriptor(
    // EOR #(ab)
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0xAD],
    4,
    'EOR',
    <Operand>[
      Operand.mem1Imm16(0x0000),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // STA #(ab)
    InstructionCategory.loadStore(),
    <int>[0xFD, 0xAE],
    4,
    'STA',
    <Operand>[
      Operand.mem1Imm16(0x0000),
      Operand.none(),
    ],
    CyclesCount(15, 0),
  ),
  const InstructionDescriptor(
    // BIT #(ab)
    InstructionCategory.comparisonBitTest(),
    <int>[0xFD, 0xAF],
    4,
    'BIT',
    <Operand>[
      Operand.mem1Imm16(0x0000),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),

  // 0xB0
  _illegalInstruction(<int>[0xFD, 0xB0]),
  const InstructionDescriptor(
    // HLT
    InstructionCategory.inputOutput(),
    <int>[0xFD, 0xB1],
    2,
    'HLT',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0xB2]),
  _illegalInstruction(<int>[0xFD, 0xB3]),
  _illegalInstruction(<int>[0xFD, 0xB4]),
  _illegalInstruction(<int>[0xFD, 0xB5]),
  _illegalInstruction(<int>[0xFD, 0xB6]),
  _illegalInstruction(<int>[0xFD, 0xB7]),
  _illegalInstruction(<int>[0xFD, 0xB8]),
  _illegalInstruction(<int>[0xFD, 0xB9]),
  const InstructionDescriptor(
    // ITA
    InstructionCategory.inputOutput(),
    <int>[0xFD, 0xBA],
    2,
    'ITA',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0xBB]),
  _illegalInstruction(<int>[0xFD, 0xBC]),
  _illegalInstruction(<int>[0xFD, 0xBD]),
  const InstructionDescriptor(
    // RIE
    InstructionCategory.inputOutput(),
    <int>[0xFD, 0xBE],
    2,
    'RIE',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(8, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0xBF]),

  // 0xC0
  const InstructionDescriptor(
    // RDP
    InstructionCategory.inputOutput(),
    <int>[0xFD, 0xC0],
    2,
    'RDP',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(8, 0),
  ),
  const InstructionDescriptor(
    // SDP
    InstructionCategory.inputOutput(),
    <int>[0xFD, 0xC1],
    2,
    'SDP',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(8, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0xC2]),
  _illegalInstruction(<int>[0xFD, 0xC3]),
  _illegalInstruction(<int>[0xFD, 0xC4]),
  _illegalInstruction(<int>[0xFD, 0xC5]),
  _illegalInstruction(<int>[0xFD, 0xC6]),
  _illegalInstruction(<int>[0xFD, 0xC7]),
  const InstructionDescriptor(
    // PSH A
    InstructionCategory.loadStore(),
    <int>[0xFD, 0xC8],
    2,
    'PSH',
    <Operand>[
      Operand.reg('A'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0xC9]),
  const InstructionDescriptor(
    // ADR X
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0xCA],
    2,
    'ADR',
    <Operand>[
      Operand.reg('X'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0xCB]),
  const InstructionDescriptor(
    // ATP
    InstructionCategory.inputOutput(),
    <int>[0xFD, 0xCC],
    2,
    'ATP',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0xCD]),
  const InstructionDescriptor(
    // AM0
    InstructionCategory.inputOutput(),
    <int>[0xFD, 0xCE],
    2,
    'AM0',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0xCF]),

  // 0xD0
  _illegalInstruction(<int>[0xFD, 0xD0]),
  _illegalInstruction(<int>[0xFD, 0xD1]),
  _illegalInstruction(<int>[0xFD, 0xD2]),
  const InstructionDescriptor(
    // DRR #(X)
    InstructionCategory.blockTransferSearch(),
    <int>[0xFD, 0xD3],
    2,
    'DRR',
    <Operand>[
      Operand.mem1Reg('X'),
      Operand.none(),
    ],
    CyclesCount(16, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0xD4]),
  _illegalInstruction(<int>[0xFD, 0xD5]),
  _illegalInstruction(<int>[0xFD, 0xD6]),
  const InstructionDescriptor(
    // DRL #(X)
    InstructionCategory.blockTransferSearch(),
    <int>[0xFD, 0xD7],
    2,
    'DRL',
    <Operand>[
      Operand.mem1Reg('X'),
      Operand.none(),
    ],
    CyclesCount(16, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0xD8]),
  _illegalInstruction(<int>[0xFD, 0xD9]),
  const InstructionDescriptor(
    // ADR Y
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0xDA],
    2,
    'ADR',
    <Operand>[
      Operand.reg('Y'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0xDB]),
  _illegalInstruction(<int>[0xFD, 0xDC]),
  _illegalInstruction(<int>[0xFD, 0xDD]),
  const InstructionDescriptor(
    // AM1
    InstructionCategory.inputOutput(),
    <int>[0xFD, 0xDE],
    2,
    'AM1',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0xDF]),

  // 0xE0
  _illegalInstruction(<int>[0xFD, 0xE0]),
  _illegalInstruction(<int>[0xFD, 0xE1]),
  _illegalInstruction(<int>[0xFD, 0xE2]),
  _illegalInstruction(<int>[0xFD, 0xE3]),
  _illegalInstruction(<int>[0xFD, 0xE4]),
  _illegalInstruction(<int>[0xFD, 0xE5]),
  _illegalInstruction(<int>[0xFD, 0xE6]),
  _illegalInstruction(<int>[0xFD, 0xE7]),
  _illegalInstruction(<int>[0xFD, 0xE8]),
  const InstructionDescriptor(
    // ANI #(ab), i
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0xE9],
    5,
    'ANI',
    <Operand>[
      Operand.mem1Imm16(0x0000),
      Operand.imm8(0x00),
    ],
    CyclesCount(23, 0),
  ),
  const InstructionDescriptor(
    // ADR U
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0xEA],
    2,
    'ADR',
    <Operand>[
      Operand.reg('U'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  const InstructionDescriptor(
    // ORI #(ab), i
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0xEB],
    5,
    'ORI',
    <Operand>[
      Operand.mem1Imm16(0x0000),
      Operand.imm8(0x00),
    ],
    CyclesCount(23, 0),
  ),
  const InstructionDescriptor(
    // ATT
    InstructionCategory.loadStore(),
    <int>[0xFD, 0xEC],
    2,
    'ATT',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  const InstructionDescriptor(
    // BII #(ab), i
    InstructionCategory.comparisonBitTest(),
    <int>[0xFD, 0xED],
    5,
    'BII',
    <Operand>[
      Operand.mem1Imm16(0x0000),
      Operand.imm8(0x00),
    ],
    CyclesCount(20, 0),
  ),
  _illegalInstruction(<int>[0xFD, 0xEE]),
  const InstructionDescriptor(
    // ADI #(ab), i
    InstructionCategory.logicalOperation(),
    <int>[0xFD, 0xEF],
    5,
    'ADI',
    <Operand>[
      Operand.mem1Imm16(0x0000),
      Operand.imm8(0x00),
    ],
    CyclesCount(23, 0),
  ),

  // 0xF0
  _illegalInstruction(<int>[0xFD, 0xF0]),
  _illegalInstruction(<int>[0xFD, 0xF1]),
  _illegalInstruction(<int>[0xFD, 0xF2]),
  _illegalInstruction(<int>[0xFD, 0xF3]),
  _illegalInstruction(<int>[0xFD, 0xF4]),
  _illegalInstruction(<int>[0xFD, 0xF5]),
  _illegalInstruction(<int>[0xFD, 0xF6]),
  _illegalInstruction(<int>[0xFD, 0xF7]),
  _illegalInstruction(<int>[0xFD, 0xF8]),
  _illegalInstruction(<int>[0xFD, 0xF9]),
  _illegalInstruction(<int>[0xFD, 0xFA]),
  _illegalInstruction(<int>[0xFD, 0xFB]),
  _illegalInstruction(<int>[0xFD, 0xFC]),
  _illegalInstruction(<int>[0xFD, 0xFD]),
  _illegalInstruction(<int>[0xFD, 0xFE]),
  _illegalInstruction(<int>[0xFD, 0xFF]),
];

// InstructionTable ...
final List<InstructionDescriptor> instructionTable = <InstructionDescriptor>[
  // 0x00
  const InstructionDescriptor(
    // SBC XL
    InstructionCategory.logicalOperation(),
    <int>[0x00],
    1,
    'SBC',
    <Operand>[
      Operand.reg('XL'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // SBC (X)
    InstructionCategory.logicalOperation(),
    <int>[0x01],
    1,
    'SBC',
    <Operand>[
      Operand.mem0Reg('X'),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // ADC XL
    InstructionCategory.logicalOperation(),
    <int>[0x02],
    1,
    'ADC',
    <Operand>[
      Operand.reg('XL'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // ADC (X)
    InstructionCategory.logicalOperation(),
    <int>[0x03],
    1,
    'ADC',
    <Operand>[
      Operand.mem0Reg('X'),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // LDA XL
    InstructionCategory.loadStore(),
    <int>[0x04],
    1,
    'LDA',
    <Operand>[
      Operand.reg('XL'),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  const InstructionDescriptor(
    // LDA (X)
    InstructionCategory.loadStore(),
    <int>[0x05],
    1,
    'LDA',
    <Operand>[
      Operand.mem0Reg('X'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // CPA XL
    InstructionCategory.comparisonBitTest(),
    <int>[0x06],
    1,
    'CPA',
    <Operand>[
      Operand.reg('XL'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // CPA (X)
    InstructionCategory.comparisonBitTest(),
    <int>[0x07],
    1,
    'CPA',
    <Operand>[
      Operand.mem0Reg('X'),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // STA XH
    InstructionCategory.loadStore(),
    <int>[0x08],
    1,
    'STA',
    <Operand>[
      Operand.reg('XH'),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  const InstructionDescriptor(
    // AND (X)
    InstructionCategory.logicalOperation(),
    <int>[0x09],
    1,
    'AND',
    <Operand>[
      Operand.mem0Reg('X'),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // STA XL
    InstructionCategory.loadStore(),
    <int>[0x0A],
    1,
    'STA',
    <Operand>[
      Operand.reg('XL'),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  const InstructionDescriptor(
    // ORA (X)
    InstructionCategory.logicalOperation(),
    <int>[0x0B],
    1,
    'ORA',
    <Operand>[
      Operand.mem0Reg('X'),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // DCS (X)
    InstructionCategory.logicalOperation(),
    <int>[0x0C],
    1,
    'DCS',
    <Operand>[
      Operand.mem0Reg('X'),
      Operand.none(),
    ],
    CyclesCount(13, 0),
  ),
  const InstructionDescriptor(
    // EOR (X)
    InstructionCategory.logicalOperation(),
    <int>[0x0D],
    1,
    'EOR',
    <Operand>[
      Operand.mem0Reg('X'),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // STA (X)
    InstructionCategory.loadStore(),
    <int>[0x0E],
    1,
    'STA',
    <Operand>[
      Operand.mem0Reg('X'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // BIT (X)
    InstructionCategory.comparisonBitTest(),
    <int>[0x0F],
    1,
    'BIT',
    <Operand>[
      Operand.mem0Reg('X'),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),

  // 0x10
  const InstructionDescriptor(
    // SBC YL
    InstructionCategory.logicalOperation(),
    <int>[0x10],
    1,
    'SBC',
    <Operand>[
      Operand.reg('YL'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // SBC (Y)
    InstructionCategory.logicalOperation(),
    <int>[0x11],
    1,
    'SBC',
    <Operand>[
      Operand.mem0Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // ADC YL
    InstructionCategory.logicalOperation(),
    <int>[0x12],
    1,
    'ADC',
    <Operand>[
      Operand.reg('YL'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // ADC (Y)
    InstructionCategory.logicalOperation(),
    <int>[0x13],
    1,
    'ADC',
    <Operand>[
      Operand.mem0Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // LDA YL
    InstructionCategory.loadStore(),
    <int>[0x14],
    1,
    'LDA',
    <Operand>[
      Operand.reg('YL'),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  const InstructionDescriptor(
    // LDA (Y)
    InstructionCategory.loadStore(),
    <int>[0x15],
    1,
    'LDA',
    <Operand>[
      Operand.mem0Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // CPA YL
    InstructionCategory.comparisonBitTest(),
    <int>[0x16],
    1,
    'CPA',
    <Operand>[
      Operand.reg('YL'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // CPA (Y)
    InstructionCategory.comparisonBitTest(),
    <int>[0x17],
    1,
    'CPA',
    <Operand>[
      Operand.mem0Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // STA YH
    InstructionCategory.loadStore(),
    <int>[0x18],
    1,
    'STA',
    <Operand>[
      Operand.reg('YH'),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  const InstructionDescriptor(
    // AND (Y)
    InstructionCategory.logicalOperation(),
    <int>[0x19],
    1,
    'AND',
    <Operand>[
      Operand.mem0Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // STA YL
    InstructionCategory.loadStore(),
    <int>[0x1A],
    1,
    'STA',
    <Operand>[
      Operand.reg('YL'),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  const InstructionDescriptor(
    // ORA (Y)
    InstructionCategory.logicalOperation(),
    <int>[0x1B],
    1,
    'ORA',
    <Operand>[
      Operand.mem0Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // DCS (Y)
    InstructionCategory.logicalOperation(),
    <int>[0x1C],
    1,
    'DCS',
    <Operand>[
      Operand.mem0Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(13, 0),
  ),
  const InstructionDescriptor(
    // EOR (Y)
    InstructionCategory.logicalOperation(),
    <int>[0x1D],
    1,
    'EOR',
    <Operand>[
      Operand.mem0Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // STA (Y)
    InstructionCategory.loadStore(),
    <int>[0x1E],
    1,
    'STA',
    <Operand>[
      Operand.mem0Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // BIT (Y)
    InstructionCategory.comparisonBitTest(),
    <int>[0x1F],
    1,
    'BIT',
    <Operand>[
      Operand.mem0Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),

  // 0x20
  const InstructionDescriptor(
    // SBC UL
    InstructionCategory.logicalOperation(),
    <int>[0x20],
    1,
    'SBC',
    <Operand>[
      Operand.reg('UL'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // SBC (U)
    InstructionCategory.logicalOperation(),
    <int>[0x21],
    1,
    'SBC',
    <Operand>[
      Operand.mem0Reg('U'),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // ADC UL
    InstructionCategory.logicalOperation(),
    <int>[0x22],
    1,
    'ADC',
    <Operand>[
      Operand.reg('UL'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // ADC (U)
    InstructionCategory.logicalOperation(),
    <int>[0x23],
    1,
    'ADC',
    <Operand>[
      Operand.mem0Reg('U'),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // LDA UL
    InstructionCategory.loadStore(),
    <int>[0x24],
    1,
    'LDA',
    <Operand>[
      Operand.reg('UL'),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  const InstructionDescriptor(
    // LDA (U)
    InstructionCategory.loadStore(),
    <int>[0x25],
    1,
    'LDA',
    <Operand>[
      Operand.mem0Reg('U'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // CPA UL
    InstructionCategory.comparisonBitTest(),
    <int>[0x26],
    1,
    'CPA',
    <Operand>[
      Operand.reg('UL'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // CPA (U)
    InstructionCategory.comparisonBitTest(),
    <int>[0x27],
    1,
    'CPA',
    <Operand>[
      Operand.mem0Reg('U'),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // STA UH
    InstructionCategory.loadStore(),
    <int>[0x28],
    1,
    'STA',
    <Operand>[
      Operand.reg('UH'),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  const InstructionDescriptor(
    // AND (U)
    InstructionCategory.logicalOperation(),
    <int>[0x29],
    1,
    'AND',
    <Operand>[
      Operand.mem0Reg('U'),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // STA UL
    InstructionCategory.loadStore(),
    <int>[0x2A],
    1,
    'STA',
    <Operand>[
      Operand.reg('UL'),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  const InstructionDescriptor(
    // ORA (U)
    InstructionCategory.logicalOperation(),
    <int>[0x2B],
    1,
    'ORA',
    <Operand>[
      Operand.mem0Reg('U'),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // DCS (U)
    InstructionCategory.logicalOperation(),
    <int>[0x2C],
    1,
    'DCS',
    <Operand>[
      Operand.mem0Reg('U'),
      Operand.none(),
    ],
    CyclesCount(13, 0),
  ),
  const InstructionDescriptor(
    // EOR (U)
    InstructionCategory.logicalOperation(),
    <int>[0x2D],
    1,
    'EOR',
    <Operand>[
      Operand.mem0Reg('U'),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // STA (U)
    InstructionCategory.loadStore(),
    <int>[0x2E],
    1,
    'STA',
    <Operand>[
      Operand.mem0Reg('U'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // BIT (U)
    InstructionCategory.comparisonBitTest(),
    <int>[0x2F],
    1,
    'BIT',
    <Operand>[
      Operand.mem0Reg('X'),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),

  // 0x30
  _illegalInstruction(<int>[0x30]),
  _illegalInstruction(<int>[0x31]),
  _illegalInstruction(<int>[0x32]),
  _illegalInstruction(<int>[0x33]),
  _illegalInstruction(<int>[0x34]),
  _illegalInstruction(<int>[0x35]),
  _illegalInstruction(<int>[0x36]),
  _illegalInstruction(<int>[0x37]),
  const InstructionDescriptor(
    // NOP
    InstructionCategory.inputOutput(),
    <int>[0x38],
    1,
    'NOP',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  _illegalInstruction(<int>[0x39]),
  _illegalInstruction(<int>[0x3A]),
  _illegalInstruction(<int>[0x3B]),
  _illegalInstruction(<int>[0x3C]),
  _illegalInstruction(<int>[0x3D]),
  _illegalInstruction(<int>[0x3E]),
  _illegalInstruction(<int>[0x3F]),

  // 0x40
  const InstructionDescriptor(
    // INC XL
    InstructionCategory.logicalOperation(),
    <int>[0x40],
    1,
    'INC',
    <Operand>[
      Operand.reg('XL'),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  const InstructionDescriptor(
    // SIN X
    InstructionCategory.loadStore(),
    <int>[0x41],
    1,
    'SIN',
    <Operand>[
      Operand.reg('X'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // DEC XL
    InstructionCategory.logicalOperation(),
    <int>[0x42],
    1,
    'DEC',
    <Operand>[
      Operand.reg('XL'),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  const InstructionDescriptor(
    // SDE X
    InstructionCategory.loadStore(),
    <int>[0x43],
    1,
    'SDE',
    <Operand>[
      Operand.reg('X'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // INC X
    InstructionCategory.logicalOperation(),
    <int>[0x44],
    1,
    'INC',
    <Operand>[
      Operand.reg('X'),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  const InstructionDescriptor(
    // LIN X
    InstructionCategory.loadStore(),
    <int>[0x45],
    1,
    'LIN',
    <Operand>[
      Operand.reg('X'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // DEC X
    InstructionCategory.logicalOperation(),
    <int>[0x46],
    1,
    'DEC',
    <Operand>[
      Operand.reg('X'),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  const InstructionDescriptor(
    // LDE X
    InstructionCategory.loadStore(),
    <int>[0x47],
    1,
    'LDE',
    <Operand>[
      Operand.reg('X'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // LDI XH, i
    InstructionCategory.loadStore(),
    <int>[0x48],
    2,
    'LDI',
    <Operand>[
      Operand.reg('XH'),
      Operand.imm8(0x00),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // ANI (X), i
    InstructionCategory.logicalOperation(),
    <int>[0x49],
    2,
    'ANI',
    <Operand>[
      Operand.mem0Reg('X'),
      Operand.imm8(0x00),
    ],
    CyclesCount(13, 0),
  ),
  const InstructionDescriptor(
    // LDI XL, i
    InstructionCategory.loadStore(),
    <int>[0x4A],
    2,
    'LDI',
    <Operand>[
      Operand.reg('XL'),
      Operand.imm8(0x00),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // ORI (X), i
    InstructionCategory.logicalOperation(),
    <int>[0x4B],
    2,
    'ORI',
    <Operand>[
      Operand.mem0Reg('X'),
      Operand.imm8(0x00),
    ],
    CyclesCount(13, 0),
  ),
  const InstructionDescriptor(
    // CPI XH, i
    InstructionCategory.comparisonBitTest(),
    <int>[0x4C],
    2,
    'CPI',
    <Operand>[
      Operand.reg('XH'),
      Operand.imm8(0x00),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // BII (X), i
    InstructionCategory.comparisonBitTest(),
    <int>[0x4D],
    2,
    'BII',
    <Operand>[
      Operand.mem0Reg('X'),
      Operand.imm8(0x00),
    ],
    CyclesCount(10, 0),
  ),
  const InstructionDescriptor(
    // CPI XL, i
    InstructionCategory.comparisonBitTest(),
    <int>[0x4E],
    2,
    'CPI',
    <Operand>[
      Operand.reg('XL'),
      Operand.imm8(0x00),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // ADI (X), i
    InstructionCategory.logicalOperation(),
    <int>[0x4F],
    2,
    'ADI',
    <Operand>[
      Operand.mem0Reg('X'),
      Operand.imm8(0x00),
    ],
    CyclesCount(13, 0),
  ),

  // 0x50
  const InstructionDescriptor(
    // INC YL
    InstructionCategory.logicalOperation(),
    <int>[0x50],
    1,
    'INC',
    <Operand>[
      Operand.reg('YL'),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  const InstructionDescriptor(
    // SIN Y
    InstructionCategory.loadStore(),
    <int>[0x51],
    1,
    'SIN',
    <Operand>[
      Operand.reg('Y'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // DEC YL
    InstructionCategory.logicalOperation(),
    <int>[0x52],
    1,
    'DEC',
    <Operand>[
      Operand.reg('YL'),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  const InstructionDescriptor(
    // SDE Y
    InstructionCategory.loadStore(),
    <int>[0x53],
    1,
    'SDE',
    <Operand>[
      Operand.reg('Y'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // INC Y
    InstructionCategory.logicalOperation(),
    <int>[0x54],
    1,
    'INC',
    <Operand>[
      Operand.reg('Y'),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  const InstructionDescriptor(
    // LIN Y
    InstructionCategory.loadStore(),
    <int>[0x55],
    1,
    'LIN',
    <Operand>[
      Operand.reg('Y'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // DEC Y
    InstructionCategory.logicalOperation(),
    <int>[0x56],
    1,
    'DEC',
    <Operand>[
      Operand.reg('Y'),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  const InstructionDescriptor(
    // LDE Y
    InstructionCategory.loadStore(),
    <int>[0x57],
    1,
    'LDE',
    <Operand>[
      Operand.reg('Y'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // LDI YH, i
    InstructionCategory.loadStore(),
    <int>[0x58],
    2,
    'LDI',
    <Operand>[
      Operand.reg('YH'),
      Operand.imm8(0x00),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // ANI (Y), i
    InstructionCategory.logicalOperation(),
    <int>[0x59],
    2,
    'ANI',
    <Operand>[
      Operand.mem0Reg('Y'),
      Operand.imm8(0x00),
    ],
    CyclesCount(13, 0),
  ),
  const InstructionDescriptor(
    // LDI YL, i
    InstructionCategory.loadStore(),
    <int>[0x5A],
    2,
    'LDI',
    <Operand>[
      Operand.reg('YL'),
      Operand.imm8(0x00),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // ORI (Y), i
    InstructionCategory.logicalOperation(),
    <int>[0x5B],
    2,
    'ORI',
    <Operand>[
      Operand.mem0Reg('Y'),
      Operand.imm8(0x00),
    ],
    CyclesCount(13, 0),
  ),
  const InstructionDescriptor(
    // CPI YH, i
    InstructionCategory.comparisonBitTest(),
    <int>[0x5C],
    2,
    'CPI',
    <Operand>[
      Operand.reg('YH'),
      Operand.imm8(0x00),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // BII (Y), i
    InstructionCategory.comparisonBitTest(),
    <int>[0x5D],
    2,
    'BII',
    <Operand>[
      Operand.mem0Reg('Y'),
      Operand.imm8(0x00),
    ],
    CyclesCount(10, 0),
  ),
  const InstructionDescriptor(
    // CPI YL, i
    InstructionCategory.comparisonBitTest(),
    <int>[0x5E],
    2,
    'CPI',
    <Operand>[
      Operand.reg('YL'),
      Operand.imm8(0x00),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // ADI (Y), i
    InstructionCategory.logicalOperation(),
    <int>[0x5F],
    2,
    'ADI',
    <Operand>[
      Operand.mem0Reg('Y'),
      Operand.imm8(0x00),
    ],
    CyclesCount(13, 0),
  ),

  // 0x60
  const InstructionDescriptor(
    // INC UL
    InstructionCategory.logicalOperation(),
    <int>[0x60],
    1,
    'INC',
    <Operand>[
      Operand.reg('UL'),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  const InstructionDescriptor(
    // SIN U
    InstructionCategory.loadStore(),
    <int>[0x61],
    1,
    'SIN',
    <Operand>[
      Operand.reg('U'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // DEC UL
    InstructionCategory.logicalOperation(),
    <int>[0x62],
    1,
    'DEC',
    <Operand>[
      Operand.reg('UL'),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  const InstructionDescriptor(
    // SDE U
    InstructionCategory.loadStore(),
    <int>[0x63],
    1,
    'SDE',
    <Operand>[
      Operand.reg('U'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // INC U
    InstructionCategory.logicalOperation(),
    <int>[0x64],
    1,
    'INC',
    <Operand>[
      Operand.reg('U'),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  const InstructionDescriptor(
    // LIN U
    InstructionCategory.loadStore(),
    <int>[0x65],
    1,
    'LIN',
    <Operand>[
      Operand.reg('U'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // DEC U
    InstructionCategory.logicalOperation(),
    <int>[0x66],
    1,
    'DEC',
    <Operand>[
      Operand.reg('U'),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  const InstructionDescriptor(
    // LDE U
    InstructionCategory.loadStore(),
    <int>[0x67],
    1,
    'LDE',
    <Operand>[
      Operand.reg('U'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // LDI UH, i
    InstructionCategory.loadStore(),
    <int>[0x68],
    2,
    'LDI',
    <Operand>[
      Operand.reg('UH'),
      Operand.imm8(0x00),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // ANI (U), i
    InstructionCategory.logicalOperation(),
    <int>[0x69],
    2,
    'ANI',
    <Operand>[
      Operand.mem0Reg('U'),
      Operand.imm8(0x00),
    ],
    CyclesCount(13, 0),
  ),
  const InstructionDescriptor(
    // LDI UL, i
    InstructionCategory.loadStore(),
    <int>[0x6A],
    2,
    'LDI',
    <Operand>[
      Operand.reg('UL'),
      Operand.imm8(0x00),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // ORI (U), i
    InstructionCategory.logicalOperation(),
    <int>[0x6B],
    2,
    'ORI',
    <Operand>[
      Operand.mem0Reg('U'),
      Operand.imm8(0x00),
    ],
    CyclesCount(13, 0),
  ),
  const InstructionDescriptor(
    // CPI UH, i
    InstructionCategory.comparisonBitTest(),
    <int>[0x6C],
    2,
    'CPI',
    <Operand>[
      Operand.reg('UH'),
      Operand.imm8(0x00),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // BII (U), i
    InstructionCategory.comparisonBitTest(),
    <int>[0x6D],
    2,
    'BII',
    <Operand>[
      Operand.mem0Reg('U'),
      Operand.imm8(0x00),
    ],
    CyclesCount(10, 0),
  ),
  const InstructionDescriptor(
    // CPI UL, i
    InstructionCategory.comparisonBitTest(),
    <int>[0x6E],
    2,
    'CPI',
    <Operand>[
      Operand.reg('UL'),
      Operand.imm8(0x00),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // ADI (U), i
    InstructionCategory.logicalOperation(),
    <int>[0x6F],
    2,
    'ADI',
    <Operand>[
      Operand.mem0Reg('U'),
      Operand.imm8(0x00),
    ],
    CyclesCount(13, 0),
  ),

  // 0x70
  _illegalInstruction(<int>[0x70]),
  _illegalInstruction(<int>[0x71]),
  _illegalInstruction(<int>[0x72]),
  _illegalInstruction(<int>[0x73]),
  _illegalInstruction(<int>[0x74]),
  _illegalInstruction(<int>[0x75]),
  _illegalInstruction(<int>[0x76]),
  _illegalInstruction(<int>[0x77]),
  _illegalInstruction(<int>[0x78]),
  _illegalInstruction(<int>[0x79]),
  _illegalInstruction(<int>[0x7A]),
  _illegalInstruction(<int>[0x7B]),
  _illegalInstruction(<int>[0x7C]),
  _illegalInstruction(<int>[0x7D]),
  _illegalInstruction(<int>[0x7E]),
  _illegalInstruction(<int>[0x7F]),

  // 0x80
  const InstructionDescriptor(
    // SBC XH
    InstructionCategory.logicalOperation(),
    <int>[0x80],
    1,
    'SBC',
    <Operand>[
      Operand.reg('XH'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // BCR +i
    InstructionCategory.branch(),
    <int>[0x81],
    2,
    'BCR',
    <Operand>[
      Operand.dispPlus(0x00),
      Operand.none(),
    ],
    CyclesCount(8, 2),
  ),
  const InstructionDescriptor(
    // ADC XH
    InstructionCategory.logicalOperation(),
    <int>[0x82],
    1,
    'ADC',
    <Operand>[
      Operand.reg('XH'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // BCS +i
    InstructionCategory.branch(),
    <int>[0x83],
    2,
    'BCS',
    <Operand>[
      Operand.dispPlus(0x00),
      Operand.none(),
    ],
    CyclesCount(8, 2),
  ),
  const InstructionDescriptor(
    // LDA XH
    InstructionCategory.loadStore(),
    <int>[0x84],
    1,
    'LDA',
    <Operand>[
      Operand.reg('XH'),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  const InstructionDescriptor(
    // BHR +i
    InstructionCategory.branch(),
    <int>[0x85],
    2,
    'BHR',
    <Operand>[
      Operand.dispPlus(0x00),
      Operand.none(),
    ],
    CyclesCount(8, 2),
  ),
  const InstructionDescriptor(
    // CPA XH
    InstructionCategory.comparisonBitTest(),
    <int>[0x86],
    1,
    'CPA',
    <Operand>[
      Operand.reg('XH'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // BHS +i
    InstructionCategory.branch(),
    <int>[0x87],
    2,
    'BHS',
    <Operand>[
      Operand.dispPlus(0x00),
      Operand.none(),
    ],
    CyclesCount(8, 2),
  ),
  const InstructionDescriptor(
    // LOP UL, i
    InstructionCategory.lop(),
    <int>[0x88],
    2,
    'LOP',
    <Operand>[
      Operand.reg('UL'),
      Operand.imm8(0x00),
    ],
    CyclesCount(8, 3),
  ),
  const InstructionDescriptor(
    // BZR +i
    InstructionCategory.branch(),
    <int>[0x89],
    2,
    'BZR',
    <Operand>[
      Operand.dispPlus(0x00),
      Operand.none(),
    ],
    CyclesCount(8, 2),
  ),
  const InstructionDescriptor(
    // RTI
    InstructionCategory.ret(),
    <int>[0x8A],
    1,
    'RTI',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(14, 0),
  ),
  const InstructionDescriptor(
    // BZS +i
    InstructionCategory.branch(),
    <int>[0x8B],
    2,
    'BZS',
    <Operand>[
      Operand.dispPlus(0x00),
      Operand.none(),
    ],
    CyclesCount(8, 2),
  ),
  const InstructionDescriptor(
    // DCA (X)
    InstructionCategory.logicalOperation(),
    <int>[0x8C],
    1,
    'DCA',
    <Operand>[
      Operand.mem0Reg('X'),
      Operand.none(),
    ],
    CyclesCount(15, 0),
  ),
  const InstructionDescriptor(
    // BVR +i
    InstructionCategory.branch(),
    <int>[0x8D],
    2,
    'BVR',
    <Operand>[
      Operand.dispPlus(0x00),
      Operand.none(),
    ],
    CyclesCount(8, 2),
  ),
  const InstructionDescriptor(
    // BCH +i
    InstructionCategory.branch(),
    <int>[0x8E],
    2,
    'BCH',
    <Operand>[
      Operand.dispPlus(0x00),
      Operand.none(),
    ],
    CyclesCount(8, 0),
  ),
  const InstructionDescriptor(
    // BVS +i
    InstructionCategory.branch(),
    <int>[0x8F],
    2,
    'BVS',
    <Operand>[
      Operand.dispPlus(0x00),
      Operand.none(),
    ],
    CyclesCount(8, 2),
  ),

  // 0x90
  const InstructionDescriptor(
    // SBC YH
    InstructionCategory.logicalOperation(),
    <int>[0x90],
    1,
    'SBC',
    <Operand>[
      Operand.reg('YH'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // BCR -i
    InstructionCategory.branch(),
    <int>[0x91],
    2,
    'BCR',
    <Operand>[
      Operand.dispMinus(0x00),
      Operand.none(),
    ],
    CyclesCount(9, 2),
  ),
  const InstructionDescriptor(
    // ADC YH
    InstructionCategory.logicalOperation(),
    <int>[0x92],
    1,
    'ADC',
    <Operand>[
      Operand.reg('YH'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // BCS -i
    InstructionCategory.branch(),
    <int>[0x93],
    2,
    'BCS',
    <Operand>[
      Operand.dispMinus(0x00),
      Operand.none(),
    ],
    CyclesCount(9, 2),
  ),
  const InstructionDescriptor(
    // LDA YH
    InstructionCategory.loadStore(),
    <int>[0x94],
    1,
    'LDA',
    <Operand>[
      Operand.reg('YH'),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  const InstructionDescriptor(
    // BHR -i
    InstructionCategory.branch(),
    <int>[0x95],
    2,
    'BHR',
    <Operand>[
      Operand.dispMinus(0x00),
      Operand.none(),
    ],
    CyclesCount(9, 2),
  ),
  const InstructionDescriptor(
    // CPA YH
    InstructionCategory.comparisonBitTest(),
    <int>[0x96],
    1,
    'CPA',
    <Operand>[
      Operand.reg('YH'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // BHS -i
    InstructionCategory.branch(),
    <int>[0x97],
    2,
    'BHS',
    <Operand>[
      Operand.dispMinus(0x00),
      Operand.none(),
    ],
    CyclesCount(9, 2),
  ),
  _illegalInstruction(<int>[0x98]),
  const InstructionDescriptor(
    // BZR -i
    InstructionCategory.branch(),
    <int>[0x99],
    2,
    'BZR',
    <Operand>[
      Operand.dispMinus(0x00),
      Operand.none(),
    ],
    CyclesCount(9, 2),
  ),
  const InstructionDescriptor(
    // RTN
    InstructionCategory.ret(),
    <int>[0x9A],
    1,
    'RTN',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  const InstructionDescriptor(
    // BZS -i
    InstructionCategory.branch(),
    <int>[0x9B],
    2,
    'BZS',
    <Operand>[
      Operand.dispMinus(0x00),
      Operand.none(),
    ],
    CyclesCount(9, 2),
  ),
  const InstructionDescriptor(
    // DCA (Y)
    InstructionCategory.logicalOperation(),
    <int>[0x9C],
    1,
    'DCA',
    <Operand>[
      Operand.mem0Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(15, 0),
  ),
  const InstructionDescriptor(
    // BVR -i
    InstructionCategory.branch(),
    <int>[0x9D],
    2,
    'BVR',
    <Operand>[
      Operand.dispMinus(0x00),
      Operand.none(),
    ],
    CyclesCount(9, 2),
  ),
  const InstructionDescriptor(
    // BCH -i
    InstructionCategory.branch(),
    <int>[0x9E],
    2,
    'BCH',
    <Operand>[
      Operand.dispMinus(0x00),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  const InstructionDescriptor(
    // BVS -i
    InstructionCategory.branch(),
    <int>[0x9F],
    2,
    'BVS',
    <Operand>[
      Operand.dispMinus(0x00),
      Operand.none(),
    ],
    CyclesCount(9, 2),
  ),

  // 0xA0
  const InstructionDescriptor(
    // SBC UH
    InstructionCategory.logicalOperation(),
    <int>[0xA0],
    1,
    'SBC',
    <Operand>[
      Operand.reg('UH'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // SBC (ab)
    InstructionCategory.logicalOperation(),
    <int>[0xA1],
    3,
    'SBC',
    <Operand>[
      Operand.mem0Imm16(0x0000),
      Operand.none(),
    ],
    CyclesCount(13, 0),
  ),
  const InstructionDescriptor(
    // ADC UH
    InstructionCategory.logicalOperation(),
    <int>[0xA2],
    1,
    'ADC',
    <Operand>[
      Operand.reg('UH'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // ADC (ab)
    InstructionCategory.logicalOperation(),
    <int>[0xA3],
    3,
    'ADC',
    <Operand>[
      Operand.mem0Imm16(0x0000),
      Operand.none(),
    ],
    CyclesCount(13, 0),
  ),
  const InstructionDescriptor(
    // LDA UH
    InstructionCategory.loadStore(),
    <int>[0xA4],
    1,
    'LDA',
    <Operand>[
      Operand.reg('UH'),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  const InstructionDescriptor(
    // LDA (ab)
    InstructionCategory.loadStore(),
    <int>[0xA5],
    3,
    'LDA',
    <Operand>[
      Operand.mem0Imm16(0x0000),
      Operand.none(),
    ],
    CyclesCount(12, 0),
  ),
  const InstructionDescriptor(
    // CPA UH
    InstructionCategory.comparisonBitTest(),
    <int>[0xA6],
    1,
    'CPA',
    <Operand>[
      Operand.reg('UH'),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // CPA (ab)
    InstructionCategory.comparisonBitTest(),
    <int>[0xA7],
    3,
    'CPA',
    <Operand>[
      Operand.mem0Imm16(0x0000),
      Operand.none(),
    ],
    CyclesCount(13, 0),
  ),
  const InstructionDescriptor(
    // SPV
    InstructionCategory.inputOutput(),
    <int>[0xA8],
    1,
    'SPV',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(4, 0),
  ),
  const InstructionDescriptor(
    // AND (ab)
    InstructionCategory.logicalOperation(),
    <int>[0xA9],
    3,
    'AND',
    <Operand>[
      Operand.mem0Imm16(0x0000),
      Operand.none(),
    ],
    CyclesCount(13, 0),
  ),
  const InstructionDescriptor(
    // LDI S, i, j
    InstructionCategory.loadStore(),
    <int>[0xAA],
    3,
    'LDI',
    <Operand>[
      Operand.reg('S'),
      Operand.imm16(0x0000),
    ],
    CyclesCount(12, 0),
  ),
  const InstructionDescriptor(
    // ORA (ab)
    InstructionCategory.logicalOperation(),
    <int>[0xAB],
    3,
    'ORA',
    <Operand>[
      Operand.mem0Imm16(0x0000),
      Operand.none(),
    ],
    CyclesCount(13, 0),
  ),
  const InstructionDescriptor(
    // DCA (U)
    InstructionCategory.logicalOperation(),
    <int>[0xAC],
    1,
    'DCA',
    <Operand>[
      Operand.mem0Reg('U'),
      Operand.none(),
    ],
    CyclesCount(15, 0),
  ),
  const InstructionDescriptor(
    // EOR (ab)
    InstructionCategory.logicalOperation(),
    <int>[0xAD],
    3,
    'EOR',
    <Operand>[
      Operand.mem0Imm16(0x0000),
      Operand.none(),
    ],
    CyclesCount(13, 0),
  ),
  const InstructionDescriptor(
    // STA (ab)
    InstructionCategory.loadStore(),
    <int>[0xAE],
    3,
    'STA',
    <Operand>[
      Operand.mem0Imm16(0x0000),
      Operand.none(),
    ],
    CyclesCount(12, 0),
  ),
  const InstructionDescriptor(
    // BIT (ab)
    InstructionCategory.comparisonBitTest(),
    <int>[0xAF],
    3,
    'BIT',
    <Operand>[
      Operand.mem0Imm16(0x0000),
      Operand.none(),
    ],
    CyclesCount(13, 0),
  ),

  // 0xB0
  _illegalInstruction(<int>[0xB0]),
  const InstructionDescriptor(
    // SBI A, i
    InstructionCategory.logicalOperation(),
    <int>[0xB1],
    2,
    'SBI',
    <Operand>[
      Operand.reg('A'),
      Operand.imm8(0x00),
    ],
    CyclesCount(7, 0),
  ),
  _illegalInstruction(<int>[0xB2]),
  const InstructionDescriptor(
    // ADI A, i
    InstructionCategory.logicalOperation(),
    <int>[0xB3],
    2,
    'ADI',
    <Operand>[
      Operand.reg('A'),
      Operand.imm8(0x00),
    ],
    CyclesCount(7, 0),
  ),
  _illegalInstruction(<int>[0xB4]),
  const InstructionDescriptor(
    // LDI A, i
    InstructionCategory.loadStore(),
    <int>[0xB5],
    2,
    'LDI',
    <Operand>[
      Operand.reg('A'),
      Operand.imm8(0x00),
    ],
    CyclesCount(6, 0),
  ),
  _illegalInstruction(<int>[0xB6]),
  const InstructionDescriptor(
    // CPI A, i
    InstructionCategory.comparisonBitTest(),
    <int>[0xB7],
    2,
    'CPI',
    <Operand>[
      Operand.reg('A'),
      Operand.imm8(0x00),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // RPV
    InstructionCategory.inputOutput(),
    <int>[0xB8],
    1,
    'RPV',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(4, 0),
  ),
  const InstructionDescriptor(
    // ANI A, i
    InstructionCategory.logicalOperation(),
    <int>[0xB9],
    2,
    'ANI',
    <Operand>[
      Operand.reg('A'),
      Operand.imm8(0x00),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // JMP i, j
    InstructionCategory.jump(),
    <int>[0xBA],
    3,
    'JMP',
    <Operand>[
      Operand.imm16(0x0000),
      Operand.none(),
    ],
    CyclesCount(12, 0),
  ),
  const InstructionDescriptor(
    // ORI A, i
    InstructionCategory.logicalOperation(),
    <int>[0xBB],
    2,
    'ORI',
    <Operand>[
      Operand.reg('A'),
      Operand.imm8(0x00),
    ],
    CyclesCount(7, 0),
  ),
  _illegalInstruction(<int>[0xBC]),
  const InstructionDescriptor(
    // EAI i
    InstructionCategory.logicalOperation(),
    <int>[0xBD],
    2,
    'EAI',
    <Operand>[
      Operand.imm8(0x00),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // SJP i, j
    InstructionCategory.call(),
    <int>[0xBE],
    3,
    'SJP',
    <Operand>[
      Operand.imm16(0x0000),
      Operand.none(),
    ],
    CyclesCount(19, 0),
  ),
  const InstructionDescriptor(
    // BII i
    InstructionCategory.comparisonBitTest(),
    <int>[0xBF],
    2,
    'BII',
    <Operand>[
      Operand.imm8(0x00),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),

  // 0xC0
  const InstructionDescriptor(
    // VEJ (C0H)
    InstructionCategory.call(),
    <int>[0xC0],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xC0),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // VCR i
    InstructionCategory.call(),
    <int>[0xC1],
    2,
    'VCR',
    <Operand>[
      Operand.imm8(0x00),
      Operand.none(),
    ],
    CyclesCount(8, 13),
  ),
  const InstructionDescriptor(
    // VEJ (C2H)
    InstructionCategory.call(),
    <int>[0xC2],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xC2),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // VCS i
    InstructionCategory.call(),
    <int>[0xC3],
    2,
    'VCS',
    <Operand>[
      Operand.imm8(0x00),
      Operand.none(),
    ],
    CyclesCount(8, 13),
  ),
  const InstructionDescriptor(
    // VEJ (C4H)
    InstructionCategory.call(),
    <int>[0xC4],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xC4),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // VHR i
    InstructionCategory.call(),
    <int>[0xC5],
    2,
    'VHR',
    <Operand>[
      Operand.imm8(0x00),
      Operand.none(),
    ],
    CyclesCount(8, 13),
  ),
  const InstructionDescriptor(
    // VEJ (C6H)
    InstructionCategory.call(),
    <int>[0xC6],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xC6),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // VHS i
    InstructionCategory.call(),
    <int>[0xC7],
    2,
    'VHS',
    <Operand>[
      Operand.imm8(0x00),
      Operand.none(),
    ],
    CyclesCount(8, 13),
  ),
  const InstructionDescriptor(
    // VEJ (C8H)
    InstructionCategory.call(),
    <int>[0xC8],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xC8),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // VZR i
    InstructionCategory.call(),
    <int>[0xC9],
    2,
    'VZR',
    <Operand>[
      Operand.imm8(0x00),
      Operand.none(),
    ],
    CyclesCount(8, 13),
  ),
  const InstructionDescriptor(
    // VEJ (CAH)
    InstructionCategory.call(),
    <int>[0xCA],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xCA),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // VZS i
    InstructionCategory.call(),
    <int>[0xCB],
    2,
    'VZS',
    <Operand>[
      Operand.imm8(0x00),
      Operand.none(),
    ],
    CyclesCount(8, 13),
  ),
  const InstructionDescriptor(
    // VEJ (CCH)
    InstructionCategory.call(),
    <int>[0xCC],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xCC),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // VMJ i
    InstructionCategory.call(),
    <int>[0xCD],
    2,
    'VMJ',
    <Operand>[
      Operand.imm8(0x00),
      Operand.none(),
    ],
    CyclesCount(20, 0),
  ),
  const InstructionDescriptor(
    // VEJ (CEH)
    InstructionCategory.call(),
    <int>[0xCE],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xCE),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // VVS i
    InstructionCategory.call(),
    <int>[0xCF],
    2,
    'VVS',
    <Operand>[
      Operand.imm8(0x00),
      Operand.none(),
    ],
    CyclesCount(8, 13),
  ),

  // 0xD0
  const InstructionDescriptor(
    // VEJ (D0H)
    InstructionCategory.call(),
    <int>[0xD0],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xD0),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // ROR
    InstructionCategory.blockTransferSearch(),
    <int>[0xD1],
    1,
    'ROR',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  const InstructionDescriptor(
    // VEJ (D2H)
    InstructionCategory.call(),
    <int>[0xD2],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xD2),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // DRR (X)
    InstructionCategory.blockTransferSearch(),
    <int>[0xD3],
    1,
    'DRR',
    <Operand>[
      Operand.mem0Reg('X'),
      Operand.none(),
    ],
    CyclesCount(12, 0),
  ),
  const InstructionDescriptor(
    // VEJ (D4H)
    InstructionCategory.call(),
    <int>[0xD4],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xD4),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // SHR
    InstructionCategory.blockTransferSearch(),
    <int>[0xD5],
    1,
    'SHR',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  const InstructionDescriptor(
    // VEJ (D6H)
    InstructionCategory.call(),
    <int>[0xD6],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xD6),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // DRL (X)
    InstructionCategory.blockTransferSearch(),
    <int>[0xD7],
    1,
    'DRL',
    <Operand>[
      Operand.mem0Reg('X'),
      Operand.none(),
    ],
    CyclesCount(12, 0),
  ),
  const InstructionDescriptor(
    // VEJ (D8H)
    InstructionCategory.call(),
    <int>[0xD8],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xD8),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // SHL
    InstructionCategory.blockTransferSearch(),
    <int>[0xD9],
    1,
    'SHL',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // VEJ (DAH)
    InstructionCategory.call(),
    <int>[0xDA],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xDA),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // ROL
    InstructionCategory.blockTransferSearch(),
    <int>[0xDB],
    1,
    'ROL',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(8, 0),
  ),
  const InstructionDescriptor(
    // VEJ (DCH)
    InstructionCategory.call(),
    <int>[0xDC],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xDC),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // INC A
    InstructionCategory.logicalOperation(),
    <int>[0xDD],
    1,
    'INC',
    <Operand>[
      Operand.reg('A'),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  const InstructionDescriptor(
    // VEJ (DEH)
    InstructionCategory.call(),
    <int>[0xDE],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xDE),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // DEC A
    InstructionCategory.logicalOperation(),
    <int>[0xDF],
    1,
    'DEC',
    <Operand>[
      Operand.reg('A'),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),

  // 0xE0
  const InstructionDescriptor(
    // VEJ (E0H)
    InstructionCategory.call(),
    <int>[0xE0],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xE0),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // SPU
    InstructionCategory.inputOutput(),
    <int>[0xE1],
    1,
    'SPU',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(4, 0),
  ),
  const InstructionDescriptor(
    // VEJ (E2H)
    InstructionCategory.call(),
    <int>[0xE2],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xE2),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // RPU
    InstructionCategory.inputOutput(),
    <int>[0xE3],
    1,
    'RPU',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(4, 0),
  ),
  const InstructionDescriptor(
    // VEJ (E4H)
    InstructionCategory.call(),
    <int>[0xE4],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xE4),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  _illegalInstruction(<int>[0x0E5]),
  const InstructionDescriptor(
    // VEJ (E6H)
    InstructionCategory.call(),
    <int>[0xE6],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xE6),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  _illegalInstruction(<int>[0xE7]),
  const InstructionDescriptor(
    // VEJ (E8H)
    InstructionCategory.call(),
    <int>[0xE8],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xE8),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // ANI (ab), i
    InstructionCategory.logicalOperation(),
    <int>[0xE9],
    4,
    'ANI',
    <Operand>[
      Operand.mem0Imm16(0x0000),
      Operand.imm8(0x00),
    ],
    CyclesCount(19, 0),
  ),
  const InstructionDescriptor(
    // VEJ (EAH)
    InstructionCategory.call(),
    <int>[0xEA],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xEA),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // ORI (ab), i
    InstructionCategory.logicalOperation(),
    <int>[0xEB],
    4,
    'ORI',
    <Operand>[
      Operand.mem0Imm16(0x0000),
      Operand.imm8(0x00),
    ],
    CyclesCount(19, 0),
  ),
  const InstructionDescriptor(
    // VEJ (ECH)
    InstructionCategory.call(),
    <int>[0xEC],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xEC),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // BII (ab), i
    InstructionCategory.comparisonBitTest(),
    <int>[0xED],
    4,
    'BII',
    <Operand>[
      Operand.mem0Imm16(0x0000),
      Operand.imm8(0x00),
    ],
    CyclesCount(16, 0),
  ),
  const InstructionDescriptor(
    // VEJ (EEH)
    InstructionCategory.call(),
    <int>[0xEE],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xEE),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // ADI (ab), i
    InstructionCategory.logicalOperation(),
    <int>[0xEF],
    4,
    'ADI',
    <Operand>[
      Operand.mem0Imm16(0x0000),
      Operand.imm8(0x00),
    ],
    CyclesCount(19, 0),
  ),

  // 0xF0
  const InstructionDescriptor(
    // VEJ (F0H)
    InstructionCategory.call(),
    <int>[0xF0],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xF0),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // AEX
    InstructionCategory.blockTransferSearch(),
    <int>[0xF1],
    1,
    'AEX',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(6, 0),
  ),
  const InstructionDescriptor(
    // VEJ (F2H)
    InstructionCategory.call(),
    <int>[0xF2],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xF2),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  _illegalInstruction(<int>[0xF3]),
  const InstructionDescriptor(
    // VEJ (F4H)
    InstructionCategory.call(),
    <int>[0xF4],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xF4),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // TIN
    InstructionCategory.blockTransferSearch(),
    <int>[0xF5],
    1,
    'TIN',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),
  const InstructionDescriptor(
    // VEJ (F6H)
    InstructionCategory.call(),
    <int>[0xF6],
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xF6),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  const InstructionDescriptor(
    // CIN
    InstructionCategory.blockTransferSearch(),
    <int>[0xF7],
    1,
    'CIN',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),
  _illegalInstruction(<int>[0xF8]),
  const InstructionDescriptor(
    // REC
    InstructionCategory.inputOutput(),
    <int>[0xF9],
    1,
    'REC',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(4, 0),
  ),
  _illegalInstruction(<int>[0xFA]),
  const InstructionDescriptor(
    // SEC
    InstructionCategory.inputOutput(),
    <int>[0xFB],
    1,
    'SEC',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(4, 0),
  ),
  _illegalInstruction(<int>[0xFC]),
  _illegalInstruction(<int>[0xFD]),
  _illegalInstruction(<int>[0xFE]),
  _illegalInstruction(<int>[0xFF]),
];
