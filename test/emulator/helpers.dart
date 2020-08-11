import 'dart:typed_data';

import 'package:lh5801/lh5801.dart';
import 'package:test/test.dart';

final Uint8ClampedList me0 = Uint8ClampedList(64 * 1024);
final Uint8ClampedList me1 = Uint8ClampedList(64 * 1024);

void memLoad(int address, List<int> data) {
  if (address & 0x10000 != 0) {
    final int a = address & 0xFFFF;
    me1.setRange(a, a + data.length, data);
  } else {
    me0.setRange(address, address + data.length, data);
  }
}

int memRead(int address) {
  final int value = address & 0x10000 != 0 ? me1[address & 0xFFFF] : me0[address];
  return value;
}

void memWrite(int address, int value) {
  if (address & 0x10000 != 0) {
    me1[address & 0xFFFF] = value;
  } else {
    me0[address] = value;
  }
}

class LH5801Test extends LH5801Emulator {
  LH5801Test() : super(clockFrequency: 1300000, memRead: memRead, memWrite: memWrite);

  void resetTestEnv() {
    me0.setRange(0, 64 * 1024, List<int>.filled(64 * 1024, 0));
    me1.setRange(0, 64 * 1024, List<int>.filled(64 * 1024, 0));
    super.reset();
  }
}

void testResetPin(LH5801Emulator emulator) {
  const int intAddress = 0x4000;
  const List<int> memOpcodes = <int>[0x38]; // NOP

  memLoad(0xFFFE, <int>[intAddress >> 8, intAddress & 0xFF]);
  memLoad(intAddress, memOpcodes);
  emulator.resetPin = true;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(5));
  expect(emulator.cpu.p.value, equals(intAddress + memOpcodes.length));

  expect(emulator.resetPin, isFalse);
}

void testIR0(LH5801Emulator emulator) {
  const int initialPC = 0x1002;
  const int stackAddress = 0x2000;
  const int intAddress = 0x4000;
  const int statusRegister = LH5801Flags.H | LH5801Flags.C;
  const List<int> memOpcodes = <int>[0x38]; // NOP

  memLoad(0xFFFC, <int>[intAddress >> 8, intAddress & 0xFF]);
  memLoad(intAddress, memOpcodes);
  emulator.nmiPin = true;
  emulator.cpu.p.value = initialPC;
  emulator.cpu.s.value = stackAddress;
  emulator.cpu.t.statusRegister = statusRegister;
  final int cycles = emulator.step(address: initialPC);
  expect(cycles, equals(5));
  expect(emulator.cpu.p.value, equals(intAddress + memOpcodes.length));

  expect(emulator.nmiPin, isFalse);
  expect(emulator.cpu.t.ie, isFalse);
  expect(emulator.cpu.ir0, isFalse);
  expect(emulator.cpu.ir1, isFalse);
  expect(emulator.cpu.ir2, isFalse);

  expect(emulator.cpu.s.value, equals(stackAddress - 3));
  expect(emulator.cpu.memRead(stackAddress), equals(statusRegister));
  expect(emulator.cpu.memRead(stackAddress - 1), equals(initialPC & 0xFF));
  expect(emulator.cpu.memRead(stackAddress - 2), equals(initialPC >> 8));
}

void testIR1(LH5801Emulator emulator) {
  const int initialPC = 0x1002;
  const int stackAddress = 0x2000;
  const int intAddress = 0x4000;
  const int statusRegister = 0x02 | LH5801Flags.C; // IE
  const List<int> memOpcodes = <int>[0x38]; // NOP

  // Raise timer interrupt.
  emulator.cpu.tm.value = 0x1FF;

  memLoad(0xFFFA, <int>[intAddress >> 8, intAddress & 0xFF]);
  memLoad(intAddress, memOpcodes);
  emulator.cpu.p.value = initialPC;
  emulator.cpu.s.value = stackAddress;
  emulator.cpu.t.statusRegister = statusRegister;
  expect(emulator.cpu.t.ie, isTrue);
  final int cycles = emulator.step(address: initialPC);
  expect(cycles, equals(5));
  expect(emulator.cpu.p.value, equals(intAddress + memOpcodes.length));

  expect(emulator.cpu.tm.isInterruptRaised, isFalse);
  expect(emulator.cpu.t.ie, isFalse);
  expect(emulator.cpu.ir0, isFalse);
  expect(emulator.cpu.ir1, isFalse);
  expect(emulator.cpu.ir2, isFalse);

  expect(emulator.cpu.s.value, equals(stackAddress - 3));
  expect(emulator.cpu.memRead(stackAddress), equals(statusRegister));
  expect(emulator.cpu.memRead(stackAddress - 1), equals(initialPC & 0xFF));
  expect(emulator.cpu.memRead(stackAddress - 2), equals(initialPC >> 8));
}

void testIR2(LH5801Emulator emulator) {
  const int initialPC = 0x1002;
  const int stackAddress = 0x2000;
  const int intAddress = 0x4000;
  const int statusRegister = 0x02 | LH5801Flags.C; // IE
  const List<int> memOpcodes = <int>[0x38]; // NOP

  memLoad(0xFFF8, <int>[intAddress >> 8, intAddress & 0xFF]);
  memLoad(intAddress, memOpcodes);
  emulator.miPin = true;
  emulator.cpu.p.value = initialPC;
  emulator.cpu.s.value = stackAddress;
  emulator.cpu.t.statusRegister = statusRegister;
  final int cycles = emulator.step(address: initialPC);
  expect(cycles, equals(5));
  expect(emulator.cpu.p.value, equals(intAddress + memOpcodes.length));

  expect(emulator.miPin, isFalse);
  expect(emulator.cpu.t.ie, isFalse);
  expect(emulator.cpu.ir0, isFalse);
  expect(emulator.cpu.ir1, isFalse);
  expect(emulator.cpu.ir2, isFalse);

  expect(emulator.cpu.s.value, equals(stackAddress - 3));
  expect(emulator.cpu.memRead(stackAddress), equals(statusRegister));
  expect(emulator.cpu.memRead(stackAddress - 1), equals(initialPC & 0xFF));
  expect(emulator.cpu.memRead(stackAddress - 2), equals(initialPC >> 8));
}

void testSBCReg(LH5801Emulator emulator, List<int> opcodes, Register8 register) {
  memLoad(0x0000, opcodes);
  emulator.cpu.a.value = 56;
  register.value = 33;
  emulator.cpu.t.c = true;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(6));
  expect(emulator.cpu.p.value, equals(opcodes.length));

  expect(emulator.cpu.a.value, equals(23));

  expect(emulator.cpu.t.c, isTrue);
  expect(emulator.cpu.t.z, isFalse);
  expect(emulator.cpu.t.v, isFalse);
  expect(emulator.cpu.t.h, isTrue);
}

void testSBCRReg(
  LH5801Emulator emulator,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  final int rregValue = me1 ? 0x10100 : 0x0100;

  memLoad(0x0000, opcodes);
  register.value = rregValue;
  memLoad(rregValue, <int>[33]);
  emulator.cpu.a.value = 56;
  emulator.cpu.t.c = true;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(expectedCycles));
  expect(emulator.cpu.p.value, equals(opcodes.length));

  expect(emulator.cpu.a.value, equals(23));

  expect(emulator.cpu.t.c, isTrue);
  expect(emulator.cpu.t.z, isFalse);
  expect(emulator.cpu.t.v, isFalse);
  expect(emulator.cpu.t.h, isTrue);
}

void testSBCab(LH5801Emulator emulator, int expectedCycles, List<int> opcodes,
    {bool me1 = false}) {
  final int ab = me1 ? 0x11234 : 0x1234;
  final List<int> memOpcodes = <int>[...opcodes, (ab >> 8) & 0xFF, ab & 0xFF];

  memLoad(0x0000, memOpcodes);
  memLoad(ab, <int>[33]);
  emulator.cpu.a.value = 56;
  emulator.cpu.t.c = true;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(expectedCycles));
  expect(emulator.cpu.p.value, equals(memOpcodes.length));

  expect(emulator.cpu.a.value, equals(23));

  expect(emulator.cpu.t.c, isTrue);
  expect(emulator.cpu.t.z, isFalse);
  expect(emulator.cpu.t.v, isFalse);
  expect(emulator.cpu.t.h, isTrue);
}

void testADCReg(LH5801Emulator emulator, List<int> opcodes, Register8 register) {
  memLoad(0x0000, opcodes);
  emulator.cpu.a.value = 2;
  register.value = 51;
  emulator.cpu.t.c = false;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(6));
  expect(emulator.cpu.p.value, equals(opcodes.length));

  expect(emulator.cpu.a.value, equals(53));

  expect(emulator.cpu.t.c, isFalse);
  expect(emulator.cpu.t.z, isFalse);
  expect(emulator.cpu.t.v, isFalse);
  expect(emulator.cpu.t.h, isFalse);
}

void testADCRReg(
  LH5801Emulator emulator,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  final int rregValue = me1 ? 0x10100 : 0x0100;

  memLoad(0x0000, opcodes);
  register.value = rregValue;
  memLoad(rregValue, <int>[51]);
  emulator.cpu.a.value = 2;
  emulator.cpu.t.c = false;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(expectedCycles));
  expect(emulator.cpu.p.value, equals(opcodes.length));

  expect(emulator.cpu.a.value, equals(53));

  expect(emulator.cpu.t.c, isFalse);
  expect(emulator.cpu.t.z, isFalse);
  expect(emulator.cpu.t.v, isFalse);
  expect(emulator.cpu.t.h, isFalse);
}

void testADCab(LH5801Emulator emulator, int expectedCycles, List<int> opcodes,
    {bool me1 = false}) {
  final int ab = me1 ? 0x11234 : 0x1234;
  final List<int> memOpcodes = <int>[...opcodes, (ab >> 8) & 0xFF, ab & 0xFF];

  memLoad(0x0000, memOpcodes);
  memLoad(ab, <int>[33]);
  emulator.cpu.a.value = 2;
  emulator.cpu.t.c = false;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(expectedCycles));
  expect(emulator.cpu.p.value, equals(memOpcodes.length));

  expect(emulator.cpu.a.value, equals(35));

  expect(emulator.cpu.t.c, isFalse);
  expect(emulator.cpu.t.z, isFalse);
  expect(emulator.cpu.t.v, isFalse);
  expect(emulator.cpu.t.h, isFalse);
}

