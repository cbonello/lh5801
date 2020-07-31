abstract class LH5801Core {
  /// Return the byte at the given memory address.
  int memRead(int address);

  /// Write the given 8-bit byte value to the given memory address.
  void memWrite(int address, int value);

  /// CPU internal PU flipflop output.
  void puFlipflop({bool value});

  /// CPU internal PV flipflop output.
  void pvFlipflop({bool value});

  /// CPU internal BF flipflop output.
  void bfFlipflop({bool value});

  /// LCD on/off control signal output.
  void dispFlipflop({bool value});

  /// Read/Write an 8-bit byte value from/to the data bus.
  int get dataBus;
  set dataBus(int value);
}
