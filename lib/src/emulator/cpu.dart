import 'package:meta/meta.dart';

import '../../lh5801.dart';

class LH5801CPU extends LH5801State {
  LH5801CPU({
    @required LH5801Pins pins,
    @required this.clockFrequency,
    @required this.memRead,
    @required this.memWrite,
  })  : assert(pins != null),
        _pins = pins,
        assert(memRead != null),
        assert(memWrite != null),
        super(
          tm: LH5801Timer(
            cpuClockFrequency: clockFrequency,
            timerClockFrequency: kFrequency31Khz,
          ),
        );

  factory LH5801CPU.fromJson({
    @required LH5801Pins pins,
    @required int clockFrequency,
    @required LH5801MemoryRead memRead,
    @required LH5801MemoryWrite memWrite,
    @required Map<String, dynamic> json,
  }) {
    return LH5801CPU(
      pins: pins,
      clockFrequency: clockFrequency,
      memRead: memRead,
      memWrite: memWrite,
    )
      ..p = Register16.fromJson(json['p'] as Map<String, dynamic>)
      ..s = Register16.fromJson(json['s'] as Map<String, dynamic>)
      ..a = Register8.fromJson(json['a'] as Map<String, dynamic>)
      ..x = Register16.fromJson(json['x'] as Map<String, dynamic>)
      ..y = Register16.fromJson(json['y'] as Map<String, dynamic>)
      ..u = Register16.fromJson(json['u'] as Map<String, dynamic>)
      ..tm = LH5801Timer.fromJson(json['tm'] as Map<String, dynamic>)
      ..t = LH5801Flags.fromJson(json['t'] as Map<String, dynamic>)
      ..ir0 = json['ir0'] as bool
      ..ir1 = json['ir1'] as bool
      ..ir2 = json['ir2'] as bool
      ..hlt = json['hlt'] as bool;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'p': p.toJson(),
        's': s.toJson(),
        'a': a.toJson(),
        'x': x.toJson(),
        'y': y.toJson(),
        'u': u.toJson(),
        'tm': tm.toJson(),
        't': t.toJson(),
        'ir0': ir0,
        'ir1': ir1,
        'ir2': ir2,
        'hlt': hlt,
        'clockFrequency': clockFrequency,
      };

  final LH5801Pins _pins;
  final int clockFrequency;
  final LH5801MemoryRead memRead;
  final LH5801MemoryWrite memWrite;

  int step([LoggerCallback logger]) {
    if (_pins.resetPin) {
      super.reset();
      _pins.reset();
      p.high = memRead(_me0(0xFFFE));
      p.low = memRead(_me0(0xFFFF));
    } else {
      ir0 = _pins.nmiPin;
      ir1 = tm.isInterruptRaised;
      ir2 = _pins.miPin;
    }

    if (ir0) {
      // Non-maskable interrupt
      _push8(t.statusRegister);
      t.ie = ir0 = false;
      _push16(p.value);
      p.high = memRead(_me0(0xFFFC));
      p.low = memRead(_me0(0xFFFD));
    } else if (t.ie && ir1) {
      // Timer interrupt
      _push8(t.statusRegister);
      t.ie = ir1 = false;
      _push16(p.value);
      p.high = memRead(_me0(0xFFFA));
      p.low = memRead(_me0(0xFFFB));
    } else if (t.ie && ir2) {
      // Maskable interrupt
      _push8(t.statusRegister);
      t.ie = hlt = ir2 = false;
      _push16(p.value);
      p.high = memRead(_me0(0xFFF8));
      p.low = memRead(_me0(0xFFF9));
    }

    final int initialPValue = p.value;

    int cycles = 2;
    if (hlt == false) {
      InstructionDescriptor descriptor;
      int opcode = _readOp8();

      if (opcode == 0xFD) {
        opcode = _readOp8();
        descriptor = instructionTableFD[opcode];
        cycles = _stepExtendedInstruction(opcode);
      } else {
        descriptor = instructionTable[opcode];
        cycles = _stepOpcode(opcode);
      }

      if (logger != null) {
        logger(
          LoggerData(
            Instruction(address: initialPValue, descriptor: descriptor),
            _pins.clone(),
            clone(),
          ),
        );
      }
    }

    tm.incrementClock(cycles);

    return cycles;
  }

  int _me0(int address) => address & 0xFFFF;
  int _me1(int address) => 0x10000 | address & 0xFFFF;

  int _readOp8() {
    final int op8 = memRead(p.value);
    p.value += 1;
    return op8;
  }

  int _readOp16([int address]) {
    final int op8H = _readOp8();
    final int op8L = _readOp8();
    return op8H << 8 | op8L;
  }

  int _readOp16Ind(int b) {
    final int ab = _readOp16();
    return memRead((b << 16) | ab);
  }

  int unsignedByteToInt(int value) {
    if (value & 0x80 != 0) {
      return -((0xff & ~value) + 1);
    }
    return value;
  }

  // See http://teaching.idallen.com/dat2343/10f/notes/040_overflow.txt
  int _binaryAdd(int left, int right, {bool carry = false}) {
    final int c = LH5801Flags.boolToInt(carry);
    final int sum = left + right + c;

    t.h = (((left & 0x0F) + (right & 0x0F) + c) & 0x10) != 0;
    t.v = ((left & 0x80) == ((right + c) & 0x80)) && ((left & 0x80) != (sum & 0x80));
    t.z = (sum & 0xFF) == 0;
    t.c = (sum & 0x100) != 0;

    return sum & 0xFF;
  }

  void _addAccumulator(int value) => a.value = _binaryAdd(a.value, value, carry: t.c);

