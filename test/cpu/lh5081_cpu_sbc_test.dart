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

    group('SBC [page 27]', () {
      test('should return the expected results', () {
        system.load(0x0000, <int>[0xFD, 0x01]);

        for (final bool carry in <bool>[true, false]) {
          for (int op1 = 0; op1 < 256; op1++) {
            for (int op2 = 0; op2 < 256; op2++) {
              system.load(0x10001, <int>[op2]);
              system.cpu.a.value = op1;
              system.cpu.x.value = 0x0001;
              system.cpu.t.c = carry;
              system.step(0x0000);
              expect(system.cpu.p.value, equals(2));

              final String key = generateTableKey(op1, op2 ^ 0xFF, carry);
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
