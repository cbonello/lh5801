import 'dart:typed_data';

import 'package:lh5801/lh5801.dart';
import 'package:test/test.dart';

int unsignedByteToInt(int value) {
  if (value & 0x80 != 0) {
    return -((0xff & ~value) + 1);
  }
  return value;
}

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

void testSBCReg(System system, List<int> opcodes, Register8 register) {
  system.load(0x0000, opcodes);
  system.cpu.a.value = 56;
  register.value = 33;
  system.cpu.t.c = true;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(6));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(system.cpu.a.value, equals(23));

  expect(system.cpu.t.c, isTrue);
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.v, isFalse);
  expect(system.cpu.t.h, isTrue);
}

void testSBCRReg(
  System system,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  final int rregValue = me1 ? 0x10100 : 0x0100;

  system.load(0x0000, opcodes);
  register.value = rregValue;
  system.load(rregValue, <int>[33]);
  system.cpu.a.value = 56;
  system.cpu.t.c = true;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(expectedCycles));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(system.cpu.a.value, equals(23));

  expect(system.cpu.t.c, isTrue);
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.v, isFalse);
  expect(system.cpu.t.h, isTrue);
}

void testSBCab(System system, int expectedCycles, List<int> opcodes, {bool me1 = false}) {
  final int ab = me1 ? 0x11234 : 0x1234;
  final List<int> memOpcodes = <int>[...opcodes, (ab >> 8) & 0xFF, ab & 0xFF];

  system.load(0x0000, memOpcodes);
  system.load(ab, <int>[33]);
  system.cpu.a.value = 56;
  system.cpu.t.c = true;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(expectedCycles));
  expect(system.cpu.p.value, equals(memOpcodes.length));

  expect(system.cpu.a.value, equals(23));

  expect(system.cpu.t.c, isTrue);
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.v, isFalse);
  expect(system.cpu.t.h, isTrue);
}

void testADCReg(System system, List<int> opcodes, Register8 register) {
  system.load(0x0000, opcodes);
  system.cpu.a.value = 2;
  register.value = 51;
  system.cpu.t.c = false;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(6));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(system.cpu.a.value, equals(53));

  expect(system.cpu.t.c, isFalse);
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.v, isFalse);
  expect(system.cpu.t.h, isFalse);
}

void testADCRReg(
  System system,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  final int rregValue = me1 ? 0x10100 : 0x0100;

  system.load(0x0000, opcodes);
  register.value = rregValue;
  system.load(rregValue, <int>[51]);
  system.cpu.a.value = 2;
  system.cpu.t.c = false;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(expectedCycles));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(system.cpu.a.value, equals(53));

  expect(system.cpu.t.c, isFalse);
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.v, isFalse);
  expect(system.cpu.t.h, isFalse);
}

void testADCab(System system, int expectedCycles, List<int> opcodes, {bool me1 = false}) {
  final int ab = me1 ? 0x11234 : 0x1234;
  final List<int> memOpcodes = <int>[...opcodes, (ab >> 8) & 0xFF, ab & 0xFF];

  system.load(0x0000, memOpcodes);
  system.load(ab, <int>[33]);
  system.cpu.a.value = 2;
  system.cpu.t.c = false;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(expectedCycles));
  expect(system.cpu.p.value, equals(memOpcodes.length));

  expect(system.cpu.a.value, equals(35));

  expect(system.cpu.t.c, isFalse);
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.v, isFalse);
  expect(system.cpu.t.h, isFalse);
}

void testADIAcc(System system) {
  final List<int> memOpcodes = <int>[0xB3, 0x20];
  final LH5801Flags flags = system.cpu.t.clone();

  system.load(0x0000, memOpcodes);
  system.cpu.a.value = 0x33;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(7));
  expect(system.cpu.p.value, equals(memOpcodes.length));

  expect(system.cpu.a.value, equals(0x53));

  expect(system.cpu.t.h, isFalse);
  expect(system.cpu.t.v, isFalse);
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, isFalse);
}

void testADIRReg(
  System system,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  final int regValue = me1 ? 0x10100 : 0x0100;
  final List<int> memOpcodes = <int>[...opcodes, 0x20];
  final LH5801Flags flags = system.cpu.t.clone();

  system.load(0x0000, memOpcodes);
  register.value = regValue;
  system.load(regValue, <int>[0x33]);
  final int cycles = system.step(0x0000);
  expect(cycles, equals(expectedCycles));
  expect(system.cpu.p.value, equals(memOpcodes.length));

  final int result = system.memRead(regValue);
  expect(result, equals(0x53));

  expect(system.cpu.t.h, isFalse);
  expect(system.cpu.t.v, isFalse);
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, isFalse);
}

void testADIab(System system, int expectedCycles, List<int> opcodes, {bool me1 = false}) {
  final int ab = me1 ? 0x11234 : 0x1234;
  final List<int> memOpcodes = <int>[
    ...opcodes,
    (ab >> 8) & 0xFF,
    ab & 0xFF,
    0x20,
  ];
  final LH5801Flags flags = system.cpu.t.clone();

  system.load(0x0000, memOpcodes);
  system.load(ab, <int>[0x33]);
  final int cycles = system.step(0x0000);
  expect(cycles, equals(expectedCycles));
  expect(system.cpu.p.value, equals(memOpcodes.length));

  final int result = system.memRead(ab);
  expect(result, equals(0x53));

  expect(system.cpu.t.h, isFalse);
  expect(system.cpu.t.v, isFalse);
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, isFalse);
}

void testLDAReg(System system, List<int> opcodes, Register8 register) {
  void _test(int initialValue, Matcher hFlagMatcher) {
    final LH5801Flags flags = system.cpu.t.clone();

    system.load(0x0000, opcodes);
    system.cpu.a.value = 2;
    register.value = initialValue;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(5));
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

void testLDARReg(
  System system,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  void _test(int initialValue, Matcher hFlagMatcher) {
    final int rregValue = me1 ? 0x10100 : 0x0100;
    final LH5801Flags flags = system.cpu.t.clone();

    system.load(0x0000, opcodes);
    register.value = rregValue;
    system.load(rregValue, <int>[initialValue]);
    system.cpu.a.value = 2;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(expectedCycles));
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

void testLDAab(System system, int expectedCycles, List<int> opcodes, {bool me1 = false}) {
  void _test(int initialValue, Matcher hFlagMatcher) {
    final int ab = me1 ? 0x11234 : 0x1234;
    final List<int> memOpcodes = <int>[...opcodes, (ab >> 8) & 0xFF, ab & 0xFF];
    final LH5801Flags flags = system.cpu.t.clone();

    system.load(0x0000, memOpcodes);
    system.load(ab, <int>[initialValue]);
    system.cpu.a.value = 0;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(expectedCycles));
    expect(system.cpu.p.value, equals(memOpcodes.length));

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

void testCPAReg(System system, List<int> opcodes, Register8 register) {
  void _test(int op1, int op2, Matcher cFlagMatcher, Matcher zFlagMatcher) {
    system.load(0x0000, opcodes);
    system.cpu.a.value = op1;
    register.value = op2;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(6));
    expect(system.cpu.p.value, equals(opcodes.length));

    expect(system.cpu.t.c, cFlagMatcher);
    expect(system.cpu.t.z, zFlagMatcher);
  }

  _test(84, 80, isTrue, isFalse);
  _test(2, 2, isTrue, isTrue);
  _test(84, 110, isFalse, isFalse);
}

void testCPARReg(
  System system,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  void _test(int op1, int op2, Matcher cFlagMatcher, Matcher zFlagMatcher) {
    final int rregValue = me1 ? 0x10100 : 0x0100;

    system.load(0x0000, opcodes);
    register.value = rregValue;
    system.load(rregValue, <int>[op2]);
    system.cpu.a.value = op1;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(expectedCycles));
    expect(system.cpu.p.value, equals(opcodes.length));

    expect(system.cpu.t.c, cFlagMatcher);
    expect(system.cpu.t.z, zFlagMatcher);
  }

  _test(84, 80, isTrue, isFalse);
  _test(2, 2, isTrue, isTrue);
  _test(84, 110, isFalse, isFalse);
}

void testCPAab(System system, int expectedCycles, List<int> opcodes, {bool me1 = false}) {
  final int ab = me1 ? 0x11234 : 0x1234;
  final List<int> memOpcodes = <int>[...opcodes, (ab >> 8) & 0xFF, ab & 0xFF];

  system.load(0x0000, memOpcodes);
  system.load(ab, <int>[80]);
  system.cpu.a.value = 84;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(expectedCycles));
  expect(system.cpu.p.value, equals(memOpcodes.length));

  expect(system.cpu.t.c, isTrue);
  expect(system.cpu.t.z, isFalse);
}

