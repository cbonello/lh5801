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
  final List<int> opcodes = <int>[0xFD, opcode];

  system.load(0x0000, opcodes);
  system.load(0x10001, <int>[33]);
  system.cpu.a.value = 56;
  register.value = 0x0001;
  system.cpu.t.c = true;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(11));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(system.cpu.a.value, equals(23));

  expect(system.cpu.t.c, isTrue);
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.v, isFalse);
  expect(system.cpu.t.h, isTrue);
}

void testSBCab(System system, int opcode, {bool me1 = false}) {
  final int ab = me1 ? 0x11234 : 0x1234;
  final List<int> opcodes = <int>[0xFD, opcode, (ab >> 8) & 0xFF, ab & 0xFF];

  system.load(0x0000, opcodes);
  system.load(ab, <int>[33]);
  system.cpu.a.value = 56;
  system.cpu.t.c = true;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(17));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(system.cpu.a.value, equals(23));

  expect(system.cpu.t.c, isTrue);
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.v, isFalse);
  expect(system.cpu.t.h, isTrue);
}

void testADCRReg(System system, int opcode, Register16 register) {
  final List<int> opcodes = <int>[0xFD, opcode];

  system.load(0x0000, opcodes);
  system.load(0x10001, <int>[51]);
  system.cpu.a.value = 2;
  register.value = 0x0001;
  system.cpu.t.c = false;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(11));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(system.cpu.a.value, equals(53));

  expect(system.cpu.t.c, isFalse);
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.v, isFalse);
  expect(system.cpu.t.h, isFalse);
}

void testADIRReg(System system, int opcode, Register16 register, {bool me1 = false}) {
  final List<int> opcodes = <int>[0xFD, opcode, 0x20];
  final LH5801Flags flags = system.cpu.t.clone();

  system.load(0x0000, opcodes);
  system.load(0x10001, <int>[0x33]);
  register.value = 0x0001;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(17));
  expect(system.cpu.p.value, equals(opcodes.length));

  final int result = system.memRead((me1 ? 0x10000 : 0) + register.value);
  expect(result, equals(0x53));

  expect(system.cpu.t.h, isFalse);
  expect(system.cpu.t.v, isFalse);
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, isFalse);
}

void testLDARReg(System system, int opcode, Register16 register) {
  void _test(int initialValue, Matcher hFlagMatcher) {
    final List<int> opcodes = <int>[0xFD, opcode];
    final LH5801Flags flags = system.cpu.t.clone();

    system.load(0x0000, opcodes);
    system.load(0x10001, <int>[initialValue]);
    system.cpu.a.value = 2;
    register.value = 0x0001;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(10));
    expect(system.cpu.p.value, equals(opcodes.length));

    expect(system.cpu.a.value, equals(initialValue));

    // Z should be the only flag updated.
    expect(system.cpu.t.h, equals(flags.h));
    expect(system.cpu.t.v, equals(flags.v));
    expect(system.cpu.t.z, hFlagMatcher);
    expect(system.cpu.t.ie, equals(flags.ie));
    expect(system.cpu.t.c, equals(flags.c));
  }

  _test(0, isTrue);
  _test(0xFD, isFalse);
}

void testCPARReg(System system, int opcode, Register16 register) {
  final List<int> opcodes = <int>[0xFD, opcode];

  system.load(0x0000, opcodes);
  system.load(0x10001, <int>[80]);
  system.cpu.a.value = 84;
  register.value = 0x0001;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(11));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(system.cpu.t.c, isTrue);
  expect(system.cpu.t.z, isFalse);
}

void testANDRReg(System system, int opcode, Register16 register) {
  final List<int> opcodes = <int>[0xFD, opcode];
  final LH5801Flags flags = system.cpu.t.clone();

  system.load(0x0000, opcodes);
  system.load(0x10001, <int>[0x0F]);
  system.cpu.a.value = 0xFF;
  register.value = 0x0001;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(11));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(system.cpu.a.value, equals(0x0F));

  // Z should be the only flag updated.
  expect(system.cpu.t.h, equals(flags.h));
  expect(system.cpu.t.v, equals(flags.v));
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, equals(flags.c));
}

