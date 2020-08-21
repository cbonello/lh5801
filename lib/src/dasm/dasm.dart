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

  int addressLength({
    Radix radix = const Radix.hexadecimal(),
    bool suffix = false,
  }) {
    final String address = addressToString(radix: radix, suffix: suffix);
    return address.length;
  }

  String bytesToString({
    Radix radix = const Radix.hexadecimal(),
    bool suffix = false,
  }) =>
      _formatBytes(descriptor.bytes, radix: radix, suffix: suffix);

  int bytesLength({
    Radix radix = const Radix.hexadecimal(),
    bool suffix = false,
  }) {
    final String address = bytesToString(radix: radix, suffix: suffix);
    return address.length;
  }

  String instructionToString({
    Radix radix = const Radix.hexadecimal(),
    bool suffix = false,
  }) =>
      descriptor.instructionToString(radix: radix, suffix: suffix);

  int instructionLength({
    Radix radix = const Radix.hexadecimal(),
    bool suffix = false,
  }) {
    final int length = radix.when<int>(
      binary: () =>
          'BII #(0011010001010110), 01111000'.length + (suffix ? 2 : 0),
      decimal: () => 'BII #(13398), 120'.length,
      hexadecimal: () => 'BII #(3456), 78'.length + (suffix ? 2 : 0),
    );
    return length;
  }

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
    final int byteStringSize = radix.when<int>(
      // 8 bits, one optional suffix and one space.
      binary: () => 8 + (suffix ? 1 : 0) + 1,
      // 3 digits, no suffix and one space.
      decimal: () => 3 + 1,
      // 8 hex digits, one optional suffix and one space.
      hexadecimal: () => 2 + (suffix ? 1 : 0) + 1,
    );
    // An instruction has up-to 5 bytes. -1 is to remove the trailing space
    // character.
    final int outputSize = 5 * byteStringSize - 1;

    for (int i = 0; i < bytes.length; i++) {
      output.write(
        '${OperandDump.op8(bytes[i], radix: radix, suffix: suffix)} ',
      );
    }

    return output.toString().padRight(outputSize).substring(0, outputSize);
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

      // Replaces generic operands with their actual value.
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