void testANDRReg(
  System system,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  void _test(int op1, int op2, Matcher zFlagMatcher) {
    final int rregValue = me1 ? 0x10100 : 0x0100;
    final LH5801Flags flags = system.cpu.t.clone();

    system.load(0x0000, opcodes);
    register.value = rregValue;
    system.load(rregValue, <int>[op2]);
    system.cpu.a.value = op1;
    register.value = rregValue;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(expectedCycles));
    expect(system.cpu.p.value, equals(opcodes.length));

    expect(system.cpu.a.value, equals((op1 & op2) & 0xFF));

    // Z should be the only flag updated.
    expect(system.cpu.t.h, equals(flags.h));
    expect(system.cpu.t.v, equals(flags.v));
    expect(system.cpu.t.z, zFlagMatcher);
    expect(system.cpu.t.ie, equals(flags.ie));
    expect(system.cpu.t.c, equals(flags.c));
  }

  _test(0xF0, 0x0F, isTrue);
  _test(0xFF, 0x0F, isFalse);
}

void testANDab(System system, int expectedCycles, List<int> opcodes, {bool me1 = false}) {
  final int ab = me1 ? 0x11234 : 0x1234;
  final List<int> memOpcodes = <int>[...opcodes, (ab >> 8) & 0xFF, ab & 0xFF];
  final LH5801Flags flags = system.cpu.t.clone();

  system.load(0x0000, memOpcodes);
  system.load(ab, <int>[0x0F]);
  system.cpu.a.value = 0xFF;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(expectedCycles));
  expect(system.cpu.p.value, equals(memOpcodes.length));

  expect(system.cpu.a.value, equals(0x0F));

  // Z should be the only flag updated.
  expect(system.cpu.t.h, equals(flags.h));
  expect(system.cpu.t.v, equals(flags.v));
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, equals(flags.c));
}

void testANIAcc(System system) {
  void _test(int accValue, int i, Matcher zFlagMatcher) {
    final List<int> memOpcodes = <int>[0xB9, i & 0xFF];
    final LH5801Flags flags = system.cpu.t.clone();

    system.load(0x0000, memOpcodes);
    system.cpu.a.value = accValue;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(7));
    expect(system.cpu.p.value, equals(memOpcodes.length));

    expect(system.cpu.a.value, equals((accValue & i) & 0xFF));

    // Z should be the only flag updated.
    expect(system.cpu.t.h, equals(flags.h));
    expect(system.cpu.t.v, equals(flags.v));
    expect(system.cpu.t.z, zFlagMatcher);
    expect(system.cpu.t.ie, equals(flags.ie));
    expect(system.cpu.t.c, equals(flags.c));
  }

  _test(0xF0, 0x0F, isTrue);
  _test(0x12, 0x36, isFalse);
}

void testANIRReg(
  System system,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  void _test(int memValue, int i, Matcher zFlagMatcher) {
    final List<int> memOpcodes = <int>[...opcodes, i & 0xFF];
    final LH5801Flags flags = system.cpu.t.clone();
    final int memAddress = me1 ? 0x10100 : 0x0100;

    system.load(0x0000, memOpcodes);
    register.value = memAddress;
    system.load(memAddress, <int>[memValue]);
    final int cycles = system.step(0x0000);
    expect(cycles, equals(expectedCycles));
    expect(system.cpu.p.value, equals(memOpcodes.length));

    final int result = system.memRead(memAddress);
    expect(result, equals((memValue & i) & 0xFF));

    // Z should be the only flag updated.
    expect(system.cpu.t.h, equals(flags.h));
    expect(system.cpu.t.v, equals(flags.v));
    expect(system.cpu.t.z, zFlagMatcher);
    expect(system.cpu.t.ie, equals(flags.ie));
    expect(system.cpu.t.c, equals(flags.c));
  }

  _test(0xF0, 0x0F, isTrue);
  _test(0x12, 0x36, isFalse);
}

void testANIab(System system, int expectedCycles, List<int> opcodes, {bool me1 = false}) {
  void _test(int memValue, int i, Matcher zFlagMatcher) {
    final int ab = me1 ? 0x16001 : 0x6001;
    final List<int> memOpcodes = <int>[...opcodes, (ab >> 8) & 0xFF, ab & 0xFF, i & 0xFF];
    final LH5801Flags flags = system.cpu.t.clone();

    system.load(0x0000, memOpcodes);
    system.load(ab, <int>[memValue]);
    final int cycles = system.step(0x0000);
    expect(cycles, equals(expectedCycles));
    expect(system.cpu.p.value, equals(memOpcodes.length));

    final int result = system.memRead(ab);
    expect(result, equals((memValue & i) & 0xFF));

    // Z should be the only flag updated.
    expect(system.cpu.t.h, equals(flags.h));
    expect(system.cpu.t.v, equals(flags.v));
    expect(system.cpu.t.z, zFlagMatcher);
    expect(system.cpu.t.ie, equals(flags.ie));
    expect(system.cpu.t.c, equals(flags.c));
  }

  _test(0xF0, 0x0F, isTrue);
  _test(0x12, 0x36, isFalse);
}