void testADIAcc(LH5801Emulator emulator) {
  final List<int> memOpcodes = <int>[0xB3, 0x20];
  final LH5801Flags flags = emulator.cpu.t.clone();

  memLoad(0x0000, memOpcodes);
  emulator.cpu.a.value = 0x33;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(7));
  expect(emulator.cpu.p.value, equals(memOpcodes.length));

  expect(emulator.cpu.a.value, equals(0x53));

  expect(emulator.cpu.t.h, isFalse);
  expect(emulator.cpu.t.v, isFalse);
  expect(emulator.cpu.t.z, isFalse);
  expect(emulator.cpu.t.ie, equals(flags.ie));
  expect(emulator.cpu.t.c, isFalse);
}

void testADIRReg(
  LH5801Emulator emulator,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  final int regValue = me1 ? 0x10100 : 0x0100;
  final List<int> memOpcodes = <int>[...opcodes, 0x20];
  final LH5801Flags flags = emulator.cpu.t.clone();

  memLoad(0x0000, memOpcodes);
  register.value = regValue;
  memLoad(regValue, <int>[0x33]);
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(expectedCycles));
  expect(emulator.cpu.p.value, equals(memOpcodes.length));

  final int result = emulator.cpu.memRead(regValue);
  expect(result, equals(0x53));

  expect(emulator.cpu.t.h, isFalse);
  expect(emulator.cpu.t.v, isFalse);
  expect(emulator.cpu.t.z, isFalse);
  expect(emulator.cpu.t.ie, equals(flags.ie));
  expect(emulator.cpu.t.c, isFalse);
}

void testADIab(LH5801Emulator emulator, int expectedCycles, List<int> opcodes,
    {bool me1 = false}) {
  final int ab = me1 ? 0x11234 : 0x1234;
  final List<int> memOpcodes = <int>[
    ...opcodes,
    (ab >> 8) & 0xFF,
    ab & 0xFF,
    0x20,
  ];
  final LH5801Flags flags = emulator.cpu.t.clone();

  memLoad(0x0000, memOpcodes);
  memLoad(ab, <int>[0x33]);
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(expectedCycles));
  expect(emulator.cpu.p.value, equals(memOpcodes.length));

  final int result = emulator.cpu.memRead(ab);
  expect(result, equals(0x53));

  expect(emulator.cpu.t.h, isFalse);
  expect(emulator.cpu.t.v, isFalse);
  expect(emulator.cpu.t.z, isFalse);
  expect(emulator.cpu.t.ie, equals(flags.ie));
  expect(emulator.cpu.t.c, isFalse);
}

void testLDAReg(LH5801Emulator emulator, List<int> opcodes, Register8 register) {
  void _test(int initialValue, Matcher hFlagMatcher) {
    final LH5801Flags flags = emulator.cpu.t.clone();

    memLoad(0x0000, opcodes);
    emulator.cpu.a.value = 2;
    register.value = initialValue;
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(5));
    expect(emulator.cpu.p.value, equals(opcodes.length));

    expect(emulator.cpu.a.value, equals(initialValue));

    // Z should be the only flag updated.
    expect(emulator.cpu.t.h, equals(flags.h));
    expect(emulator.cpu.t.v, equals(flags.v));
    expect(emulator.cpu.t.z, hFlagMatcher);
    expect(emulator.cpu.t.ie, equals(flags.ie));
    expect(emulator.cpu.t.c, equals(flags.c));
  }

  _test(0, isTrue);
  _test(0xFD, isFalse);
}

void testLDARReg(
  LH5801Emulator emulator,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  void _test(int initialValue, Matcher hFlagMatcher) {
    final int rregValue = me1 ? 0x10100 : 0x0100;
    final LH5801Flags flags = emulator.cpu.t.clone();

    memLoad(0x0000, opcodes);
    register.value = rregValue;
    memLoad(rregValue, <int>[initialValue]);
    emulator.cpu.a.value = 2;
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(expectedCycles));
    expect(emulator.cpu.p.value, equals(opcodes.length));

    expect(emulator.cpu.a.value, equals(initialValue));

    // Z should be the only flag updated.
    expect(emulator.cpu.t.h, equals(flags.h));
    expect(emulator.cpu.t.v, equals(flags.v));
    expect(emulator.cpu.t.z, hFlagMatcher);
    expect(emulator.cpu.t.ie, equals(flags.ie));
    expect(emulator.cpu.t.c, equals(flags.c));
  }

  _test(0, isTrue);
  _test(0xFD, isFalse);
}

void testLDAab(LH5801Emulator emulator, int expectedCycles, List<int> opcodes,
    {bool me1 = false}) {
  void _test(int initialValue, Matcher hFlagMatcher) {
    final int ab = me1 ? 0x11234 : 0x1234;
    final List<int> memOpcodes = <int>[...opcodes, (ab >> 8) & 0xFF, ab & 0xFF];
    final LH5801Flags flags = emulator.cpu.t.clone();

    memLoad(0x0000, memOpcodes);
    memLoad(ab, <int>[initialValue]);
    emulator.cpu.a.value = 0;
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(expectedCycles));
    expect(emulator.cpu.p.value, equals(memOpcodes.length));

    expect(emulator.cpu.a.value, equals(initialValue));

    // Z should be the only flag updated.
    expect(emulator.cpu.t.h, equals(flags.h));
    expect(emulator.cpu.t.v, equals(flags.v));
    expect(emulator.cpu.t.z, hFlagMatcher);
    expect(emulator.cpu.t.ie, equals(flags.ie));
    expect(emulator.cpu.t.c, equals(flags.c));
  }

  _test(0, isTrue);
  _test(0xFD, isFalse);
}

void testCPAReg(LH5801Emulator emulator, List<int> opcodes, Register8 register) {
  void _test(int op1, int op2, Matcher cFlagMatcher, Matcher zFlagMatcher) {
    memLoad(0x0000, opcodes);
    emulator.cpu.a.value = op1;
    register.value = op2;
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(6));
    expect(emulator.cpu.p.value, equals(opcodes.length));

    expect(emulator.cpu.t.c, cFlagMatcher);
    expect(emulator.cpu.t.z, zFlagMatcher);
  }

  _test(84, 80, isTrue, isFalse);
  _test(2, 2, isTrue, isTrue);
  _test(84, 110, isFalse, isFalse);
}

void testCPARReg(
  LH5801Emulator emulator,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  void _test(int op1, int op2, Matcher cFlagMatcher, Matcher zFlagMatcher) {
    final int rregValue = me1 ? 0x10100 : 0x0100;

    memLoad(0x0000, opcodes);
    register.value = rregValue;
    memLoad(rregValue, <int>[op2]);
    emulator.cpu.a.value = op1;
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(expectedCycles));
    expect(emulator.cpu.p.value, equals(opcodes.length));

    expect(emulator.cpu.t.c, cFlagMatcher);
    expect(emulator.cpu.t.z, zFlagMatcher);
  }

  _test(84, 80, isTrue, isFalse);
  _test(2, 2, isTrue, isTrue);
  _test(84, 110, isFalse, isFalse);
}

void testCPAab(LH5801Emulator emulator, int expectedCycles, List<int> opcodes,
    {bool me1 = false}) {
  final int ab = me1 ? 0x11234 : 0x1234;
  final List<int> memOpcodes = <int>[...opcodes, (ab >> 8) & 0xFF, ab & 0xFF];

  memLoad(0x0000, memOpcodes);
  memLoad(ab, <int>[80]);
  emulator.cpu.a.value = 84;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(expectedCycles));
  expect(emulator.cpu.p.value, equals(memOpcodes.length));

  expect(emulator.cpu.t.c, isTrue);
  expect(emulator.cpu.t.z, isFalse);
}

void testANDRReg(
  LH5801Emulator emulator,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  void _test(int op1, int op2, Matcher zFlagMatcher) {
    final int rregValue = me1 ? 0x10100 : 0x0100;
    final LH5801Flags flags = emulator.cpu.t.clone();

    memLoad(0x0000, opcodes);
    register.value = rregValue;
    memLoad(rregValue, <int>[op2]);
    emulator.cpu.a.value = op1;
    register.value = rregValue;
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(expectedCycles));
    expect(emulator.cpu.p.value, equals(opcodes.length));

    expect(emulator.cpu.a.value, equals((op1 & op2) & 0xFF));

    // Z should be the only flag updated.
    expect(emulator.cpu.t.h, equals(flags.h));
    expect(emulator.cpu.t.v, equals(flags.v));
    expect(emulator.cpu.t.z, zFlagMatcher);
    expect(emulator.cpu.t.ie, equals(flags.ie));
    expect(emulator.cpu.t.c, equals(flags.c));
  }

  _test(0xF0, 0x0F, isTrue);
  _test(0xFF, 0x0F, isFalse);
}

void testANDab(LH5801Emulator emulator, int expectedCycles, List<int> opcodes,
    {bool me1 = false}) {
  final int ab = me1 ? 0x11234 : 0x1234;
  final List<int> memOpcodes = <int>[...opcodes, (ab >> 8) & 0xFF, ab & 0xFF];
  final LH5801Flags flags = emulator.cpu.t.clone();

  memLoad(0x0000, memOpcodes);
  memLoad(ab, <int>[0x0F]);
  emulator.cpu.a.value = 0xFF;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(expectedCycles));
  expect(emulator.cpu.p.value, equals(memOpcodes.length));

  expect(emulator.cpu.a.value, equals(0x0F));

  // Z should be the only flag updated.
  expect(emulator.cpu.t.h, equals(flags.h));
  expect(emulator.cpu.t.v, equals(flags.v));
  expect(emulator.cpu.t.z, isFalse);
  expect(emulator.cpu.t.ie, equals(flags.ie));
  expect(emulator.cpu.t.c, equals(flags.c));
}

void testANIAcc(LH5801Emulator emulator) {
  void _test(int accValue, int i, Matcher zFlagMatcher) {
    final List<int> memOpcodes = <int>[0xB9, i & 0xFF];
    final LH5801Flags flags = emulator.cpu.t.clone();

    memLoad(0x0000, memOpcodes);
    emulator.cpu.a.value = accValue;
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(7));
    expect(emulator.cpu.p.value, equals(memOpcodes.length));

    expect(emulator.cpu.a.value, equals((accValue & i) & 0xFF));

    // Z should be the only flag updated.
    expect(emulator.cpu.t.h, equals(flags.h));
    expect(emulator.cpu.t.v, equals(flags.v));
    expect(emulator.cpu.t.z, zFlagMatcher);
    expect(emulator.cpu.t.ie, equals(flags.ie));
    expect(emulator.cpu.t.c, equals(flags.c));
  }

  _test(0xF0, 0x0F, isTrue);
  _test(0x12, 0x36, isFalse);
}

