import 'package:lh5801/src/common/common.dart';

mixin LH5801PinsObservable {
  bool registerPinsObserver(LH5801PinsObserver observer) =>
      throw UnimplementedError();
  void notifyPinsObservers() => throw UnimplementedError();
}

mixin LH5801PinsObserver {
  void update(LH5801Pins pins) => throw UnimplementedError;
}

class LH5801Pins with LH5801PinsObservable {
  LH5801Pins() : _observers = <LH5801PinsObserver>{} {
    reset();
  }

  /// CPU reset.
  bool _resetPin;

  /// Non-maskable interrupt input (NMI).
  bool _nmiPin;

  /// Maskable interrupt input (MI).
  bool _miPin;

  /// CPU internal PU flipflop output.
  bool _puFlipflop;

  /// CPU internal PV flipflop output.
  bool _pvFlipflop;

  /// CPU internal BF flipflops.
  bool _bfFlipflop;

  /// LCD on/off control signal output.
  bool _dispFlipflop;

  /// Input ports through which the CPU receives 8-bit data into the accumulator.
  int _inputPorts;

  final Set<LH5801PinsObserver> _observers;

  bool get resetPin => _resetPin;
  set resetPin(bool value) {
    _resetPin = value;
    notifyPinsObservers();
  }

  bool isResetUpdated(LH5801Pins other) => _resetPin != other._resetPin;

  bool get nmiPin => _nmiPin;
  set nmiPin(bool value) {
    _nmiPin = value;
    notifyPinsObservers();
  }

  bool isNMIUpdated(LH5801Pins other) => _nmiPin != other._nmiPin;

  bool get miPin => _miPin;
  set miPin(bool value) {
    _miPin = value;
    notifyPinsObservers();
  }

  bool isMIUpdated(LH5801Pins other) => _miPin != other._miPin;

  bool get puFlipflop => _puFlipflop;
  set puFlipflop(bool value) {
    _puFlipflop = value;
    notifyPinsObservers();
  }

  bool isPUUpdated(LH5801Pins other) => _puFlipflop != other._puFlipflop;

  bool get pvFlipflop => _pvFlipflop;
  set pvFlipflop(bool value) {
    _pvFlipflop = value;
    notifyPinsObservers();
  }

  bool isPVUpdated(LH5801Pins other) => _pvFlipflop != other._pvFlipflop;

  bool get bfFlipflop => _bfFlipflop;
  set bfFlipflop(bool value) {
    _bfFlipflop = value;
    notifyPinsObservers();
  }

  bool isBFUpdated(LH5801Pins other) => _bfFlipflop != other._bfFlipflop;

  bool get dispFlipflop => _dispFlipflop;
  set dispFlipflop(bool value) {
    _dispFlipflop = value;
    notifyPinsObservers();
  }

  bool isDispUpdated(LH5801Pins other) => _dispFlipflop != other._dispFlipflop;

  int get inputPorts => _inputPorts;
  set inputPorts(int value) {
    _inputPorts = value;
    notifyPinsObservers();
  }

  bool areInputPortspUpdated(LH5801Pins other) =>
      _inputPorts != other._inputPorts;

  void reset() {
    _resetPin =
        _nmiPin = _miPin = _puFlipflop = _pvFlipflop = _dispFlipflop = false;
    _bfFlipflop = true;
    _inputPorts = 0;
    notifyPinsObservers();
  }

  LH5801Pins clone() => LH5801Pins()
    .._resetPin = _resetPin
    .._nmiPin = _nmiPin
    .._miPin = _miPin
    .._puFlipflop = _puFlipflop
    .._pvFlipflop = _pvFlipflop
    .._bfFlipflop = _bfFlipflop
    .._dispFlipflop = _dispFlipflop
    .._inputPorts = _inputPorts;

  @override
  bool registerPinsObserver(LH5801PinsObserver observer) =>
      _observers.add(observer);

  @override
  void notifyPinsObservers() {
    for (final LH5801PinsObserver observer in _observers) {
      observer.update(clone());
    }
  }

  @override
  String toString() {
    return 'LH5801Pins(reset: $_resetPin, NMI: $_nmiPin, MI: $_miPin, PU: $_puFlipflop, PV: $_pvFlipflop, BF: $_bfFlipflop, DISP: $_dispFlipflop, inputPorts: ${OperandDump.op8(_inputPorts)})';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LH5801Pins &&
          runtimeType == other.runtimeType &&
          _resetPin == other._resetPin &&
          _nmiPin == other._nmiPin &&
          _miPin == other._miPin &&
          _puFlipflop == other._puFlipflop &&
          _pvFlipflop == other._pvFlipflop &&
          _bfFlipflop == other._bfFlipflop &&
          _dispFlipflop == other._dispFlipflop &&
          _inputPorts == other._inputPorts;

  @override
  int get hashCode =>
      _resetPin.hashCode ^
      _nmiPin.hashCode ^
      _miPin.hashCode ^
      _puFlipflop.hashCode ^
      _pvFlipflop.hashCode ^
      _bfFlipflop.hashCode ^
      _dispFlipflop.hashCode ^
      _inputPorts.hashCode;
}
