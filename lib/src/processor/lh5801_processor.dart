import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'processor.dart';

/// Return the byte at the given memory address.
typedef LH5801MemoryRead = int Function(int address);

/// Write the given 8-bit byte value to the given memory address.
typedef LH5801MemoryWrite = void Function(int address, int value);

class LH5801Processor extends LH5801Pins {
  LH5801Processor({
    @required int clockFrequency,
    @required LH5801MemoryRead memRead,
    @required LH5801MemoryWrite memWrite,
  })  : assert(memRead != null),
        assert(memWrite != null) {
    cpu = LH5801CPU(
      pins: this,
      clockFrequency: clockFrequency,
      memRead: memRead,
      memWrite: memWrite,
    );
    me0 = Uint8ClampedList(64 * 1024);
    me1 = Uint8ClampedList(64 * 1024);
  }

  LH5801CPU cpu;
  Uint8ClampedList me0, me1;

  int step(int address) {
    cpu.p.value = address;
    return cpu.step();
  }

  void reset() => cpu.reset();
}
