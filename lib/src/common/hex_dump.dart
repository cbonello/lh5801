String hex8(int value) =>
    '${value.toUnsigned(8).toRadixString(16).toUpperCase().padLeft(2, '0')}H';

String hex16(int value) =>
    '${value.toUnsigned(16).toRadixString(16).toUpperCase().padLeft(4, '0')}H';

String meHex16(int address) {
  final String prefix = address >= 0x10000 ? '#' : '';
  return '$prefix${hex16(address)}H';
}
