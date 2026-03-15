import 'package:lh5801/lh5801.dart';

abstract class LH5801Command {
  void execute();
}

class LH5801 {
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
  }) : pins = LH5801Pins() {
    cpu = LH5801CPU(
      pins: pins,
      clockFrequency: clockFrequency,
      memRead: memRead,
      memWrite: memWrite,
      ir0Enter: ir0Enter,
      ir1Enter: ir1Enter,
      ir2Enter: ir2Enter,
      irExit: irExit,
      subroutineEnter: subroutineEnter,
      subroutineExit: subroutineExit,
    )..reset();
  }

  void restoreState(Map<String, dynamic> state) {
    if (cpu.clockFrequency != state['clockFrequency'] as int) {
      throw LH5801Error(
        'clock frequency mismatch: expected ${cpu.clockFrequency}, '
        'got ${state['clockFrequency']}',
      );
    }

    pins.resetPin = state['resetPin'] as bool;
    pins.nmiPin = state['nmiPin'] as bool;
    pins.miPin = state['miPin'] as bool;
    pins.puFlipflop = state['puFlipflop'] as bool;
    pins.pvFlipflop = state['pvFlipflop'] as bool;
    pins.bfFlipflop = state['bfFlipflop'] as bool;
    pins.dispFlipflop = state['dispFlipflop'] as bool;
    pins.inputPorts = state['inputPorts'] as int;
    cpu.restoreState(state['cpu'] as Map<String, dynamic>);
  }

  Map<String, dynamic> saveState() => <String, dynamic>{
    'clockFrequency': cpu.clockFrequency,
    'resetPin': pins.resetPin,
    'nmiPin': pins.nmiPin,
    'miPin': pins.miPin,
    'puFlipflop': pins.puFlipflop,
    'pvFlipflop': pins.pvFlipflop,
    'bfFlipflop': pins.bfFlipflop,
    'dispFlipflop': pins.dispFlipflop,
    'inputPorts': pins.inputPorts,
    'cpu': cpu.saveState(),
  };

  late LH5801CPU cpu;
  final LH5801Pins pins;
  final LH5801Command? ir0Enter;
  final LH5801Command? ir1Enter;
  final LH5801Command? ir2Enter;
  final LH5801Command? irExit;
  final LH5801Command? subroutineEnter;
  final LH5801Command? subroutineExit;

  LH5801State get state => cpu.clone();

  int step({int? address}) {
    cpu.p.value = address ?? cpu.p.value;

    return cpu.step();
  }

  void reset() {
    pins.reset();
    cpu.reset();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LH5801 &&
          runtimeType == other.runtimeType &&
          pins == other.pins &&
          cpu == other.cpu;

  @override
  int get hashCode => pins.hashCode ^ cpu.hashCode;
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
    required super.clockFrequency,
    required super.memRead,
    required super.memWrite,
    super.ir0Enter,
    super.ir1Enter,
    super.ir2Enter,
    super.irExit,
    super.subroutineEnter,
    super.subroutineExit,
  }) : traces = <Trace>[];

  final List<Trace> traces;

  @override
  int step({int? address}) {
    cpu.p.value = address ?? cpu.p.value;

    return cpu.step(_logger);
  }

  void _logger(Instruction instruction, LH5801Pins pins, LH5801State state) =>
      traces.add(Trace(instruction, pins, state));
}