  void _addMemory(int address, int value) {
    final int m = memRead(address);
    final int sum = _binaryAdd(m, value);
    memWrite(address, sum);
  }

  void _addRegister(Register16 register) {
    // Technical reference manual is wrong; flags are not updated.
    final int savedFlags = t.statusRegister;
    final int low = register.low;
    register.low = _binaryAdd(low, a.value);
    if (t.c) {
      register.high++;
    }
    t.statusRegister = savedFlags;
  }

  void _aex() => a.value = (a.value << 4) | (a.value >> 4);

  void _am0() => tm.value = a.value;

  void _am1() => tm.value = 0x100 | a.value;

  void _andAccumulator(int value) {
    a.value &= value;
    t.z = a.value == 0;
  }

  void _andMemory(int address, int value) {
    final int m = memRead(address);
    final int andValue = m & value;
    t.z = (andValue & 0xFF) == 0;
    memWrite(address, andValue);
  }

  int _branchForward(int addCyclesTable, {bool cond = false}) {
    final int offset = _readOp8();

    if (cond) {
      p.value += offset;
      return addCyclesTable;
    }
    return 0;
  }

  int _branchBackward(int addCyclesTable, {bool cond = false}) {
    final int offset = _readOp8();

    if (cond) {
      p.value -= offset;
      return addCyclesTable;
    }
    return 0;
  }

  void _bit(int value1, int value2) => t.z = (value1 & value2) == 0;

  void _cpi(int value1, int value2) => _binaryAdd(value1, (value2 ^ 0xFF) + 1);

  void _cin() {
    final int m = memRead(_me0(x.value));
    _cpi(a.value, m);
    x.value += 1;
  }

  int _bcdAdd(int left, int right, {bool carry = false}) {
    int result = _binaryAdd(left, right, carry: carry);

    // See page 28 of "Sharp PC-1500 Technical Reference Manual"
    if (t.c == false && t.h == false) {
      result += 0x9A;
    } else if (t.c == false && t.h) {
      result += 0xA0;
    } else if (t.c && t.h == false) {
      result += 0xFA;
    }
    return result & 0xFF;
  }

  void _dca(int value) => a.value = _bcdAdd(a.value + 0x66, value, carry: t.c);

  void _dcs(int value) => a.value = _bcdAdd(a.value, value ^ 0xFF, carry: t.c);

  void _decRegister16(Register16 register) => register.value--;

  void _drl(int address) {
    final int m = memRead(address);
    final int tmp = (m << 8) | a.value;
    a.value = m;
    memWrite(address, (tmp >> 4) & 0xFF);
  }

  void _drr(int address) {
    final int m = memRead(address);
    final int tmp = (a.value << 8) | m;
    a.value = tmp;
    memWrite(address, (tmp >> 4) & 0xFF);
  }

  void _eorAccumulator(int value) {
    a.value ^= value;
    t.z = a.value == 0;
  }

  void _ita() {
    a.value = _pins.inputPorts;
    t.z = a.value == 0;
  }

  void _lda(int value) {
    a.value = value;
    t.z = a.value == 0;
  }

  void _lde(Register16 register) {
    a.value = memRead(_me0(register.value--));
    t.z = a.value == 0;
  }

  void _ldi(int value) {
    a.value = value;
    t.z = value == 0;
  }

  void _ldx(Register16 register) => x.value = register.value;

  void _lin(Register16 register) {
    a.value = memRead(_me0(register.value++));
    t.z = a.value == 0;
  }

  int _lop(int addCyclesTable, int d) {
    u.low--;
    if (unsignedByteToInt(u.low) >= 0) {
      p.value -= d;
      return addCyclesTable;
    }
    return 0;
  }

  void _orAccumulator(int value) {
    a.value |= value;
    t.z = a.value == 0;
  }

  void _orMemory(int address, int value) {
    final int m = memRead(address);
    final int orValue = value | m;
    memWrite(address, orValue);
    t.z = orValue == 0;
  }

  int _pop8() {
    s.value++;
    return memRead(_me0(s.value));
  }

  int _pop16() {
    final int h = _pop8();
    final int l = _pop8();
    return h << 8 | l;
  }

  void _popAccumulator() {
    a.value = _pop8();
    t.z = a.value == 0;
  }

  void _popRegister(Register16 register) {
    register.value = _pop16();
  }

  void _push8(int value) {
    memWrite(_me0(s.value), value);
    _decRegister16(s);
  }

  void _push16(int value) {
    _push8(value & 0xFF);
    _push8(value >> 8);
  }

  void _rol() {
    final int accumulator = a.value;
    a.value = accumulator << 1 | LH5801Flags.boolToInt(t.c);
    t.h = a.value & 0x10 != 0;
    t.v = (accumulator >= 0x40) && (accumulator < 0xC0);
    t.z = a.value == 0;
    t.c = (accumulator & 0x80) != 0;
  }

  void _ror() {
    final int accumulator = a.value;
    a.value = LH5801Flags.boolToInt(t.c) << 7 | (accumulator >> 1);
    t.h = a.value & 0x08 != 0;
    t.v = ((accumulator & 0x01) != 0 && (a.value & 0x02) != 0) ||
        ((accumulator & 0x02) != 0 && (a.value & 0x01) != 0);
    t.z = a.value == 0;
    t.c = (accumulator & 0x01) != 0;
  }

  void _rti() {
    _popRegister(p);
    t.statusRegister = _pop8();
  }

  void _rtn() => _popRegister(p);

