import 'package:json_annotation/json_annotation.dart';

part 'lh5801_flags.g.dart';

@JsonSerializable(
  createFactory: true,
  disallowUnrecognizedKeys: true,
)
class LH5801Flags {
  LH5801Flags({this.h = 0, this.v = 0, this.z = 0, this.ie = 0, this.c = 0});

  factory LH5801Flags.fromJson(Map<String, dynamic> json) => _$LH5801FlagsFromJson(json);

  Map<String, dynamic> toJson() => _$LH5801FlagsToJson(this);

  int h, v, z, ie, c;

  int get statusRegister => (h << 4) | (v << 3) | (z << 2) | (ie << 1) | c;

  set statusRegister(int flags) {
    h = (flags & 0x10) >> 4;
    v = (flags & 0x08) >> 3;
    z = (flags & 0x04) >> 2;
    ie = (flags & 0x02) >> 1;
    c = flags & 0x01;
  }

  void reset() => statusRegister = 0;

  LH5801Flags clone() => LH5801Flags(h: h, v: v, z: z, ie: ie, c: c);
}
