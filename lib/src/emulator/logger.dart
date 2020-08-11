import '../../lh5801.dart';

typedef LoggerCallback = void Function(LoggerData data);

class LoggerData {
  LoggerData(this.instruction, this.pins, this.state);

  final Instruction instruction;
  final LH5801Pins pins;
  final LH5801State state;

  @override
  String toString() {
    final StringBuffer output = StringBuffer();

    output.write('${OperandDump.op16(instruction.address)}  ');
    output.write('${_formatOpcodes(instruction.descriptor.opcodes)}  ');
    output.writeln(instruction.descriptor);

    output.writeln(pins);

    output.writeln(state);

    return output.toString();
  }

  String _formatOpcodes(List<int> opcodes) {
    final StringBuffer output = StringBuffer();

    for (int i = 0; i < opcodes.length; i++) {
      output.write(
        '${opcodes[i].toUnsigned(8).toRadixString(16).toUpperCase().padLeft(2, '0')} ',
      );
    }

    // An instruction has at most 4 bytes.
    return output.toString().padRight(12);
  }
}
