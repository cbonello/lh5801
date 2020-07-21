class LH5801Timer {
  LH5801Timer({int cpuClockFrequency, int timerClockFrequency})
      : _cpuCyclesPerTick =
            (cpuClockFrequency.toDouble() / timerClockFrequency.toDouble()).round() {
    _counterValue = 0;
    _cpuCycles = 0;
  }

  int _counterValue;
  // Number of CPU cycles during one timer clock tick.
  final int _cpuCyclesPerTick;
  int _cpuCycles;

  static const int maxCounterValue = 0x1FF;

  int get counterValue => _counterValue;

  bool set(int v) {
    _counterValue = v;
    return _counterValue == maxCounterValue;
  }

  bool incrementClock([int cpuCycles]) {
    final int cpuCyclesIncrenment = cpuCycles ?? _cpuCyclesPerTick;
    if (_cpuCycles + cpuCyclesIncrenment >= _cpuCyclesPerTick) {
      _cpuCycles = (_cpuCycles + cpuCyclesIncrenment) % _cpuCyclesPerTick;
      // The LH5801 timer is a 9-bit linear-feedback shift register with taps at bits 9 and 3.
      final int nextValue = ((_counterValue << 1) & 0x1FE) |
          (((_counterValue >> 8) ^ (_counterValue >> 3)) & 1);
      return set(nextValue);
    }
    return false;
  }
}