void testANIRReg(
  LH5801Emulator emulator,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  void _test(int memValue, int i, Matcher zFlagMatcher) {
    final List<int> memOpcodes = <int>[...opcodes, i & 0xFF];
    final LH5801Flags flags = emulator.cpu.t.clone();
    final int memAddress = me1 ? 0x10100 : 0x0100;

    memLoad(0x0000, memOpcodes);
    register.value = memAddress;
    memLoad(memAddress, <int>[memValue]);
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(expectedCycles));
    expect(emulator.cpu.p.value, equals(memOpcodes.length));

    final int result = emulator.cpu.memRead(memAddress);
    expect(result, equals((memValue & i) & 0xFF));

    // Z should be the only flag updated.
    expect(emulator.cpu.t.h, equals(flags.h));
    expect(emulator.cpu.t.v, equals(flags.v));
    expect(emulator.cpu.t.z, zFlagMatcher);
    expect(emulator.cpu.t.ie, equals(flags.ie));
    expect(emulator.cpu.t.c, equals(flags.c));
  }

  _test(0xF0, 0x0F, isTrue);
  _test(0x12, 0x36, isFalse);
}

void testANIab(LH5801Emulator emulator, int expectedCycles, List<int> opcodes,
    {bool me1 = false}) {
  void _test(int memValue, int i, Matcher zFlagMatcher) {
    final int ab = me1 ? 0x16001 : 0x6001;
    final List<int> memOpcodes = <int>[...opcodes, (ab >> 8) & 0xFF, ab & 0xFF, i & 0xFF];
    final LH5801Flags flags = emulator.cpu.t.clone();

    memLoad(0x0000, memOpcodes);
    memLoad(ab, <int>[memValue]);
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(expectedCycles));
    expect(emulator.cpu.p.value, equals(memOpcodes.length));

    final int result = emulator.cpu.memRead(ab);
    expect(result, equals((memValue & i) & 0xFF));

    // Z should be the only flag updated.
    expect(emulator.cpu.t.h, equals(flags.h));
    expect(emulator.cpu.t.v, equals(flags.v));
    expect(emulator.cpu.t.z, zFlagMatcher);
    expect(emulator.cpu.t.ie, equals(flags.ie));
    expect(emulator.cpu.t.c, equals(flags.c));
  }

  _test(0xF0, 0x0F, isTrue);
  _test(0x12, 0x36, isFalse);
}

void testPOPRReg(LH5801Emulator emulator, List<int> opcodes, Register16 register) {
  void _test(int intialValue) {
    final int statusRegister = emulator.cpu.t.statusRegister;
    const int initialStackValue = 0x46FD;

    memLoad(0x0000, opcodes);
    emulator.cpu.s.value = initialStackValue;
    memLoad(initialStackValue + 1, <int>[intialValue >> 8, intialValue & 0xFF]);
    register.value = 0;
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(15));
    expect(emulator.cpu.p.value, equals(opcodes.length));

    expect(register.value, equals(intialValue));
    expect(emulator.cpu.s.value, equals(initialStackValue + 2));

    expect(emulator.cpu.t.statusRegister, equals(statusRegister));
  }

  _test(0x2030);
  _test(0x0000);
}

void testPOPA(LH5801Emulator emulator) {
  void _test(int intialValue, Matcher zFlagMatcher) {
    final List<int> opcodes = <int>[0xFD, 0x8A];
    final LH5801Flags flags = emulator.cpu.t.clone();
    const int initialStackValue = 0x46FF;

    memLoad(0x0000, opcodes);
    emulator.cpu.s.value = initialStackValue;
    memLoad(initialStackValue + 1, <int>[intialValue]);
    emulator.cpu.a.value = 0;
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(12));
    expect(emulator.cpu.p.value, equals(opcodes.length));

    expect(emulator.cpu.a.value, equals(intialValue));
    expect(emulator.cpu.s.value, equals(initialStackValue + 1));

    // Z should be the only flag updated.
    expect(emulator.cpu.t.h, equals(flags.h));
    expect(emulator.cpu.t.v, equals(flags.v));
    expect(emulator.cpu.t.z, zFlagMatcher);
    expect(emulator.cpu.t.ie, equals(flags.ie));
    expect(emulator.cpu.t.c, equals(flags.c));
  }

  _test(0x23, isFalse);
  _test(0x00, isTrue);
}

void testORARReg(
  LH5801Emulator emulator,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  void _test(int op1, int op2, Matcher zFlagMatcher) {
    final int rregValue = me1 ? 0x10100 : 0x0100;
    final LH5801Flags flags = emulator.cpu.t.clone();

    memLoad(0x0000, opcodes);
    register.value = rregValue;
    memLoad(rregValue, <int>[op2]);
    emulator.cpu.a.value = op1;
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(expectedCycles));
    expect(emulator.cpu.p.value, equals(opcodes.length));

    expect(emulator.cpu.a.value, equals((op1 | op2) & 0xFF));

    // Z should be the only flag updated.
    expect(emulator.cpu.t.h, equals(flags.h));
    expect(emulator.cpu.t.v, equals(flags.v));
    expect(emulator.cpu.t.z, zFlagMatcher);
    expect(emulator.cpu.t.ie, equals(flags.ie));
    expect(emulator.cpu.t.c, equals(flags.c));
  }

  _test(0x58, 0x27, isFalse);
  _test(0x00, 0x00, isTrue);
}

void testORAab(LH5801Emulator emulator, int expectedCycles, List<int> opcodes,
    {bool me1 = false}) {
  void _test(int op1, int op2, Matcher zFlagMatcher) {
    final int ab = me1 ? 0x11234 : 0x1234;
    final List<int> memOpcodes = <int>[...opcodes, (ab >> 8) & 0xFF, ab & 0xFF];
    final LH5801Flags flags = emulator.cpu.t.clone();

    memLoad(0x0000, memOpcodes);
    memLoad(ab, <int>[op2]);
    emulator.cpu.a.value = op1;
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(expectedCycles));
    expect(emulator.cpu.p.value, equals(memOpcodes.length));

    expect(emulator.cpu.a.value, equals((op1 | op2) & 0xFF));

    // Z should be the only flag updated.
    expect(emulator.cpu.t.h, equals(flags.h));
    expect(emulator.cpu.t.v, equals(flags.v));
    expect(emulator.cpu.t.z, zFlagMatcher);
    expect(emulator.cpu.t.ie, equals(flags.ie));
    expect(emulator.cpu.t.c, equals(flags.c));
  }

  _test(0x58, 0x27, isFalse);
  _test(0x00, 0x00, isTrue);
}

void testORIAcc(LH5801Emulator emulator) {
  void _test(int accValue, int i, Matcher zFlagMatcher) {
    final List<int> memOpcodes = <int>[0xBB, i & 0xFF];
    final LH5801Flags flags = emulator.cpu.t.clone();

    memLoad(0x0000, memOpcodes);
    emulator.cpu.a.value = accValue;
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(7));
    expect(emulator.cpu.p.value, equals(memOpcodes.length));

    expect(emulator.cpu.a.value, equals((accValue | i) & 0xFF));

    // Z should be the only flag updated.
    expect(emulator.cpu.t.h, equals(flags.h));
    expect(emulator.cpu.t.v, equals(flags.v));
    expect(emulator.cpu.t.z, zFlagMatcher);
    expect(emulator.cpu.t.ie, equals(flags.ie));
    expect(emulator.cpu.t.c, equals(flags.c));
  }

  _test(0x00, 0x00, isTrue);
  _test(0x10, 0x01, isFalse);
}

void testORIRReg(
  LH5801Emulator emulator,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  void _test(int memValue, int i, Matcher zFlagMatcher) {
    final int ab = me1 ? 0x10101 : 0x0101;
    final List<int> memOpcodes = <int>[...opcodes, i & 0xFF];
    final LH5801Flags flags = emulator.cpu.t.clone();

    memLoad(0x0000, memOpcodes);
    memLoad(ab, <int>[memValue]);
    register.value = ab;
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(expectedCycles));
    expect(emulator.cpu.p.value, equals(memOpcodes.length));

    final int result = emulator.cpu.memRead(ab);
    expect(result, equals((memValue | i) & 0xFF));

    // Z should be the only flag updated.
    expect(emulator.cpu.t.h, equals(flags.h));
    expect(emulator.cpu.t.v, equals(flags.v));
    expect(emulator.cpu.t.z, zFlagMatcher);
    expect(emulator.cpu.t.ie, equals(flags.ie));
    expect(emulator.cpu.t.c, equals(flags.c));
  }

  _test(0x00, 0x00, isTrue);
  _test(0x10, 0x01, isFalse);
}

void testORIab(LH5801Emulator emulator, int expectedCycles, List<int> opcodes,
    {bool me1 = false}) {
  void _test(int memValue, int i, Matcher zFlagMatcher) {
    final int ab = me1 ? 0x10101 : 0x0101;
    final List<int> memOpcodes = <int>[...opcodes, (ab >> 8) & 0xFF, ab & 0xFF, i & 0xFF];
    final LH5801Flags flags = emulator.cpu.t.clone();

    memLoad(0x0000, memOpcodes);
    memLoad(ab, <int>[memValue]);
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(expectedCycles));
    expect(emulator.cpu.p.value, equals(memOpcodes.length));

    final int result = emulator.cpu.memRead(ab);
    expect(result, equals((memValue | i) & 0xFF));

    // Z should be the only flag updated.
    expect(emulator.cpu.t.h, equals(flags.h));
    expect(emulator.cpu.t.v, equals(flags.v));
    expect(emulator.cpu.t.z, zFlagMatcher);
    expect(emulator.cpu.t.ie, equals(flags.ie));
    expect(emulator.cpu.t.c, equals(flags.c));
  }

  _test(0x00, 0x00, isTrue);
  _test(0x10, 0x01, isFalse);
}

void testDCSRReg(
  LH5801Emulator emulator,
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

    memLoad(0x0000, opcodes);
    register.value = rregValue;
    memLoad(rregValue, <int>[initialOp2Value]);
    emulator.cpu.a.value = initialOp1Value;
    emulator.cpu.t.c = initialCarryValue;
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(expectedCycles));
    expect(emulator.cpu.p.value, equals(opcodes.length));

    expect(emulator.cpu.a.value, expectedAccValue);

    expect(emulator.cpu.t.c, cFlagMatcher);
    expect(emulator.cpu.t.h, hFlagMatcher);
  }

  _test(0x42, 0x31, true, 0x11, isTrue, isTrue);
  _test(0x42, 0x31, false, 0x10, isTrue, isTrue);
  _test(0x23, 0x54, true, 0x69, isFalse, isFalse);
  _test(0x23, 0x54, false, 0x68, isFalse, isFalse);
}

