import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  final LH5801Test lh5801 = LH5801Test();

  group('LH5801CPU', () {
    setUp(() {
      lh5801.resetTestEnv();
    });

    group('Add, subtract and logical instructions', () {
      group('ADC [page 25]', () {
        test('ADC XL', () {
          testADCReg(lh5801, <int>[0x02], lh5801.cpu.x.lowRegister);
        });

        test('ADC XH', () {
          testADCReg(lh5801, <int>[0x82], lh5801.cpu.x.highRegister);
        });

        test('ADC YL', () {
          testADCReg(lh5801, <int>[0x12], lh5801.cpu.y.lowRegister);
        });

        test('ADC YH', () {
          testADCReg(lh5801, <int>[0x92], lh5801.cpu.y.highRegister);
        });

        test('ADC UL', () {
          testADCReg(lh5801, <int>[0x22], lh5801.cpu.u.lowRegister);
        });

        test('ADC UH', () {
          testADCReg(lh5801, <int>[0xA2], lh5801.cpu.u.highRegister);
        });

        test('ADC (X)', () {
          testADCRReg(lh5801, 7, <int>[0x03], lh5801.cpu.x);
        });

        test('ADC #(X)', () {
          testADCRReg(lh5801, 11, <int>[0xFD, 0x03], lh5801.cpu.x, me1: true);
        });

        test('ADC (Y)', () {
          testADCRReg(lh5801, 7, <int>[0x13], lh5801.cpu.y);
        });

        test('ADC #(Y)', () {
          testADCRReg(lh5801, 11, <int>[0xFD, 0x13], lh5801.cpu.y, me1: true);
        });

        test('ADC (U)', () {
          testADCRReg(lh5801, 7, <int>[0x23], lh5801.cpu.u);
        });

        test('ADC #(U)', () {
          testADCRReg(lh5801, 11, <int>[0xFD, 0x23], lh5801.cpu.u, me1: true);
        });

        test('ADC (ab)', () {
          testADCab(lh5801, 13, <int>[0xA3]);
        });

        test('ADC #(ab)', () {
          testADCab(lh5801, 17, <int>[0xFD, 0xA3], me1: true);
        });
      });

      group('ADI [page 26]', () {
        test('ADI A, i', () {
          testADIAcc(lh5801);
        });

        test('ADI (X), i', () {
          testADIRReg(lh5801, 13, <int>[0x4F], lh5801.cpu.x);
        });

        test('ADI #(X), i', () {
          testADIRReg(lh5801, 17, <int>[0xFD, 0x4F], lh5801.cpu.x, me1: true);
        });

        test('ADI (Y), i', () {
          testADIRReg(lh5801, 13, <int>[0x5F], lh5801.cpu.y);
        });

        test('ADI #(Y), i', () {
          testADIRReg(lh5801, 17, <int>[0xFD, 0x5F], lh5801.cpu.y, me1: true);
        });

        test('ADI (U), i', () {
          testADIRReg(lh5801, 13, <int>[0x6F], lh5801.cpu.u);
        });

        test('ADI #(U), i', () {
          testADIRReg(lh5801, 17, <int>[0xFD, 0x6F], lh5801.cpu.u, me1: true);
        });

        test('ADI (ab), i', () {
          testADIab(lh5801, 19, <int>[0xEF]);
        });

        test('ADI #(ab), i', () {
          testADIab(lh5801, 23, <int>[0xFD, 0xEF], me1: true);
        });
      });

      group('DCA [page 26]', () {
        test('DCA (X)', () {
          testDCARReg(lh5801, 15, <int>[0x8C], lh5801.cpu.x);
        });

        test('DCA #(X)', () {
          testDCARReg(lh5801, 19, <int>[0xFD, 0x8C], lh5801.cpu.x, me1: true);
        });

        test('DCA (Y)', () {
          testDCARReg(lh5801, 15, <int>[0x9C], lh5801.cpu.y);
        });

        test('DCA #(Y)', () {
          testDCARReg(lh5801, 19, <int>[0xFD, 0x9C], lh5801.cpu.y, me1: true);
        });

        test('DCA (U)', () {
          testDCARReg(lh5801, 15, <int>[0xAC], lh5801.cpu.u);
        });

        test('DCA #(U)', () {
          testDCARReg(lh5801, 19, <int>[0xFD, 0xAC], lh5801.cpu.u, me1: true);
        });
      });

      group('ADR [page 27]', () {
        test('ADR X', () {
          testADRRReg(lh5801, <int>[0xFD, 0xCA], lh5801.cpu.x);
        });

        test('ADR Y', () {
          testADRRReg(lh5801, <int>[0xFD, 0xDA], lh5801.cpu.y);
        });

        test('ADR U', () {
          testADRRReg(lh5801, <int>[0xFD, 0xEA], lh5801.cpu.u);
        });
      });

      group('SBC [page 27]', () {
        test('SBC XL', () {
          testSBCReg(lh5801, <int>[0x00], lh5801.cpu.x.lowRegister);
        });

        test('SBC XH', () {
          testSBCReg(lh5801, <int>[0x80], lh5801.cpu.x.highRegister);
        });

        test('SBC YL', () {
          testSBCReg(lh5801, <int>[0x10], lh5801.cpu.y.lowRegister);
        });

        test('SBC YH', () {
          testSBCReg(lh5801, <int>[0x90], lh5801.cpu.y.highRegister);
        });

        test('SBC UL', () {
          testSBCReg(lh5801, <int>[0x20], lh5801.cpu.u.lowRegister);
        });

        test('SBC UH', () {
          testSBCReg(lh5801, <int>[0xA0], lh5801.cpu.u.highRegister);
        });

        test('SBC (X)', () {
          testSBCRReg(lh5801, 7, <int>[0x01], lh5801.cpu.x);
        });

        test('SBC #(X)', () {
          testSBCRReg(lh5801, 11, <int>[0xFD, 0x01], lh5801.cpu.x, me1: true);
        });

        test('SBC (Y)', () {
          testSBCRReg(lh5801, 7, <int>[0x11], lh5801.cpu.y);
        });

        test('SBC #(Y)', () {
          testSBCRReg(lh5801, 11, <int>[0xFD, 0x11], lh5801.cpu.y, me1: true);
        });

        test('SBC (U)', () {
          testSBCRReg(lh5801, 7, <int>[0x21], lh5801.cpu.u);
        });

        test('SBC #(U)', () {
          testSBCRReg(lh5801, 11, <int>[0xFD, 0x21], lh5801.cpu.u, me1: true);
        });

        test('SBC (ab)', () {
          testSBCab(lh5801, 13, <int>[0xA1]);
        });

        test('SBC #(ab)', () {
          testSBCab(lh5801, 17, <int>[0xFD, 0xA1], me1: true);
        });
      });

      group('SBI [page 28]', () {
        test('SBI A, i', () {
          testSBIAcc(lh5801);
        });
      });

      group('DCS [page 28]', () {
        test('DCS (X)', () {
          testDCSRReg(lh5801, 13, <int>[0x0C], lh5801.cpu.x);
        });

        test('DCS #(X)', () {
          testDCSRReg(lh5801, 17, <int>[0xFD, 0x0C], lh5801.cpu.x, me1: true);
        });

        test('DCS (Y)', () {
          testDCSRReg(lh5801, 13, <int>[0x1C], lh5801.cpu.y);
        });

        test('DCS #(Y)', () {
          testDCSRReg(lh5801, 17, <int>[0xFD, 0x1C], lh5801.cpu.y, me1: true);
        });

        test('DCS (U)', () {
          testDCSRReg(lh5801, 13, <int>[0x2C], lh5801.cpu.u);
        });

        test('DCS #(U)', () {
          testDCSRReg(lh5801, 17, <int>[0xFD, 0x2C], lh5801.cpu.u, me1: true);
        });
      });

      group('AND [page 29]', () {
        test('AND (X)', () {
          testANDRReg(lh5801, 7, <int>[0x09], lh5801.cpu.x);
        });

        test('AND #(X)', () {
          testANDRReg(lh5801, 11, <int>[0xFD, 0x09], lh5801.cpu.x, me1: true);
        });

        test('AND (Y)', () {
          testANDRReg(lh5801, 7, <int>[0x19], lh5801.cpu.y);
        });

        test('AND #(Y)', () {
          testANDRReg(lh5801, 11, <int>[0xFD, 0x19], lh5801.cpu.y, me1: true);
        });

        test('AND (U)', () {
          testANDRReg(lh5801, 7, <int>[0x29], lh5801.cpu.u);
        });

        test('AND #(U)', () {
          testANDRReg(lh5801, 11, <int>[0xFD, 0x29], lh5801.cpu.u, me1: true);
        });

        test('AND (ab)', () {
          testANDab(lh5801, 13, <int>[0xA9]);
        });

        test('AND #(ab)', () {
          testANDab(lh5801, 17, <int>[0xFD, 0xA9], me1: true);
        });
      });

      group('ANI [page 29]', () {
        test('ANI A, i', () {
          testANIAcc(lh5801);
        });

        test('ANI (X), i', () {
          testANIRReg(lh5801, 13, <int>[0x49], lh5801.cpu.x);
        });

        test('ANI #(X), i', () {
          testANIRReg(lh5801, 17, <int>[0xFD, 0x49], lh5801.cpu.x, me1: true);
        });

        test('ANI (Y), i', () {
          testANIRReg(lh5801, 13, <int>[0x59], lh5801.cpu.y);
        });

        test('ANI #(Y), i', () {
          testANIRReg(lh5801, 17, <int>[0xFD, 0x59], lh5801.cpu.y, me1: true);
        });

        test('ANI (U), i', () {
          testANIRReg(lh5801, 13, <int>[0x69], lh5801.cpu.u);
        });

        test('ANI #(U), i', () {
          testANIRReg(lh5801, 17, <int>[0xFD, 0x69], lh5801.cpu.u, me1: true);
        });

        test('ANI (ab), i', () {
          testANIab(lh5801, 19, <int>[0xE9]);
        });

        test('ANI #(ab), i', () {
          testANIab(lh5801, 23, <int>[0xFD, 0xE9], me1: true);
        });
      });

      group('ORA [page 29]', () {
        test('ORA (X)', () {
          testORARReg(lh5801, 7, <int>[0x0B], lh5801.cpu.x);
        });

        test('ORA #(X)', () {
          testORARReg(lh5801, 11, <int>[0xFD, 0x0B], lh5801.cpu.x, me1: true);
        });

        test('ORA (Y)', () {
          testORARReg(lh5801, 7, <int>[0x1B], lh5801.cpu.y);
        });

        test('ORA #(Y)', () {
          testORARReg(lh5801, 11, <int>[0xFD, 0x1B], lh5801.cpu.y, me1: true);
        });

        test('ORA (U)', () {
          testORARReg(lh5801, 7, <int>[0x2B], lh5801.cpu.u);
        });

        test('ORA #(U)', () {
          testORARReg(lh5801, 11, <int>[0xFD, 0x2B], lh5801.cpu.u, me1: true);
        });

        test('ORA (ab)', () {
          testORAab(lh5801, 13, <int>[0xAB]);
        });

        test('ORA #(ab)', () {
          testORAab(lh5801, 17, <int>[0xFD, 0xAB], me1: true);
        });
      });

      group('ORI [page 30]', () {
        test('ORI A, i', () {
          testORIAcc(lh5801);
        });

        test('ORI (X), i', () {
          testORIRReg(lh5801, 13, <int>[0x4B], lh5801.cpu.x);
        });

        test('ORI #(X), i', () {
          testORIRReg(lh5801, 17, <int>[0xFD, 0x4B], lh5801.cpu.x, me1: true);
        });

        test('ORI (Y), i', () {
          testORIRReg(lh5801, 13, <int>[0x5B], lh5801.cpu.y);
        });

        test('ORI #(Y), i', () {
          testORIRReg(lh5801, 17, <int>[0xFD, 0x5B], lh5801.cpu.y, me1: true);
        });

        test('ORI (U), i', () {
          testORIRReg(lh5801, 13, <int>[0x6B], lh5801.cpu.u);
        });

        test('ORI #(U), i', () {
          testORIRReg(lh5801, 17, <int>[0xFD, 0x6B], lh5801.cpu.u, me1: true);
        });

        test('ORI (ab), i', () {
          testORIab(lh5801, 19, <int>[0xEB]);
        });

        test('ORI #(ab), i', () {
          testORIab(lh5801, 23, <int>[0xFD, 0xEB], me1: true);
        });
      });

      group('EOR [page 30]', () {
        test('EOR (X)', () {
          testEORRReg(lh5801, 7, <int>[0x0D], lh5801.cpu.x);
        });

        test('EOR #(X)', () {
          testEORRReg(lh5801, 11, <int>[0xFD, 0x0D], lh5801.cpu.x, me1: true);
        });

        test('EOR (Y)', () {
          testEORRReg(lh5801, 7, <int>[0x1D], lh5801.cpu.y);
        });

        test('EOR #(Y)', () {
          testEORRReg(lh5801, 11, <int>[0xFD, 0x1D], lh5801.cpu.y, me1: true);
        });

        test('EOR (U)', () {
          testEORRReg(lh5801, 7, <int>[0x2D], lh5801.cpu.u);
        });

        test('EOR #(U)', () {
          testEORRReg(lh5801, 11, <int>[0xFD, 0x2D], lh5801.cpu.u, me1: true);
        });

        test('EOR (ab)', () {
          testEORab(lh5801, 13, <int>[0xAD]);
        });

        test('EOR #(ab)', () {
          testEORab(lh5801, 17, <int>[0xFD, 0xAD], me1: true);
        });
      });

      group('EAI [page 30]', () {
        test('EAI i', () {
          testEAI(lh5801);
        });
      });

      group('INC [page 30]', () {
        test('INC A', () {
          testIncReg8(
            lh5801,
            5,
            <int>[0xDD],
            lh5801.cpu.a,
          );
        });

        test('INC XL', () {
          testIncReg8(
            lh5801,
            5,
            <int>[0x40],
            lh5801.cpu.x.lowRegister,
          );
        });

        test('INC XH', () {
          testIncReg8(
            lh5801,
            9,
            <int>[0xFD, 0x40],
            lh5801.cpu.x.highRegister,
          );
        });

        test('INC YL', () {
          testIncReg8(
            lh5801,
            5,
            <int>[0x50],
            lh5801.cpu.y.lowRegister,
          );
        });

        test('INC YH', () {
          testIncReg8(
            lh5801,
            9,
            <int>[0xFD, 0x50],
            lh5801.cpu.y.highRegister,
          );
        });

        test('INC UL', () {
          testIncReg8(
            lh5801,
            5,
            <int>[0x60],
            lh5801.cpu.u.lowRegister,
          );
        });

        test('INC UH', () {
          testIncReg8(
            lh5801,
            9,
            <int>[0xFD, 0x60],
            lh5801.cpu.u.highRegister,
          );
        });

        test('INC X', () {
          testIncReg16(
            lh5801,
            5,
            <int>[0x44],
            lh5801.cpu.x,
          );
        });

        test('INC Y', () {
          testIncReg16(
            lh5801,
            5,
            <int>[0x54],
            lh5801.cpu.y,
          );
        });

        test('INC U', () {
          testIncReg16(
            lh5801,
            5,
            <int>[0x64],
            lh5801.cpu.u,
          );
        });
      });

      group('DEC [page 31]', () {
        test('DEC A', () {
          testDecReg8(
            lh5801,
            5,
            <int>[0xDF],
            lh5801.cpu.a,
          );
        });

        test('DEC XL', () {
          testDecReg8(
            lh5801,
            5,
            <int>[0x42],
            lh5801.cpu.x.lowRegister,
          );
        });

        test('DEC XH', () {
          testDecReg8(
            lh5801,
            9,
            <int>[0xFD, 0x42],
            lh5801.cpu.x.highRegister,
          );
        });

        test('DEC YL', () {
          testDecReg8(
            lh5801,
            5,
            <int>[0x52],
            lh5801.cpu.y.lowRegister,
          );
        });

        test('DEC YH', () {
          testDecReg8(
            lh5801,
            9,
            <int>[0xFD, 0x52],
            lh5801.cpu.y.highRegister,
          );
        });

        test('DEC UL', () {
          testDecReg8(
            lh5801,
            5,
            <int>[0x62],
            lh5801.cpu.u.lowRegister,
          );
        });

        test('DEC UH', () {
          testDecReg8(
            lh5801,
            9,
            <int>[0xFD, 0x62],
            lh5801.cpu.u.highRegister,
          );
        });

        test('DEC X', () {
          testDecReg16(
            lh5801,
            5,
            <int>[0x46],
            lh5801.cpu.x,
          );
        });

        test('DEC Y', () {
          testDecReg16(
            lh5801,
            5,
            <int>[0x56],
            lh5801.cpu.y,
          );
        });

        test('DEC U', () {
          testDecReg16(
            lh5801,
            5,
            <int>[0x66],
            lh5801.cpu.u,
          );
        });
      });
    });

    group('Compare and bit test instructions', () {
      group('CPA [page 31]', () {
        test('CPA XL', () {
          testCPAReg(lh5801, <int>[0x06], lh5801.cpu.x.lowRegister);
        });

        test('CPA XH', () {
          testCPAReg(lh5801, <int>[0x86], lh5801.cpu.x.highRegister);
        });

        test('CPA YL', () {
          testCPAReg(lh5801, <int>[0x16], lh5801.cpu.y.lowRegister);
        });

        test('CPA YH', () {
          testCPAReg(lh5801, <int>[0x96], lh5801.cpu.y.highRegister);
        });

        test('CPA UL', () {
          testCPAReg(lh5801, <int>[0x26], lh5801.cpu.u.lowRegister);
        });

        test('CPA UH', () {
          testCPAReg(lh5801, <int>[0xA6], lh5801.cpu.u.highRegister);
        });

        test('CPA (X)', () {
          testCPARReg(lh5801, 7, <int>[0x07], lh5801.cpu.x);
        });

        test('CPA #(X)', () {
          testCPARReg(lh5801, 11, <int>[0xFD, 0x07], lh5801.cpu.x, me1: true);
        });

        test('CPA (Y)', () {
          testCPARReg(lh5801, 7, <int>[0x17], lh5801.cpu.y);
        });

        test('CPA #(Y)', () {
          testCPARReg(lh5801, 11, <int>[0xFD, 0x17], lh5801.cpu.y, me1: true);
        });

        test('CPA (U)', () {
          testCPARReg(lh5801, 7, <int>[0x27], lh5801.cpu.u);
        });

        test('CPA #(U)', () {
          testCPARReg(lh5801, 11, <int>[0xFD, 0x27], lh5801.cpu.u, me1: true);
        });

        test('CPA (ab)', () {
          testCPAab(lh5801, 13, <int>[0xA7]);
        });

        test('CPA #(ab)', () {
          testCPAab(lh5801, 17, <int>[0xFD, 0xA7], me1: true);
        });
      });

      group('CPI [page 32]', () {
        test('CPI XL, i', () {
          testCPIReg(lh5801, <int>[0x4E], lh5801.cpu.x.lowRegister);
        });

        test('CPI XH, i', () {
          testCPIReg(lh5801, <int>[0x4C], lh5801.cpu.x.highRegister);
        });

        test('CPI YL, i', () {
          testCPIReg(lh5801, <int>[0x5E], lh5801.cpu.y.lowRegister);
        });

        test('CPI YH, i', () {
          testCPIReg(lh5801, <int>[0x5C], lh5801.cpu.y.highRegister);
        });

        test('CPI UL, i', () {
          testCPIReg(lh5801, <int>[0x6E], lh5801.cpu.u.lowRegister);
        });

        test('CPI UH, i', () {
          testCPIReg(lh5801, <int>[0x6C], lh5801.cpu.u.highRegister);
        });

        test('CPI A, i', () {
          testCPIReg(lh5801, <int>[0xB7], lh5801.cpu.a);
        });
      });

      group('BIT [page 32]', () {
        test('BIT (X)', () {
          testBITRReg(lh5801, 7, <int>[0x0F], lh5801.cpu.x);
        });

        test('BIT #(X)', () {
          testBITRReg(lh5801, 11, <int>[0xFD, 0x0F], lh5801.cpu.x, me1: true);
        });

        test('BIT (Y)', () {
          testBITRReg(lh5801, 7, <int>[0x1F], lh5801.cpu.y);
        });

        test('BIT #(Y)', () {
          testBITRReg(lh5801, 11, <int>[0xFD, 0x1F], lh5801.cpu.y, me1: true);
        });

        test('BIT (U)', () {
          testBITRReg(lh5801, 7, <int>[0x2F], lh5801.cpu.u);
        });

        test('BIT #(U)', () {
          testBITRReg(lh5801, 11, <int>[0xFD, 0x2F], lh5801.cpu.u, me1: true);
        });

        test('BIT (ab)', () {
          testBITab(lh5801, 13, <int>[0xAF]);
        });

        test('BIT #(ab)', () {
          testBITab(lh5801, 17, <int>[0xFD, 0xAF], me1: true);
        });
      });

      group('BII [page 32]', () {
        test('BII A, i', () {
          testBIIAcc(lh5801);
        });

        test('BII (X), i', () {
          testBIIRReg(lh5801, 10, <int>[0x4D], lh5801.cpu.x);
        });

        test('BII #(X), i', () {
          testBIIRReg(lh5801, 14, <int>[0xFD, 0x4D], lh5801.cpu.x, me1: true);
        });

        test('BII (Y), i', () {
          testBIIRReg(lh5801, 10, <int>[0x5D], lh5801.cpu.y);
        });

        test('BII #(Y), i', () {
          testBIIRReg(lh5801, 14, <int>[0xFD, 0x5D], lh5801.cpu.y, me1: true);
        });

        test('BII (U), i', () {
          testBIIRReg(lh5801, 10, <int>[0x6D], lh5801.cpu.u);
        });

        test('BII #(U), i', () {
          testBIIRReg(lh5801, 14, <int>[0xFD, 0x6D], lh5801.cpu.u, me1: true);
        });

        test('BII (ab), i', () {
          testBIIab(lh5801, 16, <int>[0xED]);
        });

        test('BII #(ab), i', () {
          testBIIab(lh5801, 20, <int>[0xFD, 0xED], me1: true);
        });
      });
    });

    group('Transfer and search instructions', () {
      group('LDA [page 33]', () {
        test('LDA XL', () {
          testLDAReg(lh5801, <int>[0x04], lh5801.cpu.x.lowRegister);
        });

        test('LDA XH', () {
          testLDAReg(lh5801, <int>[0x84], lh5801.cpu.x.highRegister);
        });

        test('LDA YL', () {
          testLDAReg(lh5801, <int>[0x14], lh5801.cpu.y.lowRegister);
        });

        test('LDA YH', () {
          testLDAReg(lh5801, <int>[0x94], lh5801.cpu.y.highRegister);
        });

        test('LDA UL', () {
          testLDAReg(lh5801, <int>[0x24], lh5801.cpu.u.lowRegister);
        });

        test('LDA UH', () {
          testLDAReg(lh5801, <int>[0xA4], lh5801.cpu.u.highRegister);
        });

        test('LDA (X)', () {
          testLDARReg(lh5801, 6, <int>[0x05], lh5801.cpu.x);
        });

        test('LDA #(X)', () {
          testLDARReg(lh5801, 10, <int>[0xFD, 0x05], lh5801.cpu.x, me1: true);
        });

        test('LDA (Y)', () {
          testLDARReg(lh5801, 6, <int>[0x15], lh5801.cpu.y);
        });

        test('LDA #(Y)', () {
          testLDARReg(lh5801, 10, <int>[0xFD, 0x15], lh5801.cpu.y, me1: true);
        });

        test('LDA (U)', () {
          testLDARReg(lh5801, 6, <int>[0x25], lh5801.cpu.u);
        });

        test('LDA #(U)', () {
          testLDARReg(lh5801, 10, <int>[0xFD, 0x25], lh5801.cpu.u, me1: true);
        });

        test('LDA (ab)', () {
          testLDAab(lh5801, 12, <int>[0xA5]);
        });

        test('LDA #(ab)', () {
          testLDAab(lh5801, 16, <int>[0xFD, 0xA5], me1: true);
        });
      });

      group('LDE [page 33]', () {
        test('LDE X', () {
          testLDERReg(lh5801, <int>[0x47], lh5801.cpu.x);
        });

        test('LDE Y', () {
          testLDERReg(lh5801, <int>[0x57], lh5801.cpu.y);
        });

        test('LDE U', () {
          testLDERReg(lh5801, <int>[0x67], lh5801.cpu.u);
        });
      });

      group('LIN [page 34]', () {
        test('LIN X', () {
          testLINRReg(lh5801, <int>[0x45], lh5801.cpu.x);
        });

        test('LIN Y', () {
          testLINRReg(lh5801, <int>[0x55], lh5801.cpu.y);
        });

        test('LIN U', () {
          testLINRReg(lh5801, <int>[0x65], lh5801.cpu.u);
        });
      });

      group('LDI [page 34]', () {
        test('LDI A, i', () {
          testLDIAcc(lh5801);
        });

        test('LDI XL, i', () {
          testLDIReg(lh5801, <int>[0x4A], lh5801.cpu.x.lowRegister);
        });

        test('LDI XH, i', () {
          testLDIReg(lh5801, <int>[0x48], lh5801.cpu.x.highRegister);
        });

        test('LDI YL, i', () {
          testLDIReg(lh5801, <int>[0x5A], lh5801.cpu.y.lowRegister);
        });

        test('LDI YH, i', () {
          testLDIReg(lh5801, <int>[0x58], lh5801.cpu.y.highRegister);
        });

        test('LDI UL, i', () {
          testLDIReg(lh5801, <int>[0x6A], lh5801.cpu.u.lowRegister);
        });

        test('LDI UH, i', () {
          testLDIReg(lh5801, <int>[0x68], lh5801.cpu.u.highRegister);
        });

        test('LDI S, i, j', () {
          testLDISij(lh5801);
        });
      });

      group('LDX [page 35]', () {
        test('LDX S', () {
          testLDXReg(lh5801, <int>[0xFD, 0x48], lh5801.cpu.s);
        });

        test('LDX P', () {
          final List<int> opcodes = <int>[0xFD, 0x58];
          final int statusRegister = lh5801.cpu.t.statusRegister;

          memLoad(0x0020, opcodes);
          final int cycles = lh5801.step(0x0020);
          expect(cycles, equals(11));
          expect(lh5801.cpu.p.value, equals(0x0020 + opcodes.length));

          expect(lh5801.cpu.t.statusRegister, statusRegister);
        });
      });

      group('STA [page 35]', () {
        test('STA XL', () {
          testSTAReg(lh5801, <int>[0x0A], lh5801.cpu.x.lowRegister);
        });

        test('STA XH', () {
          testSTAReg(lh5801, <int>[0x08], lh5801.cpu.x.highRegister);
        });

        test('STA YL', () {
          testSTAReg(lh5801, <int>[0x1A], lh5801.cpu.y.lowRegister);
        });

        test('STA YH', () {
          testSTAReg(lh5801, <int>[0x18], lh5801.cpu.y.highRegister);
        });

        test('STA UL', () {
          testSTAReg(lh5801, <int>[0x2A], lh5801.cpu.u.lowRegister);
        });

        test('STA UH', () {
          testSTAReg(lh5801, <int>[0x28], lh5801.cpu.u.highRegister);
        });

        test('STA (X)', () {
          testSTARReg(lh5801, 6, <int>[0x0E], lh5801.cpu.x);
        });

        test('STA #(X)', () {
          testSTARReg(lh5801, 10, <int>[0xFD, 0x0E], lh5801.cpu.x, me1: true);
        });

        test('STA (Y)', () {
          testSTARReg(lh5801, 6, <int>[0x1E], lh5801.cpu.y);
        });

        test('STA #(Y)', () {
          testSTARReg(lh5801, 10, <int>[0xFD, 0x1E], lh5801.cpu.y, me1: true);
        });

        test('STA (U)', () {
          testSTARReg(lh5801, 6, <int>[0x2E], lh5801.cpu.u);
        });

        test('STA #(U)', () {
          testSTARReg(lh5801, 10, <int>[0xFD, 0x2E], lh5801.cpu.u, me1: true);
        });

        test('STA (ab)', () {
          testSTAab(lh5801, 12, <int>[0xAE]);
        });

        test('STA #(ab)', () {
          testSTAab(lh5801, 15, <int>[0xFD, 0xAE], me1: true);
        });
      });

      group('SDE [page 35]', () {
        test('SDE X', () {
          testSDERReg(lh5801, <int>[0x43], lh5801.cpu.x);
        });

        test('SDE Y', () {
          testSDERReg(lh5801, <int>[0x53], lh5801.cpu.y);
        });

        test('SDE U', () {
          testSDERReg(lh5801, <int>[0x63], lh5801.cpu.u);
        });
      });

      group('SIN [page 36]', () {
        test('SIN X', () {
          testSINRReg(lh5801, <int>[0x41], lh5801.cpu.x);
        });

        test('SIN Y', () {
          testSINRReg(lh5801, <int>[0x51], lh5801.cpu.y);
        });

        test('SIN U', () {
          testSINRReg(lh5801, <int>[0x61], lh5801.cpu.u);
        });
      });

      group('STX [page 36]', () {
        test('STX Y', () {
          testSTXReg(lh5801, <int>[0xFD, 0x5A], lh5801.cpu.y);
        });

        test('STX U', () {
          testSTXReg(lh5801, <int>[0xFD, 0x6A], lh5801.cpu.u);
        });

        test('STX S', () {
          testSTXReg(lh5801, <int>[0xFD, 0x4E], lh5801.cpu.s);
        });

        test('STX P', () {
          final List<int> opcodes = <int>[0xFD, 0x5E];
          final int statusRegister = lh5801.cpu.t.statusRegister;

          memLoad(0x0020, opcodes);
          lh5801.cpu.x.value = 0x1234;
          final int cycles = lh5801.step(0x0020);
          expect(cycles, equals(17));
          expect(lh5801.cpu.p.value, equals(0x1234));

          expect(lh5801.cpu.t.statusRegister, statusRegister);
        });
      });

      group('PSH [page 36]', () {
        test('PSH X', () {
          testPSHRReg(lh5801, <int>[0xFD, 0x88], lh5801.cpu.x);
        });

        test('PSH Y', () {
          testPSHRReg(lh5801, <int>[0xFD, 0x98], lh5801.cpu.y);
        });

        test('PSH U', () {
          testPSHRReg(lh5801, <int>[0xFD, 0xA8], lh5801.cpu.u);
        });

        test('PSH A', () {
          final List<int> opcodes = <int>[0xFD, 0xC8];
          final int statusRegister = lh5801.cpu.t.statusRegister;

          memLoad(0x0000, opcodes);
          lh5801.cpu.s.value = 0x46FF;
          lh5801.cpu.a.value = 0x3F;
          final int cycles = lh5801.step(0x0000);
          expect(cycles, equals(11));
          expect(lh5801.cpu.p.value, equals(opcodes.length));

          expect(lh5801.cpu.s.value, equals(0x46FF - 1));
          expect(lh5801.cpu.memRead(0x46FF), equals(0x3F));
          expect(lh5801.cpu.a.value, equals(0x3F));

          expect(lh5801.cpu.t.statusRegister, statusRegister);
        });
      });

      group('POP [page 37]', () {
        test('POP X', () {
          testPOPRReg(lh5801, <int>[0xFD, 0x0A], lh5801.cpu.x);
        });

        test('POP Y', () {
          testPOPRReg(lh5801, <int>[0xFD, 0x1A], lh5801.cpu.y);
        });

        test('POP U', () {
          testPOPRReg(lh5801, <int>[0xFD, 0x2A], lh5801.cpu.u);
        });

        test('POP A', () {
          testPOPA(lh5801);
        });
      });

      test('ATT [page 37]', () {
        testATT(lh5801);
      });

      test('TTA [page 38]', () {
        testTTA(lh5801);
      });
    });

    group('Block transfer and search instructions', () {
      group('TIN [page 38]', () {
        test('TIN', () {
          testTIN(lh5801);
        });
      });

      group('CIN [page 38]', () {
        test('CIN', () {
          testCIN(lh5801);
        });
      });
    });

    group('Rotate and shift instructions', () {
      group('ROL [page 39]', () {
        test('ROL', () {
          testROL(lh5801);
        });
      });

      group('ROR [page 39]', () {
        test('ROR', () {
          testROR(lh5801);
        });
      });

      group('SHL [page 39]', () {
        test('SHL', () {
          testSHL(lh5801);
        });
      });

      group('SHR [page 40]', () {
        test('SHR', () {
          testSHR(lh5801);
        });
      });

      group('DRL [page 40]', () {
        test('DRL (X)', () {
          testDRLRReg(lh5801, 12, <int>[0xD7]);
        });

        test('DRL #(X)', () {
          testDRLRReg(lh5801, 16, <int>[0xFD, 0xD7], me1: true);
        });
      });

      group('DRR [page 41]', () {
        test('DRR (X)', () {
          testDRRRReg(lh5801, 12, <int>[0xD3]);
        });

        test('DRR #(X)', () {
          testDRRRReg(lh5801, 16, <int>[0xFD, 0xD3], me1: true);
        });
      });

      group('AEX [page 41]', () {
        test('AEX', () {
          testAEX(lh5801);
        });
      });
    });

    group('CPU control instructions', () {
      group('SEC [page 42]', () {
        test('SEC', () {
          testRECSEC(lh5801, <int>[0xFB], expectedCarry: true);
        });
      });

      group('REC [page 42]', () {
        test('REC', () {
          testRECSEC(lh5801, <int>[0xF9]);
        });
      });

      group('CDV [page 42]', () {
        // test('CDV', () {
        //   ;
        // });
      });

      group('ATP [page 42]', () {
        test('ATP', () {
          testATP(lh5801);
        });
      });

      group('SPU [page 43]', () {
        test('SPU', () {
          testRPUSPU(lh5801, <int>[0xE1], expectedPU: true);
        });
      });

      group('RPU [page 43]', () {
        test('RPU', () {
          testRPUSPU(lh5801, <int>[0xE3]);
        });
      });

      group('SPV [page 43]', () {
        test('SPV', () {
          testRPVSPV(lh5801, <int>[0xA8], expectedPV: true);
        });
      });

      group('RPV [page 43]', () {
        test('RPV', () {
          testRPVSPV(lh5801, <int>[0xB8]);
        });
      });

      group('SDP [page 43]', () {
        test('SDP', () {
          testSDPRDP(lh5801, <int>[0xFD, 0xC1], expectedDisp: true);
        });
      });

      group('RDP [page 44]', () {
        test('RDP', () {
          testSDPRDP(lh5801, <int>[0xFD, 0xC0]);
        });
      });

      group('ITA [page 44]', () {
        test('ITA', () {
          testITA(lh5801);
        });
      });

      group('SIE [page 44]', () {
        test('SIE', () {
          testSIERIE(lh5801, <int>[0xFD, 0x81], expectedIE: true);
        });
      });

      group('RIE [page 44]', () {
        test('RIE', () {
          testSIERIE(lh5801, <int>[0xFD, 0xBE]);
        });
      });

      group('AM0 [page 44]', () {
        test('AM0', () {
          testAM(lh5801, <int>[0xFD, 0xCE], 0);
        });
      });

      group('AM1 [page 45]', () {
        test('AM1', () {
          testAM(lh5801, <int>[0xFD, 0xDE], 1);
        });
      });

      group('NOP [page 45]', () {
        test('NOP', () {
          testNOP(lh5801);
        });
      });

      group('HLT [page 45]', () {
        test('HLT', () {
          testHLT(lh5801);
        });
      });

      group('OFF [page 45]', () {
        test('OFF', () {
          testOFF(lh5801);
        });
      });
    });

    group('Jump instructions', () {
      group('JMP [page 45]', () {
        test('JMP i, j', () {
          testJMP(lh5801);
        });
      });

      group('BCH [page 46]', () {
        test('BCH +i', () {
          testBCH(lh5801, <int>[0x8E]);
        });

        test('BCH -i', () {
          testBCH(lh5801, <int>[0x9E], forward: false);
        });
      });

      group('BCS [page 46]', () {
        test('BCS +i', () {
          testBCS(lh5801, <int>[0x83]);
        });

        test('BCS -i', () {
          testBCS(lh5801, <int>[0x93], forward: false);
        });
      });

      group('BCR [page 47]', () {
        test('BCR +i', () {
          testBCR(lh5801, <int>[0x81]);
        });

        test('BCR -i', () {
          testBCR(lh5801, <int>[0x91], forward: false);
        });
      });

      group('BHS [page 47]', () {
        test('BHS +i', () {
          testBHS(lh5801, <int>[0x87]);
        });

        test('BHS -i', () {
          testBHS(lh5801, <int>[0x97], forward: false);
        });
      });

      group('BHR [page 47]', () {
        test('BHR +i', () {
          testBHR(lh5801, <int>[0x85]);
        });

        test('BHR -i', () {
          testBHR(lh5801, <int>[0x95], forward: false);
        });
      });

      group('BZS [page 47]', () {
        test('BZS +i', () {
          testBZS(lh5801, <int>[0x8B]);
        });

        test('BZS -i', () {
          testBZS(lh5801, <int>[0x9B], forward: false);
        });
      });

      group('BZR [page 47]', () {
        test('BZR +i', () {
          testBZR(lh5801, <int>[0x89]);
        });

        test('BZR -i', () {
          testBZR(lh5801, <int>[0x99], forward: false);
        });
      });

      group('BVS [page 47]', () {
        test('BVS +i', () {
          testBVS(lh5801, <int>[0x8F]);
        });

        test('BVS -i', () {
          testBVS(lh5801, <int>[0x9F], forward: false);
        });
      });

      group('BVR [page 48]', () {
        test('BVR +i', () {
          testBVR(lh5801, <int>[0x8D]);
        });

        test('BVR -i', () {
          testBVR(lh5801, <int>[0x9D], forward: false);
        });
      });

      group('LOP [page 48]', () {
        test('LOP i', () {
          testLOP(lh5801);
        });
      });
    });

    group('Subroutine jump instructions', () {
      group('SJP [page 49]', () {
        test('SJP i, j', () {
          testSJP(lh5801);
        });
      });

      group('VEJ [page 50]', () {
        for (int vectorId = 0xC0; vectorId <= 0xF6; vectorId += 2) {
          test('VEJ (${vectorId.toRadixString(16).padLeft(2, '0').toUpperCase()})', () {
            testVSJ(lh5801, 17, <int>[vectorId]);
          });
        }
      });

      group('VMJ [page 51]', () {
        for (int vectorId = 0xC0; vectorId <= 0xF6; vectorId += 2) {
          test('VMJ ${vectorId.toRadixString(16).padLeft(2, '0').toUpperCase()}', () {
            testVSJ(lh5801, 20, <int>[0xCD, vectorId]);
          });
        }
      });

      group('VCS [page 52]', () {
        test('VCS i', () {
          testVCS(lh5801, <int>[0xC3, 0xC0]);
        });
      });

      group('VCR [page 52]', () {
        test('VCR i', () {
          testVCR(lh5801, <int>[0xC1, 0xC0]);
        });
      });

      group('VHS [page 52]', () {
        test('VHS i', () {
          testVHS(lh5801, <int>[0xC7, 0xC2]);
        });
      });

      group('VHR [page 52]', () {
        test('VHR i', () {
          testVHR(lh5801, <int>[0xC5, 0xC0]);
        });
      });

      group('VZS [page 52]', () {
        test('VZS i', () {
          testVZS(lh5801, <int>[0xCB, 0xC4]);
        });
      });

      group('VZR [page 53]', () {
        test('VZR i', () {
          testVZR(lh5801, <int>[0xC9, 0xC0]);
        });
      });

      group('VVS [page 53]', () {
        test('VVS i', () {
          testVVS(lh5801, <int>[0xCF, 0xC4]);
        });
      });
    });

    group('Return instructions', () {
      group('RTN [page 53]', () {
        test('RTN', () {
          testRTN(lh5801);
        });
      });

      group('RTI [page 53]', () {
        test('RTI', () {
          testRTI(lh5801);
        });
      });
    });
  });
}
