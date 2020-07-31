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
  void incrementClock(int cpuCycles) {}
  bool get isInterruptRaised;
}

class LH5801Timer implements _SubClock {
  LH5801Timer({int cpuClockFrequency, int timerClockFrequency})
      : _cpuCyclesPerTick = (cpuClockFrequency / timerClockFrequency).round() {
    _value = 0;
    _cpuCycles = 0;
    _interruptRaised = false;
  }

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
}