  void _sbc(int value) => a.value = _binaryAdd(a.value, value ^ 0xFF, carry: t.c);

  void _sde(Register16 register) => memWrite(_me0(register.value--), a.value);

  void _shl() {
    final int accumulator = a.value;
    a.value <<= 1;
    t.h = (accumulator & 0x08) != 0;
    t.v = accumulator >= 0x40 && accumulator < 0xC0;
    t.z = a.value == 0;
    t.c = (accumulator & 0x80) != 0;
  }

  void _shr() {
    final int accumulator = a.value;
    a.value >>= 1;
    t.h = (a.value & 0x08) != 0;
    t.v = ((accumulator & 0x01) != 0 && (a.value & 0x02) != 0) ||
        ((accumulator & 0x02) != 0 && (a.value & 0x01) != 0);
    t.z = a.value == 0;
    t.c = (accumulator & 0x01) != 0;
  }

  void _sin(Register16 register) => memWrite(_me0(register.value++), a.value);

  void _sjp(int address) {
    _push16(p.value);
    p.value = address;
  }

  void _tin() {
    final int m = memRead(_me0(x.value++));
    memWrite(_me0(y.value++), m);
  }

  void _tta() {
    a.value = t.statusRegister;
    t.z = a.value == 0;
  }

  int _vector(int addCyclesTable, bool cond, int vectorID) {
    int cycles = 0;
    if (cond) {
      cycles += addCyclesTable;
      _push16(p.value);
      final int h = memRead(_me0(0xFF00 + vectorID));
      final int l = memRead(_me0(0xFF00 + vectorID + 1));
      p.value = (h << 8) | l;
    }
    t.z = false;
    return cycles;
  }

