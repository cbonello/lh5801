import 'package:test/test.dart';

import '../tools/lh5801_add_table.dart';
import 'helpers.dart';

void main() {
  final System system = System();
  group('LH5801CPU', () {
    setUp(() {
      system.resetMemories();
    });

    group('ADC [page 25]', () {
      test('should return the expected results', () {
        final List<int> opcodes = <int>[0xFD, 0x03];
        system.load(0x0000, opcodes);

        for (final bool carry in <bool>[true, false]) {
          for (int op1 = 0; op1 < 256; op1++) {
            for (int op2 = 0; op2 < 256; op2++) {
              system.load(0x10001, <int>[op2]);
              system.cpu.a.value = op1;
              system.cpu.x.value = 0x0001;
              system.cpu.t.c = carry;
              system.step(0x0000);
              expect(system.cpu.p.value, equals(opcodes.length));

              final String key = generateTableKey(op1, op2, carry);
              expect(addTable.containsKey(key), isTrue);
              final ALUResult expected = addTable[key];

              expect(system.cpu.a.value, equals(expected.value));
              expect(system.cpu.t.statusRegister, equals(expected.flags));
            }
          }
        }
      });
    });
  });
}
