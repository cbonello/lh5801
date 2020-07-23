import 'package:test/test.dart';

import '../../tools/lh5801_add_table.dart';
import 'helpers.dart';

String toHex(int value) => value.toUnsigned(8).toRadixString(16).padLeft(2, '0');

// ignore: avoid_positional_boolean_parameters
String generateTableKey(int op1, int op2, bool carry) {
  return '${toHex(op1)}_${toHex(op2)}_${carry ? 1 : 0}'.toUpperCase();
}

void main() {
  final System system = System();
  group('LH5801CPU', () {
    setUp(() {
      system.resetMemories();
    });

    group('CPA [page 31]', () {
      test('should return the expected results', () {
        final List<int> opcodes = <int>[0xFD, 0x07];
        system.load(0x0000, opcodes);

        for (int op1 = 0; op1 < 256; op1++) {
          for (int op2 = 0; op2 < 256; op2++) {
            system.load(0x10001, <int>[op2]);
            system.cpu.a.value = op1;
            system.cpu.x.value = 0x0001;
            system.step(0x0000);
            expect(system.cpu.p.value, equals(opcodes.length));

            final String key = generateTableKey(op1, op2 ^ 0xFF, true);
            expect(addTable.containsKey(key), isTrue);
            final ALUResult expected = addTable[key];

            expect(system.cpu.t.c, equals((expected.flags & 0x01) != 0));
            expect(system.cpu.t.z, equals((expected.flags & 0x04) != 0));
          }
        }
      });
    });
  });
}