void testANIRReg(System system, int opcode, Register16 register, {bool me1 = false}) {
  final List<int> opcodes = <int>[0xFD, opcode, 0x0F];
  final LH5801Flags flags = system.cpu.t.clone();

  system.load(0x0000, opcodes);
  system.load(0x10001, <int>[0xF0]);
  register.value = 0x0001;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(17));
  expect(system.cpu.p.value, equals(opcodes.length));

  final int result = system.memRead((me1 ? 0x10000 : 0) + register.value);
  expect(result, equals(0x00));

  // Z should be the only flag updated.
  expect(system.cpu.t.h, equals(flags.h));
  expect(system.cpu.t.v, equals(flags.v));
  expect(system.cpu.t.z, isTrue);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, equals(flags.c));
}

void testPOPRReg(System system, int opcode, Register16 register) {
  void _test(int intialValue) {
    final List<int> opcodes = <int>[0xFD, opcode];
    final int statusRegister = system.cpu.t.statusRegister;
    const int initialStackValue = 0x46FD;

    system.load(0x0000, opcodes);
    system.cpu.s.value = initialStackValue;
    system.load(initialStackValue + 1, <int>[intialValue >> 8, intialValue & 0xFF]);
    register.value = 0;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(15));
    expect(system.cpu.p.value, equals(opcodes.length));

    expect(register.value, equals(intialValue));
    expect(system.cpu.s.value, equals(initialStackValue + 2));

    expect(system.cpu.t.statusRegister, equals(statusRegister));
  }

  _test(0x2030);
  _test(0x0000);
}

void testPOPA(System system) {
  void _test(int intialValue, Matcher zFlagMatcher) {
    final List<int> opcodes = <int>[0xFD, 0x8A];
    final LH5801Flags flags = system.cpu.t.clone();
    const int initialStackValue = 0x46FF;

    system.load(0x0000, opcodes);
    system.cpu.s.value = initialStackValue;
    system.load(initialStackValue + 1, <int>[intialValue]);
    system.cpu.a.value = 0;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(12));
    expect(system.cpu.p.value, equals(opcodes.length));

    expect(system.cpu.a.value, equals(intialValue));
    expect(system.cpu.s.value, equals(initialStackValue + 1));

    // Z should be the only flag updated.
    expect(system.cpu.t.h, equals(flags.h));
    expect(system.cpu.t.v, equals(flags.v));
    expect(system.cpu.t.z, zFlagMatcher);
    expect(system.cpu.t.ie, equals(flags.ie));
    expect(system.cpu.t.c, equals(flags.c));
  }

  _test(0x23, isFalse);
  _test(0x00, isTrue);
}

void testORARReg(System system, int opcode, Register16 register) {
  final List<int> opcodes = <int>[0xFD, opcode];
  final LH5801Flags flags = system.cpu.t.clone();

  system.load(0x0000, opcodes);
  system.load(0x10001, <int>[0x00]);
  system.cpu.a.value = 0x00;
  register.value = 0x0001;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(11));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(system.cpu.a.value, equals(0));

  // Z should be the only flag updated.
  expect(system.cpu.t.h, equals(flags.h));
  expect(system.cpu.t.v, equals(flags.v));
  expect(system.cpu.t.z, isTrue);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, equals(flags.c));
}

void testORIRReg(System system, int opcode, Register16 register, {bool me1 = false}) {
  final List<int> opcodes = <int>[0xFD, opcode, 0x0F];
  final LH5801Flags flags = system.cpu.t.clone();

  system.load(0x0000, opcodes);
  system.load(0x10001, <int>[0xF0]);
  register.value = 0x0001;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(17));
  expect(system.cpu.p.value, equals(opcodes.length));

  final int result = system.memRead((me1 ? 0x10000 : 0) + register.value);
  expect(result, equals(0xFF));

  // Z should be the only flag updated.
  expect(system.cpu.t.h, equals(flags.h));
  expect(system.cpu.t.v, equals(flags.v));
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, equals(flags.c));
}

