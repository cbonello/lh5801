import 'package:json_annotation/json_annotation.dart';

import '../lh5801.dart';

part 'lh5801_state.dart';
part 'lh5801_cpu.g.dart';

typedef LH5801Instruction = void Function();

class LH5801CPU extends LH5801State {
  LH5801CPU({
    int clockFrequency,
    int Function(int) memRead,
    void Function(int, int) memWrite,
    void Function(bool) pu,
    void Function(bool) pv,
    void Function(int) dataBus,
  })  : _clockFrequency = clockFrequency,
        _memRead = memRead,
        _memWrite = memWrite,
        _puFlipFlop = pu,
        _pvFlipFlop = pv,
        _dataBus = dataBus;

  final int _clockFrequency;
  final int Function(int) _memRead;
  final void Function(int, int) _memWrite;
  final void Function(bool) _puFlipFlop;
  final void Function(bool) _pvFlipFlop;
  final void Function(int) _dataBus;

  void MI() => _ir2 = true;

  void NMI() => _ir0 = true;

  void BFI() => throw Exception();

  @override
  void reset() {
    super.reset();
    _p.high = _memRead(_me0(0xFFFE));
    _p.low = _memRead(_me0(0xFFFF));
  }

  int _me0(int address) => address & 0xFFFF;
  int _me1(int address) => 0x10000 | address & 0xFFFF;
}
