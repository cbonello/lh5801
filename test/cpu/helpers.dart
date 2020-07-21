import 'dart:typed_data';

import 'package:lh5801/lh5801.dart';
import 'package:test/test.dart';

class System implements LH5801Core {
  System() {
    cpu = LH5801CPU(core: this, clockFrequency: 1300000);
    _me0 = Uint8ClampedList(64 * 1024);
    _me1 = Uint8ClampedList(64 * 1024);
  }

  LH5801CPU cpu;
  Uint8ClampedList _me0, _me1;

  void resetMemories() {
    _me0.setRange(0, 64 * 1024, List<int>.filled(64 * 1024, 0));
    _me1.setRange(0, 64 * 1024, List<int>.filled(64 * 1024, 0));
  }

  void load(int address, List<int> data) {
    if (address & 0x10000 != 0) {
      final int a = address & 0xFFFF;
      _me1.setRange(a, a + data.length, data);
    } else {
      _me0.setRange(address, address + data.length, data);
    }
  }

  int step(int address) {
    cpu.p.value = address;
    return cpu.step();
  }

  @override
  int memRead(int address) {
    final int value = address & 0x10000 != 0 ? _me1[address & 0xFFFF] : _me0[address];
    return value;
  }

  @override
  void memWrite(int address, int value) {
    if (address & 0x10000 != 0) {
      _me1[address & 0xFFFF] = value;
    } else {
      _me0[address] = value;
    }
  }

  @override
  void dataBus(int value) {}

  @override
  void puFlipFlop({bool value}) {}

  @override
  void pvFlipFlop({bool value}) {}

  @override
  void disp({bool value}) {}
}

void testSBCRReg(System system, int opcode, Register16 register) {
  system.load(0x0000, <int>[0xFD, opcode]);
  system.load(0x10001, <int>[33]);
  system.cpu.a.value = 56;
  register.value = 0x0001;
  system.cpu.t.c = false;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(11));
  expect(system.cpu.p.value, equals(2));

  expect(system.cpu.a.value, equals(22));

  expect(system.cpu.t.c, isTrue);
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.v, isFalse);
  expect(system.cpu.t.h, isTrue);
}

void testADCRReg(System system, int opcode, Register16 register) {
  system.load(0x0000, <int>[0xFD, opcode]);
  system.load(0x10001, <int>[51]);
  system.cpu.a.value = 2;
  register.value = 0x0001;
  system.cpu.t.c = false;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(11));
  expect(system.cpu.p.value, equals(2));

  expect(system.cpu.a.value, equals(53));

  expect(system.cpu.t.c, isFalse);
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.v, isFalse);
  expect(system.cpu.t.h, isFalse);
}

void testLDARReg1(System system, int opcode, Register16 register) {
  final LH5801Flags flags = system.cpu.t.clone();

  system.load(0x0000, <int>[0xFD, opcode]);
  system.load(0x10001, <int>[0]);
  system.cpu.a.value = 2;
  register.value = 0x0001;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(10));
  expect(system.cpu.p.value, equals(2));

  expect(system.cpu.a.value, equals(0));

  // Z should be the only flag updated.
  expect(system.cpu.t.h, equals(flags.h));
  expect(system.cpu.t.v, equals(flags.v));
  expect(system.cpu.t.z, isTrue);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, equals(flags.c));
}

void testLDARReg2(System system, int opcode, Register16 register) {
  final LH5801Flags flags = system.cpu.t.clone();

  system.load(0x0000, <int>[0xFD, opcode]);
  system.load(0x10001, <int>[0xFD]); // -3
  system.cpu.a.value = 2;
  register.value = 0x0001;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(10));
  expect(system.cpu.p.value, equals(2));

  expect(system.cpu.a.value, equals(0xFD));

  // Z should be the only flag updated.
  expect(system.cpu.t.h, equals(flags.h));
  expect(system.cpu.t.v, equals(flags.v));
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, equals(flags.c));
}

void testCPARReg(System system, int opcode, Register16 register) {
  system.load(0x0000, <int>[0xFD, opcode]);
  system.load(0x10001, <int>[80]);
  system.cpu.a.value = 84;
  register.value = 0x0001;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(11));
  expect(system.cpu.p.value, equals(2));

  expect(system.cpu.t.c, isTrue);
  expect(system.cpu.t.z, isFalse);
}

