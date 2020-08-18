import 'package:lh5801/src/common/common.dart';

class LH5801Pins {
  LH5801Pins() {
    reset();
  }

  /// CPU reset.
  bool resetPin;

  /// Non-maskable interrupt input (NMI).
  bool nmiPin;

  /// Maskable interrupt input (MI).
  bool miPin;

  /// CPU internal PU flipflop output.
  bool puFlipflop;

  /// CPU internal PV flipflop output.
  bool pvFlipflop;

  /// CPU internal BF flipflops.
  bool bfFlipflop;

  /// LCD on/off control signal output.
  bool dispFlipflop;

  /// Input ports through which the CPU receives 8-bit data into the accumulator.
  int inputPorts;

  void reset() {
    resetPin = nmiPin = miPin = puFlipflop = pvFlipflop = dispFlipflop = false;
    bfFlipflop = true;
    inputPorts = 0;
  }

  LH5801Pins clone() => LH5801Pins()
    ..resetPin = resetPin
    ..nmiPin = nmiPin
    ..miPin = miPin
    ..puFlipflop = puFlipflop
    ..pvFlipflop = pvFlipflop
    ..bfFlipflop = bfFlipflop
    ..dispFlipflop = dispFlipflop
    ..inputPorts = inputPorts;

  @override
  String toString() {
    return 'LH5801Pins(reset: $resetPin, NMI: $nmiPin, MI: $miPin, PU: $puFlipflop, PV: $pvFlipflop, BF: $bfFlipflop, DISP: $dispFlipflop, inputPorts: ${OperandDump.op8(inputPorts)})';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LH5801Pins &&
          runtimeType == other.runtimeType &&
          resetPin == other.resetPin &&
          nmiPin == other.nmiPin &&
          miPin == other.miPin &&
          puFlipflop == other.puFlipflop &&
          pvFlipflop == other.pvFlipflop &&
          bfFlipflop == other.bfFlipflop &&
          dispFlipflop == other.dispFlipflop &&
          inputPorts == other.inputPorts;

  @override
  int get hashCode =>
      resetPin.hashCode ^
      nmiPin.hashCode ^
      miPin.hashCode ^
      puFlipflop.hashCode ^
      pvFlipflop.hashCode ^
      bfFlipflop.hashCode ^
      dispFlipflop.hashCode ^
      inputPorts.hashCode;
}
