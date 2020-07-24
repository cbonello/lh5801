import 'package:test/test.dart';

import '../../tools/lh5801_add_table.dart';
import 'helpers.dart';

void main() {
  final System system = System();
  group('LH5801CPU', () {
    setUp(() {
      system.resetMemories();
    });

    group('DCA [page 26]', () {
      String _toHex(int value) => value.toUnsigned(8).toRadixString(16).padLeft(2, '0');

      test('should return the expected results', () {
        final List<int> opcodes = <int>[0xFD, 0x8C];
        system.load(0x0000, opcodes);

        for (final bool carry in <bool>[true, false]) {
          for (int op1Digit1 = 0; op1Digit1 < 10; op1Digit1++) {
            for (int op1Digit2 = 0; op1Digit2 < 10; op1Digit2++) {
              final int op1 = (op1Digit1 << 4) | op1Digit2;
              for (int op2Digit1 = 0; op2Digit1 < 10; op2Digit1++) {
                for (int op2Digit2 = 0; op2Digit2 < 10; op2Digit2++) {
                  final int op2 = (op2Digit1 << 4) | op2Digit2;
                  system.load(0x10001, <int>[op2]);
                  system.cpu.a.value = op1;
                  system.cpu.x.value = 0x0001;
                  system.cpu.t.c = carry;
                  system.step(0x0000);
                  expect(system.cpu.p.value, equals(opcodes.length));

                  final String key = generateTableKey(
                    op1 + 0x66,
                    op2,
                    carry,
                  );
                  expect(addTable.containsKey(key), isTrue);
                  final ALUResult expected = addTable[key];

                  expect(system.cpu.t.c, equals((expected.flags & 0x01) != 0));
                  expect(system.cpu.t.h, equals(((expected.flags & 0x10) >> 4) != 0));

                  int expectedValue = expected.value;
                  if (system.cpu.t.c == false && system.cpu.t.h == false) {
                    expectedValue += 0x9A;
                  } else if (system.cpu.t.c == false && system.cpu.t.h) {
                    expectedValue += 0xA0;
                  } else if (system.cpu.t.c && system.cpu.t.h == false) {
                    expectedValue += 0xFA;
                  }
                  expect(system.cpu.a.value, equals(expectedValue & 0xFF));
                }
              }
            }
          }
        }
      });
    });
  });
}