void testANDRReg1(System system, int opcode, Register16 register) {
  final LH5801Flags flags = system.cpu.t.clone();

  system.load(0x0000, <int>[0xFD, opcode]);
  system.load(0x10001, <int>[0x0F]);
  system.cpu.a.value = 0xF0;
  register.value = 0x0001;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(11));
  expect(system.cpu.p.value, equals(2));

  expect(system.cpu.a.value, equals(0));

  // Z should be the only flag updated.
  expect(system.cpu.t.h, equals(flags.h));
  expect(system.cpu.t.v, equals(flags.v));
  expect(system.cpu.t.z, isTrue);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, equals(flags.c));
}

void testANDRReg2(System system, int opcode, Register16 register) {
  final LH5801Flags flags = system.cpu.t.clone();

  system.load(0x0000, <int>[0xFD, opcode]);
  system.load(0x10001, <int>[0x0F]);
  system.cpu.a.value = 0xFF;
  register.value = 0x0001;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(11));
  expect(system.cpu.p.value, equals(2));

  expect(system.cpu.a.value, equals(0x0F));

  // Z should be the only flag updated.
  expect(system.cpu.t.h, equals(flags.h));
  expect(system.cpu.t.v, equals(flags.v));
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, equals(flags.c));
}

void testPOPRReg(System system, int opcode, Register16 register) {
  final int statusRegister = system.cpu.t.statusRegister;

  system.load(0x0000, <int>[0xFD, opcode]);
  system.load(0x46FE, <int>[0x20, 0x30]);
  system.cpu.s.value = 0x46FD;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(15));
  expect(system.cpu.p.value, equals(2));

  expect(register.value, equals(0x2030));
  expect(system.cpu.s.value, equals(0x46FD + 2));

  expect(system.cpu.t.statusRegister, equals(statusRegister));
}

void testORARReg1(System system, int opcode, Register16 register) {
  final LH5801Flags flags = system.cpu.t.clone();

  system.load(0x0000, <int>[0xFD, opcode]);
  system.load(0x10001, <int>[0x00]);
  system.cpu.a.value = 0x00;
  register.value = 0x0001;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(11));
  expect(system.cpu.p.value, equals(2));

  expect(system.cpu.a.value, equals(0));

  // Z should be the only flag updated.
  expect(system.cpu.t.h, equals(flags.h));
  expect(system.cpu.t.v, equals(flags.v));
  expect(system.cpu.t.z, isTrue);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, equals(flags.c));
}

void testORARReg2(System system, int opcode, Register16 register) {
  final LH5801Flags flags = system.cpu.t.clone();

  system.load(0x0000, <int>[0xFD, opcode]);
  system.load(0x10001, <int>[0x0F]);
  system.cpu.a.value = 0x04;
  register.value = 0x0001;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(11));
  expect(system.cpu.p.value, equals(2));

  expect(system.cpu.a.value, equals(0x0F));

  // Z should be the only flag updated.
  expect(system.cpu.t.h, equals(flags.h));
  expect(system.cpu.t.v, equals(flags.v));
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, equals(flags.c));
}

void testDCSRReg1(System system, int opcode, Register16 register) {
  system.load(0x0000, <int>[0xFD, opcode]);
  system.load(0x10001, <int>[0x31]);
  system.cpu.a.value = 0x42;
  register.value = 0x0001;
  system.cpu.t.c = true;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(17));
  expect(system.cpu.p.value, equals(2));

  expect(system.cpu.t.c, isTrue);
  expect(system.cpu.t.h, isTrue);
  expect(system.cpu.a.value, 0x11);
}

void testDCSRReg2(System system, int opcode, Register16 register) {
  system.load(0x0000, <int>[0xFD, opcode]);
  system.load(0x10001, <int>[0x31]);
  system.cpu.a.value = 0x42;
  register.value = 0x0001;
  system.cpu.t.c = false;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(17));
  expect(system.cpu.p.value, equals(2));

  expect(system.cpu.a.value, 0x10);

  expect(system.cpu.t.c, isTrue);
  expect(system.cpu.t.h, isTrue);
}

