// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lh5801_timer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LH5801Timer _$LH5801TimerFromJson(Map<String, dynamic> json) {
  $checkKeys(json, allowedKeys: const ['value']);
  return LH5801Timer()..value = json['value'] as int;
}

Map<String, dynamic> _$LH5801TimerToJson(LH5801Timer instance) =>
    <String, dynamic>{
      'value': instance.value,
    };
