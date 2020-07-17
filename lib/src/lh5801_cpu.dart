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

  int _readOp8() {
    final int op8 = _memRead(_p.value);
    _p.value += 1;
    return op8;
  }

  int _readOp16([int address]) {
    final int op8H = _readOp8();
    final int op8L = _readOp8();
    return op8H << 8 | op8L;
  }

  // See http://teaching.idallen.com/dat2343/10f/notes/040_overflow.txt
  int _binaryAdd(int left, int right, {bool carry = false}) {
    final int c = LH5801Flags.boolToInt(carry);
    final int sum = left + right + c;

    _t.h = (((left & 0x0F) + (right & 0x0F) + c) & 0x10) != 0;
    _t.v = ((left & 0x80) == (right & 0x80)) && ((left & 0x80) != (sum & 0x80));
    _t.z = (sum & 0xFF) == 0;
    _t.c = (sum & 0x100) != 0;

    return sum & 0xFF;
  }

  void _addAccumulator(int value) {
    _a.value = _binaryAdd(_a.value, value, carry: _t.c);
  }

  void _addMemory(int address, int value) {
    final int m = _memRead(address);
    final int sum = _binaryAdd(m, value);
    _memWrite(address, sum);
  }

  void _addRegister(Register16 register) {
    final int savedFlags = _t.statusRegister;
    final int low = register.low;
    register.low = _binaryAdd(low, _a.value);
    if (_t.c) {
      register.high++;
    }
    _t.statusRegister = savedFlags;
  }

  void _aex() {
    final int accumultor = _a._value;
    _a._value = (accumultor << 4) | (accumultor >> 4);
  }

  void _am0() => _tm = _a._value;

  void _am1() {
    _tm = 0x100 | _a._value;
    // _ir2 = _tm.isInterruptRaised()
  }

  void _andAccumulator(int value) {
    _a.value &= value;
    _t.z = _a.value == 0;
  }

  void _andMemory(int address, int value) {
    final int m = _memRead(address);
    final int andValue = m & value;
    _t.z = (andValue & 0xFF) == 0;
    _memWrite(address, andValue);
  }

  void _atp(int value) => _dataBus(value);

  void _att() => _t.statusRegister = _a.value;

  int _branchForward(int addCyclesTable, {bool cond}) {
    int cpuCycles = 0;
    final int offset = _readOp8();
    if (cond) {
      cpuCycles += addCyclesTable;
      _p.value += offset;
    }
    return cpuCycles;
  }

  int _branchBackward(int addCyclesTable, {bool cond}) {
    int cpuCycles = 0;
    final int offset = _readOp8();
    if (cond) {
      cpuCycles += addCyclesTable;
      _p.value -= offset;
    }
    return cpuCycles;
  }

  void _bit(int value1, int value2) {
    _t.z = (value1 & value2) == 0;
  }

  void _cin() {
    final int m = _memRead(_me0(_x.value));
    _cpi(_a.value, m);
    _x.value += 1;
  }

  void _cpi(int value1, int value2) {
    _binaryAdd(value1, value2 ^ 0xFF + 1);
  }

  int _bcdAdd(int left, int right, {bool carry}) {
    int result = _binaryAdd(left, right, carry: carry);

    // See page 28 of "Sharp PC-1500 Technical Reference Manual"
    if (_t.c == false && _t.h == false) {
      result += 0x9A;
    } else if (_t.c == false && _t.h) {
      result += 0xA0;
    } else if (_t.c && _t.h == false) {
      result += 0xFA;
    }
    return result;
  }

  void _dca(int value) => _a.value = _bcdAdd(_a.value + 0x66, value, carry: _t.c);

  void _dcs(int value) {
    int v = value;
    if (_t.c) {
      v++;
    }
    _a.value = _bcdAdd(_a.value, v ^ 0xFF + 1);
  }

  void _decRegister8(Register8 register) =>
      register.value = _binaryAdd(register.value, 0x01 ^ 0xFF + 1);

  void _decRegister16(Register16 register) => register.value -= 1;

  void _drl(int address) {
    final int m = _memRead(address);
    final int tmp = m << 8 | _a.value;
    _a.value = m;
    _memWrite(address, tmp >> 4);
  }

  void _drr(int address) {
    final int m = _memRead(address);
    final int tmp = _a.value << 8 | m;
    _a.value = tmp;
    _memWrite(address, tmp >> 4);
  }
}
