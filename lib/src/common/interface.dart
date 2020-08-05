class LH5801Error extends Error {
  LH5801Error(this.message);

  final String message;

  @override
  String toString() => 'LH5801: $message';
}

/// Return the byte at the given memory address.
typedef LH5801MemoryRead = int Function(int address);

/// Write the given 8-bit byte value to the given memory address.
typedef LH5801MemoryWrite = void Function(int address, int value);
