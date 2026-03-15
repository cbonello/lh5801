import '../../lh5801.dart';

class Instruction {
  Instruction({required this.address, required this.descriptor});

  final int address;
  final InstructionDescriptor descriptor;

  String addressToString({
    Radix radix = Radix.hexadecimal,
    bool suffix = false,
  }) => OperandDump.op16(address, radix: radix, suffix: suffix);

  /// Return the maximum length of the address field for given arguments.
  /// Usefull for tabulating the disassembly listing.
  static int addressLength({
    Radix radix = Radix.hexadecimal,
    bool suffix = false,
  }) {
    final String address = OperandDump.op16(
      0x1FFFF,
      radix: radix,
      suffix: suffix,
    );

    return address.length;
  }

  String bytesToString({
    Radix radix = Radix.hexadecimal,
    bool suffix = false,
  }) => _formatBytes(descriptor.bytes, radix: radix, suffix: suffix);

  /// Return the maximum length of the bytes field for given arguments.
  /// Usefull for tabulating the disassembly listing.
  static int bytesLength({
    Radix radix = Radix.hexadecimal,
    bool suffix = false,
  }) {
    final int byteStringSize = switch (radix) {
      Radix.binary => 8 + (suffix ? 1 : 0) + 1,
      Radix.decimal => 3 + 1,
      Radix.hexadecimal => 2 + (suffix ? 1 : 0) + 1,
    };

    // An instruction has up-to 5 bytes. -1 is to remove the trailing space
    // character.
    return 5 * byteStringSize - 1;
  }

  String instructionToString({
    Radix radix = Radix.hexadecimal,
    bool suffix = false,
  }) => descriptor.instructionToString(radix: radix, suffix: suffix);

  /// Return the maximum length of the instruction field for given arguments.
  /// Usefull for tabulating the disassembly listing.
  static int instructionLength({
    Radix radix = Radix.hexadecimal,
    bool suffix = false,
  }) {
    // 'BII #(ab), i' is encoded in 5 bytes; it's the biggest LH5801 instruction.
    final int length = switch (radix) {
      Radix.binary =>
          'BII #(0011010001010110), 01111000'.length + (suffix ? 2 : 0),
      Radix.decimal => 'BII #(13398), 120'.length,
      Radix.hexadecimal => 'BII #(3456), 78'.length + (suffix ? 2 : 0),
    };

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
    Radix radix = Radix.hexadecimal,
    bool suffix = false,
  }) {
    final StringBuffer output = StringBuffer();
    final int byteStringSize = switch (radix) {
      Radix.binary => 8 + (suffix ? 1 : 0) + 1,
      Radix.decimal => 3 + 1,
      Radix.hexadecimal => 2 + (suffix ? 1 : 0) + 1,
    };
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
  LH5801DASM({required LH5801MemoryRead memRead}) : _memRead = memRead;

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
      updatedOperands.add(switch (operand) {
        OperandImm8() => Operand.imm8(readOp8()),
        OperandImm16() => Operand.imm16(readOp16()),
        OperandMem0Imm16() => Operand.mem0Imm16(readOp16()),
        OperandMem1Imm16() => Operand.mem1Imm16(readOp16()),
        OperandDispPlus() => Operand.dispPlus(readOp8()),
        OperandDispMinus() => Operand.dispMinus(readOp8()),
        _ => operand,
      });
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