void testPOPRReg(System system, List<int> opcodes, Register16 register) {
  void _test(int intialValue) {
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

void testORARReg(
  System system,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  void _test(int op1, int op2, Matcher zFlagMatcher) {
    final int rregValue = me1 ? 0x10100 : 0x0100;
    final LH5801Flags flags = system.cpu.t.clone();

    system.load(0x0000, opcodes);
    register.value = rregValue;
    system.load(rregValue, <int>[op2]);
    system.cpu.a.value = op1;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(expectedCycles));
    expect(system.cpu.p.value, equals(opcodes.length));

    expect(system.cpu.a.value, equals((op1 | op2) & 0xFF));

    // Z should be the only flag updated.
    expect(system.cpu.t.h, equals(flags.h));
    expect(system.cpu.t.v, equals(flags.v));
    expect(system.cpu.t.z, zFlagMatcher);
    expect(system.cpu.t.ie, equals(flags.ie));
    expect(system.cpu.t.c, equals(flags.c));
  }

  _test(0x58, 0x27, isFalse);
  _test(0x00, 0x00, isTrue);
}

void testORAab(System system, int expectedCycles, List<int> opcodes, {bool me1 = false}) {
  void _test(int op1, int op2, Matcher zFlagMatcher) {
    final int ab = me1 ? 0x11234 : 0x1234;
    final List<int> memOpcodes = <int>[...opcodes, (ab >> 8) & 0xFF, ab & 0xFF];
    final LH5801Flags flags = system.cpu.t.clone();

    system.load(0x0000, memOpcodes);
    system.load(ab, <int>[op2]);
    system.cpu.a.value = op1;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(expectedCycles));
    expect(system.cpu.p.value, equals(memOpcodes.length));

    expect(system.cpu.a.value, equals((op1 | op2) & 0xFF));

    // Z should be the only flag updated.
    expect(system.cpu.t.h, equals(flags.h));
    expect(system.cpu.t.v, equals(flags.v));
    expect(system.cpu.t.z, zFlagMatcher);
    expect(system.cpu.t.ie, equals(flags.ie));
    expect(system.cpu.t.c, equals(flags.c));
  }

  _test(0x58, 0x27, isFalse);
  _test(0x00, 0x00, isTrue);
}

void testORIAcc(System system) {
  void _test(int accValue, int i, Matcher zFlagMatcher) {
    final List<int> memOpcodes = <int>[0xBB, i & 0xFF];
    final LH5801Flags flags = system.cpu.t.clone();

    system.load(0x0000, memOpcodes);
    system.cpu.a.value = accValue;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(7));
    expect(system.cpu.p.value, equals(memOpcodes.length));

    expect(system.cpu.a.value, equals((accValue | i) & 0xFF));

    // Z should be the only flag updated.
    expect(system.cpu.t.h, equals(flags.h));
    expect(system.cpu.t.v, equals(flags.v));
    expect(system.cpu.t.z, zFlagMatcher);
    expect(system.cpu.t.ie, equals(flags.ie));
    expect(system.cpu.t.c, equals(flags.c));
  }

  _test(0x00, 0x00, isTrue);
  _test(0x10, 0x01, isFalse);
}

void testORIRReg(
  System system,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  void _test(int memValue, int i, Matcher zFlagMatcher) {
    final int ab = me1 ? 0x10101 : 0x0101;
    final List<int> memOpcodes = <int>[...opcodes, i & 0xFF];
    final LH5801Flags flags = system.cpu.t.clone();

    system.load(0x0000, memOpcodes);
    system.load(ab, <int>[memValue]);
    register.value = ab;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(expectedCycles));
    expect(system.cpu.p.value, equals(memOpcodes.length));

    final int result = system.memRead(ab);
    expect(result, equals((memValue | i) & 0xFF));

    // Z should be the only flag updated.
    expect(system.cpu.t.h, equals(flags.h));
    expect(system.cpu.t.v, equals(flags.v));
    expect(system.cpu.t.z, zFlagMatcher);
    expect(system.cpu.t.ie, equals(flags.ie));
    expect(system.cpu.t.c, equals(flags.c));
  }

  _test(0x00, 0x00, isTrue);
  _test(0x10, 0x01, isFalse);
}

void testORIab(System system, int expectedCycles, List<int> opcodes, {bool me1 = false}) {
  void _test(int memValue, int i, Matcher zFlagMatcher) {
    final int ab = me1 ? 0x10101 : 0x0101;
    final List<int> memOpcodes = <int>[...opcodes, (ab >> 8) & 0xFF, ab & 0xFF, i & 0xFF];
    final LH5801Flags flags = system.cpu.t.clone();

    system.load(0x0000, memOpcodes);
    system.load(ab, <int>[memValue]);
    final int cycles = system.step(0x0000);
    expect(cycles, equals(expectedCycles));
    expect(system.cpu.p.value, equals(memOpcodes.length));

    final int result = system.memRead(ab);
    expect(result, equals((memValue | i) & 0xFF));

    // Z should be the only flag updated.
    expect(system.cpu.t.h, equals(flags.h));
    expect(system.cpu.t.v, equals(flags.v));
    expect(system.cpu.t.z, zFlagMatcher);
    expect(system.cpu.t.ie, equals(flags.ie));
    expect(system.cpu.t.c, equals(flags.c));
  }

  _test(0x00, 0x00, isTrue);
  _test(0x10, 0x01, isFalse);
}

void testDCSRReg(
  System system,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  void _test(
    int initialOp1Value,
    int initialOp2Value,
    bool initialCarryValue,
    int expectedAccValue,
    Matcher cFlagMatcher,
    Matcher hFlagMatcher,
  ) {
    final int rregValue = me1 ? 0x10100 : 0x0100;

    system.load(0x0000, opcodes);
    register.value = rregValue;
    system.load(rregValue, <int>[initialOp2Value]);
    system.cpu.a.value = initialOp1Value;
    system.cpu.t.c = initialCarryValue;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(expectedCycles));
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

void testEORRReg(
  System system,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  void _test(
    int initialOp1Value,
    int initialOp2Value,
    int expectedAccValue,
    Matcher zFlagMatcher,
  ) {
    final int rregValue = me1 ? 0x10100 : 0x0100;
    final LH5801Flags flags = system.cpu.t.clone();

    system.load(0x0000, opcodes);
    register.value = rregValue;
    system.load(rregValue, <int>[initialOp2Value]);
    system.cpu.a.value = initialOp1Value;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(expectedCycles));
    expect(system.cpu.p.value, equals(opcodes.length));

    expect(system.cpu.a.value, equals(expectedAccValue));

    // Z should be the only flag updated.
    expect(system.cpu.t.h, equals(flags.h));
    expect(system.cpu.t.v, equals(flags.v));
    expect(system.cpu.t.z, zFlagMatcher);
    expect(system.cpu.t.ie, equals(flags.ie));
    expect(system.cpu.t.c, equals(flags.c));
  }

  _test(0x36, 0x6D, 0x5B, isFalse);
  _test(0x00, 0x00, 0x00, isTrue);
}

void testEORab(System system, int expectedCycles, List<int> opcodes, {bool me1 = false}) {
  void _test(
    int initialOp1Value,
    int initialOp2Value,
    int expectedAccValue,
    Matcher zFlagMatcher,
  ) {
    final int ab = me1 ? 0x11234 : 0x1234;
    final List<int> memOpcodes = <int>[...opcodes, (ab >> 8) & 0xFF, ab & 0xFF];
    final LH5801Flags flags = system.cpu.t.clone();

    system.load(0x0000, memOpcodes);
    system.load(ab, <int>[initialOp2Value]);
    system.cpu.a.value = initialOp1Value;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(expectedCycles));
    expect(system.cpu.p.value, equals(memOpcodes.length));

    expect(system.cpu.a.value, equals(expectedAccValue));

    // Z should be the only flag updated.
    expect(system.cpu.t.h, equals(flags.h));
    expect(system.cpu.t.v, equals(flags.v));
    expect(system.cpu.t.z, zFlagMatcher);
    expect(system.cpu.t.ie, equals(flags.ie));
    expect(system.cpu.t.c, equals(flags.c));
  }

  _test(0x36, 0x6D, 0x5B, isFalse);
  _test(0x00, 0x00, 0x00, isTrue);
}

void testSTAReg(System system, List<int> opcodes, Register8 register) {
  final int statusRegister = system.cpu.t.statusRegister;

  system.load(0x0000, opcodes);
  system.cpu.a.value = 0x33;
  register.value = 0x01;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(5));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(register.value, equals(system.cpu.a.value));

  expect(system.cpu.t.statusRegister, equals(statusRegister));
}