void testEORRReg(
  LH5801Emulator emulator,
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
    final LH5801Flags flags = emulator.cpu.t.clone();

    memLoad(0x0000, opcodes);
    register.value = rregValue;
    memLoad(rregValue, <int>[initialOp2Value]);
    emulator.cpu.a.value = initialOp1Value;
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(expectedCycles));
    expect(emulator.cpu.p.value, equals(opcodes.length));

    expect(emulator.cpu.a.value, equals(expectedAccValue));

    // Z should be the only flag updated.
    expect(emulator.cpu.t.h, equals(flags.h));
    expect(emulator.cpu.t.v, equals(flags.v));
    expect(emulator.cpu.t.z, zFlagMatcher);
    expect(emulator.cpu.t.ie, equals(flags.ie));
    expect(emulator.cpu.t.c, equals(flags.c));
  }

  _test(0x36, 0x6D, 0x5B, isFalse);
  _test(0x00, 0x00, 0x00, isTrue);
}

void testEORab(LH5801Emulator emulator, int expectedCycles, List<int> opcodes,
    {bool me1 = false}) {
  void _test(
    int initialOp1Value,
    int initialOp2Value,
    int expectedAccValue,
    Matcher zFlagMatcher,
  ) {
    final int ab = me1 ? 0x11234 : 0x1234;
    final List<int> memOpcodes = <int>[...opcodes, (ab >> 8) & 0xFF, ab & 0xFF];
    final LH5801Flags flags = emulator.cpu.t.clone();

    memLoad(0x0000, memOpcodes);
    memLoad(ab, <int>[initialOp2Value]);
    emulator.cpu.a.value = initialOp1Value;
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(expectedCycles));
    expect(emulator.cpu.p.value, equals(memOpcodes.length));

    expect(emulator.cpu.a.value, equals(expectedAccValue));

    // Z should be the only flag updated.
    expect(emulator.cpu.t.h, equals(flags.h));
    expect(emulator.cpu.t.v, equals(flags.v));
    expect(emulator.cpu.t.z, zFlagMatcher);
    expect(emulator.cpu.t.ie, equals(flags.ie));
    expect(emulator.cpu.t.c, equals(flags.c));
  }

  _test(0x36, 0x6D, 0x5B, isFalse);
  _test(0x00, 0x00, 0x00, isTrue);
}

void testSTAReg(LH5801Emulator emulator, List<int> opcodes, Register8 register) {
  final int statusRegister = emulator.cpu.t.statusRegister;

  memLoad(0x0000, opcodes);
  emulator.cpu.a.value = 0x33;
  register.value = 0x01;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(5));
  expect(emulator.cpu.p.value, equals(opcodes.length));

  expect(register.value, equals(emulator.cpu.a.value));

  expect(emulator.cpu.t.statusRegister, equals(statusRegister));
}

void testSTARReg(
  LH5801Emulator emulator,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  final int rregValue = me1 ? 0x10100 : 0x0100;
  final int statusRegister = emulator.cpu.t.statusRegister;

  memLoad(0x0000, opcodes);
  emulator.cpu.a.value = 0x33;
  register.value = rregValue;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(expectedCycles));
  expect(emulator.cpu.p.value, equals(opcodes.length));

  expect(emulator.cpu.memRead(rregValue), equals(emulator.cpu.a.value));

  expect(emulator.cpu.t.statusRegister, equals(statusRegister));
}

void testSTAab(LH5801Emulator emulator, int expectedCycles, List<int> opcodes,
    {bool me1 = false}) {
  final int ab = me1 ? 0x1CB00 : 0xCB00;
  final List<int> memOpcodes = <int>[...opcodes, (ab >> 8) & 0xFF, ab & 0xFF];
  final int statusRegister = emulator.cpu.t.statusRegister;

  memLoad(0x0000, memOpcodes);
  memLoad(ab, <int>[0xFF]);
  emulator.cpu.a.value = 0x51;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(expectedCycles));
  expect(emulator.cpu.p.value, equals(memOpcodes.length));

  expect(emulator.cpu.a.value, equals(emulator.cpu.memRead(ab)));

  expect(emulator.cpu.t.statusRegister, equals(statusRegister));
}

void testBITRReg(
  LH5801Emulator emulator,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  void _test(int memValue, int i, Matcher zFlagMatcher) {
    final int regValue = me1 ? 0x10100 : 0x0100;
    final LH5801Flags flags = emulator.cpu.t.clone();

    memLoad(0x0000, opcodes);
    register.value = regValue;
    memLoad(regValue, <int>[memValue]);
    emulator.cpu.a.value = i;
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(expectedCycles));
    expect(emulator.cpu.p.value, equals(opcodes.length));

    // Accumulator should not be updated.
    expect(emulator.cpu.a.value, equals(i));

    // Z should be the only flag updated.
    expect(emulator.cpu.t.h, equals(flags.h));
    expect(emulator.cpu.t.v, equals(flags.v));
    expect(emulator.cpu.t.z, zFlagMatcher);
    expect(emulator.cpu.t.ie, equals(flags.ie));
    expect(emulator.cpu.t.c, equals(flags.c));
  }

  _test(0x0F, 0x80, isTrue);
  _test(0x10, 0x30, isFalse);
}

void testBITab(LH5801Emulator emulator, int expectedCycles, List<int> opcodes,
    {bool me1 = false}) {
  void _test(int accValue, int abValue, Matcher zFlagMatcher) {
    final int ab = me1 ? 0x1CB00 : 0xCB00;
    final List<int> memOpcodes = <int>[...opcodes, (abValue >> 8) & 0xFF, abValue & 0xFF];
    final LH5801Flags flags = emulator.cpu.t.clone();

    memLoad(0x0000, memOpcodes);
    memLoad(ab, <int>[abValue]);
    emulator.cpu.a.value = accValue;
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(expectedCycles));
    expect(emulator.cpu.p.value, equals(memOpcodes.length));

    // Accumulator should not be updated.
    expect(emulator.cpu.a.value, equals(accValue));

    // Z should be the only flag updated.
    expect(emulator.cpu.t.h, equals(flags.h));
    expect(emulator.cpu.t.v, equals(flags.v));
    expect(emulator.cpu.t.z, isTrue);
    expect(emulator.cpu.t.ie, equals(flags.ie));
    expect(emulator.cpu.t.c, equals(flags.c));
  }

  _test(0x0F, 0x80, isTrue);
  _test(0x10, 0x30, isFalse);
}

void testBIIAcc(LH5801Emulator emulator) {
  void _test(int accValue, int i, Matcher zFlagMatcher) {
    final List<int> memOpcodes = <int>[0xBF, i & 0xFF];
    final LH5801Flags flags = emulator.cpu.t.clone();

    memLoad(0x0000, memOpcodes);
    emulator.cpu.a.value = accValue;
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(7));
    expect(emulator.cpu.p.value, equals(memOpcodes.length));

    // Accumulator should not be updated.
    expect(emulator.cpu.a.value, accValue);

    // Z should be the only flag updated.
    expect(emulator.cpu.t.h, equals(flags.h));
    expect(emulator.cpu.t.v, equals(flags.v));
    expect(emulator.cpu.t.z, zFlagMatcher);
    expect(emulator.cpu.t.ie, equals(flags.ie));
    expect(emulator.cpu.t.c, equals(flags.c));
  }

  _test(0x0F, 0x80, isTrue);
  _test(0x10, 0x30, isFalse);
}

void testBIIRReg(
  LH5801Emulator emulator,
  int expectedCycles,
  List<int> opcodes,
  Register16 register, {
  bool me1 = false,
}) {
  void _test(int memValue, int i, Matcher zFlagMatcher) {
    final int regValue = me1 ? 0x10100 : 0x0100;
    final List<int> memOpcodes = <int>[...opcodes, i & 0xFF];
    final LH5801Flags flags = emulator.cpu.t.clone();

    memLoad(0x0000, memOpcodes);
    register.value = regValue;
    memLoad(regValue, <int>[memValue]);
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(expectedCycles));
    expect(emulator.cpu.p.value, equals(memOpcodes.length));

    // Memory should not be updated.
    final int newMemValue = emulator.cpu.memRead(regValue);
    expect(newMemValue, memValue);

    // Z should be the only flag updated.
    expect(emulator.cpu.t.h, equals(flags.h));
    expect(emulator.cpu.t.v, equals(flags.v));
    expect(emulator.cpu.t.z, zFlagMatcher);
    expect(emulator.cpu.t.ie, equals(flags.ie));
    expect(emulator.cpu.t.c, equals(flags.c));
  }

  _test(0x0F, 0x80, isTrue);
  _test(0x10, 0x30, isFalse);
}

void testBIIab(LH5801Emulator emulator, int expectedCycles, List<int> opcodes,
    {bool me1 = false}) {
  void _test(int memValue, int i, Matcher zFlagMatcher) {
    final int ab = me1 ? 0x1CB00 : 0xCB00;
    final List<int> memOpcodes = <int>[
      ...opcodes,
      (ab >> 8) & 0xFF,
      ab & 0xFF,
      i & 0xFF,
    ];
    final LH5801Flags flags = emulator.cpu.t.clone();

    memLoad(0x0000, memOpcodes);
    memLoad(ab, <int>[memValue]);
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(expectedCycles));
    expect(emulator.cpu.p.value, equals(memOpcodes.length));

    // Memory should not be updated.
    final int newABValue = emulator.cpu.memRead(ab);
    expect(newABValue, memValue);

    // Z should be the only flag updated.
    expect(emulator.cpu.t.h, equals(flags.h));
    expect(emulator.cpu.t.v, equals(flags.v));
    expect(emulator.cpu.t.z, zFlagMatcher);
    expect(emulator.cpu.t.ie, equals(flags.ie));
    expect(emulator.cpu.t.c, equals(flags.c));
  }

  _test(0x0F, 0x80, isTrue);
  _test(0x10, 0x30, isFalse);
}

void testIncReg8(
  LH5801Emulator emulator,
  int expectedCycles,
  List<int> opcodes,
  Register8 register,
) {
  final LH5801Flags flags = emulator.cpu.t.clone();

  memLoad(0x0000, opcodes);
  register.value = 0x80; // -128
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(expectedCycles));
  expect(emulator.cpu.p.value, equals(opcodes.length));

  expect(register.value, equals(0x81)); // -127

  expect(emulator.cpu.t.h, isFalse);
  expect(emulator.cpu.t.v, isFalse);
  expect(emulator.cpu.t.z, isFalse);
  expect(emulator.cpu.t.ie, equals(flags.ie));
  expect(emulator.cpu.t.c, isFalse);
}

