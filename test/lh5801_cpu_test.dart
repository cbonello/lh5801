import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:lh5801/lh5801.dart';

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

int unsignedByteToInt(int value) {
  if (value & 0x80 != 0) {
    return -((value ^ 0xFF) + 1);
  }
  return value;
}

void main() {
  final System system = System();
  int cycles;

  group('LH5801CPU', () {
    setUp(() {
      system.resetMemories();
    });

    group('SBC [page 27]', () {
      test('should return the expected results', () {
        system.load(0x0000, <int>[0xFD, 0x01]);

        for (final bool carry in <bool>[true, false]) {
          for (int op1 = 0; op1 < 256; op1++) {
            for (int op2 = 0; op2 < 256; op2++) {
              system.load(0x10000, <int>[op2]);
              system.cpu.a.value = op1;
              system.cpu.x.value = 0x0000;
              system.cpu.t.c = carry;
              system.step(0x0000);
              expect(system.cpu.p.value, equals(2));

              final int left = op1;
              final int right = op2 ^ 0xFF;
              final int c = LH5801Flags.boolToInt(carry);

              final int expected = left + right + c;
              expect(system.cpu.a.value, equals(expected & 0xFF));

              final bool expectedH = (((left & 0x0F) + (right & 0x0F) + c) & 0x10) != 0;
              expect(system.cpu.t.h, equals(expectedH));

              final bool expectedV = ((left & 0x80) == (right & 0x80)) &&
                  ((left & 0x80) != (expected & 0x80));
              expect(system.cpu.t.v, equals(expectedV));

              final bool expectedZ = (expected & 0xFF) == 0;
              expect(system.cpu.t.z, equals(expectedZ));

              final bool expectedC = (expected & 0x100) != 0;
              expect(system.cpu.t.c, equals(expectedC));
            }
          }
        }
      });

      test('SBC #(X): A = 56, #(X) = 33, C = 0', () {
        system.load(0x0000, <int>[0xFD, 0x01]);
        system.load(0x10000, <int>[33]);
        system.cpu.a.value = 56;
        system.cpu.x.value = 0x0000;
        system.cpu.t.c = false;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(22));

        expect(system.cpu.t.c, isTrue);
        expect(system.cpu.t.z, isFalse);
        expect(system.cpu.t.v, isFalse);
        expect(system.cpu.t.h, isTrue);
      });

      test('SBC #(Y): A = 56, #(Y) = 33, C = 0', () {
        system.load(0x0000, <int>[0xFD, 0x11]);
        system.load(0x10000, <int>[33]);
        system.cpu.a.value = 56;
        system.cpu.y.value = 0x0000;
        system.cpu.t.c = false;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(22));

        expect(system.cpu.t.c, isTrue);
        expect(system.cpu.t.z, isFalse);
        expect(system.cpu.t.v, isFalse);
        expect(system.cpu.t.h, isTrue);
      });

      test('SBC #(U): A = 56, #(U) = 33, C = 0', () {
        system.load(0x0000, <int>[0xFD, 0x21]);
        system.load(0x10000, <int>[33]);
        system.cpu.a.value = 56;
        system.cpu.u.value = 0x0000;
        system.cpu.t.c = false;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(22));

        expect(system.cpu.t.c, isTrue);
        expect(system.cpu.t.z, isFalse);
        expect(system.cpu.t.v, isFalse);
        expect(system.cpu.t.h, isTrue);
      });
    });

    group('ADC [page 25]', () {
      test('should return the expected results', () {
        system.load(0x0000, <int>[0xFD, 0x03]);

        for (final bool carry in <bool>[true, false]) {
          for (int op1 = 0; op1 < 256; op1++) {
            for (int op2 = 0; op2 < 256; op2++) {
              system.load(0x10000, <int>[op2]);
              system.cpu.a.value = op1;
              system.cpu.x.value = 0x0000;
              system.cpu.t.c = carry;
              system.step(0x0000);
              expect(system.cpu.p.value, equals(2));

              final int left = op1;
              final int right = op2;
              final int c = LH5801Flags.boolToInt(carry);

              final int expected = left + right + c;
              expect(system.cpu.a.value, equals(expected & 0xFF));

              final bool expectedH = (((left & 0x0F) + (right & 0x0F) + c) & 0x10) != 0;
              expect(system.cpu.t.h, equals(expectedH));

              final bool expectedV = ((left & 0x80) == (right & 0x80)) &&
                  ((left & 0x80) != (expected & 0x80));
              expect(system.cpu.t.v, equals(expectedV));

              final bool expectedZ = (expected & 0xFF) == 0;
              expect(system.cpu.t.z, equals(expectedZ));

              final bool expectedC = (expected & 0x100) != 0;
              expect(system.cpu.t.c, equals(expectedC));
            }
          }
        }
      });

      test('ADC #(X): A = 2, #(X) = 51, C = 0', () {
        system.load(0x0000, <int>[0xFD, 0x03]);
        system.load(0x10000, <int>[51]);
        system.cpu.a.value = 2;
        system.cpu.x.value = 0x0000;
        system.cpu.t.c = false;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(53));

        expect(system.cpu.t.c, isFalse);
        expect(system.cpu.t.z, isFalse);
        expect(system.cpu.t.v, isFalse);
        expect(system.cpu.t.h, isFalse);
      });

      test('ADC #(Y): A = 2, #(Y) = 51, C = 0', () {
        system.load(0x0000, <int>[0xFD, 0x13]);
        system.load(0x10000, <int>[51]);
        system.cpu.a.value = 2;
        system.cpu.y.value = 0x0000;
        system.cpu.t.c = false;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(53));

        expect(system.cpu.t.c, isFalse);
        expect(system.cpu.t.z, isFalse);
        expect(system.cpu.t.v, isFalse);
        expect(system.cpu.t.h, isFalse);
      });

      test('ADC #(U): A = 2, #(U) = 51, C = 0', () {
        system.load(0x0000, <int>[0xFD, 0x23]);
        system.load(0x10000, <int>[51]);
        system.cpu.a.value = 2;
        system.cpu.u.value = 0x0000;
        system.cpu.t.c = false;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(53));

        expect(system.cpu.t.c, isFalse);
        expect(system.cpu.t.z, isFalse);
        expect(system.cpu.t.v, isFalse);
        expect(system.cpu.t.h, isFalse);
      });
    });

    group('LDA [page 33]', () {
      test('LDA #(X): #(X) = 0', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x05]);
        system.load(0x10000, <int>[0]);
        system.cpu.a.value = 2;
        system.cpu.x.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(10));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(0));

        // Z should be the only flag updated.
        expect(system.cpu.t.h, equals(flags.h));
        expect(system.cpu.t.v, equals(flags.v));
        expect(system.cpu.t.z, isTrue);
        expect(system.cpu.t.ie, equals(flags.ie));
        expect(system.cpu.t.c, equals(flags.c));
      });

      test('LDA #(X): #(X) = -3', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x05]);
        system.load(0x10000, <int>[0xFD]); // -3
        system.cpu.a.value = 2;
        system.cpu.x.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(10));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(0xFD));

        // Z should be the only flag updated.
        expect(system.cpu.t.h, equals(flags.h));
        expect(system.cpu.t.v, equals(flags.v));
        expect(system.cpu.t.z, isFalse);
        expect(system.cpu.t.ie, equals(flags.ie));
        expect(system.cpu.t.c, equals(flags.c));
      });

      test('LDA #(Y): #(Y) = 0', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x15]);
        system.load(0x10000, <int>[0]);
        system.cpu.a.value = 2;
        system.cpu.y.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(10));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(0));

        // Z should be the only flag updated.
        expect(system.cpu.t.h, equals(flags.h));
        expect(system.cpu.t.v, equals(flags.v));
        expect(system.cpu.t.z, isTrue);
        expect(system.cpu.t.ie, equals(flags.ie));
        expect(system.cpu.t.c, equals(flags.c));
      });

      test('LDA #(Y): #(Y) = -3', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x15]);
        system.load(0x10000, <int>[0xFD]); // -3
        system.cpu.a.value = 2;
        system.cpu.y.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(10));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(0xFD));

        // Z should be the only flag updated.
        expect(system.cpu.t.h, equals(flags.h));
        expect(system.cpu.t.v, equals(flags.v));
        expect(system.cpu.t.z, isFalse);
        expect(system.cpu.t.ie, equals(flags.ie));
        expect(system.cpu.t.c, equals(flags.c));
      });

      test('LDA #(U): #(U) = 0', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x25]);
        system.load(0x10000, <int>[0]);
        system.cpu.a.value = 2;
        system.cpu.u.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(10));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(0));

        // Z should be the only flag updated.
        expect(system.cpu.t.h, equals(flags.h));
        expect(system.cpu.t.v, equals(flags.v));
        expect(system.cpu.t.z, isTrue);
        expect(system.cpu.t.ie, equals(flags.ie));
        expect(system.cpu.t.c, equals(flags.c));
      });

      test('LDA #(U): #(U) = -3', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x25]);
        system.load(0x10000, <int>[0xFD]); // -3
        system.cpu.a.value = 2;
        system.cpu.u.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(10));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(0xFD));

        // Z should be the only flag updated.
        expect(system.cpu.t.h, equals(flags.h));
        expect(system.cpu.t.v, equals(flags.v));
        expect(system.cpu.t.z, isFalse);
        expect(system.cpu.t.ie, equals(flags.ie));
        expect(system.cpu.t.c, equals(flags.c));
      });
    });

    group('CPA [page 31]', () {
      test('should return the expected results', () {
        system.load(0x0000, <int>[0xFD, 0x07]);

        for (int op1 = 0; op1 < 256; op1++) {
          for (int op2 = 0; op2 < 256; op2++) {
            system.load(0x10000, <int>[op2]);
            system.cpu.a.value = op1;
            system.cpu.x.value = 0x0000;
            system.step(0x0000);
            expect(system.cpu.p.value, equals(2));

            final int left = op1;
            final int right = (op2 ^ 0xFF) + 1;

            final int expected = left + right;
            expect(system.cpu.a.value, equals(op1));

            final bool expectedH = (((left & 0x0F) + (right & 0x0F)) & 0x10) != 0;
            expect(system.cpu.t.h, equals(expectedH));

            final bool expectedV =
                ((left & 0x80) == (right & 0x80)) && ((left & 0x80) != (expected & 0x80));
            expect(system.cpu.t.v, equals(expectedV));

            final bool expectedZ = (expected & 0xFF) == 0;
            expect(system.cpu.t.z, equals(expectedZ));

            final bool expectedC = (expected & 0x100) != 0;
            expect(system.cpu.t.c, equals(expectedC));

            if (op1 > op2) {
              expect(system.cpu.t.c, isTrue);
              expect(system.cpu.t.z, isFalse);
            } else if (op1 == op2) {
              expect(system.cpu.t.c, isTrue);
              expect(system.cpu.t.z, isTrue);
            } else {
              expect(system.cpu.t.c, isFalse);
              expect(system.cpu.t.z, isFalse);
            }
          }
        }
      });

      test('CPA #(X): A=84, #(X) = 80', () {
        system.load(0x0000, <int>[0xFD, 0x07]);
        system.load(0x10000, <int>[80]);
        system.cpu.a.value = 84;
        system.cpu.x.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.t.c, isTrue);
        expect(system.cpu.t.z, isFalse);
      });

      test('CPA #(Y): A=84, #(Y) = 80', () {
        system.load(0x0000, <int>[0xFD, 0x17]);
        system.load(0x10000, <int>[80]);
        system.cpu.a.value = 84;
        system.cpu.y.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.t.c, isTrue);
        expect(system.cpu.t.z, isFalse);
      });

      test('CPA #(U): A=84, #(U) = 80', () {
        system.load(0x0000, <int>[0xFD, 0x27]);
        system.load(0x10000, <int>[80]);
        system.cpu.a.value = 84;
        system.cpu.u.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.t.c, isTrue);
        expect(system.cpu.t.z, isFalse);
      });
    });

    group('AND [page 29]', () {
      test('AND #(X): A=0xF0, #(X) = 0x0F', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x09]);
        system.load(0x10000, <int>[0x0F]);
        system.cpu.a.value = 0xF0;
        system.cpu.x.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(0));

        // Z should be the only flag updated.
        expect(system.cpu.t.h, equals(flags.h));
        expect(system.cpu.t.v, equals(flags.v));
        expect(system.cpu.t.z, isTrue);
        expect(system.cpu.t.ie, equals(flags.ie));
        expect(system.cpu.t.c, equals(flags.c));
      });

      test('AND #(X): A=0xFF, #(X) = 0x0F', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x09]);
        system.load(0x10000, <int>[0x0F]);
        system.cpu.a.value = 0xFF;
        system.cpu.x.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(0x0F));

        // Z should be the only flag updated.
        expect(system.cpu.t.h, equals(flags.h));
        expect(system.cpu.t.v, equals(flags.v));
        expect(system.cpu.t.z, isFalse);
        expect(system.cpu.t.ie, equals(flags.ie));
        expect(system.cpu.t.c, equals(flags.c));
      });

      test('AND #(Y): A=0xF0, #(Y) = 0x0F', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x19]);
        system.load(0x10000, <int>[0x0F]);
        system.cpu.a.value = 0xF0;
        system.cpu.y.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(0));

        // Z should be the only flag updated.
        expect(system.cpu.t.h, equals(flags.h));
        expect(system.cpu.t.v, equals(flags.v));
        expect(system.cpu.t.z, isTrue);
        expect(system.cpu.t.ie, equals(flags.ie));
        expect(system.cpu.t.c, equals(flags.c));
      });

      test('AND #(Y): A=0xFF, #(Y) = 0x0F', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x19]);
        system.load(0x10000, <int>[0x0F]);
        system.cpu.a.value = 0xFF;
        system.cpu.y.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(0x0F));

        // Z should be the only flag updated.
        expect(system.cpu.t.h, equals(flags.h));
        expect(system.cpu.t.v, equals(flags.v));
        expect(system.cpu.t.z, isFalse);
        expect(system.cpu.t.ie, equals(flags.ie));
        expect(system.cpu.t.c, equals(flags.c));
      });

      test('AND #(U): A=0xF0, #(U) = 0x0F', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x29]);
        system.load(0x10000, <int>[0x0F]);
        system.cpu.a.value = 0xF0;
        system.cpu.u.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(0));

        // Z should be the only flag updated.
        expect(system.cpu.t.h, equals(flags.h));
        expect(system.cpu.t.v, equals(flags.v));
        expect(system.cpu.t.z, isTrue);
        expect(system.cpu.t.ie, equals(flags.ie));
        expect(system.cpu.t.c, equals(flags.c));
      });

      test('AND #(U): A=0xFF, #(U) = 0x0F', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x29]);
        system.load(0x10000, <int>[0x0F]);
        system.cpu.a.value = 0xFF;
        system.cpu.u.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(0x0F));

        // Z should be the only flag updated.
        expect(system.cpu.t.h, equals(flags.h));
        expect(system.cpu.t.v, equals(flags.v));
        expect(system.cpu.t.z, isFalse);
        expect(system.cpu.t.ie, equals(flags.ie));
        expect(system.cpu.t.c, equals(flags.c));
      });
    });

    group('POP [page 37]', () {
      test('POP X: [S]=0xF0, #(X) = 0x0F', () {
        final int statusRegister = system.cpu.t.statusRegister;

        system.load(0x0000, <int>[0xFD, 0x0A]);
        system.load(0x46FE, <int>[0x20, 0x30]);
        system.cpu.s.value = 0x46FD;
        cycles = system.step(0x0000);
        expect(cycles, equals(15));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.x.value, equals(0x2030));
        expect(system.cpu.s.value, equals(0x46FD + 2));

        expect(system.cpu.t.statusRegister, equals(statusRegister));
      });

      test('POP Y: [S]=0xF0, #(Y) = 0x0F', () {
        final int statusRegister = system.cpu.t.statusRegister;

        system.load(0x0000, <int>[0xFD, 0x1A]);
        system.load(0x46FE, <int>[0x20, 0x30]);
        system.cpu.s.value = 0x46FD;
        cycles = system.step(0x0000);
        expect(cycles, equals(15));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.y.value, equals(0x2030));
        expect(system.cpu.s.value, equals(0x46FD + 2));

        expect(system.cpu.t.statusRegister, equals(statusRegister));
      });

      test('POP U: [S]=0xF0, #(U) = 0x0F', () {
        final int statusRegister = system.cpu.t.statusRegister;

        system.load(0x0000, <int>[0xFD, 0x2A]);
        system.load(0x46FE, <int>[0x20, 0x30]);
        system.cpu.s.value = 0x46FD;
        cycles = system.step(0x0000);
        expect(cycles, equals(15));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.u.value, equals(0x2030));
        expect(system.cpu.s.value, equals(0x46FD + 2));

        expect(system.cpu.t.statusRegister, equals(statusRegister));
      });
    });

    group('ORA [page 29]', () {
      test('ORA #(X): A=0x00, #(X) = 0x00', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x0B]);
        system.load(0x10000, <int>[0x00]);
        system.cpu.a.value = 0x00;
        system.cpu.x.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(0));

        // Z should be the only flag updated.
        expect(system.cpu.t.h, equals(flags.h));
        expect(system.cpu.t.v, equals(flags.v));
        expect(system.cpu.t.z, isTrue);
        expect(system.cpu.t.ie, equals(flags.ie));
        expect(system.cpu.t.c, equals(flags.c));
      });

      test('ORA #(X): A=0x04, #(X) = 0x0F', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x0B]);
        system.load(0x10000, <int>[0x0F]);
        system.cpu.a.value = 0x04;
        system.cpu.x.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(0x0F));

        // Z should be the only flag updated.
        expect(system.cpu.t.h, equals(flags.h));
        expect(system.cpu.t.v, equals(flags.v));
        expect(system.cpu.t.z, isFalse);
        expect(system.cpu.t.ie, equals(flags.ie));
        expect(system.cpu.t.c, equals(flags.c));
      });

      test('ORA #(Y): A=0x00, #(Y) = 0x00', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x1B]);
        system.load(0x10000, <int>[0x00]);
        system.cpu.a.value = 0x00;
        system.cpu.y.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(0));

        // Z should be the only flag updated.
        expect(system.cpu.t.h, equals(flags.h));
        expect(system.cpu.t.v, equals(flags.v));
        expect(system.cpu.t.z, isTrue);
        expect(system.cpu.t.ie, equals(flags.ie));
        expect(system.cpu.t.c, equals(flags.c));
      });

      test('ORA #(Y): A=0x04, #(Y) = 0x0F', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x1B]);
        system.load(0x10000, <int>[0x0F]);
        system.cpu.a.value = 0x04;
        system.cpu.y.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(0x0F));

        // Z should be the only flag updated.
        expect(system.cpu.t.h, equals(flags.h));
        expect(system.cpu.t.v, equals(flags.v));
        expect(system.cpu.t.z, isFalse);
        expect(system.cpu.t.ie, equals(flags.ie));
        expect(system.cpu.t.c, equals(flags.c));
      });

      test('ORA #(U): A=0x00, #(U) = 0x00', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x2B]);
        system.load(0x10000, <int>[0x00]);
        system.cpu.a.value = 0x00;
        system.cpu.u.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(0));

        // Z should be the only flag updated.
        expect(system.cpu.t.h, equals(flags.h));
        expect(system.cpu.t.v, equals(flags.v));
        expect(system.cpu.t.z, isTrue);
        expect(system.cpu.t.ie, equals(flags.ie));
        expect(system.cpu.t.c, equals(flags.c));
      });

      test('ORA #(U): A=0x04, #(U) = 0x0F', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x2B]);
        system.load(0x10000, <int>[0x0F]);
        system.cpu.a.value = 0x04;
        system.cpu.u.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(0x0F));

        // Z should be the only flag updated.
        expect(system.cpu.t.h, equals(flags.h));
        expect(system.cpu.t.v, equals(flags.v));
        expect(system.cpu.t.z, isFalse);
        expect(system.cpu.t.ie, equals(flags.ie));
        expect(system.cpu.t.c, equals(flags.c));
      });
    });

    group('DCS [page 28]', () {
      test('should return the expected results', () {
        system.load(0x0000, <int>[0xFD, 0x0C]);

        for (final bool carry in <bool>[true, false]) {
          for (int op1Digit1 = 0; op1Digit1 < 10; op1Digit1++) {
            for (int op1Digit2 = 0; op1Digit2 < 10; op1Digit2++) {
              final int op1 = (op1Digit1 << 4) | op1Digit2;
              for (int op2Digit1 = 0; op2Digit1 < 10; op2Digit1++) {
                for (int op2Digit2 = 0; op2Digit2 < 10; op2Digit2++) {
                  final int op2 = (op2Digit1 << 4) | op2Digit2;
                  system.load(0x10000, <int>[op2]);
                  system.cpu.a.value = op1;
                  system.cpu.x.value = 0x0000;
                  system.cpu.t.c = carry;
                  system.step(0x0000);
                  expect(system.cpu.p.value, equals(2));

                  final int left = op1;
                  final int right = op2 ^ 0xFF;
                  final int c = LH5801Flags.boolToInt(carry);
                  int expected = left + right + c;

                  final bool expectedH =
                      (((left & 0x0F) + (right & 0x0F) + c) & 0x10) != 0;
                  expect(system.cpu.t.h, equals(expectedH));

                  final bool expectedV = ((left & 0x80) == (right & 0x80)) &&
                      ((left & 0x80) != (expected & 0x80));
                  expect(system.cpu.t.v, equals(expectedV));

                  final bool expectedZ = (expected & 0xFF) == 0;
                  expect(system.cpu.t.z, equals(expectedZ));

                  final bool expectedC = (expected & 0x100) != 0;
                  expect(system.cpu.t.c, equals(expectedC));

                  expected &= 0xFF;
                  if (system.cpu.t.c == false && system.cpu.t.h == false) {
                    expected += 0x9A;
                  } else if (system.cpu.t.c == false && system.cpu.t.h) {
                    expected += 0xA0;
                  } else if (system.cpu.t.c && system.cpu.t.h == false) {
                    expected += 0xFA;
                  }
                  expect(system.cpu.a.value, equals(expected & 0xFF));
                }
              }
            }
          }
        }
      });

      test('DCS #(X): A=0x42, #(X) = 0x31, C=1', () {
        system.load(0x0000, <int>[0xFD, 0x0C]);
        system.load(0x10000, <int>[0x31]);
        system.cpu.a.value = 0x42;
        system.cpu.x.value = 0x0000;
        system.cpu.t.c = true;
        cycles = system.step(0x0000);
        expect(cycles, equals(17));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.t.c, isTrue);
        expect(system.cpu.t.h, isTrue);
        expect(system.cpu.a.value, 0x11);
      });

      test('DCS #(X): A=0x42, #(X) = 0x31, C=0', () {
        system.load(0x0000, <int>[0xFD, 0x0C]);
        system.load(0x10000, <int>[0x31]);
        system.cpu.a.value = 0x42;
        system.cpu.x.value = 0x0000;
        system.cpu.t.c = false;
        cycles = system.step(0x0000);
        expect(cycles, equals(17));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, 0x10);

        expect(system.cpu.t.c, isTrue);
        expect(system.cpu.t.h, isTrue);
      });

      test('DCS #(X): A=0x23, #(X) = 0x54, C=1', () {
        system.load(0x0000, <int>[0xFD, 0x0C]);
        system.load(0x10000, <int>[0x54]);
        system.cpu.a.value = 0x23;
        system.cpu.x.value = 0x0000;
        system.cpu.t.c = true;
        cycles = system.step(0x0000);
        expect(cycles, equals(17));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, 0x69);

        expect(system.cpu.t.c, isFalse);
        expect(system.cpu.t.h, isFalse);
      });

      test('DCS #(X): A=0x23, #(X) = 0x54, C=0', () {
        system.load(0x0000, <int>[0xFD, 0x0C]);
        system.load(0x10000, <int>[0x54]);
        system.cpu.a.value = 0x23;
        system.cpu.x.value = 0x0000;
        system.cpu.t.c = false;
        cycles = system.step(0x0000);
        expect(cycles, equals(17));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, 0x68);

        expect(system.cpu.t.c, isFalse);
        expect(system.cpu.t.h, isFalse);
      });

      test('DCS #(Y): A=0x42, #(Y) = 0x31, C=1', () {
        system.load(0x0000, <int>[0xFD, 0x1C]);
        system.load(0x10000, <int>[0x31]);
        system.cpu.a.value = 0x42;
        system.cpu.y.value = 0x0000;
        system.cpu.t.c = true;
        cycles = system.step(0x0000);
        expect(cycles, equals(17));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.t.c, isTrue);
        expect(system.cpu.t.h, isTrue);
        expect(system.cpu.a.value, 0x11);
      });

      test('DCS #(Y): A=0x42, #(Y) = 0x31, C=0', () {
        system.load(0x0000, <int>[0xFD, 0x1C]);
        system.load(0x10000, <int>[0x31]);
        system.cpu.a.value = 0x42;
        system.cpu.y.value = 0x0000;
        system.cpu.t.c = false;
        cycles = system.step(0x0000);
        expect(cycles, equals(17));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, 0x10);

        expect(system.cpu.t.c, isTrue);
        expect(system.cpu.t.h, isTrue);
      });

      test('DCS #(Y): A=0x23, #(Y) = 0x54, C=1', () {
        system.load(0x0000, <int>[0xFD, 0x1C]);
        system.load(0x10000, <int>[0x54]);
        system.cpu.a.value = 0x23;
        system.cpu.y.value = 0x0000;
        system.cpu.t.c = true;
        cycles = system.step(0x0000);
        expect(cycles, equals(17));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, 0x69);

        expect(system.cpu.t.c, isFalse);
        expect(system.cpu.t.h, isFalse);
      });

      test('DCS #(Y): A=0x23, #(Y) = 0x54, C=0', () {
        system.load(0x0000, <int>[0xFD, 0x1C]);
        system.load(0x10000, <int>[0x54]);
        system.cpu.a.value = 0x23;
        system.cpu.y.value = 0x0000;
        system.cpu.t.c = false;
        cycles = system.step(0x0000);
        expect(cycles, equals(17));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, 0x68);

        expect(system.cpu.t.c, isFalse);
        expect(system.cpu.t.h, isFalse);
      });

      test('DCS #(U): A=0x42, #(U) = 0x31, C=1', () {
        system.load(0x0000, <int>[0xFD, 0x2C]);
        system.load(0x10000, <int>[0x31]);
        system.cpu.a.value = 0x42;
        system.cpu.u.value = 0x0000;
        system.cpu.t.c = true;
        cycles = system.step(0x0000);
        expect(cycles, equals(17));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.t.c, isTrue);
        expect(system.cpu.t.h, isTrue);
        expect(system.cpu.a.value, 0x11);
      });

      test('DCS #(U): A=0x42, #(U) = 0x31, C=0', () {
        system.load(0x0000, <int>[0xFD, 0x2C]);
        system.load(0x10000, <int>[0x31]);
        system.cpu.a.value = 0x42;
        system.cpu.u.value = 0x0000;
        system.cpu.t.c = false;
        cycles = system.step(0x0000);
        expect(cycles, equals(17));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, 0x10);

        expect(system.cpu.t.c, isTrue);
        expect(system.cpu.t.h, isTrue);
      });

      test('DCS #(U): A=0x23, #(U) = 0x54, C=1', () {
        system.load(0x0000, <int>[0xFD, 0x2C]);
        system.load(0x10000, <int>[0x54]);
        system.cpu.a.value = 0x23;
        system.cpu.u.value = 0x0000;
        system.cpu.t.c = true;
        cycles = system.step(0x0000);
        expect(cycles, equals(17));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, 0x69);

        expect(system.cpu.t.c, isFalse);
        expect(system.cpu.t.h, isFalse);
      });

      test('DCS #(U): A=0x23, #(U) = 0x54, C=0', () {
        system.load(0x0000, <int>[0xFD, 0x2C]);
        system.load(0x10000, <int>[0x54]);
        system.cpu.a.value = 0x23;
        system.cpu.u.value = 0x0000;
        system.cpu.t.c = false;
        cycles = system.step(0x0000);
        expect(cycles, equals(17));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, 0x68);

        expect(system.cpu.t.c, isFalse);
        expect(system.cpu.t.h, isFalse);
      });
    });

    group('EOR [page 30]', () {
      test('EOR #(X): A=0x36, #(X) = 0x6D', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x0D]);
        system.load(0x10000, <int>[0x6D]);
        system.cpu.a.value = 0x36;
        system.cpu.x.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(0x5B));

        // Z should be the only flag updated.
        expect(system.cpu.t.h, equals(flags.h));
        expect(system.cpu.t.v, equals(flags.v));
        expect(system.cpu.t.z, isFalse);
        expect(system.cpu.t.ie, equals(flags.ie));
        expect(system.cpu.t.c, equals(flags.c));
      });

      test('EOR #(X): A=0x00, #(X) = 0x00', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x0D]);
        system.load(0x10000, <int>[0x00]);
        system.cpu.a.value = 0x00;
        system.cpu.x.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(0x00));

        expect(system.cpu.t.h, equals(flags.h));

        // Z should be the only flag updated.
        expect(system.cpu.t.v, equals(flags.v));
        expect(system.cpu.t.z, isTrue);
        expect(system.cpu.t.ie, equals(flags.ie));
        expect(system.cpu.t.c, equals(flags.c));
      });

      test('EOR #(Y): A=0x36, #(Y) = 0x6D', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x1D]);
        system.load(0x10000, <int>[0x6D]);
        system.cpu.a.value = 0x36;
        system.cpu.y.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(0x5B));

        // Z should be the only flag updated.
        expect(system.cpu.t.h, equals(flags.h));
        expect(system.cpu.t.v, equals(flags.v));
        expect(system.cpu.t.z, isFalse);
        expect(system.cpu.t.ie, equals(flags.ie));
        expect(system.cpu.t.c, equals(flags.c));
      });

      test('EOR #(Y): A=0x00, #(Y) = 0x00', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x1D]);
        system.load(0x10000, <int>[0x00]);
        system.cpu.a.value = 0x00;
        system.cpu.y.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(0x00));

        expect(system.cpu.t.h, equals(flags.h));

        // Z should be the only flag updated.
        expect(system.cpu.t.v, equals(flags.v));
        expect(system.cpu.t.z, isTrue);
        expect(system.cpu.t.ie, equals(flags.ie));
        expect(system.cpu.t.c, equals(flags.c));
      });

      test('EOR #(U): A=0x36, #(U) = 0x6D', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x2D]);
        system.load(0x10000, <int>[0x6D]);
        system.cpu.a.value = 0x36;
        system.cpu.u.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(0x5B));

        // Z should be the only flag updated.
        expect(system.cpu.t.h, equals(flags.h));
        expect(system.cpu.t.v, equals(flags.v));
        expect(system.cpu.t.z, isFalse);
        expect(system.cpu.t.ie, equals(flags.ie));
        expect(system.cpu.t.c, equals(flags.c));
      });

      test('EOR #(U): A=0x00, #(U) = 0x00', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x2D]);
        system.load(0x10000, <int>[0x00]);
        system.cpu.a.value = 0x00;
        system.cpu.u.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(2));

        expect(system.cpu.a.value, equals(0x00));

        expect(system.cpu.t.h, equals(flags.h));

        // Z should be the only flag updated.
        expect(system.cpu.t.v, equals(flags.v));
        expect(system.cpu.t.z, isTrue);
        expect(system.cpu.t.ie, equals(flags.ie));
        expect(system.cpu.t.c, equals(flags.c));
      });
    });

    group('STA [page 35]', () {
      test('STA #(X): A=0x33', () {
        final int statusRegister = system.cpu.t.statusRegister;

        system.load(0x0000, <int>[0xFD, 0x0E]);
        system.cpu.a.value = 0x33;
        system.cpu.x.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(10));
        expect(system.cpu.p.value, equals(2));

        expect(system.memRead(0x10000 | system.cpu.x.value), equals(system.cpu.a.value));

        expect(system.cpu.t.statusRegister, equals(statusRegister));
      });

      test('STA #(Y): A=0x33', () {
        final int statusRegister = system.cpu.t.statusRegister;

        system.load(0x0000, <int>[0xFD, 0x1E]);
        system.cpu.a.value = 0x33;
        system.cpu.y.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(10));
        expect(system.cpu.p.value, equals(2));

        expect(system.memRead(0x10000 | system.cpu.x.value), equals(system.cpu.a.value));

        expect(system.cpu.t.statusRegister, equals(statusRegister));
      });

      test('STA #(U): A=0x33', () {
        final int statusRegister = system.cpu.t.statusRegister;

        system.load(0x0000, <int>[0xFD, 0x2E]);
        system.cpu.a.value = 0x33;
        system.cpu.u.value = 0x0000;
        cycles = system.step(0x0000);
        expect(cycles, equals(10));
        expect(system.cpu.p.value, equals(2));

        expect(system.memRead(0x10000 | system.cpu.x.value), equals(system.cpu.a.value));

        expect(system.cpu.t.statusRegister, equals(statusRegister));
      });
    });

    group('BIT [page 32]', () {
      test('BIT #(X): A=0x80, #(X)=0x0F', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x0F]);
        system.load(0x10000, <int>[0x0F]);
        system.cpu.a.value = 0x80;
        system.cpu.x.value = 0x0000;
        cycles = system.step(0x0000);
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
      });

      test('BIT #(X): A=0x82, #(X)=0x0F', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x0F]);
        system.load(0x10000, <int>[0x0F]);
        system.cpu.a.value = 0x82;
        system.cpu.x.value = 0x0000;
        cycles = system.step(0x0000);
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
      });

      test('BIT #(Y): A=0x80, #(Y)=0x0F', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x1F]);
        system.load(0x10000, <int>[0x0F]);
        system.cpu.a.value = 0x80;
        system.cpu.y.value = 0x0000;
        cycles = system.step(0x0000);
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
      });

      test('BIT #(Y): A=0x82, #(Y)=0x0F', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x1F]);
        system.load(0x10000, <int>[0x0F]);
        system.cpu.a.value = 0x82;
        system.cpu.y.value = 0x0000;
        cycles = system.step(0x0000);
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
      });

      test('BIT #(U): A=0x80, #(U)=0x0F', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x2F]);
        system.load(0x10000, <int>[0x0F]);
        system.cpu.a.value = 0x80;
        system.cpu.u.value = 0x0000;
        cycles = system.step(0x0000);
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
      });

      test('BIT #(U): A=0x82, #(U)=0x0F', () {
        final LH5801Flags flags = system.cpu.t.clone();

        system.load(0x0000, <int>[0xFD, 0x2F]);
        system.load(0x10000, <int>[0x0F]);
        system.cpu.a.value = 0x82;
        system.cpu.u.value = 0x0000;
        cycles = system.step(0x0000);
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
      });
    });
  });
}