  int _stepExtendedInstruction(int opcode) {
    final int startP = p.value - 1;
    final CyclesCount cyclesTable = instructionTableFD[opcode].cycles;
    final int cycles = cyclesTable.basic;
    int o8, p8, o16;

    switch (opcode) {
      case 0x01: // SBC #(X)
        _sbc(memRead(_me1(x.value)));
        break;
      case 0x03: // ADC #(X)
        _addAccumulator(memRead(_me1(x.value)));
        break;
      case 0x05: // LDA #(X)
        _lda(memRead(_me1(x.value)));
        break;
      case 0x07: // CPA #(X)
        _cpi(a.value, memRead(_me1(x.value)));
        break;
      case 0x08: // LDX X
        break;
      case 0x09: // AND #(X)
        _andAccumulator(memRead(_me1(x.value)));
        break;
      case 0x0A: // POP X
        _popRegister(x);
        break;
      case 0x0B: // ORA #(X)
        _orAccumulator(memRead(_me1(x.value)));
        break;
      case 0x0C: // DCS #(X)
        _dcs(memRead(_me1(x.value)));
        break;
      case 0x0D: // EOR #(X)
        _eorAccumulator(memRead(_me1(x.value)));
        break;
      case 0x0E: // STA #(X)
        memWrite(_me1(x.value), a.value);
        break;
      case 0x0F: // BIT #(X)
        _bit(memRead(_me1(x.value)), a.value);
        break;

      case 0x11: // SBC #(Y)
        _sbc(memRead(_me1(y.value)));
        break;
      case 0x13: // ADC #(Y)
        _addAccumulator(memRead(_me1(y.value)));
        break;
      case 0x15: // LDA #(Y)
        _lda(memRead(_me1(y.value)));
        break;
      case 0x17: // CPA #(Y)
        _cpi(a.value, memRead(_me1(y.value)));
        break;
      case 0x18: // LDX Y
        _ldx(y);
        break;
      case 0x19: // AND #(Y)
        _andAccumulator(memRead(_me1(y.value)));
        break;
      case 0x1A: // POP Y
        _popRegister(y);
        break;
      case 0x1B: // ORA #(Y)
        _orAccumulator(memRead(_me1(y.value)));
        break;
      case 0x1C: //DCS #(Y)
        _dcs(memRead(_me1(y.value)));
        break;
      case 0x1D: // EOR #(Y)
        _eorAccumulator(memRead(_me1(y.value)));
        break;
      case 0x1E: // STA #(Y)
        memWrite(_me1(y.value), a.value);
        break;
      case 0x1F: // BIT #(Y)
        _bit(memRead(_me1(y.value)), a.value);
        break;

      case 0x21: // SBC #(U)
        _sbc(memRead(_me1(u.value)));
        break;
      case 0x23: // ADC #(U)
        _addAccumulator(memRead(_me1(u.value)));
        break;
      case 0x25: // LDA #(U)
        _lda(memRead(_me1(u.value)));
        break;
      case 0x27: // CPA #(U)
        _cpi(a.value, memRead(_me1(u.value)));
        break;
      case 0x28: // LDX U
        _ldx(u);
        break;
      case 0x29: // AND #(U)
        _andAccumulator(memRead(_me1(u.value)));
        break;
      case 0x2A: // POP U
        _popRegister(u);
        break;
      case 0x2B: // ORA #(U)
        _orAccumulator(memRead(_me1(u.value)));
        break;
      case 0x2C: // DCS #(U)
        _dcs(memRead(_me1(u.value)));
        break;
      case 0x2D: // EOR #(U)
        _eorAccumulator(memRead(_me1(u.value)));
        break;
      case 0x2E: // STA #(U)
        memWrite(_me1(u.value), a.value);
        break;
      case 0x2F: // BIT #(U)
        _bit(memRead(_me1(u.value)), a.value);
        break;

      case 0x40: // INC XH
        x.high = _binaryAdd(x.high, 1);
        break;
      case 0x42: // DEC XH
        x.high = _binaryAdd(x.high, 0xFF);
        break;
      case 0x48: // LDX S
        _ldx(s);
        break;
      case 0x49: // ANI #(X), i
        _andMemory(_me1(x.value), _readOp8());
        break;
      case 0x4A: // STX X
        break;
      case 0x4B: // ORI #(X), i
        _orMemory(_me1(x.value), _readOp8());
        break;
      case 0x4C: // OFF
        _pins.bfFlipflop = false;
        break;
      case 0x4D: // BII #(X), i
        _bit(memRead(_me1(x.value)), _readOp8());
        break;
      case 0x4E: // STX S
        s.value = x.value;
        break;
      case 0x4F: // ADI #(X), i
        _addMemory(_me1(x.value), _readOp8());
        break;

      case 0x50: // INC YH
        y.high = _binaryAdd(y.high, 1);
        break;
      case 0x52: // DEC YH
        y.high = _binaryAdd(y.high, 0xFF);
        break;
      case 0x58: // LDX P
        _ldx(p);
        break;
      case 0x59: // ANI #(Y), i
        _andMemory(_me1(y.value), _readOp8());
        break;
      case 0x5A: // STX Y
        y.value = x.value;
        break;
      case 0x5B: // ORI #(Y), i
        _orMemory(_me1(y.value), _readOp8());
        break;
      case 0x5D: // BII #(Y), i
        _bit(memRead(_me1(y.value)), _readOp8());
        break;
      case 0x5E: // STX P
        p.value = _me0(x.value);
        break;
      case 0x5F: // ADI #(Y), i
        _addMemory(_me1(y.value), _readOp8());
        break;

      case 0x60: // INC UH
        u.high = _binaryAdd(u.high, 1);
        break;
      case 0x62: // DEC UH
        u.high = _binaryAdd(u.high, 0xFF);
        break;
      case 0x69: // ANI #(U), i
        _andMemory(_me1(u.value), _readOp8());
        break;
      case 0x6A: // STX U
        u.value = x.value;
        break;
      case 0x6B: // ORI #(U), i
        _orMemory(_me1(u.value), _readOp8());
        break;
      case 0x6D: // BII #(U), i
        _bit(memRead(_me1(u.value)), _readOp8());
        break;
      case 0x6F: // ADI #(U), i
        _addMemory(_me1(u.value), _readOp8());
        break;

      case 0x81: // SIE
        t.ie = true;
        break;
      case 0x88: // PSH X
        _push16(x.value);
        break;
      case 0x8A: // POP A
        _popAccumulator();
        break;
      case 0x8C: // DCA #(X)
        _dca(memRead(_me1(x.value)));
        break;
      case 0x8E: // CDV
        // TODO(cbonello): implement CDV instruction
        break;

      case 0x98: // PSH Y
        _push16(y.value);
        break;
      case 0x9C: // DCA #(Y)
        _dca(memRead(_me1(y.value)));
        break;

      case 0xA1: // SBC #(ab)
        _sbc(_readOp16Ind(1));
        break;
      case 0xA3: // ADC #(ab)
        _addAccumulator(_readOp16Ind(1));
        break;
      case 0xA5: // LDA #(ab)
        _lda(_readOp16Ind(1));
        break;
      case 0xA7: // CPA #(ab)
        _cpi(a.value, _readOp16Ind(1));
        break;
      case 0xA8: // PSH U
        _push16(u.value);
        break;
      case 0xA9: // AND #(ab)
        _andAccumulator(_readOp16Ind(1));
        break;
      case 0xAA: // TTA
        _tta();
        break;
      case 0xAB: // ORA #(ab)
        _orAccumulator(_readOp16Ind(1));
        break;
      case 0xAC: // DCA #(U)
        _dca(memRead(_me1(u.value)));
        break;
      case 0xAD: // EOR #(ab)
        _eorAccumulator(_readOp16Ind(1));
        break;
      case 0xAE: // STA #(ab)
        memWrite(_me1(_readOp16()), a.value);
        break;
      case 0xAF: // BIT #(ab)
        _bit(_readOp16Ind(1), a.value);
        break;

      case 0xB1: // HLT
        hlt = true;
        break;
      case 0xBA: // ITA
        _ita();
        break;
      case 0xBE: // RIE
        t.ie = false;
        break;

      case 0xC0: // RDP
        _pins.dispFlipflop = false;
        break;
      case 0xC1: // SDP
        _pins.dispFlipflop = true;
        break;
      case 0xC8: // PSH A
        _push8(a.value);
        break;
      case 0xCA: // ADR X
        _addRegister(x);
        break;
      case 0xCC: // ATP
        _pins.inputPorts = a.value;
        break;
      case 0xCE: // AM0
        _am0();
        break;

      case 0xD3: // DRR #(X)
        _drr(_me1(x.value));
        break;
      case 0xD7: // DRL #(X)
        _drl(_me1(x.value));
        break;
      case 0xDA: // ADR Y
        _addRegister(y);
        break;
      case 0xDE: // AM1
        _am1();
        break;

      case 0xE9: // ANI #(ab), i
        o16 = _readOp16();
        o8 = _readOp8();
        _andMemory(_me1(o16), o8);
        break;
      case 0xEA: // ADR U
        _addRegister(u);
        break;
      case 0xEB: // ORI #(ab), i
        o16 = _readOp16();
        o8 = _readOp8();
        _orMemory(_me1(o16), o8);
        break;
      case 0xEC: // ATT
        t.statusRegister = a.value;
        break;
      case 0xED: // BII #(ab), i
        o8 = _readOp16Ind(1);
        p8 = _readOp8();
        _bit(o8, p8);
        break;
      case 0xEF: // ADI #(ab), i
        o16 = _readOp16();
        o8 = _readOp8();
        _addMemory(_me1(o16), o8);
        break;

      default:
        throw LH5801Error(
          'illegal opcode FD${OperandDump.op8(opcode)} at address ${OperandDump.op16(startP)}',
        );
    }

    return cycles;
  }

