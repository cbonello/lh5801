import 'package:freezed_annotation/freezed_annotation.dart';

part 'operand_dump.freezed.dart';

@freezed
abstract class Radix with _$Radix {
  const Radix._();

  const factory Radix.binary() = _Binary;
  const factory Radix.decimal() = _Decimal;
  const factory Radix.hexadecimal() = _Hexadecimal;

  int toInt() => when<int>(binary: () => 2, decimal: () => 10, hexadecimal: () => 16);
}

class OperandDump {
  static String op8(
    int value, {
    Radix radix = const Radix.hexadecimal(),
    bool suffix = false,
  }) {
    return radix.when(
      binary: () =>
          '${value.toUnsigned(8).toRadixString(2).padLeft(8, '0')}${suffix ? 'B' : ''}',
      decimal: () => value.toUnsigned(8).toRadixString(10).padLeft(3),
      hexadecimal: () =>
          '${value.toUnsigned(8).toRadixString(16).toUpperCase().padLeft(2, '0')}${suffix ? 'H' : ''}',
    );
  }

  static String op16(
    int value, {
    Radix radix = const Radix.hexadecimal(),
    bool suffix = false,
  }) {
    return radix.when(
      binary: () =>
          '${value.toUnsigned(16).toRadixString(2).padLeft(16, '0')}${suffix ? 'B' : ''}',
      decimal: () => value.toUnsigned(16).toRadixString(10).padLeft(5),
      hexadecimal: () =>
          '${value.toUnsigned(16).toRadixString(16).toUpperCase().padLeft(4, '0')}${suffix ? 'H' : ''}',
    );
  }
}
