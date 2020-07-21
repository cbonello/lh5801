// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lh5801_cpu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Register8 _$Register8FromJson(Map<String, dynamic> json) {
  $checkKeys(json, allowedKeys: const ['value']);
  return Register8(
    json['value'] as int,
  );
}

Map<String, dynamic> _$Register8ToJson(Register8 instance) => <String, dynamic>{
      'value': instance.value,
    };

Register16 _$Register16FromJson(Map<String, dynamic> json) {
  $checkKeys(json, allowedKeys: const ['value', 'high', 'low']);
  return Register16()
    ..value = json['value'] as int
    ..high = json['high'] as int
    ..low = json['low'] as int;
}

Map<String, dynamic> _$Register16ToJson(Register16 instance) =>
    <String, dynamic>{
      'value': instance.value,
      'high': instance.high,
      'low': instance.low,
    };

LH5801State _$LH5801StateFromJson(Map<String, dynamic> json) {
  $checkKeys(json, allowedKeys: const [
    'p',
    's',
    'a',
    'x',
    'y',
    'u',
    'tm',
    'pu',
    'pv',
    'disp',
    't',
    'ie',
    'ir0',
    'ir1',
    'ir2',
    'hlt',
    'cycleCounter'
  ]);
  return LH5801State(
    p: json['p'] == null
        ? null
        : Register16.fromJson(json['p'] as Map<String, dynamic>),
    s: json['s'] == null
        ? null
        : Register16.fromJson(json['s'] as Map<String, dynamic>),
    a: json['a'] == null
        ? null
        : Register8.fromJson(json['a'] as Map<String, dynamic>),
    x: json['x'] == null
        ? null
        : Register16.fromJson(json['x'] as Map<String, dynamic>),
    y: json['y'] == null
        ? null
        : Register16.fromJson(json['y'] as Map<String, dynamic>),
    u: json['u'] == null
        ? null
        : Register16.fromJson(json['u'] as Map<String, dynamic>),
    tm: json['tm'] as int,
    pu: json['pu'] as bool,
    pv: json['pv'] as bool,
    disp: json['disp'] as bool,
    t: json['t'] == null
        ? null
        : LH5801Flags.fromJson(json['t'] as Map<String, dynamic>),
    ie: json['ie'] as bool,
    ir0: json['ir0'] as bool,
    ir1: json['ir1'] as bool,
    ir2: json['ir2'] as bool,
    hlt: json['hlt'] as bool,
    cycleCounter: json['cycleCounter'] as int,
  );
}

Map<String, dynamic> _$LH5801StateToJson(LH5801State instance) =>
    <String, dynamic>{
      'p': instance.p,
      's': instance.s,
      'a': instance.a,
      'x': instance.x,
      'y': instance.y,
      'u': instance.u,
      'tm': instance.tm,
      'pu': instance.pu,
      'pv': instance.pv,
      'disp': instance.disp,
      't': instance.t,
      'ie': instance.ie,
      'ir0': instance.ir0,
      'ir1': instance.ir1,
      'ir2': instance.ir2,
      'hlt': instance.hlt,
      'cycleCounter': instance.cycleCounter,
    };
