import 'package:lh5801/lh5801.dart';

import '../common/common.dart';
import 'cpu.dart';
import 'pins.dart';

abstract class LH5801Command {
  void execute() => throw UnimplementedError();
}

class LH5801 extends LH5801Pins {
  LH5801({
    required int clockFrequency,
    required LH5801MemoryRead memRead,
    required LH5801MemoryWrite memWrite,
    this.ir0Enter,
    this.ir1Enter,
    this.ir2Enter,
    this.irExit,
    this.subroutineEnter,
    this.subroutineExit,
  }) {
    cpu = LH5801CPU(
      pins: this,
      clockFrequency: clockFrequency,
      memRead: memRead,
      memWrite: memWrite,
    )..reset();
  }

  void restoreState(Map<String, dynamic> state) {
    if (cpu.clockFrequency != state['clockFrequency'] as int) {
      throw Exception();
    }

    resetPin = state['resetPin'] as bool;
    nmiPin = state['nmiPin'] as bool;
    miPin = state['miPin'] as bool;
    puFlipflop = state['puFlipflop'] as bool;
    pvFlipflop = state['pvFlipflop'] as bool;
    bfFlipflop = state['bfFlipflop'] as bool;
    dispFlipflop = state['dispFlipflop'] as bool;
    inputPorts = state['inputPorts'] as int;
    cpu.restoreState(state['cpu'] as Map<String, dynamic>);
  }

  Map<String, dynamic> saveState() => <String, dynamic>{
        'clockFrequency': cpu.clockFrequency,
        'resetPin': resetPin,
        'nmiPin': nmiPin,
        'miPin': miPin,
        'puFlipflop': puFlipflop,
        'pvFlipflop': pvFlipflop,
        'bfFlipflop': bfFlipflop,
        'dispFlipflop': dispFlipflop,
        'inputPorts': inputPorts,
        'cpu': cpu.saveState(),
      };

  late LH5801CPU cpu;
  final LH5801Command? ir0Enter;
  final LH5801Command? ir1Enter;
  final LH5801Command? ir2Enter;
  final LH5801Command? irExit;
  final LH5801Command? subroutineEnter;
  final LH5801Command? subroutineExit;

  LH5801Pins get pins => clone();

  LH5801State get state => cpu.clone();

  int step({int? address}) {
    cpu.p.value = address ?? cpu.p.value;
    return cpu.step();
  }

  @override
  void reset() {
    super.reset(); // Reset pins.
    cpu.reset(); // Reset registers.
  }
}

class Trace {
  Trace(this.instruction, this.pins, this.state);

  final Instruction instruction;
  final LH5801Pins pins;
  final LH5801State state;

  @override
  String toString() {
    final StringBuffer output = StringBuffer();

    output.writeln(instruction);
    output.writeln(pins);
    output.writeln(state);

    return output.toString();
  }
}

class LH5801Traced extends LH5801 {
  LH5801Traced({
    required int clockFrequency,
    required LH5801MemoryRead memRead,
    required LH5801MemoryWrite memWrite,
    LH5801Command? ir0Enter,
    LH5801Command? ir1Enter,
    LH5801Command? ir2Enter,
    LH5801Command? irExit,
    LH5801Command? subroutineEnter,
    LH5801Command? subroutineExit,
  })  : traces = <Trace>[],
        super(
          clockFrequency: clockFrequency,
          memRead: memRead,
          memWrite: memWrite,
          ir0Enter: ir0Enter,
          ir1Enter: ir1Enter,
          ir2Enter: ir2Enter,
          irExit: irExit,
          subroutineEnter: subroutineEnter,
          subroutineExit: subroutineExit,
        );

  final List<Trace> traces;

  @override
  int step({int? address}) {
    cpu.p.value = address ?? cpu.p.value;
    return cpu.step(_logger);
  }

  void _logger(Instruction instruction, LH5801Pins pins, LH5801State state) =>
      traces.add(Trace(instruction, pins, state));
}
