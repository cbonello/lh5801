part of 'lh5801_cpu.dart';

@JsonSerializable(
  createFactory: true,
  disallowUnrecognizedKeys: true,
)
class Register8 extends Object {
  Register8([int value = 0x00]) : _value = value & 0xFF;

  factory Register8.fromJson(Map<String, dynamic> json) => _$Register8FromJson(json);

  Map<String, dynamic> toJson() => _$Register8ToJson(this);

  int _value;

  int get value => _value;
  set value(int newValue) => _value = newValue & 0xFF;

  void reset() => _value = 0x00;

  Register8 clone() => Register8(_value);
}

@JsonSerializable(
  createFactory: true,
  disallowUnrecognizedKeys: true,
)
class Register16 extends Object {
  Register16([int initialValue = 0x0000]) {
    value = initialValue;
  }

  factory Register16.fromJson(Map<String, dynamic> json) => _$Register16FromJson(json);

  Map<String, dynamic> toJson() => _$Register16ToJson(this);

  final List<Register8> _bytes = <Register8>[Register8(), Register8()];

  int get value => _bytes[1].value << 8 | _bytes[0].value;
  set value(int newValue) {
    high = newValue >> 8;
    low = newValue & 0xFF;
  }

  int get high => _bytes[1].value;
  set high(int h) => _bytes[1].value = h & 0xFF;

  int get low => _bytes[0].value;
  set low(int l) => _bytes[0].value = l & 0xFF;

  void reset() => high = low = 0x00;

  Register16 clone() => Register16(value);
}

@JsonSerializable(
  createFactory: true,
  disallowUnrecognizedKeys: true,
)
class LH5801State {
  LH5801State({
    Register16 p,
    Register16 s,
    Register8 a,
    Register16 x,
    Register16 y,
    Register16 u,
    int tm = 0x000,
    bool pu = false,
    bool pv = false,
    bool disp = true,
    LH5801Flags t,
    bool ie = false,
    bool ir0 = false,
    bool ir1 = false,
    bool ir2 = false,
    bool hlt = false,
    int cycleCounter = 0,
  })  : _p = p ?? Register16(),
        _a = a ?? Register8(),
        _s = s ?? Register16(),
        _x = x ?? Register16(),
        _y = y ?? Register16(),
        _u = u ?? Register16(),
        _tm = tm,
        _pu = pu,
        _pv = pv,
        _disp = disp,
        _t = t ?? LH5801Flags(),
        _ie = ie,
        _ir0 = ir0,
        _ir1 = ir1,
        _ir2 = ir2,
        _hlt = hlt,
        _cycleCounter = cycleCounter;

  factory LH5801State.fromJson(Map<String, dynamic> json) => _$LH5801StateFromJson(json);

  Map<String, dynamic> toJson() => _$LH5801StateToJson(this);

  // Program counter.
  Register16 _p;
  // Program counter.
  Register16 _s;
  // Accumulator.
  Register8 _a;
  // General purpose registers.
  Register16 _x, _y, _u;
  // Timer counter (9-bit).
  int _tm;
  // General purpose flip-flops.
  bool _pu, _pv;
  // LCD on/off control.
  bool _disp;
  // Status register.
  LH5801Flags _t;
  // Interrupt enable flip-flop.
  bool _ie;
  // Non-maskable interrupt request flip-flop.
  bool _ir0;
  // Timer interrupt request flip-flop.
  bool _ir1;
  // Maskable interrupt request flip-flop.
  bool _ir2;
  bool _hlt;
  int _cycleCounter;

  LH5801State get state => clone();

  void reset() {
    _p.reset();
    _s.reset();
    _a.reset();
    _x.reset();
    _y.reset();
    _u.reset();
    _tm = 0x00;
    _pu = false;
    _pv = false;
    _disp = true;
    _t.reset();
    _ie = false;
    _ir0 = false;
    _ir1 = false;
    _ir2 = false;
    _hlt = false;
    _cycleCounter = 0;
  }

  set state(LH5801State state) {
    _p.value = state._p.value;
    _s.value = state._s.value;
    _a = state._a;
    _x.value = state._x.value;
    _y.value = state._y.value;
    _u.value = state._u.value;
    _tm = state._tm;
    _pu = state._pu;
    _pv = state._pv;
    _disp = state._disp;
    _t = state._t.clone();
    _ie = state._ie;
    _ir0 = state._ir0;
    _ir1 = state._ir1;
    _ir2 = state._ir2;
    _hlt = state._hlt;
    _cycleCounter = state._cycleCounter;
  }

  LH5801State clone() {
    return LH5801State(
      p: _p,
      s: _s,
      a: _a,
      x: _x,
      y: _y,
      u: _u,
      tm: _tm,
      pu: _pu,
      pv: _pv,
      disp: _disp,
      t: _t,
      ie: _ie,
      ir0: _ir0,
      ir1: _ir1,
      ir2: _ir2,
      hlt: _hlt,
      cycleCounter: _cycleCounter,
    );
  }

  @override
  String toString() {
    final String hash = hashCode.toUnsigned(20).toRadixString(16).padLeft(5, '0');
    return 'LH5801State($hash)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LH5801State &&
          runtimeType == other.runtimeType &&
          _p == other._p &&
          _s == other._s &&
          _a == other._a &&
          _x == other._x &&
          _y == other._y &&
          _u == other._u &&
          _tm == other._tm &&
          _pu == other._pu &&
          _pv == other._pv &&
          _disp == other._disp &&
          _t == other._t &&
          _ie == other._ie &&
          _ir0 == other._ir0 &&
          _ir1 == other._ir1 &&
          _ir2 == other._ir2 &&
          _hlt == other._hlt &&
          _cycleCounter == other._cycleCounter;

  @override
  int get hashCode =>
      _p.hashCode ^
      _s.hashCode ^
      _a.hashCode ^
      _x.hashCode ^
      _y.hashCode ^
      _u.hashCode ^
      _tm.hashCode ^
      _pu.hashCode ^
      _pv.hashCode ^
      _disp.hashCode ^
      _t.hashCode ^
      _ie.hashCode ^
      _ir0.hashCode ^
      _ir1.hashCode ^
      _ir2.hashCode ^
      _hlt.hashCode ^
      _cycleCounter.hashCode;
}
