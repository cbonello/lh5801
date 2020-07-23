import 'package:test/test.dart';
import 'package:lh5801/lh5801.dart';

import 'helpers.dart';

int unsignedByteToInt(int value) {
  if (value & 0x80 != 0) {
    return -((value ^ 0xFF) + 1);
  }
  return value;
}

void main() {
  final System system = System();
  group('LH5801CPU', () {
    setUp(() {
      system.resetMemories();
    });

    group('SBC [page 27]', () {
      test('SBC #(X)', () {
        testSBCRReg(system, 0x01, system.cpu.x);
      });

      test('SBC #(Y)', () {
        testSBCRReg(system, 0x11, system.cpu.y);
      });

      test('SBC #(U)', () {
        testSBCRReg(system, 0x21, system.cpu.u);
      });
    });

    group('ADC [page 25]', () {
      test('ADC #(X)', () {
        testADCRReg(system, 0x03, system.cpu.x);
      });

      test('ADC #(Y)', () {
        testADCRReg(system, 0x13, system.cpu.y);
      });

      test('ADC #(U)', () {
        testADCRReg(system, 0x23, system.cpu.u);
      });
    });

    group('LDA [page 33]', () {
      test('LDA #(X): #(X)=0', () {
        testLDARReg1(system, 0x05, system.cpu.x);
      });

      test('LDA #(X): #(X)=-3', () {
        testLDARReg2(system, 0x05, system.cpu.x);
      });

      test('LDA #(Y): #(Y)=0', () {
        testLDARReg1(system, 0x15, system.cpu.y);
      });
      test('LDA #(Y): #(Y)=-3', () {
        testLDARReg2(system, 0x15, system.cpu.y);
      });

      test('LDA #(U): #(U)=0', () {
        testLDARReg1(system, 0x25, system.cpu.u);
      });

      test('LDA #(U): #(U)=-3', () {
        testLDARReg2(system, 0x25, system.cpu.u);
      });
    });

    group('CPA [page 31]', () {
      test('CPA #(X)', () {
        testCPARReg(system, 0x07, system.cpu.x);
      });

      test('CPA #(Y)', () {
        testCPARReg(system, 0x17, system.cpu.y);
      });

      test('CPA #(U)', () {
        testCPARReg(system, 0x27, system.cpu.u);
      });
    });

    group('AND [page 29]', () {
      test('AND #(X)', () {
        testANDRReg(system, 0x09, system.cpu.x);
      });

      test('AND #(Y)', () {
        testANDRReg(system, 0x19, system.cpu.y);
      });

      test('AND #(U)', () {
        testANDRReg(system, 0x29, system.cpu.u);
      });
    });

    group('POP [page 37]', () {
      test('POP X', () {
        testPOPRReg(system, 0x0A, system.cpu.x);
      });

      test('POP Y', () {
        testPOPRReg(system, 0x1A, system.cpu.y);
      });

      test('POP U', () {
        testPOPRReg(system, 0x2A, system.cpu.u);
      });
    });

    group('ORA [page 29]', () {
      test('ORA #(X)', () {
        testORARReg(system, 0x0B, system.cpu.x);
      });

      test('ORA #(Y)', () {
        testORARReg(system, 0x1B, system.cpu.y);
      });

      test('ORA #(U)', () {
        testORARReg(system, 0x2B, system.cpu.u);
      });
    });

    group('DCS [page 28]', () {
      test('DCS #(X): A=0x42, #(X)=0x31, C=1', () {
        testDCSRReg1(system, 0x0C, system.cpu.x);
      });

      test('DCS #(X): A=0x42, #(X)=0x31, C=0', () {
        testDCSRReg2(system, 0x0C, system.cpu.x);
      });

      test('DCS #(X): A=0x23, #(X)=0x54, C=1', () {
        testDCSRReg3(system, 0x0C, system.cpu.x);
      });

      test('DCS #(X): A=0x23, #(X)=0x54, C=0', () {
        testDCSRReg4(system, 0x0C, system.cpu.x);
      });

      test('DCS #(Y): A=0x42, #(Y)=0x31, C=1', () {
        testDCSRReg1(system, 0x1C, system.cpu.y);
      });

      test('DCS #(Y): A=0x42, #(Y)=0x31, C=0', () {
        testDCSRReg2(system, 0x1C, system.cpu.y);
      });

      test('DCS #(Y): A=0x23, #(Y)=0x54, C=1', () {
        testDCSRReg3(system, 0x1C, system.cpu.y);
      });

      test('DCS #(Y): A=0x23, #(Y)=0x54, C=0', () {
        testDCSRReg4(system, 0x1C, system.cpu.y);
      });

      test('DCS #(U): A=0x42, #(U)=0x31, C=1', () {
        testDCSRReg1(system, 0x2C, system.cpu.u);
      });

      test('DCS #(U): A=0x42, #(U)=0x31, C=0', () {
        testDCSRReg2(system, 0x2C, system.cpu.u);
      });

      test('DCS #(U): A=0x23, #(U)=0x54, C=1', () {
        testDCSRReg3(system, 0x2C, system.cpu.u);
      });

      test('DCS #(U): A=0x23, #(U)=0x54, C=0', () {
        testDCSRReg4(system, 0x2C, system.cpu.u);
      });
    });

    group('EOR [page 30]', () {
      test('EOR #(X): A=0x36, #(X)=0x6D', () {
        testEORRReg1(system, 0x0D, system.cpu.x);
      });

      test('EOR #(X): A=0x00, #(X)=0x00', () {
        testEORRReg2(system, 0x0D, system.cpu.x);
      });

      test('EOR #(Y): A=0x36, #(Y)=0x6D', () {
        testEORRReg1(system, 0x1D, system.cpu.y);
      });

      test('EOR #(Y): A=0x00, #(Y)=0x00', () {
        testEORRReg2(system, 0x1D, system.cpu.y);
      });

      test('EOR #(U): A=0x36, #(U)=0x6D', () {
        testEORRReg1(system, 0x2D, system.cpu.u);
      });

      test('EOR #(U): A=0x00, #(U)=0x00', () {
        testEORRReg2(system, 0x2D, system.cpu.u);
      });
    });

    group('STA [page 35]', () {
      test('STA #(X)', () {
        testSTARReg(system, 0x0E, system.cpu.x);
      });

      test('STA #(Y)', () {
        testSTARReg(system, 0x1E, system.cpu.y);
      });

      test('STA #(U)', () {
        testSTARReg(system, 0x2E, system.cpu.u);
      });
    });

    group('BIT [page 32]', () {
      test('BIT #(X)', () {
        testBITRReg(system, 0x0F, system.cpu.x);
      });

      test('BIT #(Y)', () {
        testBITRReg(system, 0x2F, system.cpu.u);
      });

      test('BIT #(U)', () {
        testBITRReg(system, 0x2F, system.cpu.u);
      });
    });

    group('INC [page 30]', () {
      test('INC XH', () {
        testIncReg8(
          system,
          0x40,
          () => system.cpu.x.high,
          (int value) => system.cpu.x.high = value,
        );
      });

      test('INC YH', () {
        testIncReg8(
          system,
          0x50,
          () => system.cpu.y.high,
          (int value) => system.cpu.y.high = value,
        );
      });

      test('INC UH', () {
        testIncReg8(
          system,
          0x60,
          () => system.cpu.u.high,
          (int value) => system.cpu.u.high = value,
        );
      });
    });

    group('DEC [page 30]', () {
      test('DEC XH', () {
        testDecReg8(
          system,
          0x42,
          () => system.cpu.x.high,
          (int value) => system.cpu.x.high = value,
        );
      });

      test('DEC YH', () {
        testDecReg8(
          system,
          0x52,
          () => system.cpu.y.high,
          (int value) => system.cpu.y.high = value,
        );
      });

      test('DEC UH', () {
        testDecReg8(
          system,
          0x62,
          () => system.cpu.u.high,
          (int value) => system.cpu.u.high = value,
        );
      });
    });

    group('LDX [page 35]', () {
      test('LDX S', () {
        testLDXReg(system, 0x48, system.cpu.s);
      });

      test('LDX P', () {
        final List<int> opcodes = <int>[0xFD, 0x58];
        final int statusRegister = system.cpu.t.statusRegister;

        system.load(0x0020, opcodes);
        final int cycles = system.step(0x0020);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(0x0020 + opcodes.length));

        expect(system.cpu.t.statusRegister, statusRegister);
      });
    });

    group('ANI [page 29]', () {
      test('ANI #(X), ', () {
        testANIRReg(system, 0x49, system.cpu.x, me1: true);
      });

      test('ANI #(Y)', () {
        testANIRReg(system, 0x59, system.cpu.y, me1: true);
      });

      test('ANI #(U)', () {
        testANIRReg(system, 0x69, system.cpu.u, me1: true);
      });
    });

    group('STX [page 36]', () {
      test('STX Y', () {
        testSTXReg(system, 0x5A, system.cpu.y);
      });

      test('STX U', () {
        testSTXReg(system, 0x6A, system.cpu.u);
      });

      test('STX S', () {
        testSTXReg(system, 0x4E, system.cpu.s);
      });

      test('STX P', () {
        final List<int> opcodes = <int>[0xFD, 0x5E];
        final int statusRegister = system.cpu.t.statusRegister;

        system.load(0x0020, opcodes);
        system.cpu.x.value = 0x1234;
        final int cycles = system.step(0x0020);
        expect(cycles, equals(17));
        expect(system.cpu.p.value, equals(0x1234));

        expect(system.cpu.t.statusRegister, statusRegister);
      });
    });

    group('ORI [page 29]', () {
      test('ORI #(X), i', () {
        testORIRReg(system, 0x4B, system.cpu.x, me1: true);
      });

      test('ORI #(Y)', () {
        testORIRReg(system, 0x5B, system.cpu.y, me1: true);
      });

      test('ORI #(U)', () {
        testORIRReg(system, 0x6B, system.cpu.u, me1: true);
      });
    });

    group('BII [page 32]', () {
      test('BII #(X)', () {
        testBIIRReg(system, 0x4D, system.cpu.x, me1: true);
      });

      test('BII #(Y)', () {
        testBIIRReg(system, 0x5D, system.cpu.y, me1: true);
      });

      test('BII #(U)', () {
        testBIIRReg(system, 0x6D, system.cpu.u, me1: true);
      });
    });

    group('ADI [page 26]', () {
      test('ADI #(X)', () {
        testADIRReg(system, 0x4F, system.cpu.x, me1: true);
      });

      test('ADI #(Y)', () {
        testADIRReg(system, 0x5F, system.cpu.y, me1: true);
      });

      test('ADI #(U)', () {
        testADIRReg(system, 0x6F, system.cpu.u, me1: true);
      });
    });
  });
}