import 'package:test/test.dart';

import '../../tools/lh5801_add_table.dart';
import 'helpers.dart';

void main() {
  final LH5801Test lh5801 = LH5801Test();

  group('LH5801CPU', () {
    setUp(() {
      lh5801.resetTestEnv();
    });

    group('SBC [page 27]', () {
      test('should return the expected results', () {
        final List<int> opcodes = <int>[0xFD, 0x01];
        memLoad(0x0000, opcodes);

        for (final bool carry in <bool>[true, false]) {
          for (int op1 = 0; op1 < 256; op1++) {
            for (int op2 = 0; op2 < 256; op2++) {
              memLoad(0x10001, <int>[op2]);
              lh5801.cpu.a.value = op1;
              lh5801.cpu.x.value = 0x0001;
              lh5801.cpu.t.c = carry;
              lh5801.step(address: 0x0000);
              expect(lh5801.cpu.p.value, equals(opcodes.length));

              final String key = generateTableKey(op1, op2 ^ 0xFF, carry);
              expect(addTable.containsKey(key), isTrue);
              final ALUResult expected = addTable[key];

              expect(lh5801.cpu.a.value, equals(expected.value));
              expect(lh5801.cpu.t.statusRegister, equals(expected.flags));
            }
          }
        }
      });
    });
  });
}
