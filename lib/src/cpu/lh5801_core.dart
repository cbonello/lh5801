abstract class LH5801Core {
  /// Return the byte at the given memory address.
  int memRead(int address);

  /// Write the given 8bit byte value to the given memory address.
  void memWrite(int address, int value);

  /// CPU internal PU flipflop output.
  void puFlipFlop({bool value});

  /// CPU internal PV flipflop output.
  void pvFlipFlop({bool value});

  /// CPU internal BF flipflop output.
  void bfFlipFlop({bool value});

  /// LCD on/off control signal output.
  void disp({bool value});

  /// Write an 8bit byte value to the data bus.
  void dataBus(int value);
}
