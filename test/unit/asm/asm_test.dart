import 'package:lh5801/lh5801.dart';
import 'package:test/test.dart';

void main() {
  late LH5801ASM asm;

  setUp(() {
    asm = LH5801ASM();
  });

  group('LH5801ASM', () {
    group('basic instructions', () {
      test('NOP', () {
        final AsmResult result = asm.assemble('NOP');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0x38]));
      });

      test('HLT', () {
        final AsmResult result = asm.assemble('HLT');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0xFD, 0xB1]));
      });

      test('SEC / REC', () {
        final AsmResult result = asm.assemble('SEC\nREC');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0xFB, 0xF9]));
      });

      test('SIE / RIE', () {
        final AsmResult result = asm.assemble('SIE\nRIE');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0xFD, 0x81, 0xFD, 0xBE]));
      });
    });

    group('register operands', () {
      test('LDA XH', () {
        final AsmResult result = asm.assemble('LDA XH');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0x84]));
      });

      test('STA YL', () {
        final AsmResult result = asm.assemble('STA YL');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0x1A]));
      });

      test('LDX Y', () {
        final AsmResult result = asm.assemble('LDX Y');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0xFD, 0x18]));
      });
    });

    group('immediate operands', () {
      test('LDI A, 42', () {
        final AsmResult result = asm.assemble('LDI A, 42');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0xB5, 0x42]));
      });

      test('LDI XH, 76', () {
        final AsmResult result = asm.assemble('LDI XH, 76');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0x48, 0x76]));
      });

      test('CPI XL, 4E', () {
        final AsmResult result = asm.assemble('CPI XL, 4E');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0x4E, 0x4E]));
      });

      test('EAI FF', () {
        final AsmResult result = asm.assemble('EAI FF');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0xBD, 0xFF]));
      });
    });

    group('memory indirect ME0', () {
      test('LDA (X)', () {
        final AsmResult result = asm.assemble('LDA (X)');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0x05]));
      });

      test('STA (U)', () {
        final AsmResult result = asm.assemble('STA (U)');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0x2E]));
      });

      test('SBC (1357)', () {
        final AsmResult result = asm.assemble('SBC (1357)');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0xA1, 0x13, 0x57]));
      });
    });

    group('memory indirect ME1', () {
      test('LDA #(X)', () {
        final AsmResult result = asm.assemble('LDA #(X)');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0xFD, 0x05]));
      });

      test('STA #(Y)', () {
        final AsmResult result = asm.assemble('STA #(Y)');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0xFD, 0x1E]));
      });

      test('BII #(3456), 78', () {
        final AsmResult result = asm.assemble('BII #(3456), 78');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0xFD, 0xED, 0x34, 0x56, 0x78]));
      });
    });

    group('branch instructions', () {
      test('BZR -08', () {
        final AsmResult result = asm.assemble('BZR -08');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0x99, 0x08]));
      });

      test('BZS +06', () {
        final AsmResult result = asm.assemble('BZS +06');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0x8B, 0x06]));
      });

      test('BCH -12', () {
        final AsmResult result = asm.assemble('BCH -12');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0x9E, 0x12]));
      });
    });

    group('jump and call', () {
      test('JMP 1234', () {
        final AsmResult result = asm.assemble('JMP 1234');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0xFD, 0xBA, 0x12, 0x34]));
      });

      test('SJP 4000', () {
        final AsmResult result = asm.assemble('SJP 4000');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0xBE, 0x40, 0x00]));
      });
    });

    group('16-bit immediate', () {
      test('LDI S, 13, 57', () {
        final AsmResult result = asm.assemble('LDI S, 13, 57');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0xAA, 0x13, 0x57]));
      });
    });

    group('vector instructions', () {
      test('VEJ (C0)', () {
        final AsmResult result = asm.assemble('VEJ (C0)');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0xC0]));
      });

      test('VEJ (F6)', () {
        final AsmResult result = asm.assemble('VEJ (F6)');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0xF6]));
      });
    });

    group('block and rotate', () {
      test('SIN X', () {
        final AsmResult result = asm.assemble('SIN X');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0x41]));
      });

      test('TIN', () {
        final AsmResult result = asm.assemble('TIN');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0xF5]));
      });

      test('ROL', () {
        final AsmResult result = asm.assemble('ROL');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0xDB]));
      });

      test('DRL (X)', () {
        final AsmResult result = asm.assemble('DRL (X)');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0xD7]));
      });
    });

    group('comments', () {
      test('full-line comment', () {
        final AsmResult result = asm.assemble('; this is a comment\nNOP');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0x38]));
      });

      test('inline comment', () {
        final AsmResult result = asm.assemble('NOP ; do nothing');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0x38]));
      });

      test('blank lines', () {
        final AsmResult result = asm.assemble('\n\nNOP\n\n');
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0x38]));
      });
    });

    group('labels', () {
      test('forward branch with label', () {
        final AsmResult result = asm.assemble(
          'BZS skip\n'
          'NOP\n'
          'NOP\n'
          'skip:',
        );
        expect(result.hasErrors, isFalse);
        // BZS +02 (skip over 2 NOPs), NOP, NOP
        expect(result.bytes, equals([0x8B, 0x02, 0x38, 0x38]));
      });

      test('backward branch with label', () {
        final AsmResult result = asm.assemble(
          'loop:\n'
          'NOP\n'
          'BZR loop',
        );
        expect(result.hasErrors, isFalse);
        // NOP, BZR -03 (back to loop: PC after BZR = 3, target = 0, offset = 3)
        expect(result.bytes, equals([0x38, 0x99, 0x03]));
      });

      test('label on same line as instruction', () {
        final AsmResult result = asm.assemble(
          'start: NOP\n'
          'BZR start',
        );
        expect(result.hasErrors, isFalse);
        expect(result.bytes, equals([0x38, 0x99, 0x03]));
      });

      test('undefined label', () {
        final AsmResult result = asm.assemble('BZR missing');
        expect(result.hasErrors, isTrue);
        expect(result.errors[0].message, contains('undefined label'));
      });

      test('duplicate label', () {
        final AsmResult result = asm.assemble(
          'dup:\n'
          'NOP\n'
          'dup:\n'
          'NOP',
        );
        expect(result.hasErrors, isTrue);
        expect(result.errors[0].message, contains('duplicate label'));
      });
    });

    group('error handling', () {
      test('unknown mnemonic', () {
        final AsmResult result = asm.assemble('FOO');
        expect(result.hasErrors, isTrue);
      });

      test('invalid operand', () {
        final AsmResult result = asm.assemble('LDA #');
        expect(result.hasErrors, isTrue);
      });

      test('forward branch target too far', () {
        // 256 NOPs = 256 bytes, exceeds max displacement of 255.
        final String nops = List.filled(256, 'NOP').join('\n');
        final AsmResult result = asm.assemble(
          'BZS skip\n'
          '$nops\n'
          'skip:',
        );
        expect(result.hasErrors, isTrue);
        expect(result.errors[0].message, contains('out of range'));
      });

      test('backward branch target too far', () {
        final String nops = List.filled(256, 'NOP').join('\n');
        final AsmResult result = asm.assemble(
          'loop:\n'
          '$nops\n'
          'BZR loop',
        );
        expect(result.hasErrors, isTrue);
        expect(result.errors[0].message, contains('out of range'));
      });
    });

    group('multi-instruction programs', () {
      test('LCD inversion program', () {
        final AsmResult result = asm.assemble(
          'LDI XH, 76\n'
          'LDI XL, 00\n'
          'LDA (X)\n'
          'EAI FF\n'
          'SIN X\n'
          'CPI XL, 4E\n'
          'BZR -08\n'
          'CPI XH, 77\n'
          'BZS +06\n'
          'LDI XH, 77\n'
          'LDI XL, 00\n'
          'BCH -12\n'
          'HLT',
        );
        expect(result.hasErrors, isFalse);
        expect(
          result.bytes,
          equals([
            0x48, 0x76,
            0x4A, 0x00,
            0x05,
            0xBD, 0xFF,
            0x41,
            0x4E, 0x4E,
            0x99, 0x08,
            0x4C, 0x77,
            0x8B, 0x06,
            0x48, 0x77,
            0x4A, 0x00,
            0x9E, 0x12,
            0xFD, 0xB1,
          ]),
        );
      });

      test('LCD inversion program with labels', () {
        final AsmResult result = asm.assemble(
          '          LDI XH, 76    ; X = 0x7600\n'
          '          LDI XL, 00\n'
          'loop:     LDA (X)       ; load byte\n'
          '          EAI FF        ; invert\n'
          '          SIN X         ; store and inc\n'
          '          CPI XL, 4E\n'
          '          BZR loop      ; loop back\n'
          '          CPI XH, 77\n'
          '          BZS done\n'
          '          LDI XH, 77\n'
          '          LDI XL, 00\n'
          '          BCH loop\n'
          'done:     HLT',
        );
        expect(result.hasErrors, isFalse);
        expect(
          result.bytes,
          equals([
            0x48, 0x76,
            0x4A, 0x00,
            0x05,
            0xBD, 0xFF,
            0x41,
            0x4E, 0x4E,
            0x99, 0x08,
            0x4C, 0x77,
            0x8B, 0x06,
            0x48, 0x77,
            0x4A, 0x00,
            0x9E, 0x12,
            0xFD, 0xB1,
          ]),
        );
      });
    });
  });
}
