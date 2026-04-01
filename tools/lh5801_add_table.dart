class ALUResult {
  const ALUResult(this.value, this.flags);
  final int value, flags;
}

// index #1: op1, index #2: op2, index #3: carry (0 or 1)
final List<List<List<ALUResult>>> addTable = _generateAddTable();

List<List<List<ALUResult>>> _generateAddTable() {
  const int flagC = 0x01;
  const int flagZ = 0x04;
  const int flagV = 0x08;
  const int flagH = 0x10;

  return List<List<List<ALUResult>>>.generate(256, (int op1) {
    return List<List<ALUResult>>.generate(256, (int op2) {
      return List<ALUResult>.generate(2, (int carry) {
        final int result = op1 + op2 + carry;
        int flags = 0;

        if ((result & 0xFF) == 0) {
          flags |= flagZ;
        }
        if ((result & 0x100) != 0) {
          flags |= flagC;
        }
        if (((op1 & 0x80) == (op2 & 0x80)) &&
            ((op1 & 0x80) != (result & 0x80))) {
          flags |= flagV;
        }
        if ((((op1 & 0x0F) + (op2 & 0x0F) + carry) & 0x10) != 0) {
          flags |= flagH;
        }

        return ALUResult(result & 0xFF, flags);
      });
    });
  });
}
