import 'package:meta/meta.dart';

import '../../lh5801.dart';

class LH5801DASM {
  LH5801DASM({
    @required this.memRead,
  }) : assert(memRead != null);

  final LH5801MemoryRead memRead;

  String dump(int address) {
    if (address < 0 || address >= 0x1000) {
      throw LH5801Error('Invalid address ${meHex16(address)}');
    }

    return '';
  }
}
