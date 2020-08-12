import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lh5801/lh5801.dart';
import 'package:meta/meta.dart';

import '../common/common.dart';
import 'cpu.dart';
import 'pins.dart';

part 'emulator.freezed.dart';

@freezed
abstract class PinType with _$PinType {
  const factory PinType.reset() = _Reset;
  const factory PinType.nmi() = _NMI;
  const factory PinType.mi() = _MI;
  const factory PinType.pu() = _PU;
  const factory PinType.pv() = _PV;
  const factory PinType.bf() = _BF;
  const factory PinType.disp() = _Disp;
}

@freezed
abstract class InterruptType with _$InterruptType {
  const factory InterruptType.ir0() = _IR0;
  const factory InterruptType.ir1() = _IR1;
  const factory InterruptType.ir2() = _IR2;
}

abstract class LH5801EmulatorDebugEvents {
  void resetEvt();
  void haltEvt();

  void puFlipflopEvt({bool pu});
  void pvFlipflopEvt({bool pv});
  void bfFlipflopEvt({bool bf});
  void dispFlipflopEvt({bool disp});

  void interruptEnterEvt(InterruptType type);
  void interruptExitEvt();

  void subroutineEnterEvt();
  void subroutineExitEvt();
}

abstract class LH5801EmulatorDebugAPI {
  LH5801State get state;
  LH5801Pins get pins;

  void setPinHigh(PinType pin);
  void setPinLow(PinType pin);
  void setInputPorts(int value);

  int step({int address});

  void reset();
}

class LH5801Emulator extends LH5801Pins implements LH5801EmulatorDebugAPI {
  LH5801Emulator({
    @required int clockFrequency,
    @required LH5801MemoryRead memRead,
    @required LH5801MemoryWrite memWrite,
    this.debugCallback,
  })  : assert(memRead != null),
        assert(memWrite != null) {
    cpu = LH5801CPU(
      pins: this,
      clockFrequency: clockFrequency,
      memRead: memRead,
      memWrite: memWrite,
      debugCallback: debugCallback,
    )..reset();
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
  LH5801EmulatorDebugEvents debugCallback;

  @override
  LH5801Pins get pins => clone();

  @override
  LH5801State get state => cpu.clone();

  @override
  void setPinHigh(PinType pin) {
    pin.maybeWhen<void>(
      reset: () => resetPin = true,
      nmi: () => nmiPin = true,
      mi: () => miPin = true,
      bf: () => bfFlipflop = false,
      orElse: () => throw LH5801Error('Read-only pin'),
    );
  }

  @override
  void setPinLow(PinType pin) {
    pin.maybeWhen<void>(
      reset: () => null,
      nmi: () => null,
      mi: () => null,
      bf: () => bfFlipflop = true,
      orElse: () => throw LH5801Error('Read-only pin'),
    );
  }

  @override
  void setInputPorts(int value) {
    inputPorts = value;
  }

  @override
  int step({int address}) {
    cpu.p.value = address ?? cpu.p.value;
    return cpu.step();
  }

  @override
  void reset() {
    super.reset();
    cpu.reset();
  }
}
