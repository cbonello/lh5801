class _CPUPin {
  _CPUPin({this.resetUponRead = false, bool pin = false}) : _pin = pin;

  final bool resetUponRead;
  bool _pin;

  bool get pin {
    final bool value = _pin;
    if (resetUponRead) {
      _pin = false;
    }
    return value;
  }

  bool get peek => _pin;

  set pin(bool value) => _pin = value;

  _CPUPin clone() => _CPUPin(resetUponRead: resetUponRead, pin: _pin);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CPUPin &&
          runtimeType == other.runtimeType &&
          resetUponRead == other.resetUponRead &&
          _pin == other._pin;

  @override
  int get hashCode => resetUponRead.hashCode ^ _pin.hashCode;
}

class LH5801Pins {
  LH5801Pins();

  final _CPUPin _resetPin = _CPUPin(resetUponRead: true);
  final _CPUPin _nmiPin = _CPUPin(resetUponRead: true);
  final _CPUPin _miPin = _CPUPin(resetUponRead: true);
  final _CPUPin _puFlipflop = _CPUPin();
  final _CPUPin _pvFlipflop = _CPUPin();
  final _CPUPin _bfFlipflop = _CPUPin(pin: true);
  final _CPUPin _dispFlipflop = _CPUPin();

  /// Input ports through which the CPU receives 8-bit data into the accumulator.
  int inputPorts;

  /// CPU reset.
  bool get resetPin => _resetPin.pin;
  set resetPin(bool value) => _resetPin.pin = value;

  /// Non-maskable interrupt input (NMI).
  bool get nmiPin => _nmiPin.pin;
  set nmiPin(bool value) => _nmiPin.pin = value;

  /// Maskable interrupt input (MI).
  bool get miPin => _miPin.pin;
  set miPin(bool value) => _miPin.pin = value;

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

  void reset() {
    resetPin = nmiPin = miPin = puFlipflop = pvFlipflop = dispFlipflop = false;
    bfFlipflop = true;
  }

  LH5801Pins clone() => LH5801Pins()
    ..resetPin = _resetPin.peek
    ..nmiPin = _nmiPin.peek
    ..miPin = _miPin.peek
    ..puFlipflop = puFlipflop
    ..pvFlipflop = pvFlipflop
    ..bfFlipflop = bfFlipflop
    ..dispFlipflop = dispFlipflop
    ..inputPorts = inputPorts;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LH5801Pins &&
          runtimeType == other.runtimeType &&
          // Using the _CPUPin.pin getter will reset the pin value. And the two
          // objects won't be identical anymore after performing the equality
          // test.
          _resetPin.peek == other._resetPin.peek &&
          _nmiPin.peek == other._nmiPin.peek &&
          _miPin.peek == other._miPin.peek &&
          puFlipflop == other.puFlipflop &&
          pvFlipflop == other.pvFlipflop &&
          bfFlipflop == other.bfFlipflop &&
          dispFlipflop == other.dispFlipflop &&
          inputPorts == other.inputPorts;

  @override
  int get hashCode =>
      _resetPin.hashCode ^
      _nmiPin.hashCode ^
      _miPin.hashCode ^
      _puFlipflop.hashCode ^
      _pvFlipflop.hashCode ^
      _bfFlipflop.hashCode ^
      _dispFlipflop.hashCode ^
      inputPorts.hashCode;
}