void testDCSRReg(System system, int opcode, Register16 register) {
  void _test(
    int initialOp1Value,
    int initialOp2Value,
    bool initialCarryValue,
    int expectedAccValue,
    Matcher cFlagMatcher,
    Matcher hFlagMatcher,
  ) {
    final List<int> opcodes = <int>[0xFD, opcode];

    system.load(0x0000, opcodes);
    system.load(0x10001, <int>[initialOp2Value]);
    system.cpu.a.value = initialOp1Value;
    register.value = 0x0001;
    system.cpu.t.c = initialCarryValue;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(17));
    expect(system.cpu.p.value, equals(opcodes.length));

    expect(system.cpu.a.value, expectedAccValue);

    expect(system.cpu.t.c, cFlagMatcher);
    expect(system.cpu.t.h, hFlagMatcher);
  }

  _test(0x42, 0x31, true, 0x11, isTrue, isTrue);
  _test(0x42, 0x31, false, 0x10, isTrue, isTrue);
  _test(0x23, 0x54, true, 0x69, isFalse, isFalse);
  _test(0x23, 0x54, false, 0x68, isFalse, isFalse);
}

void testEORRReg(System system, int opcode, Register16 register) {
  void _test(
    int initialOp1Value,
    int initialOp2Value,
    int expectedAccValue,
    Matcher zFlagMatcher,
  ) {
    final List<int> opcodes = <int>[0xFD, opcode];
    final LH5801Flags flags = system.cpu.t.clone();

    system.load(0x0000, opcodes);
    system.load(0x10001, <int>[0x6D]);
    system.cpu.a.value = 0x36;
    register.value = 0x0001;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(11));
    expect(system.cpu.p.value, equals(opcodes.length));

    expect(system.cpu.a.value, equals(0x5B));

    // Z should be the only flag updated.
    expect(system.cpu.t.h, equals(flags.h));
    expect(system.cpu.t.v, equals(flags.v));
    expect(system.cpu.t.z, isFalse);
    expect(system.cpu.t.ie, equals(flags.ie));
    expect(system.cpu.t.c, equals(flags.c));
  }

  _test(0x36, 0x6D, 0x5B, isFalse);
  _test(0x00, 0x00, 0x00, isTrue);
}

void testSTARReg(System system, int opcode, Register16 register) {
  final List<int> opcodes = <int>[0xFD, opcode];
  final int statusRegister = system.cpu.t.statusRegister;

  system.load(0x0000, opcodes);
  system.cpu.a.value = 0x33;
  register.value = 0x0001;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(10));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(system.memRead(0x10000 | system.cpu.x.value), equals(system.cpu.a.value));

  expect(system.cpu.t.statusRegister, equals(statusRegister));
}

void testBITRReg(System system, int opcode, Register16 register) {
  final List<int> opcodes = <int>[0xFD, opcode];
  final LH5801Flags flags = system.cpu.t.clone();

  system.load(0x0000, opcodes);
  system.load(0x10001, <int>[0x0F]);
  system.cpu.a.value = 0x80;
  register.value = 0x0001;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(11));
  expect(system.cpu.p.value, equals(opcodes.length));

  // Accumulator should not be updated.
  expect(system.cpu.a.value, equals(0x80));

  // Z should be the only flag updated.
  expect(system.cpu.t.h, equals(flags.h));
  expect(system.cpu.t.v, equals(flags.v));
  expect(system.cpu.t.z, isTrue);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, equals(flags.c));
}