void testDCSRReg3(System system, int opcode, Register16 register) {
  system.load(0x0000, <int>[0xFD, opcode]);
  system.load(0x10001, <int>[0x54]);
  system.cpu.a.value = 0x23;
  register.value = 0x0001;
  system.cpu.t.c = true;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(17));
  expect(system.cpu.p.value, equals(2));

  expect(system.cpu.a.value, 0x69);

  expect(system.cpu.t.c, isFalse);
  expect(system.cpu.t.h, isFalse);
}

void testDCSRReg4(System system, int opcode, Register16 register) {
  system.load(0x0000, <int>[0xFD, opcode]);
  system.load(0x10001, <int>[0x54]);
  system.cpu.a.value = 0x23;
  register.value = 0x0001;
  system.cpu.t.c = false;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(17));
  expect(system.cpu.p.value, equals(2));

  expect(system.cpu.a.value, 0x68);

  expect(system.cpu.t.c, isFalse);
  expect(system.cpu.t.h, isFalse);
}

void testEORRReg1(System system, int opcode, Register16 register) {
  final LH5801Flags flags = system.cpu.t.clone();

  system.load(0x0000, <int>[0xFD, opcode]);
  system.load(0x10001, <int>[0x6D]);
  system.cpu.a.value = 0x36;
  register.value = 0x0001;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(11));
  expect(system.cpu.p.value, equals(2));

  expect(system.cpu.a.value, equals(0x5B));

  // Z should be the only flag updated.
  expect(system.cpu.t.h, equals(flags.h));
  expect(system.cpu.t.v, equals(flags.v));
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, equals(flags.c));
}

void testEORRReg2(System system, int opcode, Register16 register) {
  final LH5801Flags flags = system.cpu.t.clone();

  system.load(0x0000, <int>[0xFD, opcode]);
  system.load(0x10001, <int>[0x00]);
  system.cpu.a.value = 0x00;
  register.value = 0x0001;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(11));
  expect(system.cpu.p.value, equals(2));

  expect(system.cpu.a.value, equals(0x00));

  expect(system.cpu.t.h, equals(flags.h));

  // Z should be the only flag updated.
  expect(system.cpu.t.v, equals(flags.v));
  expect(system.cpu.t.z, isTrue);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, equals(flags.c));
}

void testSTARReg(System system, int opcode, Register16 register) {
  final int statusRegister = system.cpu.t.statusRegister;

  system.load(0x0000, <int>[0xFD, opcode]);
  system.cpu.a.value = 0x33;
  register.value = 0x0001;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(10));
  expect(system.cpu.p.value, equals(2));

  expect(system.memRead(0x10000 | system.cpu.x.value), equals(system.cpu.a.value));

  expect(system.cpu.t.statusRegister, equals(statusRegister));
}

void testBITRReg1(System system, int opcode, Register16 register) {
  final LH5801Flags flags = system.cpu.t.clone();

  system.load(0x0000, <int>[0xFD, opcode]);
  system.load(0x10001, <int>[0x0F]);
  system.cpu.a.value = 0x80;
  register.value = 0x0001;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(11));
  expect(system.cpu.p.value, equals(2));

  // Accumulator should not be updated.
  expect(system.cpu.a.value, equals(0x80));

  // Z should be the only flag updated.
  expect(system.cpu.t.h, equals(flags.h));
  expect(system.cpu.t.v, equals(flags.v));
  expect(system.cpu.t.z, isTrue);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, equals(flags.c));
}

void testBITRReg2(System system, int opcode, Register16 register) {
  final LH5801Flags flags = system.cpu.t.clone();

  system.load(0x0000, <int>[0xFD, opcode]);
  system.load(0x10001, <int>[0x0F]);
  system.cpu.a.value = 0x82;
  register.value = 0x0001;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(11));
  expect(system.cpu.p.value, equals(2));

  // Accumulator should not be updated.
  expect(system.cpu.a.value, equals(0x82));

  // Z should be the only flag updated.
  expect(system.cpu.t.h, equals(flags.h));
  expect(system.cpu.t.v, equals(flags.v));
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, equals(flags.c));
}
