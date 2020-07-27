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

  @override
  String toString() {
    return 'Register8(0x${value.toRadixString(16).padLeft(2, '0')})';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Register8 && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;
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

  Register8 get highRegister => _bytes[1];
  int get high => _bytes[1].value;
  set high(int h) => _bytes[1].value = h & 0xFF;

  Register8 get lowRegister => _bytes[0];
  int get low => _bytes[0].value;
  set low(int l) => _bytes[0].value = l & 0xFF;

  void reset() => high = low = 0x00;

  Register16 clone() => Register16(value);

  @override
  String toString() {
    return 'Register16(0x${value.toRadixString(16).padLeft(4, '0')})';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Register16 && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;
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
    this.tm = 0x000,
    this.pu = false,
    this.pv = false,
    this.disp = true,
    LH5801Flags t,
    this.ie = false,
    this.ir0 = false,
    this.ir1 = false,
    this.ir2 = false,
    this.hlt = false,
    this.cycleCounter = 0,
  })  : p = p ?? Register16(),
        a = a ?? Register8(),
        s = s ?? Register16(),
        x = x ?? Register16(),
        y = y ?? Register16(),
        u = u ?? Register16(),
        t = t ?? LH5801Flags();

  factory LH5801State.fromJson(Map<String, dynamic> json) => _$LH5801StateFromJson(json);

  Map<String, dynamic> toJson() => _$LH5801StateToJson(this);

  // Program counter.
  Register16 p;
  // Program counter.
  Register16 s;
  // Accumulator.
  Register8 a;
  // General purpose registers.
  Register16 x, y, u;
  // Timer counter (9-bit).
  int tm;
  // General purpose flip-flops.
  bool pu, pv;
  // LCD on/off control.
  bool disp;
  // Status register.
  LH5801Flags t;
  // Interrupt enable flip-flop.
  bool ie;
  // Non-maskable interrupt request flip-flop.
  bool ir0;
  // Timer interrupt request flip-flop.
  bool ir1;
  // Maskable interrupt request flip-flop.
  bool ir2;
  bool hlt;
  int cycleCounter;

  void reset() {
    p.reset();
    s.reset();
    a.reset();
    x.reset();
    y.reset();
    u.reset();
    tm = 0x00;
    pu = false;
    pv = false;
    disp = true;
    t.reset();
    ie = false;
    ir0 = false;
    ir1 = false;
    ir2 = false;
    hlt = false;
    cycleCounter = 0;
  }

  @override
  String toString() {
    final String hash = hashCode.toUnsigned(20).toRadixString(16).padLeft(5, '0');
    return 'Z80State($hash)';
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
          pu == other.pu &&
          pv == other.pv &&
          disp == other.disp &&
          t == other.t &&
          ie == other.ie &&
          ir0 == other.ir0 &&
          ir1 == other.ir1 &&
          ir2 == other.ir2 &&
          hlt == other.hlt &&
          cycleCounter == other.cycleCounter;

  @override
  int get hashCode =>
      p.hashCode ^
      s.hashCode ^
      a.hashCode ^
      x.hashCode ^
      y.hashCode ^
      u.hashCode ^
      tm.hashCode ^
      pu.hashCode ^
      pv.hashCode ^
      disp.hashCode ^
      t.hashCode ^
      ie.hashCode ^
      ir0.hashCode ^
      ir1.hashCode ^
      ir2.hashCode ^
      hlt.hashCode ^
      cycleCounter.hashCode;
}
