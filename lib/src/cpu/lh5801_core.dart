abstract class LH5801Core {
  /// CPU reset.
  void reset();

  /// Non-maskable interrupt input (NMI).
  void nmi();

  /// Maskable interrupt input (MI).
  void mi();

  /// Return the byte at the given memory address.
  int memRead(int address);

  /// Write the given 8-bit byte value to the given memory address.
  void memWrite(int address, int value);

  /// CPU internal PU flipflop output.
  void puFlipflop({bool value});

  /// CPU internal PV flipflop output.
  void pvFlipflop({bool value});

  /// CPU internal BF flipflops.
  bool get bfFlipflop;
  set bfFlipflop(bool value);

  /// LCD on/off control signal output.
  void dispFlipflop({bool value});

  /// Input ports through which the CPU receives 8-bit data into the accumulator.
  int get inputPorts;
  set inputPorts(int value);
}
