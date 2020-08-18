import 'package:meta/meta.dart';

import '../../lh5801.dart';
import 'flags.dart';
import 'timer.dart';

class Register8 extends Object {
  Register8([int value = 0x00]) : _value = value & 0xFF;

  int _value;

  int get value => _value;
  set value(int newValue) => _value = newValue & 0xFF;

  void restoreState(Map<String, dynamic> state) {
    value = state['value'] as int;
  }

  Map<String, dynamic> saveState() => <String, dynamic>{'value': value};

  void reset() => _value = 0x00;

  Register8 clone() => Register8(_value);

  @override
  String toString() => 'Register8(${OperandDump.op8(value)})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Register8 &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class Register16 extends Object {
  Register16([int value = 0x0000]) {
    this.value = value;
  }

  final List<Register8> _bytes = <Register8>[Register8(), Register8()];

  int get value => _bytes[1].value << 8 | _bytes[0].value;
  set value(int newValue) {
    high = newValue >> 8;
    low = newValue & 0xFF;
  }

  Register8 get highRegister => _bytes[1];
  int get high => _bytes[1].value;
  set high(int h) => _bytes[1].value = h & 0xFF;

  Register8 get lowRegister => _bytes[0];
  int get low => _bytes[0].value;
  set low(int l) => _bytes[0].value = l & 0xFF;

  void restoreState(Map<String, dynamic> state) {
    value = state['value'] as int;
  }

  Map<String, dynamic> saveState() => <String, dynamic>{'value': value};

  void reset() => high = low = 0x00;

  Register16 clone() => Register16(value);

  @override
  String toString() => 'Register16(${OperandDump.op16(value)})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Register16 &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class LH5801State {
  LH5801State({
    Register16 p,
    Register16 s,
    Register8 a,
    Register16 x,
    Register16 y,
    Register16 u,
    @required this.tm,
    LH5801Flags t,
    this.ir0 = false,
    this.ir1 = false,
    this.ir2 = false,
    this.hlt = false,
  })  : assert(tm != null),
        p = p ?? Register16(),
        a = a ?? Register8(),
        s = s ?? Register16(),
        x = x ?? Register16(),
        y = y ?? Register16(),
        u = u ?? Register16(),
        t = t ?? LH5801Flags();

  // Program counter.
  Register16 p;

  // Stack pointer.
  Register16 s;

  // Accumulator.
  Register8 a;

  // General purpose registers.
  Register16 x, y, u;

  // Timer (9-bit).
  LH5801Timer tm;

  // Status register.
  LH5801Flags t;

  // Non-maskable interrupt request.
  bool ir0;

  // Timer interrupt request.
  bool ir1;

  // Maskable interrupt request.
  bool ir2;

  // Stops CPU operation if true (only the timer is in operation).
  bool hlt;

  void reset() {
    p.reset();
    s.reset();
    a.reset();
    x.reset();
    y.reset();
    u.reset();
    tm.reset();
    t.reset();
    ir0 = false;
    ir1 = false;
    ir2 = false;
    hlt = false;
  }

  LH5801State clone() => LH5801State(
        p: p.clone(),
        s: s.clone(),
        a: a.clone(),
        x: x.clone(),
        y: y.clone(),
        u: u.clone(),
        tm: tm.clone(),
        t: t.clone(),
        ir0: ir0,
        ir1: ir1,
        ir2: ir2,
        hlt: hlt,
      );

  @override
  String toString() {
    return 'LH5801State(P: ${OperandDump.op16(p.value)}, S: ${OperandDump.op16(s.value)}, A: ${OperandDump.op8(a.value)}, X: ${OperandDump.op16(x.value)}, Y: ${OperandDump.op16(y.value)}, U: ${OperandDump.op16(u.value)}, TM: $tm, IR0: $tm, IR1: $ir1, IR2: $ir2, HLT: $hlt))';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LH5801State &&
          runtimeType == other.runtimeType &&
          p == other.p &&
          s == other.s &&
          a == other.a &&
          x == other.x &&
          y == other.y &&
          u == other.u &&
          tm == other.tm &&
          t == other.t &&
          ir0 == other.ir0 &&
          ir1 == other.ir1 &&
          ir2 == other.ir2 &&
          hlt == other.hlt;

  @override
  int get hashCode =>
      p.hashCode ^
      s.hashCode ^
      a.hashCode ^
      x.hashCode ^
      y.hashCode ^
      u.hashCode ^
      tm.hashCode ^
      t.hashCode ^
      ir0.hashCode ^
      ir1.hashCode ^
      ir2.hashCode ^
      hlt.hashCode;
}
