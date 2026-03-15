enum Radix { binary, decimal, hexadecimal }

class OperandDump {
  static String op8(
    int value, {
    Radix radix = Radix.hexadecimal,
    bool suffix = false,
  }) => switch (radix) {
    Radix.binary =>
        '${value.toUnsigned(8).toRadixString(2).padLeft(8, '0')}${suffix ? 'B' : ''}',
    Radix.decimal => value.toUnsigned(8).toRadixString(10).padLeft(3),
    Radix.hexadecimal =>
        '${value.toUnsigned(8).toRadixString(16).toUpperCase().padLeft(2, '0')}${suffix ? 'H' : ''}',
  };

  static String op16(
    int value, {
    Radix radix = Radix.hexadecimal,
    bool suffix = false,
  }) => switch (radix) {
    Radix.binary =>
        '${value.toUnsigned(16).toRadixString(2).padLeft(16, '0')}${suffix ? 'B' : ''}',
    Radix.decimal => value.toUnsigned(16).toRadixString(10).padLeft(5),
    Radix.hexadecimal =>
        '${value.toUnsigned(16).toRadixString(16).toUpperCase().padLeft(4, '0')}${suffix ? 'H' : ''}',
  };
}
