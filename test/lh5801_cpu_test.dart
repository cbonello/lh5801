import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  final System system = System();

  group('LH5801CPU', () {
    setUp(() {
      system.reset();
    });

    group('Add, subtract and logical instructions', () {
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

        test('ADC (ab)', () {
          testADCab(system, 13, <int>[0xA3]);
        });

        test('ADC #(ab)', () {
          testADCab(system, 17, <int>[0xFD, 0xA3], me1: true);
        });
      });

      group('ADI [page 26]', () {
        test('ADI A, i', () {
          testADIAcc(system);
        });

        test('ADI (X), i', () {
          testADIRReg(system, 13, <int>[0x4F], system.cpu.x);
        });

        test('ADI #(X), i', () {
          testADIRReg(system, 17, <int>[0xFD, 0x4F], system.cpu.x, me1: true);
        });

        test('ADI (Y), i', () {
          testADIRReg(system, 13, <int>[0x5F], system.cpu.y);
        });

        test('ADI #(Y), i', () {
          testADIRReg(system, 17, <int>[0xFD, 0x5F], system.cpu.y, me1: true);
        });

        test('ADI (U), i', () {
          testADIRReg(system, 13, <int>[0x6F], system.cpu.u);
        });

        test('ADI #(U), i', () {
          testADIRReg(system, 17, <int>[0xFD, 0x6F], system.cpu.u, me1: true);
        });

        test('ADI (ab), i', () {
          testADIab(system, 19, <int>[0xEF]);
        });

        test('ADI #(ab), i', () {
          testADIab(system, 23, <int>[0xFD, 0xEF], me1: true);
        });
      });

      group('DCA [page 26]', () {
        test('DCA (X)', () {
          testDCARReg(system, 15, <int>[0x8C], system.cpu.x);
        });

        test('DCA #(X)', () {
          testDCARReg(system, 19, <int>[0xFD, 0x8C], system.cpu.x, me1: true);
        });

        test('DCA (Y)', () {
          testDCARReg(system, 15, <int>[0x9C], system.cpu.y);
        });

        test('DCA #(Y)', () {
          testDCARReg(system, 19, <int>[0xFD, 0x9C], system.cpu.y, me1: true);
        });

        test('DCA (U)', () {
          testDCARReg(system, 15, <int>[0xAC], system.cpu.u);
        });

        test('DCA #(U)', () {
          testDCARReg(system, 19, <int>[0xFD, 0xAC], system.cpu.u, me1: true);
        });
      });

      group('ADR [page 27]', () {
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
          testSBCReg(system, <int>[0x20], system.cpu.u.lowRegister);
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

        test('SBC (ab)', () {
          testSBCab(system, 13, <int>[0xA1]);
        });

        test('SBC #(ab)', () {
          testSBCab(system, 17, <int>[0xFD, 0xA1], me1: true);
        });
      });

      group('SBI [page 28]', () {
        test('SBI A, i', () {
          testSBIAcc(system);
        });
      });

      group('DCS [page 28]', () {
        test('DCS (X)', () {
          testDCSRReg(system, 13, <int>[0x0C], system.cpu.x);
        });

        test('DCS #(X)', () {
          testDCSRReg(system, 17, <int>[0xFD, 0x0C], system.cpu.x, me1: true);
        });

        test('DCS (Y)', () {
          testDCSRReg(system, 13, <int>[0x1C], system.cpu.y);
        });

        test('DCS #(Y)', () {
          testDCSRReg(system, 17, <int>[0xFD, 0x1C], system.cpu.y, me1: true);
        });

        test('DCS (U)', () {
          testDCSRReg(system, 13, <int>[0x2C], system.cpu.u);
        });

        test('DCS #(U)', () {
          testDCSRReg(system, 17, <int>[0xFD, 0x2C], system.cpu.u, me1: true);
        });
      });

      group('AND [page 29]', () {
        test('AND (X)', () {
          testANDRReg(system, 7, <int>[0x09], system.cpu.x);
        });

        test('AND #(X)', () {
          testANDRReg(system, 11, <int>[0xFD, 0x09], system.cpu.x, me1: true);
        });

        test('AND (Y)', () {
          testANDRReg(system, 7, <int>[0x19], system.cpu.y);
        });

        test('AND #(Y)', () {
          testANDRReg(system, 11, <int>[0xFD, 0x19], system.cpu.y, me1: true);
        });

        test('AND (U)', () {
          testANDRReg(system, 7, <int>[0x29], system.cpu.u);
        });

        test('AND #(U)', () {
          testANDRReg(system, 11, <int>[0xFD, 0x29], system.cpu.u, me1: true);
        });

        test('AND (ab)', () {
          testANDab(system, 13, <int>[0xA9]);
        });

        test('AND #(ab)', () {
          testANDab(system, 17, <int>[0xFD, 0xA9], me1: true);
        });
      });

      group('ANI [page 29]', () {
        test('ANI A, i', () {
          testANIAcc(system);
        });

        test('ANI (X), i', () {
          testANIRReg(system, 13, <int>[0x49], system.cpu.x);
        });

        test('ANI #(X), i', () {
          testANIRReg(system, 17, <int>[0xFD, 0x49], system.cpu.x, me1: true);
        });

        test('ANI (Y), i', () {
          testANIRReg(system, 13, <int>[0x59], system.cpu.y);
        });

        test('ANI #(Y), i', () {
          testANIRReg(system, 17, <int>[0xFD, 0x59], system.cpu.y, me1: true);
        });

        test('ANI (U), i', () {
          testANIRReg(system, 13, <int>[0x69], system.cpu.u);
        });

        test('ANI #(U), i', () {
          testANIRReg(system, 17, <int>[0xFD, 0x69], system.cpu.u, me1: true);
        });

        test('ANI (ab), i', () {
          testANIab(system, 19, <int>[0xE9]);
        });

        test('ANI #(ab), i', () {
          testANIab(system, 23, <int>[0xFD, 0xE9], me1: true);
        });
      });

      group('ORA [page 29]', () {
        test('ORA (X)', () {
          testORARReg(system, 7, <int>[0x0B], system.cpu.x);
        });

        test('ORA #(X)', () {
          testORARReg(system, 11, <int>[0xFD, 0x0B], system.cpu.x, me1: true);
        });

        test('ORA (Y)', () {
          testORARReg(system, 7, <int>[0x1B], system.cpu.y);
        });

        test('ORA #(Y)', () {
          testORARReg(system, 11, <int>[0xFD, 0x1B], system.cpu.y, me1: true);
        });

        test('ORA (U)', () {
          testORARReg(system, 7, <int>[0x2B], system.cpu.u);
        });

        test('ORA #(U)', () {
          testORARReg(system, 11, <int>[0xFD, 0x2B], system.cpu.u, me1: true);
        });

        test('ORA (ab)', () {
          testORAab(system, 13, <int>[0xAB]);
        });

        test('ORA #(ab)', () {
          testORAab(system, 17, <int>[0xFD, 0xAB], me1: true);
        });
      });

      group('ORI [page 30]', () {
        test('ORI A, i', () {
          testORIAcc(system);
        });

        test('ORI (X), i', () {
          testORIRReg(system, 13, <int>[0x4B], system.cpu.x);
        });

        test('ORI #(X), i', () {
          testORIRReg(system, 17, <int>[0xFD, 0x4B], system.cpu.x, me1: true);
        });

        test('ORI (Y), i', () {
          testORIRReg(system, 13, <int>[0x5B], system.cpu.y);
        });

        test('ORI #(Y), i', () {
          testORIRReg(system, 17, <int>[0xFD, 0x5B], system.cpu.y, me1: true);
        });

        test('ORI (U), i', () {
          testORIRReg(system, 13, <int>[0x6B], system.cpu.u);
        });

        test('ORI #(U), i', () {
          testORIRReg(system, 17, <int>[0xFD, 0x6B], system.cpu.u, me1: true);
        });

        test('ORI (ab), i', () {
          testORIab(system, 19, <int>[0xEB]);
        });

        test('ORI #(ab), i', () {
          testORIab(system, 23, <int>[0xFD, 0xEB], me1: true);
        });
      });

      group('EOR [page 30]', () {
        test('EOR (X)', () {
          testEORRReg(system, 7, <int>[0x0D], system.cpu.x);
        });

        test('EOR #(X)', () {
          testEORRReg(system, 11, <int>[0xFD, 0x0D], system.cpu.x, me1: true);
        });

        test('EOR (Y)', () {
          testEORRReg(system, 7, <int>[0x1D], system.cpu.y);
        });

        test('EOR #(Y)', () {
          testEORRReg(system, 11, <int>[0xFD, 0x1D], system.cpu.y, me1: true);
        });

        test('EOR (U)', () {
          testEORRReg(system, 7, <int>[0x2D], system.cpu.u);
        });

        test('EOR #(U)', () {
          testEORRReg(system, 11, <int>[0xFD, 0x2D], system.cpu.u, me1: true);
        });

        test('EOR (ab)', () {
          testEORab(system, 13, <int>[0xAD]);
        });

        test('EOR #(ab)', () {
          testEORab(system, 17, <int>[0xFD, 0xAD], me1: true);
        });
      });

      group('EAI [page 30]', () {
        test('EAI i', () {
          testEAI(system);
        });
      });

      group('INC [page 30]', () {
        test('INC A', () {
          testIncReg8(
            system,
            5,
            <int>[0xDD],
            system.cpu.a,
          );
        });

        test('INC XL', () {
          testIncReg8(
            system,
            5,
            <int>[0x40],
            system.cpu.x.lowRegister,
          );
        });

        test('INC XH', () {
          testIncReg8(
            system,
            9,
            <int>[0xFD, 0x40],
            system.cpu.x.highRegister,
          );
        });

        test('INC YL', () {
          testIncReg8(
            system,
            5,
            <int>[0x50],
            system.cpu.y.lowRegister,
          );
        });

        test('INC YH', () {
          testIncReg8(
            system,
            9,
            <int>[0xFD, 0x50],
            system.cpu.y.highRegister,
          );
        });

        test('INC UL', () {
          testIncReg8(
            system,
            5,
            <int>[0x60],
            system.cpu.u.lowRegister,
          );
        });

        test('INC UH', () {
          testIncReg8(
            system,
            9,
            <int>[0xFD, 0x60],
            system.cpu.u.highRegister,
          );
        });

        test('INC X', () {
          testIncReg16(
            system,
            5,
            <int>[0x44],
            system.cpu.x,
          );
        });

        test('INC Y', () {
          testIncReg16(
            system,
            5,
            <int>[0x54],
            system.cpu.y,
          );
        });

        test('INC U', () {
          testIncReg16(
            system,
            5,
            <int>[0x64],
            system.cpu.u,
          );
        });
      });

      group('DEC [page 31]', () {
        test('DEC A', () {
          testDecReg8(
            system,
            5,
            <int>[0xDF],
            system.cpu.a,
          );
        });

        test('DEC XL', () {
          testDecReg8(
            system,
            5,
            <int>[0x42],
            system.cpu.x.lowRegister,
          );
        });

        test('DEC XH', () {
          testDecReg8(
            system,
            9,
            <int>[0xFD, 0x42],
            system.cpu.x.highRegister,
          );
        });

        test('DEC YL', () {
          testDecReg8(
            system,
            5,
            <int>[0x52],
            system.cpu.y.lowRegister,
          );
        });

        test('DEC YH', () {
          testDecReg8(
            system,
            9,
            <int>[0xFD, 0x52],
            system.cpu.y.highRegister,
          );
        });

        test('DEC UL', () {
          testDecReg8(
            system,
            5,
            <int>[0x62],
            system.cpu.u.lowRegister,
          );
        });

        test('DEC UH', () {
          testDecReg8(
            system,
            9,
            <int>[0xFD, 0x62],
            system.cpu.u.highRegister,
          );
        });

        test('DEC X', () {
          testDecReg16(
            system,
            5,
            <int>[0x46],
            system.cpu.x,
          );
        });

        test('DEC Y', () {
          testDecReg16(
            system,
            5,
            <int>[0x56],
            system.cpu.y,
          );
        });

        test('DEC U', () {
          testDecReg16(
            system,
            5,
            <int>[0x66],
            system.cpu.u,
          );
        });
      });
    });

    group('Compare and bit test instructions', () {
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
          testCPARReg(system, 7, <int>[0x07], system.cpu.x);
        });

        test('CPA #(X)', () {
          testCPARReg(system, 11, <int>[0xFD, 0x07], system.cpu.x, me1: true);
        });

        test('CPA (Y)', () {
          testCPARReg(system, 7, <int>[0x17], system.cpu.y);
        });

        test('CPA #(Y)', () {
          testCPARReg(system, 11, <int>[0xFD, 0x17], system.cpu.y, me1: true);
        });

        test('CPA (U)', () {
          testCPARReg(system, 7, <int>[0x27], system.cpu.u);
        });

        test('CPA #(U)', () {
          testCPARReg(system, 11, <int>[0xFD, 0x27], system.cpu.u, me1: true);
        });

        test('CPA (ab)', () {
          testCPAab(system, 13, <int>[0xA7]);
        });

        test('CPA #(ab)', () {
          testCPAab(system, 17, <int>[0xFD, 0xA7], me1: true);
        });
      });

      group('CPI [page 32]', () {
        test('CPI XL, i', () {
          testCPIReg(system, <int>[0x4E], system.cpu.x.lowRegister);
        });

        test('CPI XH, i', () {
          testCPIReg(system, <int>[0x4C], system.cpu.x.highRegister);
        });

        test('CPI YL, i', () {
          testCPIReg(system, <int>[0x5E], system.cpu.y.lowRegister);
        });

        test('CPI YH, i', () {
          testCPIReg(system, <int>[0x5C], system.cpu.y.highRegister);
        });

        test('CPI UL, i', () {
          testCPIReg(system, <int>[0x6E], system.cpu.u.lowRegister);
        });

        test('CPI UH, i', () {
          testCPIReg(system, <int>[0x6C], system.cpu.u.highRegister);
        });

        test('CPI A, i', () {
          testCPIReg(system, <int>[0xB7], system.cpu.a);
        });
      });

      group('BIT [page 32]', () {
        test('BIT (X)', () {
          testBITRReg(system, 7, <int>[0x0F], system.cpu.x);
        });

        test('BIT #(X)', () {
          testBITRReg(system, 11, <int>[0xFD, 0x0F], system.cpu.x, me1: true);
        });

        test('BIT (Y)', () {
          testBITRReg(system, 7, <int>[0x1F], system.cpu.y);
        });

        test('BIT #(Y)', () {
          testBITRReg(system, 11, <int>[0xFD, 0x1F], system.cpu.y, me1: true);
        });

        test('BIT (U)', () {
          testBITRReg(system, 7, <int>[0x2F], system.cpu.u);
        });

        test('BIT #(U)', () {
          testBITRReg(system, 11, <int>[0xFD, 0x2F], system.cpu.u, me1: true);
        });

        test('BIT (ab)', () {
          testBITab(system, 13, <int>[0xAF]);
        });

        test('BIT #(ab)', () {
          testBITab(system, 17, <int>[0xFD, 0xAF], me1: true);
        });
      });

      group('BII [page 32]', () {
        test('BII A, i', () {
          testBIIAcc(system);
        });

        test('BII (X), i', () {
          testBIIRReg(system, 10, <int>[0x4D], system.cpu.x);
        });

        test('BII #(X), i', () {
          testBIIRReg(system, 14, <int>[0xFD, 0x4D], system.cpu.x, me1: true);
        });

        test('BII (Y), i', () {
          testBIIRReg(system, 10, <int>[0x5D], system.cpu.y);
        });

        test('BII #(Y), i', () {
          testBIIRReg(system, 14, <int>[0xFD, 0x5D], system.cpu.y, me1: true);
        });

        test('BII (U), i', () {
          testBIIRReg(system, 10, <int>[0x6D], system.cpu.u);
        });

        test('BII #(U), i', () {
          testBIIRReg(system, 14, <int>[0xFD, 0x6D], system.cpu.u, me1: true);
        });

        test('BII (ab), i', () {
          testBIIab(system, 16, <int>[0xED]);
        });

        test('BII #(ab), i', () {
          testBIIab(system, 20, <int>[0xFD, 0xED], me1: true);
        });
      });
    });

    group('Transfer and search instructions', () {
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

        test('LDA (ab)', () {
          testLDAab(system, 12, <int>[0xA5]);
        });

        test('LDA #(ab)', () {
          testLDAab(system, 16, <int>[0xFD, 0xA5], me1: true);
        });
      });

      group('LDE [page 33]', () {
        test('LDE X', () {
          testLDERReg(system, <int>[0x47], system.cpu.x);
        });

        test('LDE Y', () {
          testLDERReg(system, <int>[0x57], system.cpu.y);
        });

        test('LDE U', () {
          testLDERReg(system, <int>[0x67], system.cpu.u);
        });
      });

      group('LIN [page 34]', () {
        test('LIN X', () {
          testLINRReg(system, <int>[0x45], system.cpu.x);
        });

        test('LIN Y', () {
          testLINRReg(system, <int>[0x55], system.cpu.y);
        });

        test('LIN U', () {
          testLINRReg(system, <int>[0x65], system.cpu.u);
        });
      });

      group('LDI [page 34]', () {
        test('LDI A, i', () {
          testLDIAcc(system);
        });

        test('LDI XL, i', () {
          testLDIReg(system, <int>[0x4A], system.cpu.x.lowRegister);
        });

        test('LDI XH, i', () {
          testLDIReg(system, <int>[0x48], system.cpu.x.highRegister);
        });

        test('LDI YL, i', () {
          testLDIReg(system, <int>[0x5A], system.cpu.y.lowRegister);
        });

        test('LDI YH, i', () {
          testLDIReg(system, <int>[0x58], system.cpu.y.highRegister);
        });

        test('LDI UL, i', () {
          testLDIReg(system, <int>[0x6A], system.cpu.u.lowRegister);
        });

        test('LDI UH, i', () {
          testLDIReg(system, <int>[0x68], system.cpu.u.highRegister);
        });

        test('LDI S, i, j', () {
          testLDISij(system);
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

        test('STA (ab)', () {
          testSTAab(system, 12, <int>[0xAE]);
        });

        test('STA #(ab)', () {
          testSTAab(system, 15, <int>[0xFD, 0xAE], me1: true);
        });
      });

      group('SDE [page 35]', () {
        test('SDE X', () {
          testSDERReg(system, <int>[0x43], system.cpu.x);
        });

        test('SDE Y', () {
          testSDERReg(system, <int>[0x53], system.cpu.y);
        });

        test('SDE U', () {
          testSDERReg(system, <int>[0x63], system.cpu.u);
        });
      });

      group('SIN [page 36]', () {
        test('SIN X', () {
          testSINRReg(system, <int>[0x41], system.cpu.x);
        });

        test('SIN Y', () {
          testSINRReg(system, <int>[0x51], system.cpu.y);
        });

        test('SIN U', () {
          testSINRReg(system, <int>[0x61], system.cpu.u);
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

      test('ATT [page 37]', () {
        testATT(system);
      });

      test('TTA [page 38]', () {
        testTTA(system);
      });
    });

    group('Block transfer and search instructions', () {
      group('TIN [page 38]', () {
        test('TIN', () {
          testTIN(system);
        });
      });

      group('CIN [page 38]', () {
        test('CIN', () {
          testCIN(system);
        });
      });
    });

    group('Rotate and shift instructions', () {
      group('ROL [page 39]', () {
        test('ROL', () {
          testROL(system);
        });
      });

      group('ROR [page 39]', () {
        test('ROR', () {
          testROR(system);
        });
      });

      group('SHL [page 39]', () {
        test('SHL', () {
          testSHL(system);
        });
      });

      group('SHR [page 40]', () {
        test('SHR', () {
          testSHR(system);
        });
      });

      group('DRL [page 40]', () {
        test('DRL (X)', () {
          testDRLRReg(system, 12, <int>[0xD7]);
        });

        test('DRL #(X)', () {
          testDRLRReg(system, 16, <int>[0xFD, 0xD7], me1: true);
        });
      });

      group('DRR [page 41]', () {
        test('DRR (X)', () {
          testDRRRReg(system, 12, <int>[0xD3]);
        });

        test('DRR #(X)', () {
          testDRRRReg(system, 16, <int>[0xFD, 0xD3], me1: true);
        });
      });

      group('AEX [page 41]', () {
        test('AEX', () {
          testAEX(system);
        });
      });
    });

    group('CPU control instructions', () {
      group('SEC [page 42]', () {
        test('SEC', () {
          testRECSEC(system, <int>[0xFB], expectedCarry: true);
        });
      });

      group('REC [page 42]', () {
        test('REC', () {
          testRECSEC(system, <int>[0xF9]);
        });
      });

      group('CDV [page 42]', () {
        test('CDV', () {
          ;
        });
      });

      group('ATP [page 42]', () {
        test('ATP', () {
          testATP(system);
        });
      });

      group('SPU [page 43]', () {
        test('SPU', () {
          testRPUSPU(system, <int>[0xE1], expectedPU: true);
        });
      });

      group('RPU [page 43]', () {
        test('RPU', () {
          testRPUSPU(system, <int>[0xE3]);
        });
      });

      group('SPV [page 43]', () {
        test('SPV', () {
          testRPVSPV(system, <int>[0xA8], expectedPV: true);
        });
      });

      group('RPV [page 43]', () {
        test('RPV', () {
          testRPVSPV(system, <int>[0xB8]);
        });
      });

      group('SDP [page 43]', () {
        test('SDP', () {
          testSDPRDP(system, <int>[0xFD, 0xC1], expectedDisp: true);
        });
      });

      group('RDP [page 44]', () {
        test('RDP', () {
          testSDPRDP(system, <int>[0xFD, 0xC0]);
        });
      });

      group('ITA [page 44]', () {
        test('ITA', () {
          testITA(system);
        });
      });

      group('SIE [page 44]', () {
        test('SIE', () {
          testSIERIE(system, <int>[0xFD, 0x81], expectedIE: true);
        });
      });

      group('RIE [page 44]', () {
        test('RIE', () {
          testSIERIE(system, <int>[0xFD, 0xBE]);
        });
      });

      group('AM0 [page 44]', () {
        test('AM0', () {
          ;
        });
      });

      group('AM1 [page 45]', () {
        test('AM1', () {
          ;
        });
      });

      group('NOP [page 45]', () {
        test('NOP', () {
          testNOP(system);
        });
      });

      group('HLT [page 45]', () {
        test('HLT', () {
          testHLT(system);
        });
      });

      group('OFF [page 45]', () {
        test('OFF', () {
          testOFF(system);
        });
      });
    });

    group('Jump instructions', () {
      group('JMP [page 45]', () {
        test('JMP i, j', () {
          testJMP(system);
        });
      });

      group('BCH [page 46]', () {
        test('BCH +i', () {
          testBCH(system, <int>[0x8E]);
        });

        test('BCH -i', () {
          testBCH(system, <int>[0x9E], forward: false);
        });
      });

      group('BCS [page 46]', () {
        test('BCS +i', () {
          testBCS(system, <int>[0x83]);
        });

        test('BCS -i', () {
          testBCS(system, <int>[0x93], forward: false);
        });
      });

      group('BCR [page 47]', () {
        test('BCR +i', () {
          testBCR(system, <int>[0x81]);
        });

        test('BCR -i', () {
          testBCR(system, <int>[0x91], forward: false);
        });
      });

      group('BHS [page 47]', () {
        test('BHS +i', () {
          testBHS(system, <int>[0x87]);
        });

        test('BHS -i', () {
          testBHS(system, <int>[0x97], forward: false);
        });
      });

      group('BHR [page 47]', () {
        test('BHR +i', () {
          testBHR(system, <int>[0x85]);
        });

        test('BHR -i', () {
          testBHR(system, <int>[0x95], forward: false);
        });
      });

      group('BZS [page 47]', () {
        test('BZS +i', () {
          testBZS(system, <int>[0x8B]);
        });

        test('BZS -i', () {
          testBZS(system, <int>[0x9B], forward: false);
        });
      });

      group('BZR [page 47]', () {
        test('BZR +i', () {
          testBZR(system, <int>[0x89]);
        });

        test('BZR -i', () {
          testBZR(system, <int>[0x99], forward: false);
        });
      });

      group('BVS [page 47]', () {
        test('BVS +i', () {
          testBVS(system, <int>[0x8F]);
        });

        test('BVS -i', () {
          testBVS(system, <int>[0x9F], forward: false);
        });
      });

      group('BVR [page 48]', () {
        test('BVR +i', () {
          testBVR(system, <int>[0x8D]);
        });

        test('BVR -i', () {
          testBVR(system, <int>[0x9D], forward: false);
        });
      });

      group('LOP [page 48]', () {
        test('LOP i', () {
          testLOP(system);
        });
      });
    });

    group('Subroutine jump instructions', () {
      group('SJP [page 49]', () {
        test('SJP i, j', () {
          testSJP(system);
        });
      });

      group('VEJ [page 50]', () {
        for (int vectorId = 0xC0; vectorId <= 0xF6; vectorId += 2) {
          test('VEJ (${vectorId.toRadixString(16).padLeft(2, '0').toUpperCase()})', () {
            testVSJ(system, 17, <int>[vectorId]);
          });
        }
      });

      group('VMJ [page 51]', () {
        for (int vectorId = 0xC0; vectorId <= 0xF6; vectorId += 2) {
          test('VMJ ${vectorId.toRadixString(16).padLeft(2, '0').toUpperCase()}', () {
            testVSJ(system, 20, <int>[0xCD, vectorId]);
          });
        }
      });

      group('VCS [page 52]', () {
        test('VCS i', () {
          testVCS(system, <int>[0xC3, 0xC0]);
        });
      });

      group('VCR [page 52]', () {
        test('VCR i', () {
          testVCR(system, <int>[0xC1, 0xC0]);
        });
      });

      group('VHS [page 52]', () {
        test('VHS i', () {
          testVHS(system, <int>[0xC7, 0xC2]);
        });
      });

      group('VHR [page 52]', () {
        test('VHR i', () {
          testVHR(system, <int>[0xC5, 0xC0]);
        });
      });

      group('VZS [page 52]', () {
        test('VZS i', () {
          testVZS(system, <int>[0xCB, 0xC4]);
        });
      });

      group('VZR [page 53]', () {
        test('VZR i', () {
          testVZR(system, <int>[0xC9, 0xC0]);
        });
      });

      group('VVS [page 53]', () {
        test('VVS i', () {
          testVVS(system, <int>[0xCF, 0xC4]);
        });
      });
    });

    group('Return instructions', () {
      group('RTN [page 53]', () {
        test('RTN', () {
          testRTN(system);
        });
      });

      group('RTI [page 53]', () {
        test('RTI', () {
          testRTI(system);
        });
      });
    });
  });
}
