import 'package:test/test.dart';

import '../../../tools/lh5801_add_table.dart';
import 'helpers.dart';

void main() {
  final LH5801Test lh5801 = LH5801Test();

  group('LH5801CPU', () {
    setUp(() {
      lh5801.resetTestEnv();
    });

    group('CPA [page 31]', () {
      test('should return the expected results', () {
        final List<int> bytes = <int>[0xFD, 0x07];
        memLoad(0x0000, bytes);

        for (int op1 = 0; op1 < 256; op1++) {
          for (int op2 = 0; op2 < 256; op2++) {
            memLoad(0x10001, <int>[op2]);
            lh5801.cpu.a.value = op1;
            lh5801.cpu.x.value = 0x0001;
            lh5801.step(address: 0x0000);
            expect(lh5801.cpu.p.value, equals(bytes.length));

            final String key = generateTableKey(op1, op2 ^ 0xFF, true);
            expect(addTable.containsKey(key), isTrue);
            final ALUResult expected = addTable[key];

            expect(lh5801.cpu.t.c, equals((expected.flags & 0x01) != 0));
            expect(lh5801.cpu.t.z, equals((expected.flags & 0x04) != 0));
          }
        }
      });
    });
  });
}
