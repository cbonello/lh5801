import 'package:meta/meta.dart';

import '../../lh5801.dart';

class Instruction {
  Instruction({@required this.address, @required this.descriptor});

  final int address;
  final InstructionDescriptor descriptor;

  String addressToString({
    Radix radix = const Radix.hexadecimal(),
    bool suffix = false,
  }) =>
      OperandDump.op16(address, radix: radix, suffix: suffix);

  String bytesToString({
    Radix radix = const Radix.hexadecimal(),
    bool suffix = false,
  }) =>
      _formatBytes(descriptor.bytes, radix: radix, suffix: suffix);

  String instructionToString({
    Radix radix = const Radix.hexadecimal(),
    bool suffix = false,
  }) =>
      descriptor.instructionToString(radix: radix, suffix: suffix);

  @override
  String toString() {
    final StringBuffer output = StringBuffer();

    output.write('${addressToString()}  ');
    output.write('${_formatBytes(descriptor.bytes)}  ');
    output.write(descriptor);
    return output.toString();
  }

  String _formatBytes(
    List<int> bytes, {
    Radix radix = const Radix.hexadecimal(),
    bool suffix = false,
  }) {
    final StringBuffer output = StringBuffer();

    for (int i = 0; i < bytes.length; i++) {
      output.write(OperandDump.op8(bytes[i], radix: radix, suffix: suffix));
      if (i < bytes.length - 1) output.write(' ');
    }

    // An instruction has at most 5 bytes. '-1' to remove trailing space.
    return output.toString().padRight(5 * 3 - 1);
  }
}

class LH5801DASM {
  LH5801DASM({@required LH5801MemoryRead memRead})
      : assert(memRead != null),
        _memRead = memRead;

  final LH5801MemoryRead _memRead;

  Instruction dump(int address) {
    final List<int> updatedBytes = <int>[];
    int addr = address;

    int readOp8() {
      final int value = _memRead(addr++);
      updatedBytes.add(value);
      return value;
    }

    int readOp16() {
      final int high = readOp8();
      final int low = readOp8();
      return high << 8 | low;
    }

    final int opcode = readOp8();

    final InstructionDescriptor descriptor = opcode == 0xFD
        ? instructionTableFD[readOp8()]
        : instructionTable[opcode];

    final List<Operand> updatedOperands = <Operand>[];

    for (int i = 0; i < descriptor.operands.length; i++) {
      final Operand operand = descriptor.operands[i];

      // Replaces the generic operand values with their actual value.
      updatedOperands.add(
        operand.maybeWhen(
          imm8: (_) => Operand.imm8(readOp8()),
          imm16: (_) => Operand.imm16(readOp16()),
          mem0Imm16: (_) => Operand.mem0Imm16(readOp16()),
          mem1Imm16: (_) => Operand.mem1Imm16(readOp16()),
          dispPlus: (_) => Operand.dispPlus(readOp8()),
          dispMinus: (_) => Operand.dispMinus(readOp8()),
          orElse: () => operand,
        ),
      );
    }

    assert(updatedBytes.length == descriptor.size);

    return Instruction(
      address: address,
      descriptor: descriptor.copyWith(
        updatedBytes: updatedBytes,
        updatedOperands: updatedOperands,
      ),
    );
  }
}
