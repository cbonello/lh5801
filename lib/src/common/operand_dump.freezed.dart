// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'operand_dump.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$RadixTearOff {
  const _$RadixTearOff();

// ignore: unused_element
  _Binary binary() {
    return const _Binary();
  }

// ignore: unused_element
  _Decimal decimal() {
    return const _Decimal();
  }

// ignore: unused_element
  _Hexadecimal hexadecimal() {
    return const _Hexadecimal();
  }
}

// ignore: unused_element
const $Radix = _$RadixTearOff();

mixin _$Radix {
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result binary(),
    @required Result decimal(),
    @required Result hexadecimal(),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result binary(),
    Result decimal(),
    Result hexadecimal(),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result binary(_Binary value),
    @required Result decimal(_Decimal value),
    @required Result hexadecimal(_Hexadecimal value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result binary(_Binary value),
    Result decimal(_Decimal value),
    Result hexadecimal(_Hexadecimal value),
    @required Result orElse(),
  });
}

abstract class $RadixCopyWith<$Res> {
  factory $RadixCopyWith(Radix value, $Res Function(Radix) then) =
      _$RadixCopyWithImpl<$Res>;
}

class _$RadixCopyWithImpl<$Res> implements $RadixCopyWith<$Res> {
  _$RadixCopyWithImpl(this._value, this._then);

  final Radix _value;
  // ignore: unused_field
  final $Res Function(Radix) _then;
}

abstract class _$BinaryCopyWith<$Res> {
  factory _$BinaryCopyWith(_Binary value, $Res Function(_Binary) then) =
      __$BinaryCopyWithImpl<$Res>;
}

class __$BinaryCopyWithImpl<$Res> extends _$RadixCopyWithImpl<$Res>
    implements _$BinaryCopyWith<$Res> {
  __$BinaryCopyWithImpl(_Binary _value, $Res Function(_Binary) _then)
      : super(_value, (v) => _then(v as _Binary));

  @override
  _Binary get _value => super._value as _Binary;
}

class _$_Binary implements _Binary {
  const _$_Binary();

  @override
  String toString() {
    return 'Radix.binary()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is _Binary);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result binary(),
    @required Result decimal(),
    @required Result hexadecimal(),
  }) {
    assert(binary != null);
    assert(decimal != null);
    assert(hexadecimal != null);
    return binary();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result binary(),
    Result decimal(),
    Result hexadecimal(),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (binary != null) {
      return binary();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result binary(_Binary value),
    @required Result decimal(_Decimal value),
    @required Result hexadecimal(_Hexadecimal value),
  }) {
    assert(binary != null);
    assert(decimal != null);
    assert(hexadecimal != null);
    return binary(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result binary(_Binary value),
    Result decimal(_Decimal value),
    Result hexadecimal(_Hexadecimal value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (binary != null) {
      return binary(this);
    }
    return orElse();
  }
}

abstract class _Binary implements Radix {
  const factory _Binary() = _$_Binary;
}

abstract class _$DecimalCopyWith<$Res> {
  factory _$DecimalCopyWith(_Decimal value, $Res Function(_Decimal) then) =
      __$DecimalCopyWithImpl<$Res>;
}

class __$DecimalCopyWithImpl<$Res> extends _$RadixCopyWithImpl<$Res>
    implements _$DecimalCopyWith<$Res> {
  __$DecimalCopyWithImpl(_Decimal _value, $Res Function(_Decimal) _then)
      : super(_value, (v) => _then(v as _Decimal));

  @override
  _Decimal get _value => super._value as _Decimal;
}

class _$_Decimal implements _Decimal {
  const _$_Decimal();

  @override
  String toString() {
    return 'Radix.decimal()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is _Decimal);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result binary(),
    @required Result decimal(),
    @required Result hexadecimal(),
  }) {
    assert(binary != null);
    assert(decimal != null);
    assert(hexadecimal != null);
    return decimal();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result binary(),
    Result decimal(),
    Result hexadecimal(),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (decimal != null) {
      return decimal();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result binary(_Binary value),
    @required Result decimal(_Decimal value),
    @required Result hexadecimal(_Hexadecimal value),
  }) {
    assert(binary != null);
    assert(decimal != null);
    assert(hexadecimal != null);
    return decimal(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result binary(_Binary value),
    Result decimal(_Decimal value),
    Result hexadecimal(_Hexadecimal value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (decimal != null) {
      return decimal(this);
    }
    return orElse();
  }
}

abstract class _Decimal implements Radix {
  const factory _Decimal() = _$_Decimal;
}

abstract class _$HexadecimalCopyWith<$Res> {
  factory _$HexadecimalCopyWith(
          _Hexadecimal value, $Res Function(_Hexadecimal) then) =
      __$HexadecimalCopyWithImpl<$Res>;
}

class __$HexadecimalCopyWithImpl<$Res> extends _$RadixCopyWithImpl<$Res>
    implements _$HexadecimalCopyWith<$Res> {
  __$HexadecimalCopyWithImpl(
      _Hexadecimal _value, $Res Function(_Hexadecimal) _then)
      : super(_value, (v) => _then(v as _Hexadecimal));

  @override
  _Hexadecimal get _value => super._value as _Hexadecimal;
}

class _$_Hexadecimal implements _Hexadecimal {
  const _$_Hexadecimal();

  @override
  String toString() {
    return 'Radix.hexadecimal()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is _Hexadecimal);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result binary(),
    @required Result decimal(),
    @required Result hexadecimal(),
  }) {
    assert(binary != null);
    assert(decimal != null);
    assert(hexadecimal != null);
    return hexadecimal();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result binary(),
    Result decimal(),
    Result hexadecimal(),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (hexadecimal != null) {
      return hexadecimal();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result binary(_Binary value),
    @required Result decimal(_Decimal value),
    @required Result hexadecimal(_Hexadecimal value),
  }) {
    assert(binary != null);
    assert(decimal != null);
    assert(hexadecimal != null);
    return hexadecimal(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result binary(_Binary value),
    Result decimal(_Decimal value),
    Result hexadecimal(_Hexadecimal value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (hexadecimal != null) {
      return hexadecimal(this);
    }
    return orElse();
  }
}

abstract class _Hexadecimal implements Radix {
  const factory _Hexadecimal() = _$_Hexadecimal;
}