void testSTARReg(
  System system,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  final int rregValue = me1 ? 0x10100 : 0x0100;
  final int statusRegister = system.cpu.t.statusRegister;

  system.load(0x0000, opcodes);
  system.cpu.a.value = 0x33;
  register.value = rregValue;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(expectedCycles));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(system.memRead(rregValue), equals(system.cpu.a.value));

  expect(system.cpu.t.statusRegister, equals(statusRegister));
}

void testSTAab(System system, int expectedCycles, List<int> opcodes, {bool me1 = false}) {
  final int ab = me1 ? 0x1CB00 : 0xCB00;
  final List<int> memOpcodes = <int>[...opcodes, (ab >> 8) & 0xFF, ab & 0xFF];
  final int statusRegister = system.cpu.t.statusRegister;

  system.load(0x0000, memOpcodes);
  system.load(ab, <int>[0xFF]);
  system.cpu.a.value = 0x51;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(expectedCycles));
  expect(system.cpu.p.value, equals(memOpcodes.length));

  expect(system.cpu.a.value, equals(system.memRead(ab)));

  expect(system.cpu.t.statusRegister, equals(statusRegister));
}

void testBITRReg(
  System system,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  void _test(int memValue, int i, Matcher zFlagMatcher) {
    final int regValue = me1 ? 0x10100 : 0x0100;
    final LH5801Flags flags = system.cpu.t.clone();

    system.load(0x0000, opcodes);
    register.value = regValue;
    system.load(regValue, <int>[memValue]);
    system.cpu.a.value = i;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(expectedCycles));
    expect(system.cpu.p.value, equals(opcodes.length));

    // Accumulator should not be updated.
    expect(system.cpu.a.value, equals(i));

    // Z should be the only flag updated.
    expect(system.cpu.t.h, equals(flags.h));
    expect(system.cpu.t.v, equals(flags.v));
    expect(system.cpu.t.z, zFlagMatcher);
    expect(system.cpu.t.ie, equals(flags.ie));
    expect(system.cpu.t.c, equals(flags.c));
  }

  _test(0x0F, 0x80, isTrue);
  _test(0x10, 0x30, isFalse);
}

void testBITab(System system, int expectedCycles, List<int> opcodes, {bool me1 = false}) {
  void _test(int accValue, int abValue, Matcher zFlagMatcher) {
    final int ab = me1 ? 0x1CB00 : 0xCB00;
    final List<int> memOpcodes = <int>[...opcodes, (abValue >> 8) & 0xFF, abValue & 0xFF];
    final LH5801Flags flags = system.cpu.t.clone();

    system.load(0x0000, memOpcodes);
    system.load(ab, <int>[abValue]);
    system.cpu.a.value = accValue;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(expectedCycles));
    expect(system.cpu.p.value, equals(memOpcodes.length));

    // Accumulator should not be updated.
    expect(system.cpu.a.value, equals(accValue));

    // Z should be the only flag updated.
    expect(system.cpu.t.h, equals(flags.h));
    expect(system.cpu.t.v, equals(flags.v));
    expect(system.cpu.t.z, isTrue);
    expect(system.cpu.t.ie, equals(flags.ie));
    expect(system.cpu.t.c, equals(flags.c));
  }

  _test(0x0F, 0x80, isTrue);
  _test(0x10, 0x30, isFalse);
}

void testBIIAcc(System system) {
  void _test(int accValue, int i, Matcher zFlagMatcher) {
    final List<int> memOpcodes = <int>[0xBF, i & 0xFF];
    final LH5801Flags flags = system.cpu.t.clone();

    system.load(0x0000, memOpcodes);
    system.cpu.a.value = accValue;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(7));
    expect(system.cpu.p.value, equals(memOpcodes.length));

    // Accumulator should not be updated.
    expect(system.cpu.a.value, accValue);

    // Z should be the only flag updated.
    expect(system.cpu.t.h, equals(flags.h));
    expect(system.cpu.t.v, equals(flags.v));
    expect(system.cpu.t.z, zFlagMatcher);
    expect(system.cpu.t.ie, equals(flags.ie));
    expect(system.cpu.t.c, equals(flags.c));
  }

  _test(0x0F, 0x80, isTrue);
  _test(0x10, 0x30, isFalse);
}

void testBIIRReg(
  System system,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  void _test(int memValue, int i, Matcher zFlagMatcher) {
    final int regValue = me1 ? 0x10100 : 0x0100;
    final List<int> memOpcodes = <int>[...opcodes, i & 0xFF];
    final LH5801Flags flags = system.cpu.t.clone();

    system.load(0x0000, memOpcodes);
    register.value = regValue;
    system.load(regValue, <int>[memValue]);
    final int cycles = system.step(0x0000);
    expect(cycles, equals(expectedCycles));
    expect(system.cpu.p.value, equals(memOpcodes.length));

    // Memory should not be updated.
    final int newMemValue = system.memRead(regValue);
    expect(newMemValue, memValue);

    // Z should be the only flag updated.
    expect(system.cpu.t.h, equals(flags.h));
    expect(system.cpu.t.v, equals(flags.v));
    expect(system.cpu.t.z, zFlagMatcher);
    expect(system.cpu.t.ie, equals(flags.ie));
    expect(system.cpu.t.c, equals(flags.c));
  }

  _test(0x0F, 0x80, isTrue);
  _test(0x10, 0x30, isFalse);
}

void testBIIab(System system, int expectedCycles, List<int> opcodes, {bool me1 = false}) {
  void _test(int memValue, int i, Matcher zFlagMatcher) {
    final int ab = me1 ? 0x1CB00 : 0xCB00;
    final List<int> memOpcodes = <int>[
      ...opcodes,
      (ab >> 8) & 0xFF,
      ab & 0xFF,
      i & 0xFF,
    ];
    final LH5801Flags flags = system.cpu.t.clone();

    system.load(0x0000, memOpcodes);
    system.load(ab, <int>[memValue]);
    final int cycles = system.step(0x0000);
    expect(cycles, equals(expectedCycles));
    expect(system.cpu.p.value, equals(memOpcodes.length));

    // Memory should not be updated.
    final int newABValue = system.memRead(ab);
    expect(newABValue, memValue);

    // Z should be the only flag updated.
    expect(system.cpu.t.h, equals(flags.h));
    expect(system.cpu.t.v, equals(flags.v));
    expect(system.cpu.t.z, zFlagMatcher);
    expect(system.cpu.t.ie, equals(flags.ie));
    expect(system.cpu.t.c, equals(flags.c));
  }

  _test(0x0F, 0x80, isTrue);
  _test(0x10, 0x30, isFalse);
}

void testIncReg8(
  System system,
  int expectedCycles,
  List<int> opcodes,
  Register8 register,
) {
  final LH5801Flags flags = system.cpu.t.clone();

  system.load(0x0000, opcodes);
  register.value = 0x80; // -128
  final int cycles = system.step(0x0000);
  expect(cycles, equals(expectedCycles));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(register.value, equals(0x81)); // -127

  expect(system.cpu.t.h, isFalse);
  expect(system.cpu.t.v, isFalse);
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, isFalse);
}

