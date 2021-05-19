const int kFrequency2Mhz = 2000000;
const int kFrequency1Mhz = 1000000;
const int kFrequency500Khz = 500000;
const int kFrequency250Khz = 250000;
const int kFrequency125Khz = 125000;
const int kFrequency62Khz = 62500;
const int kFrequency31Khz = 31250;

/* Not used for now
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
*/

abstract class _SubClock {
  void reset();
  void incrementClock(int cpuCycles) {}
  bool get isInterruptRaised;
}

class LH5801Timer implements _SubClock {
  LH5801Timer({
    required int cpuClockFrequency,
    required int timerClockFrequency,
  }) : _cpuCyclesPerTick = (cpuClockFrequency / timerClockFrequency).round() {
    _value = 0;
    _cpuCycles = 0;
    _interruptRaised = false;
  }

  LH5801Timer._({
    required int cpuCyclesPerTick,
    required int value,
    required int cpuCycles,
    required bool interruptRaised,
  })   : _cpuCyclesPerTick = cpuCyclesPerTick,
        _value = value,
        _cpuCycles = cpuCycles,
        _interruptRaised = interruptRaised;

  void restoreState(Map<String, dynamic> json) {
    _value = json['value'] as int;
    _cpuCycles = json['cpuCycles'] as int;
    _interruptRaised = json['interruptRaised'] as bool;
  }

  Map<String, dynamic> saveState() => <String, dynamic>{
        'value': _value,
        'cpuCycles': _cpuCycles,
        'interruptRaised': _interruptRaised,
      };

  late bool _interruptRaised;
  late int _value;
  late int _cpuCycles;

  // Number of CPU cycles during one timer clock-tick.
  final int _cpuCyclesPerTick;

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

  LH5801Timer clone() => LH5801Timer._(
        cpuCyclesPerTick: _cpuCyclesPerTick,
        value: _value,
        cpuCycles: _cpuCycles,
        interruptRaised: _interruptRaised,
      );

  @override
  bool incrementClock([int? cpuCycles]) {
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
  bool get isInterruptRaised {
    final bool isRaised = _interruptRaised;
    _interruptRaised = false;
    return isRaised;
  }

  @override
  String toString() =>
      'LH5801Timer(value: ${_value.toUnsigned(9).toRadixString(16).toUpperCase().padLeft(3, '0')}, interrupt: $_interruptRaised)';

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
