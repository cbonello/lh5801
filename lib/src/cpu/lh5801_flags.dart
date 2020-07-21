import 'package:json_annotation/json_annotation.dart';

part 'lh5801_flags.g.dart';

@JsonSerializable(
  createFactory: true,
  disallowUnrecognizedKeys: true,
)
class LH5801Flags {
  LH5801Flags({
    this.h = false,
    this.v = false,
    this.z = false,
    this.ie = false,
    this.c = false,
  });

  factory LH5801Flags.fromJson(Map<String, dynamic> json) => _$LH5801FlagsFromJson(json);

  Map<String, dynamic> toJson() => _$LH5801FlagsToJson(this);

  bool h, v, z, ie, c;

  int get statusRegister =>
      (boolToInt(h) << 4) |
      (boolToInt(v) << 3) |
      (boolToInt(z) << 2) |
      (boolToInt(ie) << 1) |
      boolToInt(c);

  set statusRegister(int flags) {
    h = intToBool((flags & 0x10) >> 4);
    v = intToBool((flags & 0x08) >> 3);
    z = intToBool((flags & 0x04) >> 2);
    ie = intToBool((flags & 0x02) >> 1);
    c = intToBool(flags & 0x01);
  }

  void reset() => statusRegister = 0;

  LH5801Flags clone() => LH5801Flags(h: h, v: v, z: z, ie: ie, c: c);

  // ignore: avoid_positional_boolean_parameters
  static int boolToInt(bool value) => value ? 1 : 0;
  static bool intToBool(int value) => value != 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LH5801Flags &&
          runtimeType == other.runtimeType &&
          h == other.h &&
          v == other.v &&
          z == other.z &&
          ie == other.ie &&
          c == other.c;

  @override
  int get hashCode => h.hashCode ^ v.hashCode ^ z.hashCode ^ ie.hashCode ^ c.hashCode;
}
