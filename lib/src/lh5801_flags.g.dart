// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lh5801_flags.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LH5801Flags _$LH5801FlagsFromJson(Map<String, dynamic> json) {
  $checkKeys(json,
      allowedKeys: const ['h', 'v', 'z', 'ie', 'c', 'statusRegister']);
  return LH5801Flags(
    h: json['h'] as int,
    v: json['v'] as int,
    z: json['z'] as int,
    ie: json['ie'] as int,
    c: json['c'] as int,
  )..statusRegister = json['statusRegister'] as int;
}

Map<String, dynamic> _$LH5801FlagsToJson(LH5801Flags instance) =>
    <String, dynamic>{
      'h': instance.h,
      'v': instance.v,
      'z': instance.z,
      'ie': instance.ie,
      'c': instance.c,
      'statusRegister': instance.statusRegister,
    };