void testIncReg16(
  LH5801Emulator emulator,
  int expectedCycles,
  List<int> opcodes,
  Register16 register,
) {
  final int statusRegister = emulator.cpu.t.statusRegister;

  memLoad(0x0000, opcodes);
  register.value = 0xFFFF;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(expectedCycles));
  expect(emulator.cpu.p.value, equals(opcodes.length));

  expect(register.value, equals(0x0000));

  expect(emulator.cpu.t.statusRegister, equals(statusRegister));
}

void testDecReg8(
  LH5801Emulator emulator,
  int expectedCycles,
  List<int> opcodes,
  Register8 register,
) {
  final LH5801Flags flags = emulator.cpu.t.clone();

  memLoad(0x0000, opcodes);
  register.value = 0x00;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(expectedCycles));
  expect(emulator.cpu.p.value, equals(opcodes.length));

  expect(register.value, equals(0xFF));

  expect(emulator.cpu.t.h, isFalse);
  expect(emulator.cpu.t.v, isFalse);
  expect(emulator.cpu.t.z, isFalse);
  expect(emulator.cpu.t.ie, equals(flags.ie));
  expect(emulator.cpu.t.c, isFalse);
}

void testDecReg16(
  LH5801Emulator emulator,
  int expectedCycles,
  List<int> opcodes,
  Register16 register,
) {
  final int statusRegister = emulator.cpu.t.statusRegister;

  memLoad(0x0000, opcodes);
  register.value = 0x0000;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(expectedCycles));
  expect(emulator.cpu.p.value, equals(opcodes.length));

  expect(register.value, equals(0xFFFF));

  expect(emulator.cpu.t.statusRegister, equals(statusRegister));
}

void testLDXReg(LH5801Emulator emulator, List<int> opcodes, Register16 register) {
  final int statusRegister = emulator.cpu.t.statusRegister;

  memLoad(0x0000, opcodes);
  register.value = 25;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(11));
  expect(emulator.cpu.p.value, equals(opcodes.length));

  expect(emulator.cpu.x.value, equals(25));

  expect(emulator.cpu.t.statusRegister, statusRegister);
}

void testSTXReg(LH5801Emulator emulator, List<int> opcodes, Register16 register) {
  final int statusRegister = emulator.cpu.t.statusRegister;

  memLoad(0x0000, opcodes);
  emulator.cpu.x.value = 25;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(11));
  expect(emulator.cpu.p.value, equals(opcodes.length));

  expect(register.value, equals(25));

  expect(emulator.cpu.t.statusRegister, statusRegister);
}

void testPSHRReg(LH5801Emulator emulator, List<int> opcodes, Register16 register) {
  final int statusRegister = emulator.cpu.t.statusRegister;

  memLoad(0x0000, opcodes);
  emulator.cpu.s.value = 0x46FF;
  register.value = 0x2030;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(14));
  expect(emulator.cpu.p.value, equals(opcodes.length));

  expect(emulator.cpu.s.value, equals(0x46FF - 2));
  expect(emulator.cpu.memRead(0x46FF), equals(0x30));
  expect(emulator.cpu.memRead(0x46FE), equals(0x20));
  expect(register.value, equals(0x2030));

  expect(emulator.cpu.t.statusRegister, statusRegister);
}

void testDCARReg(
  LH5801Emulator emulator,
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

    memLoad(0x0000, opcodes);
    register.value = regValue;
    memLoad(regValue, <int>[initialOp2Value]);
    emulator.cpu.a.value = initialOp1Value;
    emulator.cpu.t.c = initialCarryValue;
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(expectedCycles));
    expect(emulator.cpu.p.value, equals(opcodes.length));

    expect(emulator.cpu.a.value, expectedAccValue);

    expect(emulator.cpu.t.c, cFlagMatcher);
    expect(emulator.cpu.t.h, hFlagMatcher);
  }

  _test(0x35, 0x27, false, 0x62, isFalse, isTrue);
  _test(0x35, 0x27, true, 0x63, isFalse, isTrue);
  _test(0x35, 0x67, false, 0x02, isTrue, isTrue);
  _test(0x35, 0x67, true, 0x03, isTrue, isTrue);
}

void testATT(LH5801Emulator emulator) {
  final List<int> opcodes = <int>[0xFD, 0xEC];

  memLoad(0x0000, opcodes);
  emulator.cpu.a.value = 0x1F;
  emulator.cpu.t.statusRegister = 0;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(9));
  expect(emulator.cpu.p.value, equals(opcodes.length));

  expect(emulator.cpu.t.statusRegister, 0x1F);
}

void testTTA(LH5801Emulator emulator) {
  void _test(int initialStatusRegisterValue, Matcher zFlagMatcher) {
    final List<int> opcodes = <int>[0xFD, 0xAA];

    memLoad(0x0000, opcodes);
    emulator.cpu.a.value = 83;
    emulator.cpu.t.statusRegister = initialStatusRegisterValue;
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(9));
    expect(emulator.cpu.p.value, equals(opcodes.length));

    expect(emulator.cpu.a.value, initialStatusRegisterValue);

    expect(emulator.cpu.t.z, zFlagMatcher);
  }

  _test(0x08, isFalse);
  _test(0x00, isTrue);
}

void testADRRReg(LH5801Emulator emulator, List<int> opcodes, Register16 register) {
  final int statusRegister = emulator.cpu.t.statusRegister;

  memLoad(0x0000, opcodes);
  emulator.cpu.a.value = 0xC3;
  register.value = 0x0A88;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(11));
  expect(emulator.cpu.p.value, equals(opcodes.length));

  expect(register.value, equals(0x0B4B));

  expect(emulator.cpu.t.statusRegister, equals(statusRegister));
}

void testDRRRReg(
  LH5801Emulator emulator,
  int expectedCycles,
  List<int> opcodes, {
  bool me1 = false,
}) {
  final int statusRegister = emulator.cpu.t.statusRegister;

  memLoad(0x0000, opcodes);
  emulator.cpu.x.value = 0x4700;
  memLoad((me1 ? 0x10000 : 0) | emulator.cpu.x.value, <int>[0x42]);
  emulator.cpu.a.value = 0xC1;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(expectedCycles));
  expect(emulator.cpu.p.value, equals(opcodes.length));

  expect(emulator.cpu.a.value, equals(0x42));
  final int x = emulator.cpu.memRead((me1 ? 0x10000 : 0) | emulator.cpu.x.value);
  expect(x, equals(0x14));

  expect(emulator.cpu.t.statusRegister, equals(statusRegister));
}

void testDRLRReg(
  LH5801Emulator emulator,
  int expectedCycles,
  List<int> opcodes, {
  bool me1 = false,
}) {
  final int statusRegister = emulator.cpu.t.statusRegister;

  memLoad(0x0000, opcodes);
  emulator.cpu.x.value = 0x4700;
  memLoad((me1 ? 0x10000 : 0) | emulator.cpu.x.value, <int>[0xB3]);
  emulator.cpu.a.value = 0x6F;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(expectedCycles));
  expect(emulator.cpu.p.value, equals(opcodes.length));

  expect(emulator.cpu.a.value, equals(0xB3));
  final int x = emulator.cpu.memRead((me1 ? 0x10000 : 0) | emulator.cpu.x.value);
  expect(x, equals(0x36));

  expect(emulator.cpu.t.statusRegister, equals(statusRegister));
}

void testSINRReg(LH5801Emulator emulator, List<int> opcodes, Register16 register) {
  void _test(int regValue) {
    final int statusRegister = emulator.cpu.t.statusRegister;

    emulator.cpu.p.value = 0x1000;
    memLoad(0x1000, opcodes);
    register.value = regValue;
    memLoad(regValue, <int>[0x00]);
    emulator.cpu.a.value = 0x6F;
    final int cycles = emulator.step(address: 0x1000);
    expect(cycles, equals(6));
    expect(emulator.cpu.p.value, equals(0x1000 + opcodes.length));

    expect(emulator.cpu.a.value, equals(0x6F));
    final int x = emulator.cpu.memRead(regValue);
    expect(x, equals(0x6F));
    expect(register.value, equals((regValue + 1) & 0xFFFF));

    expect(emulator.cpu.t.statusRegister, equals(statusRegister));
  }

  _test(0x0100);
  _test(0xFFFF);
}

void testSDERReg(LH5801Emulator emulator, List<int> opcodes, Register16 register) {
  void _test(int regValue) {
    final int statusRegister = emulator.cpu.t.statusRegister;

    emulator.cpu.p.value = 0x1000;
    memLoad(0x1000, opcodes);
    register.value = regValue;
    memLoad(regValue, <int>[0x00]);
    emulator.cpu.a.value = 0x6F;
    final int cycles = emulator.step(address: 0x1000);
    expect(cycles, equals(6));
    expect(emulator.cpu.p.value, equals(0x1000 + opcodes.length));

    expect(emulator.cpu.a.value, equals(0x6F));
    final int x = emulator.cpu.memRead(regValue);
    expect(x, equals(0x6F));
    expect(register.value, equals((regValue - 1) & 0xFFFF));

    expect(emulator.cpu.t.statusRegister, equals(statusRegister));
  }

  _test(0x0100);
  _test(0x0000);
}

void testLINRReg(LH5801Emulator emulator, List<int> opcodes, Register16 register) {
  void _test(int regValue, int memValue, Matcher zFlagMatcher) {
    final LH5801Flags flags = emulator.cpu.t.clone();

    emulator.cpu.p.value = 0x1000;
    memLoad(0x1000, opcodes);
    register.value = regValue;
    memLoad(regValue, <int>[memValue]);
    emulator.cpu.a.value = 0xFF;
    final int cycles = emulator.step(address: 0x1000);
    expect(cycles, equals(6));
    expect(emulator.cpu.p.value, equals(0x1000 + opcodes.length));

    expect(emulator.cpu.a.value, equals(memValue));
    expect(register.value, equals((regValue + 1) & 0xFFFF));

    expect(emulator.cpu.t.h, equals(flags.h));
    expect(emulator.cpu.t.v, equals(flags.v));
    expect(emulator.cpu.t.z, zFlagMatcher);
    expect(emulator.cpu.t.ie, equals(flags.ie));
    expect(emulator.cpu.t.c, equals(flags.c));
  }

  _test(0x0055, 0x3A, isFalse);
  _test(0xFFFF, 0x00, isTrue);
}

