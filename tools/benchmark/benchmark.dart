import 'package:benchmark_harness/benchmark_harness.dart';

import 'lh5801_add_array_table.dart' as array_table;
import 'lh5801_add_map_table.dart' as map_table;

class ArrayBenchmark extends BenchmarkBase {
  const ArrayBenchmark() : super('Array');

  static void main() {
    const ArrayBenchmark().report();
  }

  @override
  void run() {
    for (final bool carry in <bool>[true, false]) {
      for (int op1 = 0; op1 < 256; op1++) {
        for (int op2 = 0; op2 < 256; op2++) {
          final array_table.ALUResult expected =
              array_table.addTable[op1 & 0xFF][op2 & 0xFF][carry ? 1 : 0];
        }
      }
    }
  }
}

class MapBenchmark extends BenchmarkBase {
  const MapBenchmark() : super('Map');

  static void main() {
    const MapBenchmark().report();
  }

  @override
  void run() {
    for (final bool carry in <bool>[true, false]) {
      for (int op1 = 0; op1 < 256; op1++) {
        for (int op2 = 0; op2 < 256; op2++) {
          final String key = map_table.generateTableKey(op1, op2, carry);
          final map_table.ALUResult expected = map_table.addTable[key];
        }
      }
    }
  }
}

void main() {
  ArrayBenchmark.main();
  MapBenchmark.main();
}
