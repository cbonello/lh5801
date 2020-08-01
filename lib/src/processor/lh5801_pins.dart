class _CPUPin {
  _CPUPin({bool resetUponRead = false})
      : _resetUponRead = resetUponRead,
        pin = false;

  final bool _resetUponRead;
  bool pin;

  void set() => pin = true;
  void reset() => pin = false;

  bool get isHigh {
    final bool isHigh = pin;
    if (_resetUponRead) {
      reset();
    }
    return isHigh;
  }

  bool get isLow => pin == false;
}

class LH5801Pins {
  LH5801Pins()
      : _resetPin = _CPUPin(resetUponRead: true),
        _nmiPin = _CPUPin(resetUponRead: true),
        _miPin = _CPUPin(resetUponRead: true),
        _puFlipflop = _CPUPin(),
        _pvFlipflop = _CPUPin(),
        _bfFlipflop = _CPUPin(),
        _dispFlipflop = _CPUPin();

  final _CPUPin _resetPin, _nmiPin, _miPin;
  final _CPUPin _puFlipflop, _pvFlipflop, _bfFlipflop, _dispFlipflop;

  /// Input ports through which the CPU receives 8-bit data into the accumulator.
  int inputPorts;

  /// CPU reset.
  void setResetPinHigh() => _resetPin.set();
  bool get isResetPinHigh => _resetPin.isHigh;

  /// Non-maskable interrupt input (NMI).
  void setNMIPinHigh() => _nmiPin.set();
  bool get isNMIPinHigh => _nmiPin.isHigh;

  /// Maskable interrupt input (MI).
  void setMIPinHigh() => _miPin.set();
  bool get isMIPinHigh => _miPin.isHigh;

  /// CPU internal PU flipflop output.
  bool get puFlipflop => _puFlipflop.pin;
  set puFlipflop(bool value) => _puFlipflop.pin = value;

  /// CPU internal PV flipflop output.
  bool get pvFlipflop => _pvFlipflop.pin;
  set pvFlipflop(bool value) => _pvFlipflop.pin = value;

  /// CPU internal BF flipflops.
  bool get bfFlipflop => _bfFlipflop.pin;
  set bfFlipflop(bool value) => _bfFlipflop.pin = value;

  /// LCD on/off control signal output.
  bool get dispFlipflop => _dispFlipflop.pin;
  set dispFlipflop(bool value) => _dispFlipflop.pin = value;
}