void testIncReg16(
  System system,
  int expectedCycles,
  List<int> opcodes,
  Register16 register,
) {
  final int statusRegister = system.cpu.t.statusRegister;

  system.load(0x0000, opcodes);
  register.value = 0xFFFF;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(expectedCycles));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(register.value, equals(0x0000));

  expect(system.cpu.t.statusRegister, equals(statusRegister));
}

void testDecReg8(
  System system,
  int expectedCycles,
  List<int> opcodes,
  Register8 register,
) {
  final LH5801Flags flags = system.cpu.t.clone();

  system.load(0x0000, opcodes);
  register.value = 0x00;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(expectedCycles));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(register.value, equals(0xFF));

  expect(system.cpu.t.h, isFalse);
  expect(system.cpu.t.v, isFalse);
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, isFalse);
}

void testDecReg16(
  System system,
  int expectedCycles,
  List<int> opcodes,
  Register16 register,
) {
  final int statusRegister = system.cpu.t.statusRegister;

  system.load(0x0000, opcodes);
  register.value = 0x0000;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(expectedCycles));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(register.value, equals(0xFFFF));

  expect(system.cpu.t.statusRegister, equals(statusRegister));
}

void testLDXReg(System system, List<int> opcodes, Register16 register) {
  final int statusRegister = system.cpu.t.statusRegister;

  system.load(0x0000, opcodes);
  register.value = 25;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(11));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(system.cpu.x.value, equals(25));

  expect(system.cpu.t.statusRegister, statusRegister);
}

void testSTXReg(System system, List<int> opcodes, Register16 register) {
  final int statusRegister = system.cpu.t.statusRegister;

  system.load(0x0000, opcodes);
  system.cpu.x.value = 25;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(11));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(register.value, equals(25));

  expect(system.cpu.t.statusRegister, statusRegister);
}

void testPSHRReg(System system, List<int> opcodes, Register16 register) {
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

void testDCARReg(
  System system,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  void _test(
    int initialOp1Value,
    int initialOp2Value,
    bool initialCarryValue,
    int expectedAccValue,
    Matcher cFlagMatcher,
    Matcher hFlagMatcher,
  ) {
    final int regValue = me1 ? 0x10200 : 0x0200;

    system.load(0x0000, opcodes);
    register.value = regValue;
    system.load(regValue, <int>[initialOp2Value]);
    system.cpu.a.value = initialOp1Value;
    system.cpu.t.c = initialCarryValue;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(expectedCycles));
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

void testTTA(System system) {
  void _test(int initialStatusRegisterValue, Matcher zFlagMatcher) {
    final List<int> opcodes = <int>[0xFD, 0xAA];

    system.load(0x0000, opcodes);
    system.cpu.a.value = 83;
    system.cpu.t.statusRegister = initialStatusRegisterValue;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(9));
    expect(system.cpu.p.value, equals(opcodes.length));

    expect(system.cpu.a.value, initialStatusRegisterValue);

    expect(system.cpu.t.z, zFlagMatcher);
  }

  _test(0x08, isFalse);
  _test(0x00, isTrue);
}

void testADRRReg(System system, List<int> opcodes, Register16 register) {
  final int statusRegister = system.cpu.t.statusRegister;

  system.load(0x0000, opcodes);
  system.cpu.a.value = 0xC3;
  register.value = 0x0A88;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(11));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(register.value, equals(0x0B4B));

  expect(system.cpu.t.statusRegister, equals(statusRegister));
}

void testDRRRReg(System system, List<int> opcodes, {bool me1 = false}) {
  final int statusRegister = system.cpu.t.statusRegister;

  system.load(0x0000, opcodes);
  system.cpu.x.value = 0x4700;
  system.load((me1 ? 0x10000 : 0) | system.cpu.x.value, <int>[0x42]);
  system.cpu.a.value = 0xC1;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(16));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(system.cpu.a.value, equals(0x42));
  final int x = system.memRead((me1 ? 0x10000 : 0) | system.cpu.x.value);
  expect(x, equals(0x14));

  expect(system.cpu.t.statusRegister, equals(statusRegister));
}

void testDRLRReg(System system, List<int> opcodes, {bool me1 = false}) {
  final int statusRegister = system.cpu.t.statusRegister;

  system.load(0x0000, opcodes);
  system.cpu.x.value = 0x4700;
  system.load((me1 ? 0x10000 : 0) | system.cpu.x.value, <int>[0xB3]);
  system.cpu.a.value = 0x6F;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(16));
  expect(system.cpu.p.value, equals(opcodes.length));

  expect(system.cpu.a.value, equals(0xB3));
  final int x = system.memRead((me1 ? 0x10000 : 0) | system.cpu.x.value);
  expect(x, equals(0x36));

  expect(system.cpu.t.statusRegister, equals(statusRegister));
}

void testSINRReg(System system, List<int> opcodes, Register16 register) {
  void _test(int regValue) {
    final int statusRegister = system.cpu.t.statusRegister;

    system.cpu.p.value = 0x1000;
    system.load(0x1000, opcodes);
    register.value = regValue;
    system.load(regValue, <int>[0x00]);
    system.cpu.a.value = 0x6F;
    final int cycles = system.step(0x1000);
    expect(cycles, equals(6));
    expect(system.cpu.p.value, equals(0x1000 + opcodes.length));

    expect(system.cpu.a.value, equals(0x6F));
    final int x = system.memRead(regValue);
    expect(x, equals(0x6F));
    expect(register.value, equals((regValue + 1) & 0xFFFF));

    expect(system.cpu.t.statusRegister, equals(statusRegister));
  }

  _test(0x0100);
  _test(0xFFFF);
}

void testSDERReg(System system, List<int> opcodes, Register16 register) {
  void _test(int regValue) {
    final int statusRegister = system.cpu.t.statusRegister;

    system.cpu.p.value = 0x1000;
    system.load(0x1000, opcodes);
    register.value = regValue;
    system.load(regValue, <int>[0x00]);
    system.cpu.a.value = 0x6F;
    final int cycles = system.step(0x1000);
    expect(cycles, equals(6));
    expect(system.cpu.p.value, equals(0x1000 + opcodes.length));

    expect(system.cpu.a.value, equals(0x6F));
    final int x = system.memRead(regValue);
    expect(x, equals(0x6F));
    expect(register.value, equals((regValue - 1) & 0xFFFF));

    expect(system.cpu.t.statusRegister, equals(statusRegister));
  }

  _test(0x0100);
  _test(0x0000);
}

void testLINRReg(System system, List<int> opcodes, Register16 register) {
  void _test(int regValue, int memValue, Matcher zFlagMatcher) {
    final LH5801Flags flags = system.cpu.t.clone();

    system.cpu.p.value = 0x1000;
    system.load(0x1000, opcodes);
    register.value = regValue;
    system.load(regValue, <int>[memValue]);
    system.cpu.a.value = 0xFF;
    final int cycles = system.step(0x1000);
    expect(cycles, equals(6));
    expect(system.cpu.p.value, equals(0x1000 + opcodes.length));

    expect(system.cpu.a.value, equals(memValue));
    expect(register.value, equals((regValue + 1) & 0xFFFF));

    expect(system.cpu.t.h, equals(flags.h));
    expect(system.cpu.t.v, equals(flags.v));
    expect(system.cpu.t.z, zFlagMatcher);
    expect(system.cpu.t.ie, equals(flags.ie));
    expect(system.cpu.t.c, equals(flags.c));
  }

  _test(0x0055, 0x3A, isFalse);
  _test(0xFFFF, 0x00, isTrue);
}