void testLDERReg(LH5801Emulator emulator, List<int> opcodes, Register16 register) {
  void _test(int regValue, int memValue, Matcher zFlagMatcher) {
    final LH5801Flags flags = emulator.cpu.t.clone();

    emulator.cpu.p.value = 0x1000;
    memLoad(0x1000, opcodes);
    register.value = regValue;
    memLoad(regValue, <int>[memValue]);
    emulator.cpu.a.value = 0xFF;
    final int cycles = emulator.step(address: 0x1000);
    expect(cycles, equals(6));
    expect(emulator.cpu.p.value, equals(0x1000 + opcodes.length));

    expect(emulator.cpu.a.value, equals(memValue));
    expect(register.value, equals((regValue - 1) & 0xFFFF));

    expect(emulator.cpu.t.h, equals(flags.h));
    expect(emulator.cpu.t.v, equals(flags.v));
    expect(emulator.cpu.t.z, zFlagMatcher);
    expect(emulator.cpu.t.ie, equals(flags.ie));
    expect(emulator.cpu.t.c, equals(flags.c));
  }

  _test(0x0055, 0x3A, isFalse);
  _test(0x0000, 0x00, isTrue);
}

void testLDIAcc(LH5801Emulator emulator) {
  void _test(int i, Matcher zFlagMatcher) {
    final List<int> memOpcodes = <int>[0xB5, i & 0xFF];
    final LH5801Flags flags = emulator.cpu.t.clone();

    memLoad(0x0000, memOpcodes);
    emulator.cpu.a.value = i ^ 0xFF;
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(6));
    expect(emulator.cpu.p.value, equals(memOpcodes.length));

    expect(emulator.cpu.a.value, equals(i));

    expect(emulator.cpu.t.h, equals(flags.h));
    expect(emulator.cpu.t.v, equals(flags.v));
    expect(emulator.cpu.t.z, zFlagMatcher);
    expect(emulator.cpu.t.ie, equals(flags.ie));
    expect(emulator.cpu.t.c, equals(flags.c));
  }

  _test(0x00, isTrue);
  _test(0xAA, isFalse);
}

void testLDIReg(LH5801Emulator emulator, List<int> opcodes, Register8 register) {
  final List<int> memOpcodes = <int>[...opcodes, 0x5A];
  final int statusRegister = emulator.cpu.t.statusRegister;

  memLoad(0x0000, memOpcodes);
  register.value = 0xFF;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(6));
  expect(emulator.cpu.p.value, equals(memOpcodes.length));

  expect(register.value, equals(0x5A));

  expect(emulator.cpu.t.statusRegister, equals(statusRegister));
}

void testLDISij(LH5801Emulator emulator) {
  const int ij = 0x1234;
  final List<int> memOpcodes = <int>[0xAA, ij >> 8, ij & 0xFF];
  final int statusRegister = emulator.cpu.t.statusRegister;

  memLoad(0x0000, memOpcodes);
  emulator.cpu.s.value = ij ^ 0x0FF0;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(12));
  expect(emulator.cpu.p.value, equals(memOpcodes.length));

  expect(emulator.cpu.s.value, equals(ij));

  expect(emulator.cpu.t.statusRegister, equals(statusRegister));
}

void testCPIReg(LH5801Emulator emulator, List<int> opcodes, Register8 register) {
  void _test(int op1, int op2, Matcher cFlagMatcher, Matcher zFlagMatcher) {
    final List<int> memOpcodes = <int>[...opcodes, op2 & 0xFF];

    memLoad(0x0000, memOpcodes);
    register.value = op1;
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(7));
    expect(emulator.cpu.p.value, equals(memOpcodes.length));

    expect(emulator.cpu.t.c, cFlagMatcher);
    expect(emulator.cpu.t.z, zFlagMatcher);
  }

  _test(84, 80, isTrue, isFalse);
  _test(2, 2, isTrue, isTrue);
  _test(84, 110, isFalse, isFalse);
}

void _testBranch(
  LH5801Emulator emulator,
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

  emulator.cpu.p.value = initialP;
  memLoad(initialP, memOpcodes);
  emulator.cpu.t.statusRegister = flagMask;
  final int cycles = emulator.step(address: emulator.cpu.p.value);

  // Condition is true?
  if (cond(emulator.cpu.t.statusRegister)) {
    expect(cycles, equals(expectedCycles + additionalCycles));
    expect(
      emulator.cpu.p.value,
      equals(
        initialP + memOpcodes.length + (forward ? offset : -offset),
      ),
    );
  } else {
    expect(cycles, equals(expectedCycles));
    expect(emulator.cpu.p.value, equals(initialP + memOpcodes.length));
  }
}

void testBCR(LH5801Emulator emulator, List<int> opcodes, {bool forward = true}) {
  _testBranch(
    emulator,
    2,
    opcodes,
    0,
    (int statusRegister) => (emulator.cpu.t.statusRegister & LH5801Flags.C) == 0,
    forward: forward,
  );

  _testBranch(
    emulator,
    2,
    opcodes,
    LH5801Flags.C,
    (int statusRegister) => (emulator.cpu.t.statusRegister & LH5801Flags.C) == 0,
    forward: forward,
  );
}

void testBCS(LH5801Emulator emulator, List<int> opcodes, {bool forward = true}) {
  _testBranch(
    emulator,
    2,
    opcodes,
    LH5801Flags.C,
    (int statusRegister) => (emulator.cpu.t.statusRegister & LH5801Flags.C) != 0,
    forward: forward,
  );

  _testBranch(
    emulator,
    2,
    opcodes,
    0,
    (int statusRegister) => (emulator.cpu.t.statusRegister & LH5801Flags.C) != 0,
    forward: forward,
  );
}

void testBHR(LH5801Emulator emulator, List<int> opcodes, {bool forward = true}) {
  _testBranch(
    emulator,
    2,
    opcodes,
    0,
    (int statusRegister) => (emulator.cpu.t.statusRegister & LH5801Flags.H) == 0,
    forward: forward,
  );

  _testBranch(
    emulator,
    2,
    opcodes,
    LH5801Flags.H,
    (int statusRegister) => (emulator.cpu.t.statusRegister & LH5801Flags.H) == 0,
    forward: forward,
  );
}

void testBHS(LH5801Emulator emulator, List<int> opcodes, {bool forward = true}) {
  _testBranch(
    emulator,
    2,
    opcodes,
    LH5801Flags.H,
    (int statusRegister) => (emulator.cpu.t.statusRegister & LH5801Flags.H) != 0,
    forward: forward,
  );

  _testBranch(
    emulator,
    2,
    opcodes,
    0,
    (int statusRegister) => (emulator.cpu.t.statusRegister & LH5801Flags.H) != 0,
    forward: forward,
  );
}

void testBZR(LH5801Emulator emulator, List<int> opcodes, {bool forward = true}) {
  _testBranch(
    emulator,
    2,
    opcodes,
    0,
    (int statusRegister) => (emulator.cpu.t.statusRegister & LH5801Flags.Z) == 0,
    forward: forward,
  );

  _testBranch(
    emulator,
    2,
    opcodes,
    LH5801Flags.Z,
    (int statusRegister) => (emulator.cpu.t.statusRegister & LH5801Flags.Z) == 0,
    forward: forward,
  );
}

void testBZS(LH5801Emulator emulator, List<int> opcodes, {bool forward = true}) {
  _testBranch(
    emulator,
    2,
    opcodes,
    LH5801Flags.Z,
    (int statusRegister) => (emulator.cpu.t.statusRegister & LH5801Flags.Z) != 0,
    forward: forward,
  );

  _testBranch(
    emulator,
    2,
    opcodes,
    0,
    (int statusRegister) => (emulator.cpu.t.statusRegister & LH5801Flags.Z) != 0,
    forward: forward,
  );
}

void testBVR(LH5801Emulator emulator, List<int> opcodes, {bool forward = true}) {
  _testBranch(
    emulator,
    2,
    opcodes,
    0,
    (int statusRegister) => (emulator.cpu.t.statusRegister & LH5801Flags.V) == 0,
    forward: forward,
  );

  _testBranch(
    emulator,
    2,
    opcodes,
    LH5801Flags.V,
    (int statusRegister) => (emulator.cpu.t.statusRegister & LH5801Flags.V) == 0,
    forward: forward,
  );
}

void testBVS(LH5801Emulator emulator, List<int> opcodes, {bool forward = true}) {
  _testBranch(
    emulator,
    2,
    opcodes,
    LH5801Flags.V,
    (int statusRegister) => (emulator.cpu.t.statusRegister & LH5801Flags.V) != 0,
    forward: forward,
  );

  _testBranch(
    emulator,
    2,
    opcodes,
    0,
    (int statusRegister) => (emulator.cpu.t.statusRegister & LH5801Flags.V) != 0,
    forward: forward,
  );
}

void testBCH(LH5801Emulator emulator, List<int> opcodes, {bool forward = true}) {
  _testBranch(
    emulator,
    0,
    opcodes,
    0,
    (int statusRegister) => true,
    forward: forward,
  );
}

void testLOP(LH5801Emulator emulator) {
  int _unsignedByteToSignedInt(int value) =>
      (value & 0x80 != 0) ? -((0xff & ~value) + 1) : value;

  void _test(int uValue) {
    const int initialP = 0x4003;
    const int offset = 0x05;
    final List<int> memOpcodes = <int>[0x88, 0x05];
    const int expectedCycles = 8;
    final int statusRegister = emulator.cpu.t.statusRegister;

    emulator.cpu.p.value = initialP;
    memLoad(initialP, memOpcodes);
    emulator.cpu.u.low = uValue;
    final int cycles = emulator.step(address: emulator.cpu.p.value);

    final int uLow = _unsignedByteToSignedInt(emulator.cpu.u.low);
    expect(uLow, equals(uValue - 1));

    // End of loop?
    if (uLow >= 0) {
      expect(cycles, equals(expectedCycles + 3));
      expect(
        emulator.cpu.p.value,
        equals(
          initialP + memOpcodes.length + -offset,
        ),
      );
    } else {
      expect(cycles, equals(expectedCycles));
      expect(emulator.cpu.p.value, equals(initialP + memOpcodes.length));
    }

    expect(emulator.cpu.t.statusRegister, equals(statusRegister));
  }

  _test(4);
  _test(1);
  _test(0);
}

void testSBIAcc(LH5801Emulator emulator) {
  final List<int> memOpcodes = <int>[0xB1, 7];

  memLoad(0x0000, memOpcodes);
  emulator.cpu.a.value = 36;
  emulator.cpu.t.c = false;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(7));
  expect(emulator.cpu.p.value, equals(memOpcodes.length));

  expect(emulator.cpu.a.value, equals(28));

  expect(emulator.cpu.t.c, isTrue);
  expect(emulator.cpu.t.z, isFalse);
  expect(emulator.cpu.t.v, isFalse);
  expect(emulator.cpu.t.h, isFalse);
}

