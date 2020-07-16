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
        _memReadHandler = memRead,
        _memWriteHandler = memWrite,
        _puHandler = pu,
        _pvHandler = pv,
        _dataBusHandler = dataBus;

  int _clockFrequency;
  int Function(int) _memReadHandler;
  void Function(int, int) _memWriteHandler;
  void Function(bool) _puHandler;
  void Function(bool) _pvHandler;
  void Function(int) _dataBusHandler;

  void MI() => _ir2 = true;

  void NMI() => _ir0 = true;

  void BFI() => throw Exception();
}
