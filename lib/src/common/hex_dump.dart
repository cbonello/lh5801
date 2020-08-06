class HexDump {
  static String hex8(int value) =>
      '${value.toUnsigned(8).toRadixString(16).toUpperCase().padLeft(2, '0')}H';

  static String hex16(int value) =>
      '${value.toUnsigned(16).toRadixString(16).toUpperCase().padLeft(4, '0')}H';

  static String meHex16(int address) => hex16(address);
}
