import 'package:test/test.dart';

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
      test('SBC XL', () {
        testSBCReg(system, <int>[0x00], system.cpu.x.lowRegister);
      });

      test('SBC XH', () {
        testSBCReg(system, <int>[0x80], system.cpu.x.highRegister);
      });

      test('SBC YL', () {
        testSBCReg(system, <int>[0x10], system.cpu.y.lowRegister);
      });

      test('SBC YH', () {
        testSBCReg(system, <int>[0x90], system.cpu.y.highRegister);
      });

      test('SBC UL', () {
        testSBCReg(system, <int>[0x00], system.cpu.u.lowRegister);
      });

      test('SBC UH', () {
        testSBCReg(system, <int>[0xA0], system.cpu.u.highRegister);
      });

      test('SBC (X)', () {
        testSBCRReg(system, 7, <int>[0x01], system.cpu.x);
      });

      test('SBC #(X)', () {
        testSBCRReg(system, 11, <int>[0xFD, 0x01], system.cpu.x, me1: true);
      });

      test('SBC (Y)', () {
        testSBCRReg(system, 7, <int>[0x11], system.cpu.y);
      });

      test('SBC #(Y)', () {
        testSBCRReg(system, 11, <int>[0xFD, 0x11], system.cpu.y, me1: true);
      });

      test('SBC (U)', () {
        testSBCRReg(system, 7, <int>[0x21], system.cpu.u);
      });

      test('SBC #(U)', () {
        testSBCRReg(system, 11, <int>[0xFD, 0x21], system.cpu.u, me1: true);
      });

      test('SBC #(ab)', () {
        testSBCab(system, <int>[0xFD, 0xA1], me1: true);
      });
    });

    group('ADC [page 25]', () {
      test('ADC XL', () {
        testADCReg(system, <int>[0x02], system.cpu.x.lowRegister);
      });

      test('ADC XH', () {
        testADCReg(system, <int>[0x82], system.cpu.x.highRegister);
      });

      test('ADC YL', () {
        testADCReg(system, <int>[0x12], system.cpu.y.lowRegister);
      });

      test('ADC YH', () {
        testADCReg(system, <int>[0x92], system.cpu.y.highRegister);
      });

      test('ADC UL', () {
        testADCReg(system, <int>[0x22], system.cpu.u.lowRegister);
      });

      test('ADC UH', () {
        testADCReg(system, <int>[0xA2], system.cpu.u.highRegister);
      });

      test('ADC (X)', () {
        testADCRReg(system, 7, <int>[0x03], system.cpu.x);
      });

      test('ADC #(X)', () {
        testADCRReg(system, 11, <int>[0xFD, 0x03], system.cpu.x, me1: true);
      });

      test('ADC (Y)', () {
        testADCRReg(system, 7, <int>[0x13], system.cpu.y);
      });

      test('ADC #(Y)', () {
        testADCRReg(system, 11, <int>[0xFD, 0x13], system.cpu.y, me1: true);
      });

      test('ADC (U)', () {
        testADCRReg(system, 7, <int>[0x23], system.cpu.u);
      });

      test('ADC #(U)', () {
        testADCRReg(system, 11, <int>[0xFD, 0x23], system.cpu.u, me1: true);
      });

      test('ADC #(ab)', () {
        testADCab(system, <int>[0xFD, 0xA3], me1: true);
      });
    });

    group('LDA [page 33]', () {
      test('LDA XL', () {
        testLDAReg(system, <int>[0x04], system.cpu.x.lowRegister);
      });

      test('LDA XH', () {
        testLDAReg(system, <int>[0x84], system.cpu.x.highRegister);
      });

      test('LDA YL', () {
        testLDAReg(system, <int>[0x14], system.cpu.y.lowRegister);
      });

      test('LDA YH', () {
        testLDAReg(system, <int>[0x94], system.cpu.y.highRegister);
      });

      test('LDA UL', () {
        testLDAReg(system, <int>[0x24], system.cpu.u.lowRegister);
      });

      test('LDA UH', () {
        testLDAReg(system, <int>[0xA4], system.cpu.u.highRegister);
      });

      test('LDA (X)', () {
        testLDARReg(system, 6, <int>[0x05], system.cpu.x);
      });

      test('LDA #(X)', () {
        testLDARReg(system, 10, <int>[0xFD, 0x05], system.cpu.x, me1: true);
      });

      test('LDA (Y)', () {
        testLDARReg(system, 6, <int>[0x15], system.cpu.y);
      });

      test('LDA #(Y)', () {
        testLDARReg(system, 10, <int>[0xFD, 0x15], system.cpu.y, me1: true);
      });

      test('LDA (U)', () {
        testLDARReg(system, 6, <int>[0x25], system.cpu.u);
      });

      test('LDA #(U)', () {
        testLDARReg(system, 10, <int>[0xFD, 0x25], system.cpu.u, me1: true);
      });

      test('LDA #(ab)', () {
        testLDAab(system, <int>[0xFD, 0xA5], me1: true);
      });
    });

    group('CPA [page 31]', () {
      test('CPA XL', () {
        testCPAReg(system, <int>[0x06], system.cpu.x.lowRegister);
      });

      test('CPA XH', () {
        testCPAReg(system, <int>[0x86], system.cpu.x.highRegister);
      });

      test('CPA YL', () {
        testCPAReg(system, <int>[0x16], system.cpu.y.lowRegister);
      });

      test('CPA YH', () {
        testCPAReg(system, <int>[0x96], system.cpu.y.highRegister);
      });

      test('CPA UL', () {
        testCPAReg(system, <int>[0x26], system.cpu.u.lowRegister);
      });

      test('CPA UH', () {
        testCPAReg(system, <int>[0xA6], system.cpu.u.highRegister);
      });

      test('CPA (X)', () {
        testCPARReg(system, 11, <int>[0x07], system.cpu.x);
      });

      test('CPA #(X)', () {
        testCPARReg(system, 11, <int>[0xFD, 0x07], system.cpu.x, me1: true);
      });

      test('CPA (Y)', () {
        testCPARReg(system, 11, <int>[0x17], system.cpu.y);
      });

      test('CPA #(Y)', () {
        testCPARReg(system, 11, <int>[0xFD, 0x17], system.cpu.y, me1: true);
      });

      test('CPA (U)', () {
        testCPARReg(system, 11, <int>[0x27], system.cpu.u);
      });

      test('CPA #(U)', () {
        testCPARReg(system, 11, <int>[0xFD, 0x27], system.cpu.u, me1: true);
      });

      test('CPA #(ab)', () {
        testCPAab(system, <int>[0xFD, 0xA7], me1: true);
      });
    });

    group('AND [page 29]', () {
      test('AND #(X)', () {
        testANDRReg(system, <int>[0xFD, 0x09], system.cpu.x);
      });

      test('AND #(Y)', () {
        testANDRReg(system, <int>[0xFD, 0x19], system.cpu.y);
      });

      test('AND #(U)', () {
        testANDRReg(system, <int>[0xFD, 0x29], system.cpu.u);
      });

      test('AND #(ab)', () {
        testANDab(system, <int>[0xFD, 0xA9], me1: true);
      });
    });

    group('POP [page 37]', () {
      test('POP X', () {
        testPOPRReg(system, <int>[0xFD, 0x0A], system.cpu.x);
      });

      test('POP Y', () {
        testPOPRReg(system, <int>[0xFD, 0x1A], system.cpu.y);
      });

      test('POP U', () {
        testPOPRReg(system, <int>[0xFD, 0x2A], system.cpu.u);
      });

      test('POP A', () {
        testPOPA(system);
      });
    });

    group('ORA [page 29]', () {
      test('ORA #(X)', () {
        testORARReg(system, <int>[0xFD, 0x0B], system.cpu.x);
      });

      test('ORA #(Y)', () {
        testORARReg(system, <int>[0xFD, 0x1B], system.cpu.y);
      });

      test('ORA #(U)', () {
        testORARReg(system, <int>[0xFD, 0x2B], system.cpu.u);
      });

      test('ORA #(ab)', () {
        testORAab(system, <int>[0xFD, 0xAB], me1: true);
      });
    });

    group('DCS [page 28]', () {
      test('DCS #(X)', () {
        testDCSRReg(system, <int>[0xFD, 0x0C], system.cpu.x);
      });

      test('DCS #(Y)', () {
        testDCSRReg(system, <int>[0xFD, 0x1C], system.cpu.y);
      });

      test('DCS #(U)', () {
        testDCSRReg(system, <int>[0xFD, 0x2C], system.cpu.u);
      });
    });

    group('EOR [page 30]', () {
      test('EOR #(X)', () {
        testEORRReg(system, <int>[0xFD, 0x0D], system.cpu.x);
      });

      test('EOR #(Y)', () {
        testEORRReg(system, <int>[0xFD, 0x1D], system.cpu.y);
      });

      test('EOR #(U)', () {
        testEORRReg(system, <int>[0xFD, 0x2D], system.cpu.u);
      });

      test('EOR #(ab)', () {
        testEORab(system, <int>[0xFD, 0xAD], me1: true);
      });
    });

    group('STA [page 35]', () {
      test('STA XL', () {
        testSTAReg(system, <int>[0x0A], system.cpu.x.lowRegister);
      });

      test('STA XH', () {
        testSTAReg(system, <int>[0x08], system.cpu.x.highRegister);
      });

      test('STA YL', () {
        testSTAReg(system, <int>[0x1A], system.cpu.y.lowRegister);
      });

      test('STA YH', () {
        testSTAReg(system, <int>[0x18], system.cpu.y.highRegister);
      });

      test('STA UL', () {
        testSTAReg(system, <int>[0x2A], system.cpu.u.lowRegister);
      });

      test('STA UH', () {
        testSTAReg(system, <int>[0x28], system.cpu.u.highRegister);
      });

      test('STA (X)', () {
        testSTARReg(system, 6, <int>[0x0E], system.cpu.x);
      });

      test('STA #(X)', () {
        testSTARReg(system, 10, <int>[0xFD, 0x0E], system.cpu.x, me1: true);
      });

      test('STA (Y)', () {
        testSTARReg(system, 6, <int>[0x1E], system.cpu.y);
      });

      test('STA #(Y)', () {
        testSTARReg(system, 10, <int>[0xFD, 0x1E], system.cpu.y, me1: true);
      });

      test('STA (U)', () {
        testSTARReg(system, 6, <int>[0x2E], system.cpu.u);
      });

      test('STA #(U)', () {
        testSTARReg(system, 10, <int>[0xFD, 0x2E], system.cpu.u, me1: true);
      });

      test('STA #(ab)', () {
        testSTAab(system, <int>[0xFD, 0xAE], me1: true);
      });
    });

    group('BIT [page 32]', () {
      test('BIT #(X)', () {
        testBITRReg(system, <int>[0xFD, 0x0F], system.cpu.x, me1: true);
      });

      test('BIT #(Y)', () {
        testBITRReg(system, <int>[0xFD, 0x1F], system.cpu.y, me1: true);
      });

      test('BIT #(U)', () {
        testBITRReg(system, <int>[0xFD, 0x2F], system.cpu.u, me1: true);
      });

      test('BIT #(ab)', () {
        testBITab(system, <int>[0xFD, 0xAF], me1: true);
      });
    });

    group('INC [page 30]', () {
      test('INC XH', () {
        testIncReg8(
          system,
          <int>[0xFD, 0x40],
          () => system.cpu.x.high,
          (int value) => system.cpu.x.high = value,
        );
      });

      test('INC YH', () {
        testIncReg8(
          system,
          <int>[0xFD, 0x50],
          () => system.cpu.y.high,
          (int value) => system.cpu.y.high = value,
        );
      });

      test('INC UH', () {
        testIncReg8(
          system,
          <int>[0xFD, 0x60],
          () => system.cpu.u.high,
          (int value) => system.cpu.u.high = value,
        );
      });
    });

    group('DEC [page 30]', () {
      test('DEC XH', () {
        testDecReg8(
          system,
          <int>[0xFD, 0x42],
          () => system.cpu.x.high,
          (int value) => system.cpu.x.high = value,
        );
      });

      test('DEC YH', () {
        testDecReg8(
          system,
          <int>[0xFD, 0x52],
          () => system.cpu.y.high,
          (int value) => system.cpu.y.high = value,
        );
      });

      test('DEC UH', () {
        testDecReg8(
          system,
          <int>[0xFD, 0x62],
          () => system.cpu.u.high,
          (int value) => system.cpu.u.high = value,
        );
      });
    });

    group('LDX [page 35]', () {
      test('LDX S', () {
        testLDXReg(system, <int>[0xFD, 0x48], system.cpu.s);
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
        testANIRReg(system, <int>[0xFD, 0x49], system.cpu.x, me1: true);
      });

      test('ANI #(Y)', () {
        testANIRReg(system, <int>[0xFD, 0x59], system.cpu.y, me1: true);
      });

      test('ANI #(U)', () {
        testANIRReg(system, <int>[0xFD, 0x69], system.cpu.u, me1: true);
      });

      test('ANI #(ab), i', () {
        testANIab(system, <int>[0xFD, 0xE9], me1: true);
      });
    });

    group('STX [page 36]', () {
      test('STX Y', () {
        testSTXReg(system, <int>[0xFD, 0x5A], system.cpu.y);
      });

      test('STX U', () {
        testSTXReg(system, <int>[0xFD, 0x6A], system.cpu.u);
      });

      test('STX S', () {
        testSTXReg(system, <int>[0xFD, 0x4E], system.cpu.s);
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

    group('ORI [page 30]', () {
      test('ORI #(X), i', () {
        testORIRReg(system, <int>[0xFD, 0x4B], system.cpu.x, me1: true);
      });

      test('ORI #(Y)', () {
        testORIRReg(system, <int>[0xFD, 0x5B], system.cpu.y, me1: true);
      });

      test('ORI #(U)', () {
        testORIRReg(system, <int>[0xFD, 0x6B], system.cpu.u, me1: true);
      });

      test('ORI #(ab), i', () {
        testORIab(system, <int>[0xFD, 0xEB], me1: true);
      });
    });

    group('BII [page 32]', () {
      test('BII #(X)', () {
        testBIIRReg(system, <int>[0xFD, 0x4D], system.cpu.x, me1: true);
      });

      test('BII #(Y)', () {
        testBIIRReg(system, <int>[0xFD, 0x5D], system.cpu.y, me1: true);
      });

      test('BII #(U)', () {
        testBIIRReg(system, <int>[0xFD, 0x6D], system.cpu.u, me1: true);
      });

      test('BII #(ab), i', () {
        testBIIab(system, <int>[0xFD, 0xED], me1: true);
      });
    });

    group('ADI [page 26]', () {
      test('ADI #(X)', () {
        testADIRReg(system, <int>[0xFD, 0x4F], system.cpu.x, me1: true);
      });

      test('ADI #(Y)', () {
        testADIRReg(system, <int>[0xFD, 0x5F], system.cpu.y, me1: true);
      });

      test('ADI #(U)', () {
        testADIRReg(system, <int>[0xFD, 0x6F], system.cpu.u, me1: true);
      });

      test('ADI #(ab), i', () {
        testADIab(system, <int>[0xFD, 0xEF], me1: true);
      });
    });

    group('PSH [page 36]', () {
      test('PSH X', () {
        testPSHRReg(system, <int>[0xFD, 0x88], system.cpu.x);
      });

      test('PSH Y', () {
        testPSHRReg(system, <int>[0xFD, 0x98], system.cpu.y);
      });

      test('PSH U', () {
        testPSHRReg(system, <int>[0xFD, 0xA8], system.cpu.u);
      });

      test('PSH A', () {
        final List<int> opcodes = <int>[0xFD, 0xC8];
        final int statusRegister = system.cpu.t.statusRegister;

        system.load(0x0000, opcodes);
        system.cpu.s.value = 0x46FF;
        system.cpu.a.value = 0x3F;
        final int cycles = system.step(0x0000);
        expect(cycles, equals(11));
        expect(system.cpu.p.value, equals(opcodes.length));

        expect(system.cpu.s.value, equals(0x46FF - 1));
        expect(system.memRead(0x46FF), equals(0x3F));
        expect(system.cpu.a.value, equals(0x3F));

        expect(system.cpu.t.statusRegister, statusRegister);
      });
    });

    group('DCA [page 26]', () {
      test('DCA #(X)', () {
        testDCARReg(system, <int>[0xFD, 0x8C], system.cpu.x, me1: true);
      });

      test('DCA #(Y)', () {
        testDCARReg(system, <int>[0xFD, 0x9C], system.cpu.y, me1: true);
      });

      test('DCA #(U)', () {
        testDCARReg(system, <int>[0xFD, 0xAC], system.cpu.u, me1: true);
      });
    });

    test('TTA [page 38]', () {
      testTTA(system);
    });

    group('ADR [page 26]', () {
      test('ADR X', () {
        testADRRReg(system, <int>[0xFD, 0xCA], system.cpu.x);
      });

      test('ADR Y', () {
        testADRRReg(system, <int>[0xFD, 0xDA], system.cpu.y);
      });

      test('ADR U', () {
        testADRRReg(system, <int>[0xFD, 0xEA], system.cpu.u);
      });
    });

    group('DRR [page 41]', () {
      test('DRR #(X)', () {
        testDRRRReg(system, <int>[0xFD, 0xD3], me1: true);
      });
    });

    group('DRL [page 40]', () {
      test('DRL #(X)', () {
        testDRLRReg(system, <int>[0xFD, 0xD7], me1: true);
      });
    });
  });
}
