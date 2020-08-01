class LH5801Flags {
  LH5801Flags({
    this.h = false,
    this.v = false,
    this.z = false,
    this.ie = false,
    this.c = false,
  });

  factory LH5801Flags.fromJson(Map<String, dynamic> json) {
    return LH5801Flags(
      h: json['h'] as bool,
      v: json['v'] as bool,
      z: json['z'] as bool,
      ie: json['ie'] as bool,
      c: json['c'] as bool,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'h': h,
        'v': v,
        'z': z,
        'ie': ie,
        'c': c,
      };

  bool h, v, z, ie, c;

  static const int H = 1 << 4;
  static const int V = 1 << 3;
  static const int Z = 1 << 2;
  static const int C = 1 << 0;

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
