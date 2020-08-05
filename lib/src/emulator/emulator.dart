import 'package:meta/meta.dart';

import '../common/common.dart';
import 'cpu.dart';
import 'pins.dart';

class LH5801Emulator extends LH5801Pins {
  LH5801Emulator({
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

  LH5801Emulator._();

  factory LH5801Emulator.fromJson({
    @required int clockFrequency,
    @required LH5801MemoryRead memRead,
    @required LH5801MemoryWrite memWrite,
    @required Map<String, dynamic> json,
  }) {
    final LH5801Emulator lh5801 = LH5801Emulator._()
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

  int step([int address]) {
    cpu.p.value = address ?? cpu.p.value;
    return cpu.step();
  }

  @override
  void reset() {
    super.reset();
    cpu.reset();
  }
}
