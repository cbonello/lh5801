import 'package:meta/meta.dart';

import 'processor.dart';

/// Return the byte at the given memory address.
typedef LH5801MemoryRead = int Function(int address);

/// Write the given 8-bit byte value to the given memory address.
typedef LH5801MemoryWrite = void Function(int address, int value);

class LH5801Processor extends LH5801Pins {
  LH5801Processor({
    @required int clockFrequency,
    @required LH5801MemoryRead memRead,
    @required LH5801MemoryWrite memWrite,
  })  : assert(memRead != null),
        assert(memWrite != null) {
    cpu = LH5801CPU(
      pins: this,
      clockFrequency: clockFrequency,
      memRead: memRead,
      memWrite: memWrite,
    );
  }

  LH5801Processor._();

  factory LH5801Processor.fromJson({
    @required int clockFrequency,
    @required LH5801MemoryRead memRead,
    @required LH5801MemoryWrite memWrite,
    @required Map<String, dynamic> json,
  }) {
    final LH5801Processor lh5801 = LH5801Processor._()
      ..inputPorts = json['inputPorts'] as int
      ..resetPin = json['resetPin'] as bool
      ..nmiPin = json['nmiPin'] as bool
      ..miPin = json['miPin'] as bool
      ..puFlipflop = json['puFlipflop'] as bool
      ..pvFlipflop = json['pvFlipflop'] as bool
      ..bfFlipflop = json['bfFlipflop'] as bool
      ..dispFlipflop = json['dispFlipflop'] as bool;

    final LH5801CPU cpu = LH5801CPU.fromJson(
      pins: lh5801,
      clockFrequency: clockFrequency,
      memRead: memRead,
      memWrite: memWrite,
      json: json['cpu'] as Map<String, dynamic>,
    );

    return lh5801..cpu = cpu;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'inputPorts': inputPorts,
        'resetPin': resetPin,
        'nmiPin': nmiPin,
        'miPin': miPin,
        'puFlipflop': puFlipflop,
        'pvFlipflop': pvFlipflop,
        'bfFlipflop': bfFlipflop,
        'dispFlipflop': dispFlipflop,
        'cpu': cpu.toJson(),
      };

  LH5801CPU cpu;

  int step(int address) {
    cpu.p.value = address;
    return cpu.step();
  }

  void reset() => cpu.reset();
}