void testLDERReg(System system, List<int> opcodes, Register16 register) {
  void _test(int regValue, int memValue, Matcher zFlagMatcher) {
    final LH5801Flags flags = system.cpu.t.clone();

    system.cpu.p.value = 0x1000;
    system.load(0x1000, opcodes);
    register.value = regValue;
    system.load(regValue, <int>[memValue]);
    system.cpu.a.value = 0xFF;
    final int cycles = system.step(0x1000);
    expect(cycles, equals(6));
    expect(system.cpu.p.value, equals(0x1000 + opcodes.length));

    expect(system.cpu.a.value, equals(memValue));
    expect(register.value, equals((regValue - 1) & 0xFFFF));

    expect(system.cpu.t.h, equals(flags.h));
    expect(system.cpu.t.v, equals(flags.v));
    expect(system.cpu.t.z, zFlagMatcher);
    expect(system.cpu.t.ie, equals(flags.ie));
    expect(system.cpu.t.c, equals(flags.c));
  }

  _test(0x0055, 0x3A, isFalse);
  _test(0x0000, 0x00, isTrue);
}

void testLDIAcc(System system) {
  void _test(int i, Matcher zFlagMatcher) {
    final List<int> memOpcodes = <int>[0xB5, i & 0xFF];
    final LH5801Flags flags = system.cpu.t.clone();

    system.load(0x0000, memOpcodes);
    system.cpu.a.value = i ^ 0xFF;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(6));
    expect(system.cpu.p.value, equals(memOpcodes.length));

    expect(system.cpu.a.value, equals(i));

    expect(system.cpu.t.h, equals(flags.h));
    expect(system.cpu.t.v, equals(flags.v));
    expect(system.cpu.t.z, zFlagMatcher);
    expect(system.cpu.t.ie, equals(flags.ie));
    expect(system.cpu.t.c, equals(flags.c));
  }

  _test(0x00, isTrue);
  _test(0xAA, isFalse);
}

void testLDIReg(System system, List<int> opcodes, Register8 register) {
  final List<int> memOpcodes = <int>[...opcodes, 0x5A];
  final int statusRegister = system.cpu.t.statusRegister;

  system.load(0x0000, memOpcodes);
  register.value = 0xFF;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(6));
  expect(system.cpu.p.value, equals(memOpcodes.length));

  expect(register.value, equals(0x5A));

  expect(system.cpu.t.statusRegister, equals(statusRegister));
}

void testLDISij(System system) {
  const int ij = 0x1234;
  final List<int> memOpcodes = <int>[0xAA, ij >> 8, ij & 0xFF];
  final int statusRegister = system.cpu.t.statusRegister;

  system.load(0x0000, memOpcodes);
  system.cpu.s.value = ij ^ 0x0FF0;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(12));
  expect(system.cpu.p.value, equals(memOpcodes.length));

  expect(system.cpu.s.value, equals(ij));

  expect(system.cpu.t.statusRegister, equals(statusRegister));
}

void testCPIReg(System system, List<int> opcodes, Register8 register) {
  void _test(int op1, int op2, Matcher cFlagMatcher, Matcher zFlagMatcher) {
    final List<int> memOpcodes = <int>[...opcodes, op2 & 0xFF];

    system.load(0x0000, memOpcodes);
    register.value = op1;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(7));
    expect(system.cpu.p.value, equals(memOpcodes.length));

    expect(system.cpu.t.c, cFlagMatcher);
    expect(system.cpu.t.z, zFlagMatcher);
  }

  _test(84, 80, isTrue, isFalse);
  _test(2, 2, isTrue, isTrue);
  _test(84, 110, isFalse, isFalse);
}

void _testBranch(
  System system,
  int additionalCycles,
  List<int> opcodes,
  int flagMask,
  bool Function(int) cond, {
  bool forward = true,
}) {
  const int initialP = 0x4002;
  const int offset = 0x05;
  final List<int> memOpcodes = <int>[...opcodes, 0x05];
  final int expectedCycles = 8 + (forward ? 0 : 1);

  system.cpu.p.value = initialP;
  system.load(initialP, memOpcodes);
  system.cpu.t.statusRegister = flagMask;
  final int cycles = system.step(system.cpu.p.value);

  // Condition is true?
  if (cond(system.cpu.t.statusRegister)) {
    expect(cycles, equals(expectedCycles + additionalCycles));
    expect(
      system.cpu.p.value,
      equals(
        initialP + memOpcodes.length + (forward ? offset : -offset),
      ),
    );
  } else {
    expect(cycles, equals(expectedCycles));
    expect(system.cpu.p.value, equals(initialP + memOpcodes.length));
  }
}

void testBCR(System system, List<int> opcodes, {bool forward = true}) {
  _testBranch(
    system,
    2,
    opcodes,
    0,
    (int statusRegister) => (system.cpu.t.statusRegister & LH5801Flags.C) == 0,
    forward: forward,
  );

  _testBranch(
    system,
    2,
    opcodes,
    LH5801Flags.C,
    (int statusRegister) => (system.cpu.t.statusRegister & LH5801Flags.C) == 0,
    forward: forward,
  );
}

void testBCS(System system, List<int> opcodes, {bool forward = true}) {
  _testBranch(
    system,
    2,
    opcodes,
    LH5801Flags.C,
    (int statusRegister) => (system.cpu.t.statusRegister & LH5801Flags.C) != 0,
    forward: forward,
  );

  _testBranch(
    system,
    2,
    opcodes,
    0,
    (int statusRegister) => (system.cpu.t.statusRegister & LH5801Flags.C) != 0,
    forward: forward,
  );
}

void testBHR(System system, List<int> opcodes, {bool forward = true}) {
  _testBranch(
    system,
    2,
    opcodes,
    0,
    (int statusRegister) => (system.cpu.t.statusRegister & LH5801Flags.H) == 0,
    forward: forward,
  );

  _testBranch(
    system,
    2,
    opcodes,
    LH5801Flags.H,
    (int statusRegister) => (system.cpu.t.statusRegister & LH5801Flags.H) == 0,
    forward: forward,
  );
}

void testBHS(System system, List<int> opcodes, {bool forward = true}) {
  _testBranch(
    system,
    2,
    opcodes,
    LH5801Flags.H,
    (int statusRegister) => (system.cpu.t.statusRegister & LH5801Flags.H) != 0,
    forward: forward,
  );

  _testBranch(
    system,
    2,
    opcodes,
    0,
    (int statusRegister) => (system.cpu.t.statusRegister & LH5801Flags.H) != 0,
    forward: forward,
  );
}

void testBZR(System system, List<int> opcodes, {bool forward = true}) {
  _testBranch(
    system,
    2,
    opcodes,
    0,
    (int statusRegister) => (system.cpu.t.statusRegister & LH5801Flags.Z) == 0,
    forward: forward,
  );

  _testBranch(
    system,
    2,
    opcodes,
    LH5801Flags.Z,
    (int statusRegister) => (system.cpu.t.statusRegister & LH5801Flags.Z) == 0,
    forward: forward,
  );
}

void testBZS(System system, List<int> opcodes, {bool forward = true}) {
  _testBranch(
    system,
    2,
    opcodes,
    LH5801Flags.Z,
    (int statusRegister) => (system.cpu.t.statusRegister & LH5801Flags.Z) != 0,
    forward: forward,
  );

  _testBranch(
    system,
    2,
    opcodes,
    0,
    (int statusRegister) => (system.cpu.t.statusRegister & LH5801Flags.Z) != 0,
    forward: forward,
  );
}

