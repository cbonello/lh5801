import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'flags.dart';
import 'timer.dart';

class Register8 extends Object {
  Register8([int value = 0x00]) : _value = value & 0xFF;

  factory Register8.fromJson(Map<String, dynamic> json) {
    return Register8(json['value'] as int);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'value': value,
      };

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

class Register16 extends Object {
  Register16([int value = 0x0000]) {
    this.value = value;
  }

  factory Register16.fromJson(Map<String, dynamic> json) {
    return Register16(json['value'] as int);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'value': value,
      };

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
    this.ie = false,
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
  @JsonKey(nullable: false)
  Register16 p;

  // Stack pointer.
  @JsonKey(nullable: false)
  Register16 s;

  // Accumulator.
  @JsonKey(nullable: false)
  Register8 a;

  // General purpose registers.
  @JsonKey(nullable: false)
  Register16 x, y, u;

  // Timer (9-bit).
  @JsonKey(nullable: false)
  LH5801Timer tm;

  // Status register.
  @JsonKey(nullable: false)
  LH5801Flags t;

  // Interrupt enable.
  bool ie;

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
    ie = false;
    ir0 = false;
    ir1 = false;
    ir2 = false;
    hlt = false;
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
          p == other.p &&
          s == other.s &&
          a == other.a &&
          x == other.x &&
          y == other.y &&
          u == other.u &&
          tm == other.tm &&
          t == other.t &&
          ie == other.ie &&
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
      ie.hashCode ^
      ir0.hashCode ^
      ir1.hashCode ^
      ir2.hashCode ^
      hlt.hashCode;
}