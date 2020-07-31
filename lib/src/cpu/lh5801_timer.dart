import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'lh5801_timer.g.dart';

const int clockFrequency2Mhz = 2000000;
const int clockFrequency1Mhz = 1000000;
const int clockFrequency500Khz = 500000;
const int clockFrequency250Khz = 250000;
const int clockFrequency125Khz = 125000;
const int clockFrequency62Khz = 62500;
const int clockFrequency31Khz = 31250;

class LH5801ClockControl {
  LH5801ClockControl() : _subClocks = <_SubClock>[];

  final List<_SubClock> _subClocks;

  void addSubClock(_SubClock subClock) => _subClocks.add(subClock);

  void incrementClocks(int cpuCycles) {
    for (final _SubClock subClock in _subClocks) {
      subClock.incrementClock(cpuCycles);
    }
  }
}

abstract class _SubClock {
  void reset();
  void incrementClock(int cpuCycles) {}
  bool get isInterruptRaised;
}

@JsonSerializable(
  createFactory: true,
  disallowUnrecognizedKeys: true,
)
class LH5801Timer implements _SubClock {
  LH5801Timer({@required int cpuClockFrequency, @required int timerClockFrequency})
      : _cpuCyclesPerTick = (cpuClockFrequency / timerClockFrequency).round() {
    _value = 0;
    _cpuCycles = 0;
    _interruptRaised = false;
  }

  factory LH5801Timer.fromJson(Map<String, dynamic> json) => _$LH5801TimerFromJson(json);

  Map<String, dynamic> toJson() => _$LH5801TimerToJson(this);

  int _value;
  // Number of CPU cycles during one timer clock tick.
  final int _cpuCyclesPerTick;
  int _cpuCycles;
  bool _interruptRaised;

  static const int maxCounterValue = 0x1FF;

  int get value => _value;

  set value(int value) {
    _value = value;
    _interruptRaised = value == 0x1FF;
  }

  @override
  void reset() {
    _cpuCycles = 0;
    _interruptRaised = false;
  }

  @override
  bool incrementClock([int cpuCycles]) {
    final int cpuCyclesIncrenment = cpuCycles ?? _cpuCyclesPerTick;
    if (_cpuCycles + cpuCyclesIncrenment >= _cpuCyclesPerTick) {
      _cpuCycles = (_cpuCycles + cpuCyclesIncrenment) % _cpuCyclesPerTick;
      // The LH5801 timer is a 9-bit linear-feedback shift register with taps at bits 9 and 3.
      final int nextValue =
          ((_value << 1) & 0x1FE) | (((_value >> 8) ^ (_value >> 3)) & 1);
      value = nextValue;
      return _interruptRaised;
    }
    return false;
  }

  @override
  bool get isInterruptRaised => _interruptRaised;

  @override
  String toString() =>
      'LH5801Timer(value: $_value, isInterruptRaised: $_interruptRaised)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LH5801Timer &&
          runtimeType == other.runtimeType &&
          _value == other._value &&
          _cpuCyclesPerTick == other._cpuCyclesPerTick &&
          _cpuCycles == other._cpuCycles &&
          _interruptRaised == other._interruptRaised;

  @override
  int get hashCode =>
      _value.hashCode ^
      _cpuCyclesPerTick.hashCode ^
      _cpuCycles.hashCode ^
      _interruptRaised.hashCode;
}