void testBVR(System system, List<int> opcodes, {bool forward = true}) {
  _testBranch(
    system,
    2,
    opcodes,
    0,
    (int statusRegister) => (system.cpu.t.statusRegister & LH5801Flags.V) == 0,
    forward: forward,
  );

  _testBranch(
    system,
    2,
    opcodes,
    LH5801Flags.V,
    (int statusRegister) => (system.cpu.t.statusRegister & LH5801Flags.V) == 0,
    forward: forward,
  );
}

void testBVS(System system, List<int> opcodes, {bool forward = true}) {
  _testBranch(
    system,
    2,
    opcodes,
    LH5801Flags.V,
    (int statusRegister) => (system.cpu.t.statusRegister & LH5801Flags.V) != 0,
    forward: forward,
  );

  _testBranch(
    system,
    2,
    opcodes,
    0,
    (int statusRegister) => (system.cpu.t.statusRegister & LH5801Flags.V) != 0,
    forward: forward,
  );
}

void testBCH(System system, List<int> opcodes, {bool forward = true}) {
  _testBranch(
    system,
    0,
    opcodes,
    0,
    (int statusRegister) => true,
    forward: forward,
  );
}

void testLOP(System system) {
  void _test(int uValue) {
    const int initialP = 0x4003;
    const int offset = 0x05;
    final List<int> memOpcodes = <int>[0x88, 0x05];
    const int expectedCycles = 8;
    final int statusRegister = system.cpu.t.statusRegister;

    system.cpu.p.value = initialP;
    system.load(initialP, memOpcodes);
    system.cpu.u.low = uValue;
    final int cycles = system.step(system.cpu.p.value);

    final int uLow = unsignedByteToInt(system.cpu.u.low);
    expect(uLow, equals(uValue - 1));

    // End of loop?
    if (uLow >= 0) {
      expect(cycles, equals(expectedCycles + 3));
      expect(
        system.cpu.p.value,
        equals(
          initialP + memOpcodes.length + -offset,
        ),
      );
    } else {
      expect(cycles, equals(expectedCycles));
      expect(system.cpu.p.value, equals(initialP + memOpcodes.length));
    }

    expect(system.cpu.t.statusRegister, equals(statusRegister));
  }

  _test(4);
  _test(1);
  _test(0);
}

void testSBIAcc(System system) {
  final List<int> memOpcodes = <int>[0xB1, 7];

  system.load(0x0000, memOpcodes);
  system.cpu.a.value = 36;
  system.cpu.t.c = false;
  final int cycles = system.step(0x0000);
  expect(cycles, equals(7));
  expect(system.cpu.p.value, equals(memOpcodes.length));

  expect(system.cpu.a.value, equals(28));

  expect(system.cpu.t.c, isTrue);
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.v, isFalse);
  expect(system.cpu.t.h, isFalse);
}

void testJMP(System system) {
  const int initialPValue = 0x4000;
  const int ij = 0x4100;
  final List<int> memOpcodes = <int>[0xBA, ij >> 8, ij & 0xFF];
  final int statusRegister = system.cpu.t.statusRegister;

  system.cpu.p.value = initialPValue;
  system.load(system.cpu.p.value, memOpcodes);
  final int cycles = system.step(system.cpu.p.value);
  expect(cycles, equals(12));

  expect(system.cpu.p.value, equals(ij));

  expect(system.cpu.t.statusRegister, equals(statusRegister));
}

void testEAI(System system) {
  void _test(
    int initialOp1Value,
    int initialOp2Value,
    int expectedAccValue,
    Matcher zFlagMatcher,
  ) {
    final List<int> memOpcodes = <int>[0xBD, initialOp2Value & 0xFF];
    final LH5801Flags flags = system.cpu.t.clone();

    system.load(0x0000, memOpcodes);
    system.cpu.a.value = initialOp1Value;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(7));
    expect(system.cpu.p.value, equals(memOpcodes.length));

    expect(system.cpu.a.value, equals(expectedAccValue));

    // Z should be the only flag updated.
    expect(system.cpu.t.h, equals(flags.h));
    expect(system.cpu.t.v, equals(flags.v));
    expect(system.cpu.t.z, zFlagMatcher);
    expect(system.cpu.t.ie, equals(flags.ie));
    expect(system.cpu.t.c, equals(flags.c));
  }

  _test(0x36, 0x6D, 0x5B, isFalse);
  _test(0x00, 0x00, 0x00, isTrue);
}

void testSJP(System system) {
  const int initialPValue = 0x4000;
  const int initialSValue = 0x6000;
  const int ij = 0xE000;
  final List<int> memOpcodes = <int>[0xBE, ij >> 8, ij & 0xFF];
  final int statusRegister = system.cpu.t.statusRegister;

  system.cpu.p.value = initialPValue;
  system.cpu.s.value = initialSValue;
  system.load(system.cpu.p.value, memOpcodes);
  final int cycles = system.step(system.cpu.p.value);
  expect(cycles, equals(19));

  expect(system.cpu.p.value, equals(ij));
  expect(system.cpu.s.value, equals(initialSValue - 2));
  expect((initialPValue + memOpcodes.length) & 0xFF, equals(system.memRead(0x6000)));
  expect((initialPValue + memOpcodes.length) >> 8, equals(system.memRead(0x6000 - 1)));

  expect(system.cpu.t.statusRegister, equals(statusRegister));
}

void testRTN(System system) {
  const int initialPValue = 0x4000;
  const int initialSValue = 0x6000;
  const int ij = 0xE000;

  final List<int> memOpcodes1 = <int>[
    // SJP 0xE0, 0x00
    0xBE,
    ij >> 8,
    ij & 0xFF,
  ];
  final List<int> memOpcodes2 = <int>[
    // RTN
    0x9A,
  ];
  final int statusRegister = system.cpu.t.statusRegister;

  system.cpu.p.value = initialPValue;
  system.cpu.s.value = initialSValue;

  system.load(system.cpu.p.value, memOpcodes1);
  int cycles = system.step(system.cpu.p.value);
  expect(cycles, equals(19));

  system.load(system.cpu.p.value, memOpcodes2);
  cycles = system.step(system.cpu.p.value);
  expect(cycles, equals(11));

  expect(system.cpu.p.value, equals(initialPValue + memOpcodes1.length));
  expect(system.cpu.s.value, equals(initialSValue));

  expect(system.cpu.t.statusRegister, equals(statusRegister));
}

void testRTI(System system) {
  const int initialPValue = 0x4000;
  const int initialSValue = 0x6000;
  const int statusRegister =
      LH5801Flags.H | LH5801Flags.V | LH5801Flags.Z | LH5801Flags.C;
  const int ij = 0xE000;

  final List<int> memOpcodes = <int>[
    // RTI
    0x8A,
  ];
  final List<int> stackOpcodes = <int>[
    ij >> 8,
    ij & 0xFF,
    statusRegister,
  ];

  system.cpu.p.value = initialPValue;
  system.load(system.cpu.p.value, memOpcodes);

  system.cpu.s.value = initialSValue;
  system.load(initialSValue + 1, stackOpcodes);

  final int cycles = system.step(system.cpu.p.value);
  expect(cycles, equals(14));

  expect(system.cpu.p.value, equals(ij));
  expect(system.cpu.s.value, equals(initialSValue + 3));
  expect(system.cpu.t.statusRegister, equals(statusRegister));
}

