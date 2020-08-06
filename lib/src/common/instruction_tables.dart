import 'package:freezed_annotation/freezed_annotation.dart';

import '../../lh5801.dart';

part 'instruction_tables.freezed.dart';

@freezed
abstract class InstructionCategory with _$InstructionCategory {
  // An illegal or non-implemented instruction.
  const factory InstructionCategory.illegal() = _Illegal;
  // A logical instruction.
  const factory InstructionCategory.logicalOperation() = _LogicalOperation;
  // A comparison or bit test instruction.
  const factory InstructionCategory.comparisonBitTest() = _ComparisonBitTest;
  // A load or store instruction.
  const factory InstructionCategory.loadStore() = _LoadStore;
  // A block transfer or search instruction.
  const factory InstructionCategory.blockTransferSearch() = _BlockTransferSearch;
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
abstract class Operand with _$Operand {
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

  // toString() cannot be overridden for now. See https://github.com/rrousselGit/freezed/issues/221

  @late
  String toStr() {
    return when<String>(
      none: () => '',
      reg: (String registerName) => registerName,
      mem0Reg: (String registerName) => '($registerName)',
      mem0Imm16: (int value) => '(${HexDump.meHex16(value)})',
      mem1Reg: (String registerName) => '#($registerName)',
      mem1Imm16: (int value) => '#(${HexDump.meHex16(value)})',
      imm8: (int value) => HexDump.hex8(value),
      dispPlus: (int offset) => '+${HexDump.hex8(offset)}',
      dispMinus: (int offset) => '-${HexDump.hex8(offset)}',
      mem0Cst8: (int constant) => '(${HexDump.hex8(constant)})',
      imm16: (int value) => '${HexDump.hex8(value >> 8)}, ${HexDump.hex8(value & 0xFF)}',
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
    this.opcode,
    this.size,
    this.mnemonic,
    this.operands,
    this.cycles,
  );

  final InstructionCategory category;
  final int opcode;
  final int size;
  final String mnemonic;
  final List<Operand> operands;
  final CyclesCount cycles;

  InstructionDescriptor copyWithUpdatedOperands(List<Operand> updatedOperands) =>
      InstructionDescriptor(
        category,
        opcode,
        size,
        mnemonic,
        updatedOperands,
        cycles,
      );

  @override
  String toString() {
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

        output.write(operand.toStr());
      }
    }

    return output.toString();
  }
}