void testJMP(LH5801Emulator emulator) {
  const int initialPValue = 0x4000;
  const int ij = 0x4100;
  final List<int> memOpcodes = <int>[0xBA, ij >> 8, ij & 0xFF];
  final int statusRegister = emulator.cpu.t.statusRegister;

  emulator.cpu.p.value = initialPValue;
  memLoad(emulator.cpu.p.value, memOpcodes);
  final int cycles = emulator.step(address: emulator.cpu.p.value);
  expect(cycles, equals(12));

  expect(emulator.cpu.p.value, equals(ij));

  expect(emulator.cpu.t.statusRegister, equals(statusRegister));
}

void testEAI(LH5801Emulator emulator) {
  void _test(
    int initialOp1Value,
    int initialOp2Value,
    int expectedAccValue,
    Matcher zFlagMatcher,
  ) {
    final List<int> memOpcodes = <int>[0xBD, initialOp2Value & 0xFF];
    final LH5801Flags flags = emulator.cpu.t.clone();

    memLoad(0x0000, memOpcodes);
    emulator.cpu.a.value = initialOp1Value;
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(7));
    expect(emulator.cpu.p.value, equals(memOpcodes.length));

    expect(emulator.cpu.a.value, equals(expectedAccValue));

    // Z should be the only flag updated.
    expect(emulator.cpu.t.h, equals(flags.h));
    expect(emulator.cpu.t.v, equals(flags.v));
    expect(emulator.cpu.t.z, zFlagMatcher);
    expect(emulator.cpu.t.ie, equals(flags.ie));
    expect(emulator.cpu.t.c, equals(flags.c));
  }

  _test(0x36, 0x6D, 0x5B, isFalse);
  _test(0x00, 0x00, 0x00, isTrue);
}

void testSJP(LH5801Emulator emulator) {
  const int initialPValue = 0x4000;
  const int initialSValue = 0x6000;
  const int ij = 0xE000;
  final List<int> memOpcodes = <int>[0xBE, ij >> 8, ij & 0xFF];
  final int statusRegister = emulator.cpu.t.statusRegister;

  emulator.cpu.p.value = initialPValue;
  emulator.cpu.s.value = initialSValue;
  memLoad(emulator.cpu.p.value, memOpcodes);
  final int cycles = emulator.step(address: emulator.cpu.p.value);
  expect(cycles, equals(19));

  expect(emulator.cpu.p.value, equals(ij));
  expect(emulator.cpu.s.value, equals(initialSValue - 2));
  expect(
      (initialPValue + memOpcodes.length) & 0xFF, equals(emulator.cpu.memRead(0x6000)));
  expect(
      (initialPValue + memOpcodes.length) >> 8, equals(emulator.cpu.memRead(0x6000 - 1)));

  expect(emulator.cpu.t.statusRegister, equals(statusRegister));
}

void testRTN(LH5801Emulator emulator) {
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
  final int statusRegister = emulator.cpu.t.statusRegister;

  emulator.cpu.p.value = initialPValue;
  emulator.cpu.s.value = initialSValue;

  memLoad(emulator.cpu.p.value, memOpcodes1);
  int cycles = emulator.step(address: emulator.cpu.p.value);
  expect(cycles, equals(19));

  memLoad(emulator.cpu.p.value, memOpcodes2);
  cycles = emulator.step(address: emulator.cpu.p.value);
  expect(cycles, equals(11));

  expect(emulator.cpu.p.value, equals(initialPValue + memOpcodes1.length));
  expect(emulator.cpu.s.value, equals(initialSValue));

  expect(emulator.cpu.t.statusRegister, equals(statusRegister));
}

void testRTI(LH5801Emulator emulator) {
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

  emulator.cpu.p.value = initialPValue;
  memLoad(emulator.cpu.p.value, memOpcodes);

  emulator.cpu.s.value = initialSValue;
  memLoad(initialSValue + 1, stackOpcodes);

  final int cycles = emulator.step(address: emulator.cpu.p.value);
  expect(cycles, equals(14));

  expect(emulator.cpu.p.value, equals(ij));
  expect(emulator.cpu.s.value, equals(initialSValue + 3));
  expect(emulator.cpu.t.statusRegister, equals(statusRegister));
}

void testVSJ(LH5801Emulator emulator, int expectedCycles, List<int> opcodes) {
  const int initialSValue = 0x6000;
  const int initialPValue = 0x4000;
  const int subroutineAddress = 0x4500;

  final List<int> memOpcodes = <int>[...opcodes];
  final LH5801Flags flags = emulator.cpu.t.clone();

  emulator.cpu.s.value = initialSValue;

  emulator.cpu.p.value = initialPValue;
  memLoad(emulator.cpu.p.value, memOpcodes);

  for (int vectorId = 0xC0; vectorId <= 0xF6; vectorId += 2) {
    memLoad(
      0xFF00 | vectorId,
      <int>[subroutineAddress >> 8, subroutineAddress & 0xFF],
    );
  }

  final int cycles = emulator.step(address: emulator.cpu.p.value);
  expect(cycles, equals(expectedCycles));

  expect(emulator.cpu.p.value, equals(subroutineAddress));
  expect(emulator.cpu.s.value, equals(initialSValue - 2));
  expect(
      (initialPValue + memOpcodes.length) & 0xFF, equals(emulator.cpu.memRead(0x6000)));
  expect(
      (initialPValue + memOpcodes.length) >> 8, equals(emulator.cpu.memRead(0x6000 - 1)));

  // Z is reset.
  expect(emulator.cpu.t.h, equals(flags.h));
  expect(emulator.cpu.t.v, equals(flags.v));
  expect(emulator.cpu.t.z, isFalse);
  expect(emulator.cpu.t.ie, equals(flags.ie));
  expect(emulator.cpu.t.c, equals(flags.c));
}

void _testVSJConditional(
  LH5801Emulator emulator,
  List<int> opcodes,
  int statusRegister, {
  bool jump = false,
}) {
  const int initialSValue = 0x6000;
  const int initialPValue = 0x4000;
  const int subroutineAddress = 0x4500;

  final List<int> memOpcodes = <int>[...opcodes];

  emulator.cpu.t.statusRegister = statusRegister;
  final LH5801Flags flags = emulator.cpu.t.clone();

  emulator.cpu.s.value = initialSValue;

  emulator.cpu.p.value = initialPValue;
  memLoad(emulator.cpu.p.value, memOpcodes);

  for (int vectorId = 0xC0; vectorId <= 0xF6; vectorId += 2) {
    memLoad(
      0xFF00 | vectorId,
      <int>[subroutineAddress >> 8, subroutineAddress & 0xFF],
    );
  }

  final int cycles = emulator.step(address: emulator.cpu.p.value);

  if (jump) {
    expect(cycles, equals(21));
    expect(emulator.cpu.p.value, equals(subroutineAddress));
    expect(emulator.cpu.s.value, equals(initialSValue - 2));
    expect(
        (initialPValue + memOpcodes.length) & 0xFF, equals(emulator.cpu.memRead(0x6000)));
    expect((initialPValue + memOpcodes.length) >> 8,
        equals(emulator.cpu.memRead(0x6000 - 1)));
  } else {
    expect(cycles, equals(8));
    expect(emulator.cpu.p.value, equals(initialPValue + memOpcodes.length));
    expect(emulator.cpu.s.value, equals(initialSValue));
  }

  // Z is reset.
  expect(emulator.cpu.t.h, equals(flags.h));
  expect(emulator.cpu.t.v, equals(flags.v));
  expect(emulator.cpu.t.z, isFalse);
  expect(emulator.cpu.t.ie, equals(flags.ie));
  expect(emulator.cpu.t.c, equals(flags.c));
}

void testVCS(LH5801Emulator emulator, List<int> opcodes) {
  _testVSJConditional(
    emulator,
    opcodes,
    LH5801Flags.C,
    jump: true,
  );

  _testVSJConditional(emulator, opcodes, 0);
}

void testVCR(LH5801Emulator emulator, List<int> opcodes) {
  _testVSJConditional(
    emulator,
    opcodes,
    0,
    jump: true,
  );

  _testVSJConditional(emulator, opcodes, LH5801Flags.C);
}

void testVHS(LH5801Emulator emulator, List<int> opcodes) {
  _testVSJConditional(
    emulator,
    opcodes,
    LH5801Flags.H,
    jump: true,
  );

  _testVSJConditional(emulator, opcodes, 0);
}

void testVHR(LH5801Emulator emulator, List<int> opcodes) {
  _testVSJConditional(
    emulator,
    opcodes,
    0,
    jump: true,
  );

  _testVSJConditional(emulator, opcodes, LH5801Flags.H);
}

void testVZS(LH5801Emulator emulator, List<int> opcodes) {
  _testVSJConditional(
    emulator,
    opcodes,
    LH5801Flags.Z,
    jump: true,
  );

  _testVSJConditional(emulator, opcodes, 0);
}

void testVZR(LH5801Emulator emulator, List<int> opcodes) {
  _testVSJConditional(
    emulator,
    opcodes,
    0,
    jump: true,
  );

  _testVSJConditional(emulator, opcodes, LH5801Flags.Z);
}

void testVVS(LH5801Emulator emulator, List<int> opcodes) {
  _testVSJConditional(
    emulator,
    opcodes,
    LH5801Flags.V,
    jump: true,
  );

  _testVSJConditional(emulator, opcodes, 0);
}

void testROR(LH5801Emulator emulator) {
  void _test(
    int initialAccValue,
    int expectedAccValue,
    int expectedStatusRegister, {
    bool carry = false,
  }) {
    final List<int> opcodes = <int>[0xD1];

    memLoad(0x0000, opcodes);
    emulator.cpu.a.value = initialAccValue;
    emulator.cpu.t.c = carry;
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(9));
    expect(emulator.cpu.p.value, equals(opcodes.length));

    expect(emulator.cpu.a.value, expectedAccValue);

    expect(emulator.cpu.t.statusRegister, expectedStatusRegister);
  }

  _test(0xC8, 0x64, 0);
  _test(0xC8, 0xE4, 0, carry: true);

  _test(0xF0, 0x78, LH5801Flags.H);
  _test(0x02, 0x01, LH5801Flags.V);
  _test(0x0F, 0x07, LH5801Flags.V | LH5801Flags.C);
  _test(0x01, 0x00, LH5801Flags.Z | LH5801Flags.C);
}

