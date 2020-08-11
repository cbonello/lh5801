import 'package:test/test.dart';

import 'package:lh5801/lh5801.dart';

import 'helpers.dart';

void main() {
  group('LH5801Emulator', () {
    test('should raise an exception for invalid arguments', () {
      expect(
        () => LH5801Emulator(
          clockFrequency: 1300000,
          memRead: null,
          memWrite: memWrite,
        ),
        throwsA(const TypeMatcher<AssertionError>()),
      );

      expect(
        () => LH5801Emulator(
          clockFrequency: 1300000,
          memRead: memRead,
          memWrite: null,
        ),
        throwsA(const TypeMatcher<AssertionError>()),
      );
    });

    test('should be initialized properly', () {
      final LH5801Emulator emulator = LH5801Emulator(
        clockFrequency: 1300000,
        memRead: memRead,
        memWrite: memWrite,
      );

      expect(emulator.cpu.runtimeType, equals(LH5801CPU));
    });

    test('should be serialized/deserialized successfully', () {
      final LH5801Emulator emulator1 = LH5801Emulator(
        clockFrequency: 1300000,
        memRead: memRead,
        memWrite: memWrite,
      );
      final LH5801Emulator emulator2 = LH5801Emulator.fromJson(
        clockFrequency: 1300000,
        memRead: memRead,
        memWrite: memWrite,
        json: emulator1.toJson(),
      );

      expect(emulator1, equals(emulator2));
      expect(emulator1.hashCode, equals(emulator2.hashCode));
    });

    group('CPU', () {
      LH5801Emulator emulator;

      setUp(() {
        emulator = LH5801Emulator(
          clockFrequency: 1300000,
          memRead: memRead,
          memWrite: memWrite,
        );
      });

      group('Interruptions', () {
        test('Reset pin', () {
          testResetPin(emulator);
        });

        test('IR0', () {
          testIR0(emulator);
        });

        test('IR1', () {
          testIR1(emulator);
        });

        test('IR2', () {
          testIR2(emulator);
        });
      });

      group('Add, subtract and logical instructions', () {
        group('ADC [page 25]', () {
          test('ADC XL', () {
            testADCReg(emulator, <int>[0x02], emulator.cpu.x.lowRegister);
          });

          test('ADC XH', () {
            testADCReg(emulator, <int>[0x82], emulator.cpu.x.highRegister);
          });

          test('ADC YL', () {
            testADCReg(emulator, <int>[0x12], emulator.cpu.y.lowRegister);
          });

          test('ADC YH', () {
            testADCReg(emulator, <int>[0x92], emulator.cpu.y.highRegister);
          });

          test('ADC UL', () {
            testADCReg(emulator, <int>[0x22], emulator.cpu.u.lowRegister);
          });

          test('ADC UH', () {
            testADCReg(emulator, <int>[0xA2], emulator.cpu.u.highRegister);
          });

          test('ADC (X)', () {
            testADCRReg(emulator, 7, <int>[0x03], emulator.cpu.x);
          });

          test('ADC #(X)', () {
            testADCRReg(emulator, 11, <int>[0xFD, 0x03], emulator.cpu.x, me1: true);
          });

          test('ADC (Y)', () {
            testADCRReg(emulator, 7, <int>[0x13], emulator.cpu.y);
          });

          test('ADC #(Y)', () {
            testADCRReg(emulator, 11, <int>[0xFD, 0x13], emulator.cpu.y, me1: true);
          });

          test('ADC (U)', () {
            testADCRReg(emulator, 7, <int>[0x23], emulator.cpu.u);
          });

          test('ADC #(U)', () {
            testADCRReg(emulator, 11, <int>[0xFD, 0x23], emulator.cpu.u, me1: true);
          });

          test('ADC (ab)', () {
            testADCab(emulator, 13, <int>[0xA3]);
          });

          test('ADC #(ab)', () {
            testADCab(emulator, 17, <int>[0xFD, 0xA3], me1: true);
          });
        });

        group('ADI [page 26]', () {
          test('ADI A, i', () {
            testADIAcc(emulator);
          });

          test('ADI (X), i', () {
            testADIRReg(emulator, 13, <int>[0x4F], emulator.cpu.x);
          });

          test('ADI #(X), i', () {
            testADIRReg(emulator, 17, <int>[0xFD, 0x4F], emulator.cpu.x, me1: true);
          });

          test('ADI (Y), i', () {
            testADIRReg(emulator, 13, <int>[0x5F], emulator.cpu.y);
          });

          test('ADI #(Y), i', () {
            testADIRReg(emulator, 17, <int>[0xFD, 0x5F], emulator.cpu.y, me1: true);
          });

          test('ADI (U), i', () {
            testADIRReg(emulator, 13, <int>[0x6F], emulator.cpu.u);
          });

          test('ADI #(U), i', () {
            testADIRReg(emulator, 17, <int>[0xFD, 0x6F], emulator.cpu.u, me1: true);
          });

          test('ADI (ab), i', () {
            testADIab(emulator, 19, <int>[0xEF]);
          });

          test('ADI #(ab), i', () {
            testADIab(emulator, 23, <int>[0xFD, 0xEF], me1: true);
          });
        });

        group('DCA [page 26]', () {
          test('DCA (X)', () {
            testDCARReg(emulator, 15, <int>[0x8C], emulator.cpu.x);
          });

          test('DCA #(X)', () {
            testDCARReg(emulator, 19, <int>[0xFD, 0x8C], emulator.cpu.x, me1: true);
          });

          test('DCA (Y)', () {
            testDCARReg(emulator, 15, <int>[0x9C], emulator.cpu.y);
          });

          test('DCA #(Y)', () {
            testDCARReg(emulator, 19, <int>[0xFD, 0x9C], emulator.cpu.y, me1: true);
          });

          test('DCA (U)', () {
            testDCARReg(emulator, 15, <int>[0xAC], emulator.cpu.u);
          });

          test('DCA #(U)', () {
            testDCARReg(emulator, 19, <int>[0xFD, 0xAC], emulator.cpu.u, me1: true);
          });
        });

        group('ADR [page 27]', () {
          test('ADR X', () {
            testADRRReg(emulator, <int>[0xFD, 0xCA], emulator.cpu.x);
          });

          test('ADR Y', () {
            testADRRReg(emulator, <int>[0xFD, 0xDA], emulator.cpu.y);
          });

          test('ADR U', () {
            testADRRReg(emulator, <int>[0xFD, 0xEA], emulator.cpu.u);
          });
        });

        group('SBC [page 27]', () {
          test('SBC XL', () {
            testSBCReg(emulator, <int>[0x00], emulator.cpu.x.lowRegister);
          });

          test('SBC XH', () {
            testSBCReg(emulator, <int>[0x80], emulator.cpu.x.highRegister);
          });

          test('SBC YL', () {
            testSBCReg(emulator, <int>[0x10], emulator.cpu.y.lowRegister);
          });

          test('SBC YH', () {
            testSBCReg(emulator, <int>[0x90], emulator.cpu.y.highRegister);
          });

          test('SBC UL', () {
            testSBCReg(emulator, <int>[0x20], emulator.cpu.u.lowRegister);
          });

          test('SBC UH', () {
            testSBCReg(emulator, <int>[0xA0], emulator.cpu.u.highRegister);
          });

          test('SBC (X)', () {
            testSBCRReg(emulator, 7, <int>[0x01], emulator.cpu.x);
          });

          test('SBC #(X)', () {
            testSBCRReg(emulator, 11, <int>[0xFD, 0x01], emulator.cpu.x, me1: true);
          });

          test('SBC (Y)', () {
            testSBCRReg(emulator, 7, <int>[0x11], emulator.cpu.y);
          });

          test('SBC #(Y)', () {
            testSBCRReg(emulator, 11, <int>[0xFD, 0x11], emulator.cpu.y, me1: true);
          });

          test('SBC (U)', () {
            testSBCRReg(emulator, 7, <int>[0x21], emulator.cpu.u);
          });

          test('SBC #(U)', () {
            testSBCRReg(emulator, 11, <int>[0xFD, 0x21], emulator.cpu.u, me1: true);
          });

          test('SBC (ab)', () {
            testSBCab(emulator, 13, <int>[0xA1]);
          });

          test('SBC #(ab)', () {
            testSBCab(emulator, 17, <int>[0xFD, 0xA1], me1: true);
          });
        });

        group('SBI [page 28]', () {
          test('SBI A, i', () {
            testSBIAcc(emulator);
          });
        });

        group('DCS [page 28]', () {
          test('DCS (X)', () {
            testDCSRReg(emulator, 13, <int>[0x0C], emulator.cpu.x);
          });

          test('DCS #(X)', () {
            testDCSRReg(emulator, 17, <int>[0xFD, 0x0C], emulator.cpu.x, me1: true);
          });

          test('DCS (Y)', () {
            testDCSRReg(emulator, 13, <int>[0x1C], emulator.cpu.y);
          });

          test('DCS #(Y)', () {
            testDCSRReg(emulator, 17, <int>[0xFD, 0x1C], emulator.cpu.y, me1: true);
          });

          test('DCS (U)', () {
            testDCSRReg(emulator, 13, <int>[0x2C], emulator.cpu.u);
          });

          test('DCS #(U)', () {
            testDCSRReg(emulator, 17, <int>[0xFD, 0x2C], emulator.cpu.u, me1: true);
          });
        });

        group('AND [page 29]', () {
          test('AND (X)', () {
            testANDRReg(emulator, 7, <int>[0x09], emulator.cpu.x);
          });

          test('AND #(X)', () {
            testANDRReg(emulator, 11, <int>[0xFD, 0x09], emulator.cpu.x, me1: true);
          });

          test('AND (Y)', () {
            testANDRReg(emulator, 7, <int>[0x19], emulator.cpu.y);
          });

          test('AND #(Y)', () {
            testANDRReg(emulator, 11, <int>[0xFD, 0x19], emulator.cpu.y, me1: true);
          });

          test('AND (U)', () {
            testANDRReg(emulator, 7, <int>[0x29], emulator.cpu.u);
          });

          test('AND #(U)', () {
            testANDRReg(emulator, 11, <int>[0xFD, 0x29], emulator.cpu.u, me1: true);
          });

          test('AND (ab)', () {
            testANDab(emulator, 13, <int>[0xA9]);
          });

          test('AND #(ab)', () {
            testANDab(emulator, 17, <int>[0xFD, 0xA9], me1: true);
          });
        });

        group('ANI [page 29]', () {
          test('ANI A, i', () {
            testANIAcc(emulator);
          });

          test('ANI (X), i', () {
            testANIRReg(emulator, 13, <int>[0x49], emulator.cpu.x);
          });

          test('ANI #(X), i', () {
            testANIRReg(emulator, 17, <int>[0xFD, 0x49], emulator.cpu.x, me1: true);
          });

          test('ANI (Y), i', () {
            testANIRReg(emulator, 13, <int>[0x59], emulator.cpu.y);
          });

          test('ANI #(Y), i', () {
            testANIRReg(emulator, 17, <int>[0xFD, 0x59], emulator.cpu.y, me1: true);
          });

          test('ANI (U), i', () {
            testANIRReg(emulator, 13, <int>[0x69], emulator.cpu.u);
          });

          test('ANI #(U), i', () {
            testANIRReg(emulator, 17, <int>[0xFD, 0x69], emulator.cpu.u, me1: true);
          });

          test('ANI (ab), i', () {
            testANIab(emulator, 19, <int>[0xE9]);
          });

          test('ANI #(ab), i', () {
            testANIab(emulator, 23, <int>[0xFD, 0xE9], me1: true);
          });
        });

        group('ORA [page 29]', () {
          test('ORA (X)', () {
            testORARReg(emulator, 7, <int>[0x0B], emulator.cpu.x);
          });

          test('ORA #(X)', () {
            testORARReg(emulator, 11, <int>[0xFD, 0x0B], emulator.cpu.x, me1: true);
          });

          test('ORA (Y)', () {
            testORARReg(emulator, 7, <int>[0x1B], emulator.cpu.y);
          });

          test('ORA #(Y)', () {
            testORARReg(emulator, 11, <int>[0xFD, 0x1B], emulator.cpu.y, me1: true);
          });

          test('ORA (U)', () {
            testORARReg(emulator, 7, <int>[0x2B], emulator.cpu.u);
          });

          test('ORA #(U)', () {
            testORARReg(emulator, 11, <int>[0xFD, 0x2B], emulator.cpu.u, me1: true);
          });

          test('ORA (ab)', () {
            testORAab(emulator, 13, <int>[0xAB]);
          });

          test('ORA #(ab)', () {
            testORAab(emulator, 17, <int>[0xFD, 0xAB], me1: true);
          });
        });

        group('ORI [page 30]', () {
          test('ORI A, i', () {
            testORIAcc(emulator);
          });

          test('ORI (X), i', () {
            testORIRReg(emulator, 13, <int>[0x4B], emulator.cpu.x);
          });

          test('ORI #(X), i', () {
            testORIRReg(emulator, 17, <int>[0xFD, 0x4B], emulator.cpu.x, me1: true);
          });

          test('ORI (Y), i', () {
            testORIRReg(emulator, 13, <int>[0x5B], emulator.cpu.y);
          });

          test('ORI #(Y), i', () {
            testORIRReg(emulator, 17, <int>[0xFD, 0x5B], emulator.cpu.y, me1: true);
          });

          test('ORI (U), i', () {
            testORIRReg(emulator, 13, <int>[0x6B], emulator.cpu.u);
          });

          test('ORI #(U), i', () {
            testORIRReg(emulator, 17, <int>[0xFD, 0x6B], emulator.cpu.u, me1: true);
          });

          test('ORI (ab), i', () {
            testORIab(emulator, 19, <int>[0xEB]);
          });

          test('ORI #(ab), i', () {
            testORIab(emulator, 23, <int>[0xFD, 0xEB], me1: true);
          });
        });

        group('EOR [page 30]', () {
          test('EOR (X)', () {
            testEORRReg(emulator, 7, <int>[0x0D], emulator.cpu.x);
          });

          test('EOR #(X)', () {
            testEORRReg(emulator, 11, <int>[0xFD, 0x0D], emulator.cpu.x, me1: true);
          });

          test('EOR (Y)', () {
            testEORRReg(emulator, 7, <int>[0x1D], emulator.cpu.y);
          });

          test('EOR #(Y)', () {
            testEORRReg(emulator, 11, <int>[0xFD, 0x1D], emulator.cpu.y, me1: true);
          });

          test('EOR (U)', () {
            testEORRReg(emulator, 7, <int>[0x2D], emulator.cpu.u);
          });

          test('EOR #(U)', () {
            testEORRReg(emulator, 11, <int>[0xFD, 0x2D], emulator.cpu.u, me1: true);
          });

          test('EOR (ab)', () {
            testEORab(emulator, 13, <int>[0xAD]);
          });

          test('EOR #(ab)', () {
            testEORab(emulator, 17, <int>[0xFD, 0xAD], me1: true);
          });
        });

        group('EAI [page 30]', () {
          test('EAI i', () {
            testEAI(emulator);
          });
        });

        group('INC [page 30]', () {
          test('INC A', () {
            testIncReg8(
              emulator,
              5,
              <int>[0xDD],
              emulator.cpu.a,
            );
          });

          test('INC XL', () {
            testIncReg8(
              emulator,
              5,
              <int>[0x40],
              emulator.cpu.x.lowRegister,
            );
          });

          test('INC XH', () {
            testIncReg8(
              emulator,
              9,
              <int>[0xFD, 0x40],
              emulator.cpu.x.highRegister,
            );
          });

          test('INC YL', () {
            testIncReg8(
              emulator,
              5,
              <int>[0x50],
              emulator.cpu.y.lowRegister,
            );
          });

          test('INC YH', () {
            testIncReg8(
              emulator,
              9,
              <int>[0xFD, 0x50],
              emulator.cpu.y.highRegister,
            );
          });

          test('INC UL', () {
            testIncReg8(
              emulator,
              5,
              <int>[0x60],
              emulator.cpu.u.lowRegister,
            );
          });

          test('INC UH', () {
            testIncReg8(
              emulator,
              9,
              <int>[0xFD, 0x60],
              emulator.cpu.u.highRegister,
            );
          });

          test('INC X', () {
            testIncReg16(
              emulator,
              5,
              <int>[0x44],
              emulator.cpu.x,
            );
          });

          test('INC Y', () {
            testIncReg16(
              emulator,
              5,
              <int>[0x54],
              emulator.cpu.y,
            );
          });

          test('INC U', () {
            testIncReg16(
              emulator,
              5,
              <int>[0x64],
              emulator.cpu.u,
            );
          });
        });

        group('DEC [page 31]', () {
          test('DEC A', () {
            testDecReg8(
              emulator,
              5,
              <int>[0xDF],
              emulator.cpu.a,
            );
          });

          test('DEC XL', () {
            testDecReg8(
              emulator,
              5,
              <int>[0x42],
              emulator.cpu.x.lowRegister,
            );
          });

          test('DEC XH', () {
            testDecReg8(
              emulator,
              9,
              <int>[0xFD, 0x42],
              emulator.cpu.x.highRegister,
            );
          });

          test('DEC YL', () {
            testDecReg8(
              emulator,
              5,
              <int>[0x52],
              emulator.cpu.y.lowRegister,
            );
          });

          test('DEC YH', () {
            testDecReg8(
              emulator,
              9,
              <int>[0xFD, 0x52],
              emulator.cpu.y.highRegister,
            );
          });

          test('DEC UL', () {
            testDecReg8(
              emulator,
              5,
              <int>[0x62],
              emulator.cpu.u.lowRegister,
            );
          });

          test('DEC UH', () {
            testDecReg8(
              emulator,
              9,
              <int>[0xFD, 0x62],
              emulator.cpu.u.highRegister,
            );
          });

          test('DEC X', () {
            testDecReg16(
              emulator,
              5,
              <int>[0x46],
              emulator.cpu.x,
            );
          });

          test('DEC Y', () {
            testDecReg16(
              emulator,
              5,
              <int>[0x56],
              emulator.cpu.y,
            );
          });

          test('DEC U', () {
            testDecReg16(
              emulator,
              5,
              <int>[0x66],
              emulator.cpu.u,
            );
          });
        });
      });

      group('Compare and bit test instructions', () {
        group('CPA [page 31]', () {
          test('CPA XL', () {
            testCPAReg(emulator, <int>[0x06], emulator.cpu.x.lowRegister);
          });

          test('CPA XH', () {
            testCPAReg(emulator, <int>[0x86], emulator.cpu.x.highRegister);
          });

          test('CPA YL', () {
            testCPAReg(emulator, <int>[0x16], emulator.cpu.y.lowRegister);
          });

          test('CPA YH', () {
            testCPAReg(emulator, <int>[0x96], emulator.cpu.y.highRegister);
          });

          test('CPA UL', () {
            testCPAReg(emulator, <int>[0x26], emulator.cpu.u.lowRegister);
          });

          test('CPA UH', () {
            testCPAReg(emulator, <int>[0xA6], emulator.cpu.u.highRegister);
          });

          test('CPA (X)', () {
            testCPARReg(emulator, 7, <int>[0x07], emulator.cpu.x);
          });

          test('CPA #(X)', () {
            testCPARReg(emulator, 11, <int>[0xFD, 0x07], emulator.cpu.x, me1: true);
          });

          test('CPA (Y)', () {
            testCPARReg(emulator, 7, <int>[0x17], emulator.cpu.y);
          });

          test('CPA #(Y)', () {
            testCPARReg(emulator, 11, <int>[0xFD, 0x17], emulator.cpu.y, me1: true);
          });

          test('CPA (U)', () {
            testCPARReg(emulator, 7, <int>[0x27], emulator.cpu.u);
          });

          test('CPA #(U)', () {
            testCPARReg(emulator, 11, <int>[0xFD, 0x27], emulator.cpu.u, me1: true);
          });

          test('CPA (ab)', () {
            testCPAab(emulator, 13, <int>[0xA7]);
          });

          test('CPA #(ab)', () {
            testCPAab(emulator, 17, <int>[0xFD, 0xA7], me1: true);
          });
        });

        group('CPI [page 32]', () {
          test('CPI XL, i', () {
            testCPIReg(emulator, <int>[0x4E], emulator.cpu.x.lowRegister);
          });

          test('CPI XH, i', () {
            testCPIReg(emulator, <int>[0x4C], emulator.cpu.x.highRegister);
          });

          test('CPI YL, i', () {
            testCPIReg(emulator, <int>[0x5E], emulator.cpu.y.lowRegister);
          });

          test('CPI YH, i', () {
            testCPIReg(emulator, <int>[0x5C], emulator.cpu.y.highRegister);
          });

          test('CPI UL, i', () {
            testCPIReg(emulator, <int>[0x6E], emulator.cpu.u.lowRegister);
          });

          test('CPI UH, i', () {
            testCPIReg(emulator, <int>[0x6C], emulator.cpu.u.highRegister);
          });

          test('CPI A, i', () {
            testCPIReg(emulator, <int>[0xB7], emulator.cpu.a);
          });
        });

        group('BIT [page 32]', () {
          test('BIT (X)', () {
            testBITRReg(emulator, 7, <int>[0x0F], emulator.cpu.x);
          });

          test('BIT #(X)', () {
            testBITRReg(emulator, 11, <int>[0xFD, 0x0F], emulator.cpu.x, me1: true);
          });

          test('BIT (Y)', () {
            testBITRReg(emulator, 7, <int>[0x1F], emulator.cpu.y);
          });

          test('BIT #(Y)', () {
            testBITRReg(emulator, 11, <int>[0xFD, 0x1F], emulator.cpu.y, me1: true);
          });

          test('BIT (U)', () {
            testBITRReg(emulator, 7, <int>[0x2F], emulator.cpu.u);
          });

          test('BIT #(U)', () {
            testBITRReg(emulator, 11, <int>[0xFD, 0x2F], emulator.cpu.u, me1: true);
          });

          test('BIT (ab)', () {
            testBITab(emulator, 13, <int>[0xAF]);
          });

          test('BIT #(ab)', () {
            testBITab(emulator, 17, <int>[0xFD, 0xAF], me1: true);
          });
        });

        group('BII [page 32]', () {
          test('BII A, i', () {
            testBIIAcc(emulator);
          });

          test('BII (X), i', () {
            testBIIRReg(emulator, 10, <int>[0x4D], emulator.cpu.x);
          });

          test('BII #(X), i', () {
            testBIIRReg(emulator, 14, <int>[0xFD, 0x4D], emulator.cpu.x, me1: true);
          });

          test('BII (Y), i', () {
            testBIIRReg(emulator, 10, <int>[0x5D], emulator.cpu.y);
          });

          test('BII #(Y), i', () {
            testBIIRReg(emulator, 14, <int>[0xFD, 0x5D], emulator.cpu.y, me1: true);
          });

          test('BII (U), i', () {
            testBIIRReg(emulator, 10, <int>[0x6D], emulator.cpu.u);
          });

          test('BII #(U), i', () {
            testBIIRReg(emulator, 14, <int>[0xFD, 0x6D], emulator.cpu.u, me1: true);
          });

          test('BII (ab), i', () {
            testBIIab(emulator, 16, <int>[0xED]);
          });

          test('BII #(ab), i', () {
            testBIIab(emulator, 20, <int>[0xFD, 0xED], me1: true);
          });
        });
      });

      group('Transfer and search instructions', () {
        group('LDA [page 33]', () {
          test('LDA XL', () {
            testLDAReg(emulator, <int>[0x04], emulator.cpu.x.lowRegister);
          });

          test('LDA XH', () {
            testLDAReg(emulator, <int>[0x84], emulator.cpu.x.highRegister);
          });

          test('LDA YL', () {
            testLDAReg(emulator, <int>[0x14], emulator.cpu.y.lowRegister);
          });

          test('LDA YH', () {
            testLDAReg(emulator, <int>[0x94], emulator.cpu.y.highRegister);
          });

          test('LDA UL', () {
            testLDAReg(emulator, <int>[0x24], emulator.cpu.u.lowRegister);
          });

          test('LDA UH', () {
            testLDAReg(emulator, <int>[0xA4], emulator.cpu.u.highRegister);
          });

          test('LDA (X)', () {
            testLDARReg(emulator, 6, <int>[0x05], emulator.cpu.x);
          });

          test('LDA #(X)', () {
            testLDARReg(emulator, 10, <int>[0xFD, 0x05], emulator.cpu.x, me1: true);
          });

          test('LDA (Y)', () {
            testLDARReg(emulator, 6, <int>[0x15], emulator.cpu.y);
          });

          test('LDA #(Y)', () {
            testLDARReg(emulator, 10, <int>[0xFD, 0x15], emulator.cpu.y, me1: true);
          });

          test('LDA (U)', () {
            testLDARReg(emulator, 6, <int>[0x25], emulator.cpu.u);
          });

          test('LDA #(U)', () {
            testLDARReg(emulator, 10, <int>[0xFD, 0x25], emulator.cpu.u, me1: true);
          });

          test('LDA (ab)', () {
            testLDAab(emulator, 12, <int>[0xA5]);
          });

          test('LDA #(ab)', () {
            testLDAab(emulator, 16, <int>[0xFD, 0xA5], me1: true);
          });
        });

        group('LDE [page 33]', () {
          test('LDE X', () {
            testLDERReg(emulator, <int>[0x47], emulator.cpu.x);
          });

          test('LDE Y', () {
            testLDERReg(emulator, <int>[0x57], emulator.cpu.y);
          });

          test('LDE U', () {
            testLDERReg(emulator, <int>[0x67], emulator.cpu.u);
          });
        });

        group('LIN [page 34]', () {
          test('LIN X', () {
            testLINRReg(emulator, <int>[0x45], emulator.cpu.x);
          });

          test('LIN Y', () {
            testLINRReg(emulator, <int>[0x55], emulator.cpu.y);
          });

          test('LIN U', () {
            testLINRReg(emulator, <int>[0x65], emulator.cpu.u);
          });
        });

        group('LDI [page 34]', () {
          test('LDI A, i', () {
            testLDIAcc(emulator);
          });

          test('LDI XL, i', () {
            testLDIReg(emulator, <int>[0x4A], emulator.cpu.x.lowRegister);
          });

          test('LDI XH, i', () {
            testLDIReg(emulator, <int>[0x48], emulator.cpu.x.highRegister);
          });

          test('LDI YL, i', () {
            testLDIReg(emulator, <int>[0x5A], emulator.cpu.y.lowRegister);
          });

          test('LDI YH, i', () {
            testLDIReg(emulator, <int>[0x58], emulator.cpu.y.highRegister);
          });

          test('LDI UL, i', () {
            testLDIReg(emulator, <int>[0x6A], emulator.cpu.u.lowRegister);
          });

          test('LDI UH, i', () {
            testLDIReg(emulator, <int>[0x68], emulator.cpu.u.highRegister);
          });

          test('LDI S, i, j', () {
            testLDISij(emulator);
          });
        });

        group('LDX [page 35]', () {
          test('LDX X', () {
            testLDXReg(emulator, <int>[0xFD, 0x08], emulator.cpu.x);
          });

          test('LDX Y', () {
            testLDXReg(emulator, <int>[0xFD, 0x18], emulator.cpu.y);
          });

          test('LDX U', () {
            testLDXReg(emulator, <int>[0xFD, 0x28], emulator.cpu.u);
          });

          test('LDX S', () {
            testLDXReg(emulator, <int>[0xFD, 0x48], emulator.cpu.s);
          });

          test('LDX P', () {
            final List<int> opcodes = <int>[0xFD, 0x58];
            final int statusRegister = emulator.cpu.t.statusRegister;

            memLoad(0x0020, opcodes);
            final int cycles = emulator.step(address: 0x0020);
            expect(cycles, equals(11));
            expect(emulator.cpu.p.value, equals(0x0020 + opcodes.length));

            expect(emulator.cpu.t.statusRegister, statusRegister);
          });
        });

        group('STA [page 35]', () {
          test('STA XL', () {
            testSTAReg(emulator, <int>[0x0A], emulator.cpu.x.lowRegister);
          });

          test('STA XH', () {
            testSTAReg(emulator, <int>[0x08], emulator.cpu.x.highRegister);
          });

          test('STA YL', () {
            testSTAReg(emulator, <int>[0x1A], emulator.cpu.y.lowRegister);
          });

          test('STA YH', () {
            testSTAReg(emulator, <int>[0x18], emulator.cpu.y.highRegister);
          });

          test('STA UL', () {
            testSTAReg(emulator, <int>[0x2A], emulator.cpu.u.lowRegister);
          });

          test('STA UH', () {
            testSTAReg(emulator, <int>[0x28], emulator.cpu.u.highRegister);
          });

          test('STA (X)', () {
            testSTARReg(emulator, 6, <int>[0x0E], emulator.cpu.x);
          });

          test('STA #(X)', () {
            testSTARReg(emulator, 10, <int>[0xFD, 0x0E], emulator.cpu.x, me1: true);
          });

          test('STA (Y)', () {
            testSTARReg(emulator, 6, <int>[0x1E], emulator.cpu.y);
          });

          test('STA #(Y)', () {
            testSTARReg(emulator, 10, <int>[0xFD, 0x1E], emulator.cpu.y, me1: true);
          });

          test('STA (U)', () {
            testSTARReg(emulator, 6, <int>[0x2E], emulator.cpu.u);
          });

          test('STA #(U)', () {
            testSTARReg(emulator, 10, <int>[0xFD, 0x2E], emulator.cpu.u, me1: true);
          });

          test('STA (ab)', () {
            testSTAab(emulator, 12, <int>[0xAE]);
          });

          test('STA #(ab)', () {
            testSTAab(emulator, 15, <int>[0xFD, 0xAE], me1: true);
          });
        });

        group('SDE [page 35]', () {
          test('SDE X', () {
            testSDERReg(emulator, <int>[0x43], emulator.cpu.x);
          });

          test('SDE Y', () {
            testSDERReg(emulator, <int>[0x53], emulator.cpu.y);
          });

          test('SDE U', () {
            testSDERReg(emulator, <int>[0x63], emulator.cpu.u);
          });
        });

        group('SIN [page 36]', () {
          test('SIN X', () {
            testSINRReg(emulator, <int>[0x41], emulator.cpu.x);
          });

          test('SIN Y', () {
            testSINRReg(emulator, <int>[0x51], emulator.cpu.y);
          });

          test('SIN U', () {
            testSINRReg(emulator, <int>[0x61], emulator.cpu.u);
          });
        });

        group('STX [page 36]', () {
          test('STX Y', () {
            testSTXReg(emulator, <int>[0xFD, 0x5A], emulator.cpu.y);
          });

          test('STX U', () {
            testSTXReg(emulator, <int>[0xFD, 0x6A], emulator.cpu.u);
          });

          test('STX S', () {
            testSTXReg(emulator, <int>[0xFD, 0x4E], emulator.cpu.s);
          });

          test('STX P', () {
            final List<int> opcodes = <int>[0xFD, 0x5E];
            final int statusRegister = emulator.cpu.t.statusRegister;

            memLoad(0x0020, opcodes);
            emulator.cpu.x.value = 0x1234;
            final int cycles = emulator.step(address: 0x0020);
            expect(cycles, equals(17));
            expect(emulator.cpu.p.value, equals(0x1234));

            expect(emulator.cpu.t.statusRegister, statusRegister);
          });
        });

        group('PSH [page 36]', () {
          test('PSH X', () {
            testPSHRReg(emulator, <int>[0xFD, 0x88], emulator.cpu.x);
          });

          test('PSH Y', () {
            testPSHRReg(emulator, <int>[0xFD, 0x98], emulator.cpu.y);
          });

          test('PSH U', () {
            testPSHRReg(emulator, <int>[0xFD, 0xA8], emulator.cpu.u);
          });

          test('PSH A', () {
            final List<int> opcodes = <int>[0xFD, 0xC8];
            final int statusRegister = emulator.cpu.t.statusRegister;

            memLoad(0x0000, opcodes);
            emulator.cpu.s.value = 0x46FF;
            emulator.cpu.a.value = 0x3F;
            final int cycles = emulator.step(address: 0x0000);
            expect(cycles, equals(11));
            expect(emulator.cpu.p.value, equals(opcodes.length));

            expect(emulator.cpu.s.value, equals(0x46FF - 1));
            expect(emulator.cpu.memRead(0x46FF), equals(0x3F));
            expect(emulator.cpu.a.value, equals(0x3F));

            expect(emulator.cpu.t.statusRegister, statusRegister);
          });
        });

        group('POP [page 37]', () {
          test('POP X', () {
            testPOPRReg(emulator, <int>[0xFD, 0x0A], emulator.cpu.x);
          });

          test('POP Y', () {
            testPOPRReg(emulator, <int>[0xFD, 0x1A], emulator.cpu.y);
          });

          test('POP U', () {
            testPOPRReg(emulator, <int>[0xFD, 0x2A], emulator.cpu.u);
          });

          test('POP A', () {
            testPOPA(emulator);
          });
        });

        test('ATT [page 37]', () {
          testATT(emulator);
        });

        test('TTA [page 38]', () {
          testTTA(emulator);
        });
      });

      group('Block transfer and search instructions', () {
        group('TIN [page 38]', () {
          test('TIN', () {
            testTIN(emulator);
          });
        });

        group('CIN [page 38]', () {
          test('CIN', () {
            testCIN(emulator);
          });
        });
      });

      group('Rotate and shift instructions', () {
        group('ROL [page 39]', () {
          test('ROL', () {
            testROL(emulator);
          });
        });

        group('ROR [page 39]', () {
          test('ROR', () {
            testROR(emulator);
          });
        });

        group('SHL [page 39]', () {
          test('SHL', () {
            testSHL(emulator);
          });
        });

        group('SHR [page 40]', () {
          test('SHR', () {
            testSHR(emulator);
          });
        });

        group('DRL [page 40]', () {
          test('DRL (X)', () {
            testDRLRReg(emulator, 12, <int>[0xD7]);
          });

          test('DRL #(X)', () {
            testDRLRReg(emulator, 16, <int>[0xFD, 0xD7], me1: true);
          });
        });

        group('DRR [page 41]', () {
          test('DRR (X)', () {
            testDRRRReg(emulator, 12, <int>[0xD3]);
          });

          test('DRR #(X)', () {
            testDRRRReg(emulator, 16, <int>[0xFD, 0xD3], me1: true);
          });
        });

        group('AEX [page 41]', () {
          test('AEX', () {
            testAEX(emulator);
          });
        });
      });

      group('CPU control instructions', () {
        group('SEC [page 42]', () {
          test('SEC', () {
            testRECSEC(emulator, <int>[0xFB], expectedCarry: true);
          });
        });

        group('REC [page 42]', () {
          test('REC', () {
            testRECSEC(emulator, <int>[0xF9]);
          });
        });

        group('CDV [page 42]', () {
          // test('CDV', () {
          //   ;
          // });
        });

        group('ATP [page 42]', () {
          test('ATP', () {
            testATP(emulator);
          });
        });

        group('SPU [page 43]', () {
          test('SPU', () {
            testRPUSPU(emulator, <int>[0xE1], expectedPU: true);
          });
        });

        group('RPU [page 43]', () {
          test('RPU', () {
            testRPUSPU(emulator, <int>[0xE3]);
          });
        });

        group('SPV [page 43]', () {
          test('SPV', () {
            testRPVSPV(emulator, <int>[0xA8], expectedPV: true);
          });
        });

        group('RPV [page 43]', () {
          test('RPV', () {
            testRPVSPV(emulator, <int>[0xB8]);
          });
        });

        group('SDP [page 43]', () {
          test('SDP', () {
            testSDPRDP(emulator, <int>[0xFD, 0xC1], expectedDisp: true);
          });
        });

        group('RDP [page 44]', () {
          test('RDP', () {
            testSDPRDP(emulator, <int>[0xFD, 0xC0]);
          });
        });

        group('ITA [page 44]', () {
          test('ITA', () {
            testITA(emulator);
          });
        });

        group('SIE [page 44]', () {
          test('SIE', () {
            testSIERIE(emulator, <int>[0xFD, 0x81], expectedIE: true);
          });
        });

        group('RIE [page 44]', () {
          test('RIE', () {
            testSIERIE(emulator, <int>[0xFD, 0xBE]);
          });
        });

        group('AM0 [page 44]', () {
          test('AM0', () {
            testAM(emulator, <int>[0xFD, 0xCE], 0);
          });
        });

        group('AM1 [page 45]', () {
          test('AM1', () {
            testAM(emulator, <int>[0xFD, 0xDE], 1);
          });
        });

        group('NOP [page 45]', () {
          test('NOP', () {
            testNOP(emulator);
          });
        });

        group('HLT [page 45]', () {
          test('HLT', () {
            testHLT(emulator);
          });
        });

        group('OFF [page 45]', () {
          test('OFF', () {
            testOFF(emulator);
          });
        });
      });

      group('Jump instructions', () {
        group('JMP [page 45]', () {
          test('JMP i, j', () {
            testJMP(emulator);
          });
        });

        group('BCH [page 46]', () {
          test('BCH +i', () {
            testBCH(emulator, <int>[0x8E]);
          });

          test('BCH -i', () {
            testBCH(emulator, <int>[0x9E], forward: false);
          });
        });

        group('BCS [page 46]', () {
          test('BCS +i', () {
            testBCS(emulator, <int>[0x83]);
          });

          test('BCS -i', () {
            testBCS(emulator, <int>[0x93], forward: false);
          });
        });

        group('BCR [page 47]', () {
          test('BCR +i', () {
            testBCR(emulator, <int>[0x81]);
          });

          test('BCR -i', () {
            testBCR(emulator, <int>[0x91], forward: false);
          });
        });

        group('BHS [page 47]', () {
          test('BHS +i', () {
            testBHS(emulator, <int>[0x87]);
          });

          test('BHS -i', () {
            testBHS(emulator, <int>[0x97], forward: false);
          });
        });

        group('BHR [page 47]', () {
          test('BHR +i', () {
            testBHR(emulator, <int>[0x85]);
          });

          test('BHR -i', () {
            testBHR(emulator, <int>[0x95], forward: false);
          });
        });

        group('BZS [page 47]', () {
          test('BZS +i', () {
            testBZS(emulator, <int>[0x8B]);
          });

          test('BZS -i', () {
            testBZS(emulator, <int>[0x9B], forward: false);
          });
        });

        group('BZR [page 47]', () {
          test('BZR +i', () {
            testBZR(emulator, <int>[0x89]);
          });

          test('BZR -i', () {
            testBZR(emulator, <int>[0x99], forward: false);
          });
        });

        group('BVS [page 47]', () {
          test('BVS +i', () {
            testBVS(emulator, <int>[0x8F]);
          });

          test('BVS -i', () {
            testBVS(emulator, <int>[0x9F], forward: false);
          });
        });

        group('BVR [page 48]', () {
          test('BVR +i', () {
            testBVR(emulator, <int>[0x8D]);
          });

          test('BVR -i', () {
            testBVR(emulator, <int>[0x9D], forward: false);
          });
        });

        group('LOP [page 48]', () {
          test('LOP i', () {
            testLOP(emulator);
          });
        });
      });

      group('Subroutine jump instructions', () {
        group('SJP [page 49]', () {
          test('SJP i, j', () {
            testSJP(emulator);
          });
        });

        group('VEJ [page 50]', () {
          for (int vectorId = 0xC0; vectorId <= 0xF6; vectorId += 2) {
            test('VEJ (${vectorId.toRadixString(16).padLeft(2, '0').toUpperCase()})', () {
              testVSJ(emulator, 17, <int>[vectorId]);
            });
          }
        });

        group('VMJ [page 51]', () {
          for (int vectorId = 0xC0; vectorId <= 0xF6; vectorId += 2) {
            test('VMJ ${vectorId.toRadixString(16).padLeft(2, '0').toUpperCase()}', () {
              testVSJ(emulator, 20, <int>[0xCD, vectorId]);
            });
          }
        });

        group('VCS [page 52]', () {
          test('VCS i', () {
            testVCS(emulator, <int>[0xC3, 0xC0]);
          });
        });

        group('VCR [page 52]', () {
          test('VCR i', () {
            testVCR(emulator, <int>[0xC1, 0xC0]);
          });
        });

        group('VHS [page 52]', () {
          test('VHS i', () {
            testVHS(emulator, <int>[0xC7, 0xC2]);
          });
        });

        group('VHR [page 52]', () {
          test('VHR i', () {
            testVHR(emulator, <int>[0xC5, 0xC0]);
          });
        });

        group('VZS [page 52]', () {
          test('VZS i', () {
            testVZS(emulator, <int>[0xCB, 0xC4]);
          });
        });

        group('VZR [page 53]', () {
          test('VZR i', () {
            testVZR(emulator, <int>[0xC9, 0xC0]);
          });
        });

        group('VVS [page 53]', () {
          test('VVS i', () {
            testVVS(emulator, <int>[0xCF, 0xC4]);
          });
        });
      });

      group('Return instructions', () {
        group('RTN [page 53]', () {
          test('RTN', () {
            testRTN(emulator);
          });
        });

        group('RTI [page 53]', () {
          test('RTI', () {
            testRTI(emulator);
          });
        });
      });
    });
  });
}