InstructionDescriptor _illegalInstruction(int opcode) => InstructionDescriptor(
      const InstructionCategory.illegal(),
      opcode,
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
  _illegalInstruction(0xFD00),
  const InstructionDescriptor(
    // SBC #(X)
    InstructionCategory.logicalOperation(),
    0xFD01,
    2,
    'SBC',
    <Operand>[
      Operand.mem1Reg('X'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  _illegalInstruction(0xFD02),
  const InstructionDescriptor(
    // ADC #(X)
    InstructionCategory.logicalOperation(),
    0xFD03,
    2,
    'ADC',
    <Operand>[
      Operand.mem1Reg('X'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  _illegalInstruction(0xFD04),
  const InstructionDescriptor(
    // LDA #(X)
    InstructionCategory.loadStore(),
    0xFD05,
    2,
    'LDA',
    <Operand>[
      Operand.mem1Reg('X'),
      Operand.none(),
    ],
    CyclesCount(10, 0),
  ),
  _illegalInstruction(0xFD06),
  const InstructionDescriptor(
    // CPA #(X)
    InstructionCategory.comparisonBitTest(),
    0xFD07,
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
    0xFD08,
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
    0xFD09,
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
    0xFD0A,
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
    0xFD0B,
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
    0xFD0C,
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
    0xFD0D,
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
    0xFD0E,
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
    0xFD0F,
    2,
    'BIT',
    <Operand>[
      Operand.mem1Reg('X'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),

  // 0x10
  _illegalInstruction(0xFD10),
  const InstructionDescriptor(
    // SBC #(Y)
    InstructionCategory.logicalOperation(),
    0xFD11,
    2,
    'SBC',
    <Operand>[
      Operand.mem1Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  _illegalInstruction(0xFD12),
  const InstructionDescriptor(
    // ADC #(Y)
    InstructionCategory.logicalOperation(),
    0xFD13,
    2,
    'ADC',
    <Operand>[
      Operand.mem1Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  _illegalInstruction(0xFD14),
  const InstructionDescriptor(
    // LDA #(Y)
    InstructionCategory.loadStore(),
    0xFD15,
    2,
    'LDA',
    <Operand>[
      Operand.mem1Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(10, 0),
  ),
  _illegalInstruction(0xFD16),
  const InstructionDescriptor(
    // CPA #(Y)
    InstructionCategory.comparisonBitTest(),
    0xFD17,
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
    0xFD18,
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
    0xFD19,
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
    0xFD1A,
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
    0xFD1B,
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
    0xFD1C,
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
    0xFD1D,
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
    0xFD1E,
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
    0xFD1F,
    2,
    'BIT',
    <Operand>[
      Operand.mem1Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),

  // 0x20
  _illegalInstruction(0xFD20),
  const InstructionDescriptor(
    // SBC #(U)
    InstructionCategory.logicalOperation(),
    0xFD21,
    2,
    'SBC',
    <Operand>[
      Operand.mem1Reg('U'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  _illegalInstruction(0xFD22),
  const InstructionDescriptor(
    // ADC #(U)
    InstructionCategory.logicalOperation(),
    0xFD23,
    2,
    'ADC',
    <Operand>[
      Operand.mem1Reg('U'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  _illegalInstruction(0xFD24),
  const InstructionDescriptor(
    // LDA #(U)
    InstructionCategory.loadStore(),
    0xFD25,
    2,
    'LDA',
    <Operand>[
      Operand.mem1Reg('U'),
      Operand.none(),
    ],
    CyclesCount(10, 0),
  ),
  _illegalInstruction(0xFD26),
  const InstructionDescriptor(
    // CPA #(U)
    InstructionCategory.comparisonBitTest(),
    0xFD27,
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
    0xFD28,
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
    0xFD29,
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
    0xFD2A,
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
    0xFD2B,
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
    0xFD2C,
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
    0xFD2D,
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
    0xFD2E,
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
    0xFD2F,
    2,
    'BIT',
    <Operand>[
      Operand.mem1Reg('U'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),

  // 0x30
  _illegalInstruction(0xFD30),
  _illegalInstruction(0xFD31),
  _illegalInstruction(0xFD32),
  _illegalInstruction(0xFD33),
  _illegalInstruction(0xFD34),
  _illegalInstruction(0xFD35),
  _illegalInstruction(0xFD36),
  _illegalInstruction(0xFD37),
  _illegalInstruction(0xFD38),
  _illegalInstruction(0xFD39),
  _illegalInstruction(0xFD3A),
  _illegalInstruction(0xFD3B),
  _illegalInstruction(0xFD3C),
  _illegalInstruction(0xFD3D),
  _illegalInstruction(0xFD3E),
  _illegalInstruction(0xFD3F),

  // 0x40
  const InstructionDescriptor(
    // INC XH
    InstructionCategory.logicalOperation(),
    0xFD40,
    2,
    'INC',
    <Operand>[
      Operand.reg('XH'),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  _illegalInstruction(0xFD41),
  const InstructionDescriptor(
    // DEC XH
    InstructionCategory.logicalOperation(),
    0xFD42,
    2,
    'DEC',
    <Operand>[
      Operand.reg('XH'),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  _illegalInstruction(0xFD43),
  _illegalInstruction(0xFD44),
  _illegalInstruction(0xFD45),
  _illegalInstruction(0xFD46),
  _illegalInstruction(0xFD47),
  const InstructionDescriptor(
    // LDX S
    InstructionCategory.loadStore(),
    0xFD48,
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
    0xFD49,
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
    0xFD4A,
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
    0xFD4B,
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
    0xFD4C,
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
    0xFD4D,
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
    0xFD4E,
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
    0xFD4F,
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
    0xFD50,
    2,
    'INC',
    <Operand>[
      Operand.reg('YH'),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  _illegalInstruction(0xFD51),
  const InstructionDescriptor(
    // DEC YH
    InstructionCategory.logicalOperation(),
    0xFD52,
    2,
    'DEC',
    <Operand>[
      Operand.reg('YH'),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  _illegalInstruction(0xFD53),
  _illegalInstruction(0xFD54),
  _illegalInstruction(0xFD55),
  _illegalInstruction(0xFD56),
  _illegalInstruction(0xFD57),
  const InstructionDescriptor(
    // LDX P
    InstructionCategory.loadStore(),
    0xFD58,
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
    0xFD59,
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
    0xFD5A,
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
    0xFD5B,
    3,
    'ORI',
    <Operand>[
      Operand.mem1Reg('Y'),
      Operand.imm8(0x00),
    ],
    CyclesCount(17, 0),
  ),
  _illegalInstruction(0xFD5C),
  const InstructionDescriptor(
    // BII #(Y), i
    InstructionCategory.comparisonBitTest(),
    0xFD5D,
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
    0xFD5E,
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
    0xFD5F,
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
    0xFD60,
    2,
    'INC',
    <Operand>[
      Operand.reg('UH'),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  _illegalInstruction(0xFD61),
  const InstructionDescriptor(
    // DEC UH
    InstructionCategory.logicalOperation(),
    0xFD62,
    2,
    'DEC',
    <Operand>[
      Operand.reg('UH'),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  _illegalInstruction(0xFD63),
  _illegalInstruction(0xFD64),
  _illegalInstruction(0xFD65),
  _illegalInstruction(0xFD66),
  _illegalInstruction(0xFD67),
  _illegalInstruction(0xFD68),
  const InstructionDescriptor(
    // ANI #(U), i
    InstructionCategory.logicalOperation(),
    0xFD69,
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
    0xFD6A,
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
    0xFD6B,
    3,
    'ORI',
    <Operand>[
      Operand.mem1Reg('U'),
      Operand.imm8(0x00),
    ],
    CyclesCount(17, 0),
  ),
  _illegalInstruction(0xFD6C),
  const InstructionDescriptor(
    // BII #(U), i
    InstructionCategory.comparisonBitTest(),
    0xFD6D,
    3,
    'BII',
    <Operand>[
      Operand.mem1Reg('U'),
      Operand.imm8(0x00),
    ],
    CyclesCount(14, 0),
  ),
  _illegalInstruction(0xFD6E),
  const InstructionDescriptor(
    // ADI #(U), i
    InstructionCategory.logicalOperation(),
    0xFD6F,
    3,
    'ADI',
    <Operand>[
      Operand.mem1Reg('U'),
      Operand.imm8(0x00),
    ],
    CyclesCount(17, 0),
  ),

  // 0x70
  _illegalInstruction(0xFD70),
  _illegalInstruction(0xFD71),
  _illegalInstruction(0xFD72),
  _illegalInstruction(0xFD73),
  _illegalInstruction(0xFD74),
  _illegalInstruction(0xFD75),
  _illegalInstruction(0xFD76),
  _illegalInstruction(0xFD77),
  _illegalInstruction(0xFD78),
  _illegalInstruction(0xFD79),
  _illegalInstruction(0xFD7A),
  _illegalInstruction(0xFD7B),
  _illegalInstruction(0xFD7C),
  _illegalInstruction(0xFD7D),
  _illegalInstruction(0xFD7E),
  _illegalInstruction(0xFD7F),

  // 0x80
  _illegalInstruction(0xFD80),
  const InstructionDescriptor(
    // SIE
    InstructionCategory.inputOutput(),
    0xFD81,
    2,
    'SIE',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(8, 0),
  ),
  _illegalInstruction(0xFD82),
  _illegalInstruction(0xFD83),
  _illegalInstruction(0xFD84),
  _illegalInstruction(0xFD85),
  _illegalInstruction(0xFD86),
  _illegalInstruction(0xFD87),
  const InstructionDescriptor(
    // PSH X
    InstructionCategory.loadStore(),
    0xFD88,
    2,
    'PSH',
    <Operand>[
      Operand.reg('X'),
      Operand.none(),
    ],
    CyclesCount(14, 0),
  ),
  _illegalInstruction(0xFD89),
  const InstructionDescriptor(
    // POP A
    InstructionCategory.loadStore(),
    0xFD8A,
    2,
    'POP',
    <Operand>[
      Operand.reg('A'),
      Operand.none(),
    ],
    CyclesCount(12, 0),
  ),
  _illegalInstruction(0xFD8B),
  const InstructionDescriptor(
    // DCA #(X)
    InstructionCategory.logicalOperation(),
    0xFD8C,
    2,
    'DCA',
    <Operand>[
      Operand.mem1Reg('X'),
      Operand.none(),
    ],
    CyclesCount(19, 0),
  ),
  _illegalInstruction(0xFD8D),
  const InstructionDescriptor(
    // CDV
    InstructionCategory.inputOutput(),
    0xFD8E,
    2,
    'CDV',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(8, 0),
  ),
  _illegalInstruction(0xFD8F),

  // 0x90
  _illegalInstruction(0xFD90),
  _illegalInstruction(0xFD91),
  _illegalInstruction(0xFD92),
  _illegalInstruction(0xFD93),
  _illegalInstruction(0xFD94),
  _illegalInstruction(0xFD95),
  _illegalInstruction(0xFD96),
  _illegalInstruction(0xFD97),
  const InstructionDescriptor(
    // PSH Y
    InstructionCategory.loadStore(),
    0xFD98,
    2,
    'PSH',
    <Operand>[
      Operand.reg('Y'),
      Operand.none(),
    ],
    CyclesCount(14, 0),
  ),
  _illegalInstruction(0xFD99),
  _illegalInstruction(0xFD9A),
  _illegalInstruction(0xFD9B),
  const InstructionDescriptor(
    // DCA #(Y)
    InstructionCategory.logicalOperation(),
    0xFD9C,
    2,
    'DCA',
    <Operand>[
      Operand.mem1Reg('Y'),
      Operand.none(),
    ],
    CyclesCount(19, 0),
  ),
  _illegalInstruction(0xFD9D),
  _illegalInstruction(0xFD9E),
  _illegalInstruction(0xFD9F),

  // 0xA0
  _illegalInstruction(0xFDA0),
  const InstructionDescriptor(
    // SBC #(ab)
    InstructionCategory.logicalOperation(),
    0xFDA1,
    4,
    'SBC',
    <Operand>[
      Operand.mem1Imm16(0x0000),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  _illegalInstruction(0xFDA2),
  const InstructionDescriptor(
    // ADC #(ab)
    InstructionCategory.logicalOperation(),
    0xFDA3,
    4,
    'ADC',
    <Operand>[
      Operand.mem1Imm16(0x0000),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  _illegalInstruction(0xFDA4),
  const InstructionDescriptor(
    // LDA #(ab)
    InstructionCategory.loadStore(),
    0xFDA5,
    4,
    'LDA',
    <Operand>[
      Operand.mem1Imm16(0x0000),
      Operand.none(),
    ],
    CyclesCount(16, 0),
  ),
  _illegalInstruction(0xFDA6),
  const InstructionDescriptor(
    // CPA #(ab)
    InstructionCategory.comparisonBitTest(),
    0xFDA7,
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
    0xFDA8,
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
    0xFDA9,
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
    0xFDAA,
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
    0xFDAB,
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
    0xFDAC,
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
    0xFDAD,
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
    0xFDAE,
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
    0xFDAF,
    4,
    'BIT',
    <Operand>[
      Operand.mem1Imm16(0x0000),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),

  // 0xB0
  _illegalInstruction(0xFDB0),
  const InstructionDescriptor(
    // HLT
    InstructionCategory.inputOutput(),
    0xFDB1,
    2,
    'HLT',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  _illegalInstruction(0xFDB2),
  _illegalInstruction(0xFDB3),
  _illegalInstruction(0xFDB4),
  _illegalInstruction(0xFDB5),
  _illegalInstruction(0xFDB6),
  _illegalInstruction(0xFDB7),
  _illegalInstruction(0xFDB8),
  _illegalInstruction(0xFDB9),
  const InstructionDescriptor(
    // ITA
    InstructionCategory.inputOutput(),
    0xFDBA,
    2,
    'ITA',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  _illegalInstruction(0xFDBB),
  _illegalInstruction(0xFDBC),
  _illegalInstruction(0xFDBD),
  const InstructionDescriptor(
    // RIE
    InstructionCategory.inputOutput(),
    0xFDBE,
    2,
    'RIE',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(8, 0),
  ),
  _illegalInstruction(0xFDBF),

  // 0xC0
  const InstructionDescriptor(
    // RDP
    InstructionCategory.inputOutput(),
    0xFDC0,
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
    0xFDC1,
    2,
    'SDP',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(8, 0),
  ),
  _illegalInstruction(0xFDC2),
  _illegalInstruction(0xFDC3),
  _illegalInstruction(0xFDC4),
  _illegalInstruction(0xFDC5),
  _illegalInstruction(0xFDC6),
  _illegalInstruction(0xFDC7),
  const InstructionDescriptor(
    // PSH A
    InstructionCategory.loadStore(),
    0xFDC8,
    2,
    'PSH',
    <Operand>[
      Operand.reg('A'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  _illegalInstruction(0xFDC9),
  const InstructionDescriptor(
    // ADR X
    InstructionCategory.logicalOperation(),
    0xFDCA,
    2,
    'ADR',
    <Operand>[
      Operand.reg('X'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  _illegalInstruction(0xFDCB),
  const InstructionDescriptor(
    // ATP
    InstructionCategory.inputOutput(),
    0xFDCC,
    2,
    'ATP',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  _illegalInstruction(0xFDCD),
  const InstructionDescriptor(
    // AM0
    InstructionCategory.inputOutput(),
    0xFDCE,
    2,
    'AM0',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  _illegalInstruction(0xFDCF),

  // 0xD0
  _illegalInstruction(0xFDD0),
  _illegalInstruction(0xFDD1),
  _illegalInstruction(0xFDD2),
  const InstructionDescriptor(
    // DRR #(X)
    InstructionCategory.blockTransferSearch(),
    0xFDD3,
    2,
    'DRR',
    <Operand>[
      Operand.mem1Reg('X'),
      Operand.none(),
    ],
    CyclesCount(16, 0),
  ),
  _illegalInstruction(0xFDD4),
  _illegalInstruction(0xFDD5),
  _illegalInstruction(0xFDD6),
  const InstructionDescriptor(
    // DRL #(X)
    InstructionCategory.blockTransferSearch(),
    0xFDD7,
    2,
    'DRL',
    <Operand>[
      Operand.mem1Reg('X'),
      Operand.none(),
    ],
    CyclesCount(16, 0),
  ),
  _illegalInstruction(0xFDD8),
  _illegalInstruction(0xFDD9),
  const InstructionDescriptor(
    // ADR Y
    InstructionCategory.logicalOperation(),
    0xFDDA,
    2,
    'ADR',
    <Operand>[
      Operand.reg('Y'),
      Operand.none(),
    ],
    CyclesCount(11, 0),
  ),
  _illegalInstruction(0xFDDB),
  _illegalInstruction(0xFDDC),
  _illegalInstruction(0xFDDD),
  const InstructionDescriptor(
    // AM1
    InstructionCategory.inputOutput(),
    0xFDDE,
    2,
    'AM1',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(9, 0),
  ),
  _illegalInstruction(0xFDDF),

  // 0xE0
  _illegalInstruction(0xFDE0),
  _illegalInstruction(0xFDE1),
  _illegalInstruction(0xFDE2),
  _illegalInstruction(0xFDE3),
  _illegalInstruction(0xFDE4),
  _illegalInstruction(0xFDE5),
  _illegalInstruction(0xFDE6),
  _illegalInstruction(0xFDE7),
  _illegalInstruction(0xFDE8),
  const InstructionDescriptor(
    // ANI #(ab), i
    InstructionCategory.logicalOperation(),
    0xFDE9,
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
    0xFDEA,
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
    0xFDEB,
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
    0xFDEC,
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
    0xFDED,
    5,
    'BII',
    <Operand>[
      Operand.mem1Imm16(0x0000),
      Operand.imm8(0x00),
    ],
    CyclesCount(20, 0),
  ),
  _illegalInstruction(0xFDEE),
  const InstructionDescriptor(
    // ADI #(ab), i
    InstructionCategory.logicalOperation(),
    0xFDEF,
    5,
    'ADI',
    <Operand>[
      Operand.mem1Imm16(0x0000),
      Operand.imm8(0x00),
    ],
    CyclesCount(23, 0),
  ),

  // 0xF0
  _illegalInstruction(0xFDF0),
  _illegalInstruction(0xFDF1),
  _illegalInstruction(0xFDF2),
  _illegalInstruction(0xFDF3),
  _illegalInstruction(0xFDF4),
  _illegalInstruction(0xFDF5),
  _illegalInstruction(0xFDF6),
  _illegalInstruction(0xFDF7),
  _illegalInstruction(0xFDF8),
  _illegalInstruction(0xFDF9),
  _illegalInstruction(0xFDFA),
  _illegalInstruction(0xFDFB),
  _illegalInstruction(0xFDFC),
  _illegalInstruction(0xFDFD),
  _illegalInstruction(0xFDFE),
  _illegalInstruction(0xFDFF),
];

// InstructionTable ...
final List<InstructionDescriptor> instructionTable = <InstructionDescriptor>[
  // 0x00
  const InstructionDescriptor(
    // SBC XL
    InstructionCategory.logicalOperation(),
    0x0000,
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
    0x0001,
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
    0x0002,
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
    0x0003,
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
    0x0004,
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
    0x0005,
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
    0x0006,
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
    0x0007,
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
    0x0008,
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
    0x0009,
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
    0x000A,
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
    0x000B,
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
    0x000C,
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
    0x000D,
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
    0x000E,
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
    0x000F,
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
    0x0010,
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
    0x0011,
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
    0x0012,
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
    0x0013,
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
    0x0014,
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
    0x0015,
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
    0x0016,
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
    0x0017,
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
    0x0018,
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
    0x0019,
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
    0x001A,
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
    0x001B,
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
    0x001C,
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
    0x001D,
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
    0x001E,
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
    0x001F,
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
    0x0020,
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
    0x0021,
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
    0x0022,
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
    0x0023,
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
    0x0024,
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
    0x0025,
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
    0x0026,
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
    0x0027,
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
    0x0028,
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
    0x0029,
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
    0x002A,
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
    0x002B,
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
    0x002C,
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
    0x002D,
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
    0x002E,
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
    0x002F,
    1,
    'BIT',
    <Operand>[
      Operand.mem0Reg('X'),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),

  // 0x30
  _illegalInstruction(0x0030),
  _illegalInstruction(0x0031),
  _illegalInstruction(0x0032),
  _illegalInstruction(0x0033),
  _illegalInstruction(0x0034),
  _illegalInstruction(0x0035),
  _illegalInstruction(0x0036),
  _illegalInstruction(0x0037),
  const InstructionDescriptor(
    // NOP
    InstructionCategory.inputOutput(),
    0x0038,
    1,
    'NOP',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(5, 0),
  ),
  _illegalInstruction(0x0039),
  _illegalInstruction(0x003A),
  _illegalInstruction(0x003B),
  _illegalInstruction(0x003C),
  _illegalInstruction(0x003D),
  _illegalInstruction(0x003E),
  _illegalInstruction(0x003F),

  // 0x40
  const InstructionDescriptor(
    // INC XL
    InstructionCategory.logicalOperation(),
    0x0040,
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
    0x0041,
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
    0x0042,
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
    0x0043,
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
    0x0044,
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
    0x0045,
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
    0x0046,
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
    0x0047,
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
    0x0048,
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
    0x0049,
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
    0x004A,
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
    0x004B,
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
    0x004C,
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
    0x004D,
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
    0x004E,
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
    0x004F,
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
    0x0050,
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
    0x0051,
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
    0x0052,
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
    0x0053,
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
    0x0054,
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
    0x0055,
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
    0x0056,
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
    0x0057,
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
    0x0058,
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
    0x0059,
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
    0x005A,
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
    0x005B,
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
    0x005C,
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
    0x005D,
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
    0x005E,
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
    0x005F,
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
    0x0060,
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
    0x0061,
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
    0x0062,
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
    0x0063,
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
    0x0064,
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
    0x0065,
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
    0x0066,
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
    0x0067,
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
    0x0068,
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
    0x0069,
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
    0x006A,
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
    0x006B,
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
    0x006C,
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
    0x006D,
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
    0x006E,
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
    0x006F,
    2,
    'ADI',
    <Operand>[
      Operand.mem0Reg('U'),
      Operand.imm8(0x00),
    ],
    CyclesCount(13, 0),
  ),

  // 0x70
  _illegalInstruction(0x0070),
  _illegalInstruction(0x0071),
  _illegalInstruction(0x0072),
  _illegalInstruction(0x0073),
  _illegalInstruction(0x0074),
  _illegalInstruction(0x0075),
  _illegalInstruction(0x0076),
  _illegalInstruction(0x0077),
  _illegalInstruction(0x0078),
  _illegalInstruction(0x0079),
  _illegalInstruction(0x007A),
  _illegalInstruction(0x007B),
  _illegalInstruction(0x007C),
  _illegalInstruction(0x007D),
  _illegalInstruction(0x007E),
  _illegalInstruction(0x007F),

  // 0x80
  const InstructionDescriptor(
    // SBC XH
    InstructionCategory.logicalOperation(),
    0x0080,
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
    0x0081,
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
    0x0082,
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
    0x0083,
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
    0x0084,
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
    0x0085,
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
    0x0086,
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
    0x0087,
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
    0x0088,
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
    0x0089,
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
    0x008A,
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
    0x008B,
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
    0x008C,
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
    0x008D,
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
    0x008E,
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
    0x008F,
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
    0x0090,
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
    0x0091,
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
    0x0092,
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
    0x0093,
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
    0x0094,
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
    0x0095,
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
    0x0096,
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
    0x0097,
    2,
    'BHS',
    <Operand>[
      Operand.dispMinus(0x00),
      Operand.none(),
    ],
    CyclesCount(9, 2),
  ),
  _illegalInstruction(0x0098),
  const InstructionDescriptor(
    // BZR -i
    InstructionCategory.branch(),
    0x0099,
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
    0x009A,
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
    0x009B,
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
    0x009C,
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
    0x009D,
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
    0x009E,
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
    0x009F,
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
    0x00A0,
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
    0x00A1,
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
    0x00A2,
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
    0x00A3,
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
    0x00A4,
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
    0x00A5,
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
    0x00A6,
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
    0x00A7,
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
    0x00A8,
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
    0x00A9,
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
    0x00AA,
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
    0x00AB,
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
    0x00AC,
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
    0x00AD,
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
    0x00AE,
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
    0x00AF,
    3,
    'BIT',
    <Operand>[
      Operand.mem0Imm16(0x0000),
      Operand.none(),
    ],
    CyclesCount(13, 0),
  ),

  // 0xB0
  _illegalInstruction(0x00B0),
  const InstructionDescriptor(
    // SBI A, i
    InstructionCategory.logicalOperation(),
    0x00B1,
    2,
    'SBI',
    <Operand>[
      Operand.reg('A'),
      Operand.imm8(0x00),
    ],
    CyclesCount(7, 0),
  ),
  _illegalInstruction(0x00B2),
  const InstructionDescriptor(
    // ADI A, i
    InstructionCategory.logicalOperation(),
    0x00B3,
    2,
    'ADI',
    <Operand>[
      Operand.reg('A'),
      Operand.imm8(0x00),
    ],
    CyclesCount(7, 0),
  ),
  _illegalInstruction(0x00B4),
  const InstructionDescriptor(
    // LDI A, i
    InstructionCategory.loadStore(),
    0x00B5,
    2,
    'LDI',
    <Operand>[
      Operand.reg('A'),
      Operand.imm8(0x00),
    ],
    CyclesCount(6, 0),
  ),
  _illegalInstruction(0x00B6),
  const InstructionDescriptor(
    // CPI A, i
    InstructionCategory.comparisonBitTest(),
    0x00B7,
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
    0x00B8,
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
    0x00B9,
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
    0x00BA,
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
    0x00BB,
    2,
    'ORI',
    <Operand>[
      Operand.reg('A'),
      Operand.imm8(0x00),
    ],
    CyclesCount(7, 0),
  ),
  _illegalInstruction(0x00BC),
  const InstructionDescriptor(
    // EAI i
    InstructionCategory.logicalOperation(),
    0x00BD,
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
    0x00BE,
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
    0x00BF,
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
    0x00C0,
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
    0x00C1,
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
    0x00C2,
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
    0x00C3,
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
    0x00C4,
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
    0x00C5,
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
    0x00C6,
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
    0x00C7,
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
    0x00C8,
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
    0x00C9,
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
    0x00CA,
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
    0x00CB,
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
    0x00CC,
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
    0x00CD,
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
    0x00CE,
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
    0x00CF,
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
    0x00D0,
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
    0x00D1,
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
    0x00D2,
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
    0x00D3,
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
    0x00D4,
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
    0x00D5,
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
    0x00D6,
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
    0x00D7,
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
    0x00D8,
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
    0x00D9,
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
    0x00DA,
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
    0x00DB,
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
    0x00DC,
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
    0x00DD,
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
    0x00DE,
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
    0x00DF,
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
    0x00E0,
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
    0x00E1,
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
    0x00E2,
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
    0x00E3,
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
    0x00E4,
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xE4),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  _illegalInstruction(0x0E5),
  const InstructionDescriptor(
    // VEJ (E6H)
    InstructionCategory.call(),
    0x00E6,
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xE6),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  _illegalInstruction(0x00E7),
  const InstructionDescriptor(
    // VEJ (E8H)
    InstructionCategory.call(),
    0x00E8,
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
    0x00E9,
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
    0x00EA,
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
    0x00EB,
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
    0x00EC,
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
    0x00ED,
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
    0x00EE,
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
    0x00EF,
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
    0x00F0,
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
    0x00F1,
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
    0x00F2,
    1,
    'VEJ',
    <Operand>[
      Operand.mem0Cst8(0xF2),
      Operand.none(),
    ],
    CyclesCount(17, 0),
  ),
  _illegalInstruction(0x00F3),
  const InstructionDescriptor(
    // VEJ (F4H)
    InstructionCategory.call(),
    0x00F4,
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
    0x00F5,
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
    0x00F6,
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
    0x00F7,
    1,
    'CIN',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(7, 0),
  ),
  _illegalInstruction(0x00F8),
  const InstructionDescriptor(
    // REC
    InstructionCategory.inputOutput(),
    0x00F9,
    1,
    'REC',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(4, 0),
  ),
  _illegalInstruction(0x00FA),
  const InstructionDescriptor(
    // SEC
    InstructionCategory.inputOutput(),
    0x00FB,
    1,
    'SEC',
    <Operand>[
      Operand.none(),
      Operand.none(),
    ],
    CyclesCount(4, 0),
  ),
  _illegalInstruction(0x00FC),
  _illegalInstruction(0x00FD),
  _illegalInstruction(0x00FE),
  _illegalInstruction(0x00FF),
];
