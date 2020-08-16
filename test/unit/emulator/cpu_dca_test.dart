import 'package:test/test.dart';

import '../../../tools/lh5801_add_table.dart';
import 'helpers.dart';

void main() {
  final LH5801Test lh5801 = LH5801Test();

  group('LH5801CPU', () {
    setUp(() {
      lh5801.resetTestEnv();
    });

    group('DCA [page 26]', () {
      test('should return the expected results', () {
        final List<int> bytes = <int>[0xFD, 0x8C];
        memLoad(0x0000, bytes);

        for (final bool carry in <bool>[true, false]) {
          for (int op1Digit1 = 0; op1Digit1 < 10; op1Digit1++) {
            for (int op1Digit2 = 0; op1Digit2 < 10; op1Digit2++) {
              final int op1 = (op1Digit1 << 4) | op1Digit2;
              for (int op2Digit1 = 0; op2Digit1 < 10; op2Digit1++) {
                for (int op2Digit2 = 0; op2Digit2 < 10; op2Digit2++) {
                  final int op2 = (op2Digit1 << 4) | op2Digit2;
                  memLoad(0x10001, <int>[op2]);
                  lh5801.cpu.a.value = op1;
                  lh5801.cpu.x.value = 0x0001;
                  lh5801.cpu.t.c = carry;
                  lh5801.step(address: 0x0000);
                  expect(lh5801.cpu.p.value, equals(bytes.length));

                  final String key = generateTableKey(
                    op1 + 0x66,
                    op2,
                    carry,
                  );
                  expect(addTable.containsKey(key), isTrue);
                  final ALUResult expected = addTable[key];

                  expect(lh5801.cpu.t.c, equals((expected.flags & 0x01) != 0));
                  expect(lh5801.cpu.t.h,
                      equals(((expected.flags & 0x10) >> 4) != 0));

                  int expectedValue = expected.value;
                  if (lh5801.cpu.t.c == false && lh5801.cpu.t.h == false) {
                    expectedValue += 0x9A;
                  } else if (lh5801.cpu.t.c == false && lh5801.cpu.t.h) {
                    expectedValue += 0xA0;
                  } else if (lh5801.cpu.t.c && lh5801.cpu.t.h == false) {
                    expectedValue += 0xFA;
                  }
                  expect(lh5801.cpu.a.value, equals(expectedValue & 0xFF));
                }
              }
            }
          }
        }
      });
    });
  });
}