void testVSJ(System system, int expectedCycles, List<int> opcodes) {
  const int initialSValue = 0x6000;
  const int initialPValue = 0x4000;
  const int subroutineAddress = 0x4500;

  final List<int> memOpcodes = <int>[...opcodes];
  final LH5801Flags flags = system.cpu.t.clone();

  system.cpu.s.value = initialSValue;

  system.cpu.p.value = initialPValue;
  system.load(system.cpu.p.value, memOpcodes);

  for (int vectorId = 0xC0; vectorId <= 0xF6; vectorId += 2) {
    system.load(
      0xFF00 | vectorId,
      <int>[subroutineAddress >> 8, subroutineAddress & 0xFF],
    );
  }

  final int cycles = system.step(system.cpu.p.value);
  expect(cycles, equals(expectedCycles));

  expect(system.cpu.p.value, equals(subroutineAddress));
  expect(system.cpu.s.value, equals(initialSValue - 2));
  expect((initialPValue + memOpcodes.length) & 0xFF, equals(system.memRead(0x6000)));
  expect((initialPValue + memOpcodes.length) >> 8, equals(system.memRead(0x6000 - 1)));

  // Z is reset.
  expect(system.cpu.t.h, equals(flags.h));
  expect(system.cpu.t.v, equals(flags.v));
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, equals(flags.c));
}

void _testVSJConditional(
  System system,
  List<int> opcodes,
  int statusRegister, {
  bool jump = false,
}) {
  const int initialSValue = 0x6000;
  const int initialPValue = 0x4000;
  const int subroutineAddress = 0x4500;

  final List<int> memOpcodes = <int>[...opcodes];

  system.cpu.t.statusRegister = statusRegister;
  final LH5801Flags flags = system.cpu.t.clone();

  system.cpu.s.value = initialSValue;

  system.cpu.p.value = initialPValue;
  system.load(system.cpu.p.value, memOpcodes);

  for (int vectorId = 0xC0; vectorId <= 0xF6; vectorId += 2) {
    system.load(
      0xFF00 | vectorId,
      <int>[subroutineAddress >> 8, subroutineAddress & 0xFF],
    );
  }

  final int cycles = system.step(system.cpu.p.value);

  if (jump) {
    expect(cycles, equals(21));
    expect(system.cpu.p.value, equals(subroutineAddress));
    expect(system.cpu.s.value, equals(initialSValue - 2));
    expect((initialPValue + memOpcodes.length) & 0xFF, equals(system.memRead(0x6000)));
    expect((initialPValue + memOpcodes.length) >> 8, equals(system.memRead(0x6000 - 1)));
  } else {
    expect(cycles, equals(8));
    expect(system.cpu.p.value, equals(initialPValue + memOpcodes.length));
    expect(system.cpu.s.value, equals(initialSValue));
  }

  // Z is reset.
  expect(system.cpu.t.h, equals(flags.h));
  expect(system.cpu.t.v, equals(flags.v));
  expect(system.cpu.t.z, isFalse);
  expect(system.cpu.t.ie, equals(flags.ie));
  expect(system.cpu.t.c, equals(flags.c));
}

void testVCS(System system, List<int> opcodes) {
  _testVSJConditional(
    system,
    opcodes,
    LH5801Flags.C,
    jump: true,
  );

  _testVSJConditional(system, opcodes, 0);
}

void testVCR(System system, List<int> opcodes) {
  _testVSJConditional(
    system,
    opcodes,
    0,
    jump: true,
  );

  _testVSJConditional(system, opcodes, LH5801Flags.C);
}

void testVHS(System system, List<int> opcodes) {
  _testVSJConditional(
    system,
    opcodes,
    LH5801Flags.H,
    jump: true,
  );

  _testVSJConditional(system, opcodes, 0);
}

void testVHR(System system, List<int> opcodes) {
  _testVSJConditional(
    system,
    opcodes,
    0,
    jump: true,
  );

  _testVSJConditional(system, opcodes, LH5801Flags.H);
}

void testVZS(System system, List<int> opcodes) {
  _testVSJConditional(
    system,
    opcodes,
    LH5801Flags.Z,
    jump: true,
  );

  _testVSJConditional(system, opcodes, 0);
}

void testVZR(System system, List<int> opcodes) {
  _testVSJConditional(
    system,
    opcodes,
    0,
    jump: true,
  );

  _testVSJConditional(system, opcodes, LH5801Flags.Z);
}

void testVVS(System system, List<int> opcodes) {
  _testVSJConditional(
    system,
    opcodes,
    LH5801Flags.V,
    jump: true,
  );

  _testVSJConditional(system, opcodes, 0);
}

void testROR(System system) {
  void _test(
    int initialAccValue,
    int expectedAccValue,
    int expectedStatusRegister, {
    bool carry = false,
  }) {
    final List<int> opcodes = <int>[0xD1];

    system.load(0x0000, opcodes);
    system.cpu.a.value = initialAccValue;
    system.cpu.t.c = carry;
    final int cycles = system.step(0x0000);
    expect(cycles, equals(9));
    expect(system.cpu.p.value, equals(opcodes.length));

    expect(system.cpu.a.value, expectedAccValue);

    expect(system.cpu.t.statusRegister, expectedStatusRegister);
  }

  _test(0xC8, 0x64, 0);
  _test(0xC8, 0xE4, 0, carry: true);

  _test(0xF0, 0x78, LH5801Flags.H);
  _test(0x02, 0x01, LH5801Flags.V);
  _test(0x0F, 0x07, LH5801Flags.V | LH5801Flags.C);
  _test(0x01, 0x00, LH5801Flags.Z | LH5801Flags.C);
}

void testTIN(System system) {
  const int initialXValue = 0x4700;
  const int memXValue = 0x33;
  const int initialYValue = 0x4800;
  final List<int> memOpcodes = <int>[0xF5];
  final int statusRegister = system.cpu.t.statusRegister;

  system.load(0x0000, memOpcodes);
  system.cpu.x.value = initialXValue;
  system.load(initialXValue, <int>[memXValue]);
  system.cpu.y.value = initialYValue;
  system.load(initialYValue, <int>[0xFF]);
  final int cycles = system.step(0x0000);
  expect(cycles, equals(7));
  expect(system.cpu.p.value, equals(memOpcodes.length));

  expect(system.cpu.x.value, equals(initialXValue + 1));
  expect(system.cpu.y.value, equals(initialYValue + 1));
  expect(system.memRead(initialYValue), equals(memXValue));

  expect(system.cpu.t.statusRegister, statusRegister);
}

void testCIN(System system) {
  void _test(int op1, int op2, Matcher cFlagMatcher, Matcher zFlagMatcher) {
    const int initialXValue = 0x4700;
    final List<int> memOpcodes = <int>[0xF7];

    system.load(0x0000, memOpcodes);
    system.cpu.a.value = op1;
    system.cpu.x.value = initialXValue;
    system.load(initialXValue, <int>[op2]);
    final int cycles = system.step(0x0000);
    expect(cycles, equals(7));
    expect(system.cpu.p.value, equals(memOpcodes.length));

    expect(system.cpu.x.value, equals(initialXValue + 1));

    expect(system.cpu.t.c, cFlagMatcher);
    expect(system.cpu.t.z, zFlagMatcher);
  }

  _test(84, 80, isTrue, isFalse);
  _test(2, 2, isTrue, isTrue);
  _test(84, 110, isFalse, isFalse);
}