void testROL(LH5801Emulator emulator) {
  void _test(
    int initialAccValue,
    int expectedAccValue,
    int expectedStatusRegister, {
    bool carry = false,
  }) {
    final List<int> opcodes = <int>[0xDB];

    memLoad(0x0000, opcodes);
    emulator.cpu.a.value = initialAccValue;
    emulator.cpu.t.c = carry;
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(8));
    expect(emulator.cpu.p.value, equals(opcodes.length));

    expect(emulator.cpu.a.value, expectedAccValue);

    expect(emulator.cpu.t.statusRegister, expectedStatusRegister);
  }

  _test(0x5D, 0xBB, LH5801Flags.H | LH5801Flags.V, carry: true);
  _test(0x5D, 0xBA, LH5801Flags.H | LH5801Flags.V);

  _test(0x08, 0x10, LH5801Flags.H);
  _test(0x40, 0x80, LH5801Flags.V);
  _test(0x80, 0x00, LH5801Flags.V | LH5801Flags.Z | LH5801Flags.C);
}

void testTIN(LH5801Emulator emulator) {
  const int initialXValue = 0x4700;
  const int memXValue = 0x33;
  const int initialYValue = 0x4800;
  final List<int> memOpcodes = <int>[0xF5];
  final int statusRegister = emulator.cpu.t.statusRegister;

  memLoad(0x0000, memOpcodes);
  emulator.cpu.x.value = initialXValue;
  memLoad(initialXValue, <int>[memXValue]);
  emulator.cpu.y.value = initialYValue;
  memLoad(initialYValue, <int>[0xFF]);
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(7));
  expect(emulator.cpu.p.value, equals(memOpcodes.length));

  expect(emulator.cpu.x.value, equals(initialXValue + 1));
  expect(emulator.cpu.y.value, equals(initialYValue + 1));
  expect(emulator.cpu.memRead(initialYValue), equals(memXValue));

  expect(emulator.cpu.t.statusRegister, statusRegister);
}

void testCIN(LH5801Emulator emulator) {
  void _test(int op1, int op2, Matcher cFlagMatcher, Matcher zFlagMatcher) {
    const int initialXValue = 0x4700;
    final List<int> memOpcodes = <int>[0xF7];

    memLoad(0x0000, memOpcodes);
    emulator.cpu.a.value = op1;
    emulator.cpu.x.value = initialXValue;
    memLoad(initialXValue, <int>[op2]);
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(7));
    expect(emulator.cpu.p.value, equals(memOpcodes.length));

    expect(emulator.cpu.x.value, equals(initialXValue + 1));

    expect(emulator.cpu.t.c, cFlagMatcher);
    expect(emulator.cpu.t.z, zFlagMatcher);
  }

  _test(84, 80, isTrue, isFalse);
  _test(2, 2, isTrue, isTrue);
  _test(84, 110, isFalse, isFalse);
}

void testRECSEC(LH5801Emulator emulator, List<int> opcodes,
    {bool expectedCarry = false}) {
  final LH5801Flags flags = emulator.cpu.t.clone();

  memLoad(0x0000, opcodes);
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(4));
  expect(emulator.cpu.p.value, equals(opcodes.length));

  expect(emulator.cpu.t.h, equals(flags.h));
  expect(emulator.cpu.t.v, equals(flags.v));
  expect(emulator.cpu.t.z, equals(flags.z));
  expect(emulator.cpu.t.ie, equals(flags.ie));
  expect(emulator.cpu.t.c, equals(expectedCarry));
}

void testAEX(LH5801Emulator emulator) {
  final List<int> memOpcodes = <int>[0xF1];
  final int statusRegister = emulator.cpu.t.statusRegister;

  memLoad(0x0000, memOpcodes);
  emulator.cpu.a.value = 0xCA;
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(6));
  expect(emulator.cpu.p.value, equals(memOpcodes.length));

  expect(emulator.cpu.a.value, equals(0xAC));

  expect(emulator.cpu.t.statusRegister, equals(statusRegister));
}

void testRPUSPU(LH5801Emulator emulator, List<int> opcodes, {bool expectedPU = false}) {
  final int statusRegister = emulator.cpu.t.statusRegister;

  memLoad(0x0000, opcodes);
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(4));
  expect(emulator.cpu.p.value, equals(opcodes.length));

  expect(emulator.puFlipflop, equals(expectedPU));

  expect(emulator.cpu.t.statusRegister, equals(statusRegister));
}

void testRPVSPV(LH5801Emulator emulator, List<int> opcodes, {bool expectedPV = false}) {
  final int statusRegister = emulator.cpu.t.statusRegister;

  memLoad(0x0000, opcodes);
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(4));
  expect(emulator.cpu.p.value, equals(opcodes.length));

  expect(emulator.pvFlipflop, equals(expectedPV));

  expect(emulator.cpu.t.statusRegister, equals(statusRegister));
}

void testSDPRDP(LH5801Emulator emulator, List<int> opcodes, {bool expectedDisp = false}) {
  final int statusRegister = emulator.cpu.t.statusRegister;

  memLoad(0x0000, opcodes);
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(8));
  expect(emulator.cpu.p.value, equals(opcodes.length));

  expect(emulator.dispFlipflop, equals(expectedDisp));

  expect(emulator.cpu.t.statusRegister, equals(statusRegister));
}

void testSIERIE(LH5801Emulator emulator, List<int> opcodes, {bool expectedIE = false}) {
  final LH5801Flags flags = emulator.cpu.t.clone();

  memLoad(0x0000, opcodes);
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(8));
  expect(emulator.cpu.p.value, equals(opcodes.length));

  expect(emulator.cpu.t.h, equals(flags.h));
  expect(emulator.cpu.t.v, equals(flags.v));
  expect(emulator.cpu.t.z, equals(flags.z));
  expect(emulator.cpu.t.ie, equals(expectedIE));
  expect(emulator.cpu.t.c, equals(flags.c));
}

void testSHR(LH5801Emulator emulator) {
  final List<int> memOpcodes = <int>[0xD5];
  final LH5801Flags flags = emulator.cpu.t.clone();

  emulator.cpu.a.value = 0x93;
  memLoad(0x0000, memOpcodes);
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(9));
  expect(emulator.cpu.p.value, equals(memOpcodes.length));

  expect(emulator.cpu.a.value, equals(0x93 >> 1));

  expect(emulator.cpu.t.h, isTrue);
  expect(emulator.cpu.t.v, isTrue);
  expect(emulator.cpu.t.z, isFalse);
  expect(emulator.cpu.t.ie, equals(flags.ie));
  expect(emulator.cpu.t.c, isTrue);
}

void testSHL(LH5801Emulator emulator) {
  final List<int> memOpcodes = <int>[0xD9];
  final LH5801Flags flags = emulator.cpu.t.clone();

  emulator.cpu.a.value = 0x9D;
  memLoad(0x0000, memOpcodes);
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(6));
  expect(emulator.cpu.p.value, equals(memOpcodes.length));

  expect(emulator.cpu.a.value, equals((0x9D << 1) & 0xFF));

  expect(emulator.cpu.t.h, isTrue);
  expect(emulator.cpu.t.v, isTrue);
  expect(emulator.cpu.t.z, isFalse);
  expect(emulator.cpu.t.ie, equals(flags.ie));
  expect(emulator.cpu.t.c, isTrue);
}

void testOFF(LH5801Emulator emulator) {
  final List<int> memOpcodes = <int>[0xFD, 0x4C];
  final int statusRegister = emulator.cpu.t.statusRegister;

  emulator.bfFlipflop = true;
  memLoad(0x0000, memOpcodes);
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(8));
  expect(emulator.cpu.p.value, equals(memOpcodes.length));

  expect(emulator.bfFlipflop, isFalse);

  expect(emulator.cpu.t.statusRegister, equals(statusRegister));
}

void testATP(LH5801Emulator emulator) {
  final List<int> memOpcodes = <int>[0xFD, 0xCC];
  final int statusRegister = emulator.cpu.t.statusRegister;

  emulator.inputPorts = 0x00;
  emulator.cpu.a.value = 0x07;
  memLoad(0x0000, memOpcodes);
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(9));
  expect(emulator.cpu.p.value, equals(memOpcodes.length));

  expect(emulator.inputPorts, emulator.cpu.a.value);

  expect(emulator.cpu.t.statusRegister, equals(statusRegister));
}

void testITA(LH5801Emulator emulator) {
  void _test(int inputPortsValue, Matcher zFlagMatcher) {
    final List<int> memOpcodes = <int>[0xFD, 0xBA];
    final LH5801Flags flags = emulator.cpu.t.clone();

    emulator.inputPorts = inputPortsValue;
    memLoad(0x0000, memOpcodes);
    final int cycles = emulator.step(address: 0x0000);
    expect(cycles, equals(9));
    expect(emulator.cpu.p.value, equals(memOpcodes.length));

    expect(emulator.cpu.a.value, inputPortsValue);

    expect(emulator.cpu.t.h, equals(flags.h));
    expect(emulator.cpu.t.v, equals(flags.v));
    expect(emulator.cpu.t.z, zFlagMatcher);
    expect(emulator.cpu.t.ie, equals(flags.ie));
    expect(emulator.cpu.t.c, equals(flags.c));
  }

  _test(0x01, isFalse);
  _test(0x00, isTrue);
}

void testNOP(LH5801Emulator emulator) {
  final List<int> memOpcodes = <int>[0x38];
  final int statusRegister = emulator.cpu.t.statusRegister;

  memLoad(0x0000, memOpcodes);
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(5));
  expect(emulator.cpu.p.value, equals(memOpcodes.length));

  expect(emulator.cpu.t.statusRegister, equals(statusRegister));
}

void testHLT(LH5801Emulator emulator) {
  final List<int> memOpcodes = <int>[0xFD, 0xB1];
  final int statusRegister = emulator.cpu.t.statusRegister;

  emulator.cpu.hlt = false;
  memLoad(0x0000, memOpcodes);
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(9));
  expect(emulator.cpu.p.value, equals(memOpcodes.length));

  expect(emulator.cpu.hlt, isTrue);

  expect(emulator.cpu.t.statusRegister, equals(statusRegister));
}

void testAM(LH5801Emulator emulator, List<int> opcodes, int bit8) {
  final List<int> memOpcodes = <int>[...opcodes];
  final int statusRegister = emulator.cpu.t.statusRegister;

  emulator.cpu.tm.value = 0x000;
  emulator.cpu.a.value = 0x45;
  memLoad(0x0000, memOpcodes);
  final int cycles = emulator.step(address: 0x0000);
  expect(cycles, equals(9));
  expect(emulator.cpu.p.value, equals(memOpcodes.length));

  expect(emulator.cpu.tm.value, (bit8 << 8) | emulator.cpu.a.value);

  expect(emulator.cpu.t.statusRegister, equals(statusRegister));
}