void testBIIRReg(System system, int opcode, Register16 register, {bool me1 = false}) {
  final List<int> opcodes = <int>[0xFD, opcode, 0x0F];
  final LH5801Flags flags = system.cpu.t.clone();

  system.load(0x0000, opcodes);
  system.load(0x10001, <int>[0xF0]);
  register.value = 0x0001;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(14));
  expect(system.cpu.p.value, equals(opcodes.length));

  // Memory should not be updated.
  final int result = system.memRead((me1 ? 0x10000 : 0) + register.value);
  expect(result, equals(0xF0));

  // Z should be the only flag updated.
  expect(system.cpu.t.h, equals(flags.h));
  expect(system.cpu.t.v, equals(flags.v));
  expect(system.cpu.t.z, isTrue);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, equals(flags.c));
}

void testIncReg8(System system, int opcode, int Function() get, void Function(int) set) {
  final List<int> opcodes = <int>[0xFD, opcode];
  final LH5801Flags flags = system.cpu.t.clone();

  system.load(0x0000, opcodes);
  set(0x80); // -128
  final int cycles = system.step(0x0000);
  expect(cycles, equals(9));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(get(), equals(0x81)); // -127

  expect(system.cpu.t.h, isFalse);
  expect(system.cpu.t.v, isFalse);
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, isFalse);
}

void testDecReg8(System system, int opcode, int Function() get, void Function(int) set) {
  final List<int> opcodes = <int>[0xFD, opcode];
  final LH5801Flags flags = system.cpu.t.clone();

  system.load(0x0000, opcodes);
  set(0x00);
  final int cycles = system.step(0x0000);
  expect(cycles, equals(9));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(get(), equals(0xFF));

  expect(system.cpu.t.h, isFalse);
  expect(system.cpu.t.v, isFalse);
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, isFalse);
}

void testLDXReg(System system, int opcode, Register16 register) {
  final List<int> opcodes = <int>[0xFD, opcode];
  final int statusRegister = system.cpu.t.statusRegister;

  system.load(0x0000, opcodes);
  register.value = 25;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(11));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(system.cpu.x.value, equals(25));

  expect(system.cpu.t.statusRegister, statusRegister);
}

void testSTXReg(System system, int opcode, Register16 register) {
  final List<int> opcodes = <int>[0xFD, opcode];
  final int statusRegister = system.cpu.t.statusRegister;

  system.load(0x0000, opcodes);
  system.cpu.x.value = 25;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(11));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(register.value, equals(25));

  expect(system.cpu.t.statusRegister, statusRegister);
}

void testPSHRReg(System system, int opcode, Register16 register) {
  final List<int> opcodes = <int>[0xFD, opcode];
  final int statusRegister = system.cpu.t.statusRegister;

  system.load(0x0000, opcodes);
  system.cpu.s.value = 0x46FF;
  register.value = 0x2030;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(14));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(system.cpu.s.value, equals(0x46FF - 2));
  expect(system.memRead(0x46FF), equals(0x30));
  expect(system.memRead(0x46FE), equals(0x20));
  expect(register.value, equals(0x2030));

  expect(system.cpu.t.statusRegister, statusRegister);
}

void testDCARReg(System system, int opcode, Register16 register, {bool me1 = false}) {
  void _test(
    int initialOp1Value,
    int initialOp2Value,
    bool initialCarryValue,
    int expectedAccValue,
    Matcher cFlagMatcher,
    Matcher hFlagMatcher,
  ) {
    final List<int> opcodes = <int>[0xFD, opcode];

    system.load(0x0000, opcodes);
    system.load(0x10001, <int>[initialOp2Value]);
    system.cpu.a.value = initialOp1Value;
    register.value = 0x0001;
    system.cpu.t.c = initialCarryValue;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(19));
    expect(system.cpu.p.value, equals(opcodes.length));

    expect(system.cpu.a.value, expectedAccValue);

    expect(system.cpu.t.c, cFlagMatcher);
    expect(system.cpu.t.h, hFlagMatcher);
  }

  _test(0x35, 0x27, false, 0x62, isFalse, isTrue);
  _test(0x35, 0x27, true, 0x63, isFalse, isTrue);
  _test(0x35, 0x67, false, 0x02, isTrue, isTrue);
  _test(0x35, 0x67, true, 0x03, isTrue, isTrue);
}
