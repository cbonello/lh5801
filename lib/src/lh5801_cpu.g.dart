// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lh5801_cpu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Register16 _$Register16FromJson(Map<String, dynamic> json) {
  $checkKeys(json, allowedKeys: const ['value', 'high', 'low']);
  return Register16(
    json['value'] as int,
  )
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
  $checkKeys(json, allowedKeys: const ['state']);
  return LH5801State()
    ..state = json['state'] == null
        ? null
        : LH5801State.fromJson(json['state'] as Map<String, dynamic>);
}

Map<String, dynamic> _$LH5801StateToJson(LH5801State instance) =>
    <String, dynamic>{
      'state': instance.state,
    };