  int _stepOpcode(int opcode) {
    final int startP = p.value - 1;
    final CyclesCount cyclesTable = instructionTable[opcode].cycles;
    int cycles = cyclesTable.basic;
    int o8, p8, o16;

    switch (opcode) {
      case 0x00: // SBC XL
        _sbc(x.low);
        break;
      case 0x01: // SBC (X)
        _sbc(memRead(_me0(x.value)));
        break;
      case 0x02: // ADC XL
        _addAccumulator(x.low);
        break;
      case 0x03: // ADC (X)
        _addAccumulator(memRead(_me0(x.value)));
        break;
      case 0x04: // LDA XL
        _lda(x.low);
        break;
      case 0x05: // LDA (X)
        _lda(memRead(_me0(x.value)));
        break;
      case 0x06: // CPA XL
        _cpi(a.value, x.low);
        break;
      case 0x07: // CPA (X)
        _cpi(a.value, memRead(_me0(x.value)));
        break;
      case 0x08: // STA XH
        x.high = a.value;
        break;
      case 0x09: // AND (X)
        _andAccumulator(memRead(_me0(x.value)));
        break;
      case 0x0A: // STA XL
        x.low = a.value;
        break;
      case 0x0B: // ORA (X)
        _orAccumulator(memRead(_me0(x.value)));
        break;
      case 0x0C: // DCS (X)
        _dcs(memRead(_me0(x.value)));
        break;
      case 0x0D: // EOR (X)
        _eorAccumulator(memRead(_me0(x.value)));
        break;
      case 0x0E: // STA (X)
        memWrite(_me0(x.value), a.value);
        break;
      case 0x0F: // BIT (X)
        _bit(memRead(_me0(x.value)), a.value);
        break;

      case 0x10: // SBC YL
        _sbc(y.low);
        break;
      case 0x11: // SBC (Y)
        _sbc(memRead(_me0(y.value)));
        break;
      case 0x12: // ADC YL
        _addAccumulator(y.low);
        break;
      case 0x13: // ADC (Y)
        _addAccumulator(memRead(_me0(y.value)));
        break;
      case 0x14: // LDA YL
        _lda(y.low);
        break;
      case 0x15: // LDA (Y)
        _lda(memRead(_me0(y.value)));
        break;

      case 0x16: // CPA YL
        _cpi(a.value, y.low);
        break;
      case 0x17: // CPA (Y)
        _cpi(a.value, memRead(_me0(y.value)));
        break;
      case 0x18: // STA YH
        y.high = a.value;
        break;
      case 0x19: // AND (Y)
        _andAccumulator(memRead(_me0(y.value)));
        break;
      case 0x1A: // STA YL
        y.low = a.value;
        break;
      case 0x1B: // ORA (Y)
        _orAccumulator(memRead(_me0(y.value)));
        break;
      case 0x1C: // DCS (Y)
        _dcs(memRead(_me0(y.value)));
        break;
      case 0x1D: // EOR (Y)
        _eorAccumulator(memRead(_me0(y.value)));
        break;
      case 0x1E: // STA (Y)
        memWrite(_me0(y.value), a.value);
        break;
      case 0x1F: // BIT (Y)
        _bit(memRead(_me0(y.value)), a.value);
        break;

      case 0x20: // SBC UL
        _sbc(u.low);
        break;
      case 0x21: // SBC (U)
        _sbc(memRead(_me0(u.value)));
        break;
      case 0x22: // ADC UL
        _addAccumulator(u.low);
        break;
      case 0x23: // ADC (U)
        _addAccumulator(memRead(_me0(u.value)));
        break;
      case 0x24: // LDA UL
        _lda(u.low);
        break;
      case 0x25: // LDA (U)
        _lda(memRead(_me0(u.value)));
        break;
      case 0x26: // CPA UL
        _cpi(a.value, u.low);
        break;
      case 0x27: // CPA (U)
        _cpi(a.value, memRead(_me0(u.value)));
        break;
      case 0x28: // STA UH
        u.high = a.value;
        break;
      case 0x29: // AND (U)
        _andAccumulator(memRead(_me0(u.value)));
        break;

      case 0x2A: // STA UL
        u.low = a.value;
        break;
      case 0x2B: // ORA (U)
        _orAccumulator(memRead(_me0(u.value)));
        break;
      case 0x2C: // DCS (U)
        _dcs(memRead(_me0(u.value)));
        break;
      case 0x2D: // EOR (U)
        _eorAccumulator(memRead(_me0(u.value)));
        break;
      case 0x2E: // STA (U)
        memWrite(_me0(u.value), a.value);
        break;
      case 0x2F: // BIT (U)
        _bit(memRead(_me0(u.value)), a.value);
        break;

      case 0x38: // NOP
        break;

      case 0x40: // INC XL
        x.low = _binaryAdd(x.low, 1);
        break;
      case 0x41: // SIN X
        _sin(x);
        break;
      case 0x42: // DEC XL
        x.low = _binaryAdd(x.low, 0xFF);
        break;
      case 0x43: // SDE X
        _sde(x);
        break;
      case 0x44: // INC X
        x.value++;
        break;
      case 0x45: // LIN X
        _lin(x);
        break;
      case 0x46: // DEC X
        x.value--;
        break;
      case 0x47: // LDE X
        _lde(x);
        break;
      case 0x48: // LDI XH, i
        x.high = _readOp8();
        break;
      case 0x49: // ANI (X), i
        _andMemory(_me0(x.value), _readOp8());
        break;
      case 0x4A: // LDI XL, i
        x.low = _readOp8();
        break;
      case 0x4B: // ORI (X), i
        _orMemory(_me0(x.value), _readOp8());
        break;
      case 0x4C: // CPI XH, i
        _cpi(x.high, _readOp8());
        break;
      case 0x4D: // BII (X), i
        _bit(memRead(_me0(x.value)), _readOp8());
        break;
      case 0x4E: // CPI XL, i
        _cpi(x.low, _readOp8());
        break;
      case 0x4F: // ADI (X), i
        _addMemory(_me0(x.value), _readOp8());
        break;

      case 0x50: // INC YL
        y.low = _binaryAdd(y.low, 1);
        break;
      case 0x51: // SIN Y
        _sin(y);
        break;
      case 0x52: // DEC YL
        y.low = _binaryAdd(y.low, 0xFF);
        break;
      case 0x53: // SDE Y
        _sde(y);
        break;
      case 0x54: // INC Y
        y.value++;
        break;
      case 0x55: // LIN Y
        _lin(y);
        break;
      case 0x56: // DEC Y
        y.value--;
        break;
      case 0x57: // LDE Y
        _lde(y);
        break;
      case 0x58: // LDI YH, i
        y.high = _readOp8();
        break;
      case 0x59: // ANI (Y), i
        _andMemory(_me0(y.value), _readOp8());
        break;
      case 0x5A: // LDI YL, i
        y.low = _readOp8();
        break;
      case 0x5B: // ORI (Y), i
        _orMemory(_me0(y.value), _readOp8());
        break;
      case 0x5C: // CPI YH, i
        _cpi(y.high, _readOp8());
        break;
      case 0x5D: // BII (Y), i
        _bit(memRead(_me0(y.value)), _readOp8());
        break;
      case 0x5E: // CPI YL, i
        _cpi(y.low, _readOp8());
        break;
      case 0x5F: // ADI (Y), i
        _addMemory(_me0(y.value), _readOp8());
        break;

      case 0x60: // INC UL
        u.low = _binaryAdd(u.low, 1);
        break;
      case 0x61: // SIN U
        _sin(u);
        break;
      case 0x62: // DEC UL
        u.low = _binaryAdd(u.low, 0xFF);
        break;
      case 0x63: // SDE U
        _sde(u);
        break;
      case 0x64: // INC U
        u.value++;
        break;
      case 0x65: // LIN U
        _lin(u);
        break;
      case 0x66: // DEC U
        u.value--;
        break;
      case 0x67: // LDE U
        _lde(u);
        break;
      case 0x68: // LDI UH, i
        u.high = _readOp8();
        break;
      case 0x69: // ANI (U), i
        _andMemory(_me0(u.value), _readOp8());
        break;
      case 0x6A: // LDI UL, i
        u.low = _readOp8();
        break;
      case 0x6B: // ORI (U), i
        _orMemory(_me0(u.value), _readOp8());
        break;
      case 0x6C: // CPI UH, i
        _cpi(u.high, _readOp8());
        break;
      case 0x6D: // BII (U), i
        _bit(memRead(_me0(u.value)), _readOp8());
        break;
      case 0x6E: // CPI UL, i
        _cpi(u.low, _readOp8());
        break;
      case 0x6F: // ADI (U), i
        _addMemory(_me0(u.value), _readOp8());
        break;

      case 0x80: // SBC XH
        _sbc(x.high);
        break;
      case 0x81: // BCR +i
        cycles += _branchForward(cyclesTable.additional, cond: t.c == false);
        break;
      case 0x82: // ADC XH
        _addAccumulator(x.high);
        break;
      case 0x83: // BCS +i
        cycles += _branchForward(cyclesTable.additional, cond: t.c == true);
        break;
      case 0x84: // LDA XH
        _lda(x.high);
        break;
      case 0x85: // BHR +i
        cycles += _branchForward(cyclesTable.additional, cond: t.h == false);
        break;
      case 0x86: // CPA XH
        _cpi(a.value, x.high);
        break;
      case 0x87: // BHS +i
        cycles += _branchForward(cyclesTable.additional, cond: t.h == true);
        break;
      case 0x88: // LOP i
        cycles += _lop(cyclesTable.additional, _readOp8());
        break;
      case 0x89: // BZR +i
        cycles += _branchForward(cyclesTable.additional, cond: t.z == false);
        break;
      case 0x8A: // RTI
        _rti();
        break;
      case 0x8B: // BZS +i
        cycles += _branchForward(cyclesTable.additional, cond: t.z == true);
        break;
      case 0x8C: // DCA (X)
        _dca(memRead(_me0(x.value)));
        break;
      case 0x8D: // BVR +i
        cycles += _branchForward(cyclesTable.additional, cond: t.v == false);
        break;
      case 0x8E: // BCH +i
        cycles += _branchForward(cyclesTable.additional, cond: true);
        break;
      case 0x8F: // BVS +i
        cycles += _branchForward(cyclesTable.additional, cond: t.v == true);
        break;

      case 0x90: // SBC YH
        _sbc(y.high);
        break;
      case 0x91: // BCR -i
        cycles += _branchBackward(cyclesTable.additional, cond: t.c == false);
        break;
      case 0x92: // ADC YH
        _addAccumulator(y.high);
        break;
      case 0x93: // BCS -i
        cycles += _branchBackward(cyclesTable.additional, cond: t.c == true);
        break;
      case 0x94: // LDA YH
        _lda(y.high);
        break;
      case 0x95: // BHR -i
        cycles += _branchBackward(cyclesTable.additional, cond: t.h == false);
        break;
      case 0x96: // CPA YH
        _cpi(a.value, y.high);
        break;
      case 0x97: // BHS -i
        cycles += _branchBackward(cyclesTable.additional, cond: t.h == true);
        break;
      case 0x99: // BZR -i
        cycles += _branchBackward(cyclesTable.additional, cond: t.z == false);
        break;
      case 0x9A: // RTN
        _rtn();
        break;
      case 0x9B: // BZS -i
        cycles += _branchBackward(cyclesTable.additional, cond: t.z == true);
        break;
      case 0x9C: // DCA (Y)
        _dca(memRead(_me0(y.value)));
        break;
      case 0x9D: // BVR -i
        cycles += _branchBackward(cyclesTable.additional, cond: t.v == false);
        break;
      case 0x9E: // BCH -i
        cycles += _branchBackward(cyclesTable.additional, cond: true);
        break;
      case 0x9F: // BVS -i
        cycles += _branchBackward(cyclesTable.additional, cond: t.v == true);
        break;

      case 0xA0: // SBC UH
        _sbc(u.high);
        break;
      case 0xA1: // SBC (ab)
        _sbc(_readOp16Ind(0));
        break;
      case 0xA2: // ADC UH
        _addAccumulator(u.high);
        break;
      case 0xA3: // ADC (ab)
        _addAccumulator(_readOp16Ind(0));
        break;
      case 0xA4: // LDA UH
        _lda(u.high);
        break;
      case 0xA5: // LDA (ab)
        _lda(_readOp16Ind(0));
        break;
      case 0xA6: // CPA UH
        _cpi(a.value, u.high);
        break;
      case 0xA7: // CPA (ab)
        _cpi(a.value, _readOp16Ind(0));
        break;
      case 0xA8: // SPV
        _pins.pvFlipflop = true;
        break;
      case 0xA9: // AND (ab)
        _andAccumulator(_readOp16Ind(0));
        break;
      case 0xAA: // LDI S, i, j
        o16 = _readOp16();
        s.value = o16;
        break;
      case 0xAB: // ORA (ab)
        _orAccumulator(_readOp16Ind(0));
        break;
      case 0xAC: // DCA (U)
        _dca(memRead(_me0(u.value)));
        break;
      case 0xAD: // EOR (ab)
        _eorAccumulator(_readOp16Ind(0));
        break;
      case 0xAE: // STA (ab)
        memWrite(_me0(_readOp16()), a.value);
        break;
      case 0xAF: // BIT (ab)
        _bit(_readOp16Ind(0), a.value);
        break;

      case 0xB1: // SBI A, i
        _sbc(_readOp8());
        break;
      case 0xB3: // ADI A, i
        _addAccumulator(_readOp8());
        break;
      case 0xB5: // LDI A, i
        _ldi(_readOp8());
        break;
      case 0xB7: // CPI A, i
        _cpi(a.value, _readOp8());
        break;
      case 0xB8: // RPV
        _pins.pvFlipflop = false;
        break;
      case 0xB9: // ANI A, i
        _andAccumulator(_readOp8());
        break;
      case 0xBA: // JMP i, j
        p.value = _me0(_readOp16());
        break;
      case 0xBB: // ORI A, i
        _orAccumulator(_readOp8());
        break;
      case 0xBD: // EAI i
        _eorAccumulator(_readOp8());
        break;
      case 0xBE: // SJP
        _sjp(_me0(_readOp16()));
        break;
      case 0xBF: // BII A, i
        _bit(a.value, _readOp8());
        break;

      case 0xC0: // VEJ (C0)
        cycles += _vector(cyclesTable.additional, true, 0xC0);
        break;
      case 0xC1: // VCR i
        cycles += _vector(cyclesTable.additional, t.c == false, _readOp8());
        break;
      case 0xC2: // VEJ (C2)
        cycles += _vector(cyclesTable.additional, true, 0xC2);
        break;
      case 0xC3: // VCS i
        cycles += _vector(cyclesTable.additional, t.c, _readOp8());
        break;
      case 0xC4: // VEJ (C4)
        cycles += _vector(cyclesTable.additional, true, 0xC4);
        break;
      case 0xC5: // VHR i
        cycles += _vector(cyclesTable.additional, t.h == false, _readOp8());
        break;
      case 0xC6: // VEJ (C6)
        cycles += _vector(cyclesTable.additional, true, 0xC6);
        break;
      case 0xC7: // VHS i
        cycles += _vector(cyclesTable.additional, t.h, _readOp8());
        break;
      case 0xC8: // VEJ (C8)
        cycles += _vector(cyclesTable.additional, true, 0xC8);
        break;
      case 0xC9: // VZR i
        cycles += _vector(cyclesTable.additional, t.z == false, _readOp8());
        break;
      case 0xCA: // VEJ (CA)
        cycles += _vector(cyclesTable.additional, true, 0xCA);
        break;
      case 0xCB: // VZS i
        cycles += _vector(cyclesTable.additional, t.z, _readOp8());
        break;
      case 0xCC: // VEJ (CC)
        cycles += _vector(cyclesTable.additional, true, 0xCC);
        break;
      case 0xCD: // VMJ i
        cycles += _vector(cyclesTable.additional, true, _readOp8());
        break;
      case 0xCE: // VEJ (CE)
        cycles += _vector(cyclesTable.additional, true, 0xCE);
        break;
      case 0xCF: // VVS i
        cycles += _vector(cyclesTable.additional, t.v, _readOp8());
        break;

      case 0xD0: // VEJ (D0)
        cycles += _vector(cyclesTable.additional, true, 0xD0);
        break;
      case 0xD1: // ROR
        _ror();
        break;
      case 0xD2: // VEJ (D2)
        cycles += _vector(cyclesTable.additional, true, 0xD2);
        break;
      case 0xD3: // DRR (X)
        _drr(_me0(x.value));
        break;
      case 0xD4: // VEJ (D4)
        cycles += _vector(cyclesTable.additional, true, 0xD4);
        break;
      case 0xD5: // SHR
        _shr();
        break;
      case 0xD6: // VEJ (D6)
        cycles += _vector(cyclesTable.additional, true, 0xD6);
        break;
      case 0xD7: // DRL (X)
        _drl(_me0(x.value));
        break;
      case 0xD8: // VEJ (D8)
        cycles += _vector(cyclesTable.additional, true, 0xD8);
        break;
      case 0xD9: // SHL
        _shl();
        break;
      case 0xDA: // VEJ (DA)
        cycles += _vector(cyclesTable.additional, true, 0xDA);
        break;
      case 0xDB: // ROL
        _rol();
        break;
      case 0xDC: // VEJ (DC)
        cycles += _vector(cyclesTable.additional, true, 0xDC);
        break;
      case 0xDD: // INC A
        a.value = _binaryAdd(a.value, 1);
        break;
      case 0xDE: // VEJ (DE)
        cycles += _vector(cyclesTable.additional, true, 0xDE);
        break;
      case 0xDF: // DEC A
        a.value = _binaryAdd(a.value, 0xFF);
        break;

      case 0xE0: // VEJ (E0)
        cycles += _vector(cyclesTable.additional, true, 0xE0);
        break;
      case 0xE1: // SPU
        _pins.puFlipflop = true;
        break;
      case 0xE2: // VEJ (E2)
        cycles += _vector(cyclesTable.additional, true, 0xE2);
        break;
      case 0xE3: // RPU
        _pins.puFlipflop = false;
        break;
      case 0xE4: // VEJ (E4)
        cycles += _vector(cyclesTable.additional, true, 0xE4);
        break;
      case 0xE6: // VEJ (E6)
        cycles += _vector(cyclesTable.additional, true, 0xE6);
        break;
      case 0xE8: // VEJ (E8)
        cycles += _vector(cyclesTable.additional, true, 0xE8);
        break;
      case 0xE9: // ANI (ab), i
        o16 = _readOp16();
        o8 = _readOp8();
        _andMemory(_me0(o16), o8);
        break;
      case 0xEA: // VEJ (EA)
        cycles += _vector(cyclesTable.additional, true, 0xEA);
        break;
      case 0xEB: // ORI (ab), i
        o16 = _readOp16();
        o8 = _readOp8();
        _orMemory(_me0(o16), o8);
        break;
      case 0xEC: // VEJ (EC)
        cycles += _vector(cyclesTable.additional, true, 0xEC);
        break;
      case 0xED: // BII (ab), i
        o8 = _readOp16Ind(0);
        p8 = _readOp8();
        _bit(o8, p8);
        break;
      case 0xEE: // VEJ (EE)
        cycles += _vector(cyclesTable.additional, true, 0xEE);
        break;
      case 0xEF: // ADI (ab), i
        o16 = _readOp16();
        o8 = _readOp8();
        _addMemory(_me0(o16), o8);
        break;

      case 0xF0: // VEJ (F0)
        cycles += _vector(cyclesTable.additional, true, 0xF0);
        break;
      case 0xF1: // AEX
        _aex();
        break;
      case 0xF2: // VEJ (F2)
        cycles += _vector(cyclesTable.additional, true, 0xF2);
        break;
      case 0xF4: // VEJ (F4)
        cycles += _vector(cyclesTable.additional, true, 0xF4);
        break;
      case 0xF5: // TIN
        _tin();
        break;
      case 0xF6: // VEJ (F6)
        cycles += _vector(cyclesTable.additional, true, 0xF6);
        break;
      case 0xF7: // CIN
        _cin();
        break;
      case 0xF9: // REC
        t.c = false;
        break;
      case 0xFB: // SEC
        t.c = true;
        break;

      default:
        throw LH5801Error(
          'illegal opcode ${OperandDump.op8(opcode)} at address ${OperandDump.op16(startP)}',
        );
    }

    return cycles;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LH5801CPU &&
          runtimeType == other.runtimeType &&
          _pins == other._pins &&
          clockFrequency == other.clockFrequency &&
          p == other.p &&
          s == other.s &&
          a == other.a &&
          x == other.x &&
          y == other.y &&
          u == other.u &&
          tm == other.tm &&
          t == other.t &&
          ir0 == other.ir0 &&
          ir1 == other.ir1 &&
          ir2 == other.ir2 &&
          hlt == other.hlt;

  @override
  int get hashCode =>
      _pins.hashCode ^
      clockFrequency.hashCode ^
      p.hashCode ^
      s.hashCode ^
      a.hashCode ^
      x.hashCode ^
      y.hashCode ^
      u.hashCode ^
      tm.hashCode ^
      t.hashCode ^
      ir0.hashCode ^
      ir1.hashCode ^
      ir2.hashCode ^
      hlt.hashCode;
}
