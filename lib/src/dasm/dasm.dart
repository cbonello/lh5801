import 'package:meta/meta.dart';

import '../../lh5801.dart';

class Instruction {
  Instruction({@required this.address, @required this.descriptor});

  final int address;
  final InstructionDescriptor descriptor;
}

class LH5801DASM {
  LH5801DASM({
    @required LH5801MemoryRead memRead,
  })  : assert(memRead != null),
        _memRead = memRead;

  final LH5801MemoryRead _memRead;

  Instruction dump(int address) {
    final List<int> updatedOpcodes = <int>[];
    int addr = address;

    int readOp8() {
      final int value = _memRead(addr++);
      updatedOpcodes.add(value);
      return value;
    }

    int readOp16() {
      final int high = _memRead(addr++);
      final int low = _memRead(addr++);
      return high << 8 | low;
    }

    final int opcode = readOp8();

    final InstructionDescriptor descriptor =
        opcode == 0xFD ? instructionTableFD[readOp8()] : instructionTable[opcode];

    final List<Operand> updatedOperands = <Operand>[];

    for (int i = 0; i < descriptor.operands.length; i++) {
      final Operand operand = descriptor.operands[i];

      // Replaces the generic operand values with their actual value.
      updatedOperands.add(
        operand.maybeWhen(
          mem0Imm16: (_) => Operand.mem0Imm16(readOp16()),
          mem1Imm16: (_) => Operand.mem1Imm16(readOp16()),
          imm8: (_) => Operand.imm8(readOp8()),
          dispPlus: (_) => Operand.dispPlus(readOp8()),
          dispMinus: (_) => Operand.dispMinus(readOp8()),
          imm16: (_) => Operand.imm16(readOp16()),
          orElse: () => operand,
        ),
      );
    }

    assert(updatedOpcodes.length == descriptor.size);

    return Instruction(
      address: address,
      descriptor: descriptor.copyWith(
        updatedOpcodes: updatedOpcodes,
        updatedOperands: updatedOperands,
      ),
    );
  }
}
