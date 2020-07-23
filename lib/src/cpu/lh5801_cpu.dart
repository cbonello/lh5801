import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'cpu.dart';

part 'lh5801_state.dart';
part 'lh5801_cpu.g.dart';

typedef LH5801Instruction = void Function();

class LH5801CPU extends LH5801State {
  LH5801CPU({
    @required LH5801Core core,
    @required this.clockFrequency,
  })  : assert(core != null),
        _core = core;

  final LH5801Core _core;
  final int clockFrequency;

  void MI() => ir2 = true;

  void NMI() => ir0 = true;

  void BFI() => throw Exception();

  @override
  void reset() {
    super.reset();
    p.high = _core.memRead(_me0(0xFFFE));
    p.low = _core.memRead(_me0(0xFFFF));
  }

  int _me0(int address) => address & 0xFFFF;
  int _me1(int address) => 0x10000 | address & 0xFFFF;

  int _readOp8() {
    final int op8 = _core.memRead(p.value);
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
    return _core.memRead((b << 16) | ab);
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
    final int m = _core.memRead(address);
    final int sum = _binaryAdd(m, value);
    _core.memWrite(address, sum);
  }

  void _addRegister(Register16 register) {
    final int savedFlags = t.statusRegister;
    final int low = register.low;
    register.low = _binaryAdd(low, a.value);
    if (t.c) {
      register.high++;
    }
    t.statusRegister = savedFlags;
  }

  void _aex() => a._value = (a._value << 4) | (a._value >> 4);

  void _am0() => tm = a._value;

  void _am1() {
    tm = 0x100 | a._value;
    // _ir2 = tm.isInterruptRaised()
  }

  void _andAccumulator(int value) {
    a.value &= value;
    t.z = a.value == 0;
  }

  void _andMemory(int address, int value) {
    final int m = _core.memRead(address);
    final int andValue = m & value;
    t.z = (andValue & 0xFF) == 0;
    _core.memWrite(address, andValue);
  }

  void _atp(int value) => _core.dataBus(value);

  void _att() => t.statusRegister = a.value;

  int _branchForward(int addCyclesTable, {bool cond = false}) {
    int cpuCycles = 0;
    final int offset = _readOp8();
    if (cond) {
      cpuCycles += addCyclesTable;
      p.value += offset;
    }
    return cpuCycles;
  }

  int _branchBackward(int addCyclesTable, {bool cond = false}) {
    int cpuCycles = 0;
    final int offset = _readOp8();
    if (cond) {
      cpuCycles += addCyclesTable;
      p.value -= offset;
    }
    return cpuCycles;
  }

  void _bit(int value1, int value2) => t.z = (value1 & value2) == 0;

  void _bii(int address, int value) {
    final int m = _core.memRead(address);
    final int andValue = m & value;
    t.z = (andValue & 0xFF) == 0;
  }

  void _cpi(int value1, int value2) => _binaryAdd(value1, (value2 ^ 0xFF) + 1);

  void _cin() {
    final int m = _core.memRead(_me0(x.value));
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

  void _decRegister8(Register8 register) =>
      register.value = _binaryAdd(register.value, 0x01 ^ 0xFF + 1);

  void _decRegister16(Register16 register) => register.value -= 1;

  void _drl(int address) {
    final int m = _core.memRead(address);
    final int tmp = m << 8 | a.value;
    a.value = m;
    _core.memWrite(address, tmp >> 4);
  }

  void _drr(int address) {
    final int m = _core.memRead(address);
    final int tmp = a.value << 8 | m;
    a.value = tmp;
    _core.memWrite(address, tmp >> 4);
  }

  void _eor(int value) {
    a.value ^= value;
    t.z = a.value == 0;
  }

  void _ita() {
    // TODO Handle IN
    a.value = 0;
    t.z = a.value == 0;
  }

  void _jmp(int address) => p.value = address;

  void _lda(int value) {
    a.value = value;
    t.z = a.value == 0;
  }

  void _lde(Register16 register) {
    a.value = _core.memRead(_me0(register.value));
    _decRegister16(register);
    t.z = a.value == 0;
  }

  void _ldx(Register16 register) => x.value = register.value;

  void _lin(Register16 register) {
    a.value = _core.memRead(_me0(register.value));
    register.value++;
    ;
    t.z = a.value == 0;
  }

  int _lop(int addCyclesTable, int d) {
    int cycles = 0;
    u.low--;
    if (u.low >= 0) {
      cycles += addCyclesTable;
      p.value -= d;
    }
    return cycles;
  }

  void _orAccumulator(int value) {
    a.value |= value;
    t.z = a.value == 0;
  }

  void _orMemory(int address, int value) {
    final int m = _core.memRead(address);
    final int orValue = value | m;
    _core.memWrite(address, orValue);
    t.z = orValue == 0;
  }

  int _pop8() {
    s.value++;
    return _core.memRead(_me0(s.value));
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
    register.high = _pop8();
    register.low = _pop8();
  }

  void _push8(int value) {
    _core.memWrite(_me0(s.value), value);
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

  int unsignedByteToInt(int value) {
    if (value & 0x80 != 0) {
      return -((0xff & ~value) + 1);
    }
    return value;
  }

  void _rtn() => _popRegister(p);

  void _sbc(int value) => a.value = _binaryAdd(a.value, value ^ 0xFF, carry: t.c);

  void _sde(Register16 register) => _core.memWrite(register.value, a.value);

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

  void _sin(Register16 register) => _core.memWrite(_me0(register.value), a.value);

  void _sjp(int address) {
    _push16(p.value);
    p.value = address;
  }

  void _tin() {
    final int m = _core.memRead(_me0(x.value));
    _core.memWrite(_me0(y.value), m);
    y.value++;
    x.value++;
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
      final int h = _core.memRead(_me0(0xFF00 + vectorID));
      final int l = _core.memRead(_me0(0xFF00 + vectorID + 1));
      p.value = (h << 8) | l;
    }
    t.z = false;
    return cycles;
  }

  int step() {
    final int opcode = _readOp8();
    int cycles;

    if (opcode == 0xFD) {
      cycles = stepExtendedInstruction();
    }

    return cycles;
  }

  int stepExtendedInstruction() {
    final int opcode = _readOp8();
    final CyclesCount cyclesTable = instructionTableFD[opcode].cycles;
    final int cycles = cyclesTable.basic;
    int o8, p8, o16;

    switch (opcode) {
      case 0x01: // SBC #(X)
        _sbc(_core.memRead(_me1(x.value)));
        break;
      case 0x03: // ADC #(X)
        _addAccumulator(_core.memRead(_me1(x.value)));
        break;
      case 0x05: // LDA #(X)
        _lda(_core.memRead(_me1(x.value)));
        break;
      case 0x07: // CPA #(X)
        _cpi(a.value, _core.memRead(_me1(x.value)));
        break;
      case 0x08: // LDX X
        //_ldx(x);
        break;
      case 0x09: // AND #(X)
        _andAccumulator(_core.memRead(_me1(x.value)));
        break;
      case 0x0A: // POP X
        _popRegister(x);
        break;
      case 0x0B: // ORA #(X)
        _orAccumulator(_core.memRead(_me1(x.value)));
        break;
      case 0x0C: // DCS #(X)
        _dcs(_core.memRead(_me1(x.value)));
        break;
      case 0x0D: // EOR #(X)
        _eor(_core.memRead(_me1(x.value)));
        break;
      case 0x0E: // STA #(X)
        _core.memWrite(_me1(x.value), a.value);
        break;
      case 0x0F: // BIT #(X)
        _bit(_core.memRead(_me1(x.value)), a.value);
        break;

      case 0x11: // SBC #(Y)
        _sbc(_core.memRead(_me1(y.value)));
        break;
      case 0x13: // ADC #(Y)
        _addAccumulator(_core.memRead(_me1(y.value)));
        break;
      case 0x15: // LDA #(Y)
        _lda(_core.memRead(_me1(y.value)));
        break;
      case 0x17: // CPA #(Y)
        _cpi(a.value, _core.memRead(_me1(y.value)));
        break;
      case 0x18: // LDX Y
        _ldx(y);
        break;
      case 0x19: // AND #(Y)
        _andAccumulator(_core.memRead(_me1(y.value)));
        break;
      case 0x1A: // POP Y
        _popRegister(y);
        break;
      case 0x1B: // ORA #(Y)
        _orAccumulator(_core.memRead(_me1(y.value)));
        break;
      case 0x1C: //DCS #(Y)
        _dcs(_core.memRead(_me1(y.value)));
        break;
      case 0x1D: // EOR #(Y)
        _eor(_core.memRead(_me1(y.value)));
        break;
      case 0x1E: // STA #(Y)
        _core.memWrite(_me1(y.value), a.value);
        break;
      case 0x1F: // BIT #(Y)
        _bit(_core.memRead(_me1(y.value)), a.value);
        break;

      case 0x21: // SBC #(U)
        _sbc(_core.memRead(_me1(u.value)));
        break;
      case 0x23: // ADC #(U)
        _addAccumulator(_core.memRead(_me1(u.value)));
        break;
      case 0x25: // LDA #(U)
        _lda(_core.memRead(_me1(u.value)));
        break;
      case 0x27: // CPA #(U)
        _cpi(a.value, _core.memRead(_me1(u.value)));
        break;
      case 0x28: // LDX U
        _ldx(u);
        break;
      case 0x29: // AND #(U)
        _andAccumulator(_core.memRead(_me1(u.value)));
        break;
      case 0x2A: // POP U
        _popRegister(u);
        break;
      case 0x2B: // ORA #(U)
        _orAccumulator(_core.memRead(_me1(u.value)));
        break;
      case 0x2C: // DCS #(U)
        _dcs(_core.memRead(_me1(u.value)));
        break;
      case 0x2D: // EOR #(U)
        _eor(_core.memRead(_me1(u.value)));
        break;
      case 0x2E: // STA #(U)
        _core.memWrite(_me1(u.value), a.value);
        break;
      case 0x2F: // BIT #(U)
        _bit(_core.memRead(_me1(u.value)), a.value);
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
        // TODO: fix.
        // _bf = false;
        break;
      case 0x4D: // BII #(X), i
        _bii(_me1(x.value), _readOp8());
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
        _bii(_me1(y.value), _readOp8());
        break;
      case 0x5E: // STX P
        _jmp(_me0(x.value));
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
        _bii(_me1(u.value), _readOp8());
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
        _dca(_core.memRead(_me1(x.value)));
        break;
      case 0x8E: // CDV
        print('lh5801 opcode FD 8E (CDV instruction) not implemented');
        break;

      case 0x98: // PSH Y
        _push16(y.value);
        break;
      case 0x9C: // DCA #(Y)
        _dca(_core.memRead(_me1(y.value)));
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
        _dca(_core.memRead(_me1(u.value)));
        break;
      case 0xAD: // EOR #(ab)
        _eor(_readOp16Ind(1));
        break;
      case 0xAE: // STA #(ab)
        _core.memWrite(_readOp16(), a.value);
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
        disp = false;
        break;
      case 0xC1: // SDP
        disp = true;
        break;
      case 0xC8: // PSH A
        _push8(a.value);
        break;
      case 0xCA: // ADR X
        _addRegister(x);
        break;
      case 0xCC: // ATP
        _atp(a.value);
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
        print('LH5801 illegal opcode: $opcode');
    }

    return cycles;
  }

// int stepOpcode(int opcode)  {
// 	final int cyclesTable = instructionTable[opcode].cycles;
// 	int cycles = cyclesTable.basic;

// 	switch (opcode) {
// 	case 0x00: // SBC XL
// 		cpu.sbc(*cpu.x.Low())
// 	case 0x01: // SBC (X)
// 		if o8, err = cpu.Read(_me0(x.value)); err == nil {
// 			cpu.sbc(o8)
// 		}
// 	case 0x02: // ADC XL
// 		cpu.addAccumulator(*cpu.x.Low())
// 	case 0x03: // ADC (X)
// 		if o8, err = cpu.Read(_me0(x.value)); err == nil {
// 			cpu.addAccumulator(o8)
// 		}
// 	case 0x04: // LDA XL
// 		cpu.lda(*cpu.x.Low())
// 	case 0x05: // LDA (X)
// 		if o8, err = cpu.Read(_me0(x.value)); err == nil {
// 			cpu.lda(o8)
// 		}
// 	case 0x06: // CPA XL
// 		cpu.cpi(a.value, *cpu.x.Low())
// 	case 0x07: // CPA (X)
// 		if o8, err = cpu.Read(_me0(x.value)); err == nil {
// 			cpu.cpi(a.value, o8)
// 		}
// 	case 0x08: // STA XH
// 		*cpu.x.High() = a.value
// 	case 0x09: // AND (X)
// 		if o8, err = cpu.Read(_me0(x.value)); err == nil {
// 			cpu.andAccumulator(o8)
// 		}
// 	case 0x0A: // STA XL
// 		*cpu.x.Low() = a.value
// 	case 0x0B: // ORA (X)
// 		if o8, err = cpu.Read(_me0(x.value)); err == nil {
// 			cpu.orAccumulator(o8)
// 		}
// 	case 0x0C: // DCS (X)
// 		if o8, err = cpu.Read(_me0(x.value)); err == nil {
// 			cpu.dcs(o8)
// 		}
// 	case 0x0D: // EOR (X)
// 		if o8, err = cpu.Read(_me0(x.value)); err == nil {
// 			cpu.eor(o8)
// 		}
// 	case 0x0E: // STA (X)
// 		err = cpu.Write(_me0(x.value), a.value)
// 	case 0x0F: // BIT (X)
// 		if o8, err = cpu.Read(_me0(x.value)); err == nil {
// 			cpu.bit(a.value, o8)
// 		}

// 	case 0x10: // SBC YL
// 		cpu.sbc(*cpu.y.Low())
// 	case 0x11: // SBC (Y)
// 		if o8, err = cpu.Read(_me0(cpu.y.Value())); err == nil {
// 			cpu.sbc(o8)
// 		}
// 	case 0x12: // ADC YL
// 		cpu.addAccumulator(*cpu.y.Low())
// 	case 0x13: // ADC (Y)
// 		if o8, err = cpu.Read(_me0(cpu.y.Value())); err == nil {
// 			cpu.addAccumulator(o8)
// 		}
// 	case 0x14: // LDA YL
// 		cpu.lda(*cpu.y.Low())
// 	case 0x15: // LDA (Y)
// 		if o8, err = cpu.Read(_me0(cpu.y.Value())); err == nil {
// 			cpu.lda(o8)
// 		}
// 	case 0x16: // CPA YL
// 		cpu.cpi(a.value, *cpu.y.Low())
// 	case 0x17: // CPA (Y)
// 		if o8, err = cpu.Read(_me0(cpu.y.Value())); err == nil {
// 			cpu.cpi(a.value, o8)
// 		}
// 	case 0x18: // STA YH
// 		*cpu.y.High() = a.value
// 	case 0x19: // AND (Y)
// 		if o8, err = cpu.Read(_me0(cpu.y.Value())); err == nil {
// 			cpu.andAccumulator(o8)
// 		}
// 	case 0x1A: // STA YL
// 		*cpu.y.Low() = a.value
// 	case 0x1B: // ORA (Y)
// 		if o8, err = cpu.Read(_me0(cpu.y.Value())); err == nil {
// 			cpu.orAccumulator(o8)
// 		}
// 	case 0x1C: // DCS (Y)
// 		if o8, err = cpu.Read(_me0(cpu.y.Value())); err == nil {
// 			cpu.dcs(o8)
// 		}
// 	case 0x1D: // EOR (Y)
// 		if o8, err = cpu.Read(_me0(cpu.y.Value())); err == nil {
// 			cpu.eor(o8)
// 		}
// 	case 0x1E: // STA (Y)
// 		err = cpu.Write(_me0(cpu.y.Value()), a.value)
// 	case 0x1F: // BIT (Y)
// 		if o8, err = cpu.Read(_me0(cpu.y.Value())); err == nil {
// 			cpu.bit(a.value, o8)
// 		}

// 	case 0x20: // SBC UL
// 		cpu.sbc(*cpu.u.Low())
// 	case 0x21: // SBC (U)
// 		if o8, err = cpu.Read(_me0(cpu.u.Value())); err == nil {
// 			cpu.sbc(o8)
// 		}
// 	case 0x22: // ADC UL
// 		cpu.addAccumulator(*cpu.u.Low())
// 	case 0x23: // ADC (U)
// 		if o8, err = cpu.Read(_me0(cpu.u.Value())); err == nil {
// 			cpu.addAccumulator(o8)
// 		}
// 	case 0x24: // LDA UL
// 		cpu.lda(*cpu.u.Low())
// 	case 0x25: // LDA (U)
// 		if o8, err = cpu.Read(_me0(cpu.u.Value())); err == nil {
// 			cpu.lda(o8)
// 		}
// 	case 0x26: // CPA UL
// 		cpu.cpi(a.value, *cpu.u.Low())
// 	case 0x27: // CPA (U)
// 		if o8, err = cpu.Read(_me0(cpu.u.Value())); err == nil {
// 			cpu.cpi(a.value, o8)
// 		}
// 	case 0x28: // STA UH
// 		*cpu.u.High() = a.value
// 	case 0x29: // AND (U)
// 		if o8, err = cpu.Read(_me0(cpu.u.Value())); err == nil {
// 			cpu.andAccumulator(o8)
// 		}
// 	case 0x2A: // STA UL
// 		*cpu.u.Low() = a.value
// 	case 0x2B: // ORA (U)
// 		if o8, err = cpu.Read(_me0(cpu.u.Value())); err == nil {
// 			cpu.orAccumulator(o8)
// 		}
// 	case 0x2C: // DCS (U)
// 		if o8, err = cpu.Read(_me0(cpu.u.Value())); err == nil {
// 			cpu.dcs(o8)
// 		}
// 	case 0x2D: // EOR (U)
// 		if o8, err = cpu.Read(_me0(cpu.u.Value())); err == nil {
// 			cpu.eor(o8)
// 		}
// 	case 0x2E: // STA (U)
// 		err = cpu.Write(_me0(cpu.u.Value()), a.value)
// 	case 0x2F: // BIT (U)
// 		if o8, err = cpu.Read(_me0(cpu.u.Value())); err == nil {
// 			cpu.bit(a.value, o8)
// 		}

// 	case 0x38: // NOP
// 		break

// 	case 0x40: // INC XL
// 		cpu.incRegister8(cpu.x.Low())
// 	case 0x41: // SIN X
// 		err = cpu.sin(&cpu.x)
// 	case 0x42: // DEC XL
// 		cpu.decRegister8(cpu.x.Low())
// 	case 0x43: // SDE X
// 		err = cpu.sde(&cpu.x)
// 	case 0x44: // INC X
// 		cpu.incRegister16(&cpu.x)
// 	case 0x45: // LIN X
// 		err = cpu.lin(&cpu.x)
// 	case 0x46: // DEC X
// 		cpu.decRegister16(&cpu.x)
// 	case 0x47: // LDE X
// 		err = cpu.lde(&cpu.x)
// 	case 0x48: // LDI XH, i
// 		*cpu.x.High(), err = cpu.readOp8()
// 	case 0x49: // ANI (X), i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			err = cpu.andMemory(_me0(x.value), o8)
// 		}
// 	case 0x4A: // LDI XL, i
// 		*cpu.x.Low(), err = cpu.readOp8()
// 	case 0x4B: // OR (X), i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			err = cpu.orMemory(_me0(x.value), o8)
// 		}
// 	case 0x4C: // CPI XH, i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			cpu.cpi(*cpu.x.High(), o8)
// 		}
// 	case 0x4D: // BII (X), i
// 		if p8, err = cpu.readOp8(); err == nil {
// 			if o8, err = cpu.Read(_me0(x.value)); err == nil {
// 				cpu.bit(o8, p8)
// 			}
// 		}
// 	case 0x4E: // CPI XL, i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			cpu.cpi(*cpu.x.Low(), o8)
// 		}
// 	case 0x4F: // ADI (X), i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			err = cpu.addMemory(_me0(x.value), o8)
// 		}

// 	case 0x50: // INC YL
// 		cpu.incRegister8(cpu.y.Low())
// 	case 0x51: // SIN Y
// 		err = cpu.sin(&cpu.y)
// 	case 0x52: // DEC YL
// 		cpu.decRegister8(cpu.y.Low())
// 	case 0x53: // SDE Y
// 		err = cpu.sde(&cpu.y)
// 	case 0x54: // INC Y
// 		cpu.incRegister16(&cpu.y)
// 	case 0x55: // LIN Y
// 		err = cpu.lin(&cpu.y)
// 	case 0x56: // DEC Y
// 		cpu.decRegister16(&cpu.y)
// 	case 0x57: // LDE Y
// 		err = cpu.lde(&cpu.y)
// 	case 0x58: // LDI YH, i
// 		*cpu.y.High(), err = cpu.readOp8()
// 	case 0x59: // ANI (Y), i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			err = cpu.andMemory(_me0(cpu.y.Value()), o8)
// 		}
// 	case 0x5A: // LDI YL, i
// 		*cpu.y.Low(), err = cpu.readOp8()
// 	case 0x5B: // OR (Y), i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			err = cpu.orMemory(_me0(cpu.y.Value()), o8)
// 		}
// 	case 0x5C: // CPI YH, i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			cpu.cpi(*cpu.y.High(), o8)
// 		}
// 	case 0x5D: // BII (Y), i
// 		if p8, err = cpu.readOp8(); err == nil {
// 			if o8, err = cpu.Read(_me0(cpu.y.Value())); err == nil {
// 				cpu.bit(o8, p8)
// 			}
// 		}
// 	case 0x5E: // CPI YL, i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			cpu.cpi(*cpu.y.Low(), o8)
// 		}
// 	case 0x5F: // ADI (Y), i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			err = cpu.addMemory(_me0(cpu.y.Value()), o8)
// 		}

// 	case 0x60: // INC UL
// 		cpu.incRegister8(cpu.u.Low())
// 	case 0x61: // SIN U
// 		err = cpu.sin(u)
// 	case 0x62: // DEC UL
// 		cpu.decRegister8(cpu.u.Low())
// 	case 0x63: // SDE U
// 		err = cpu.sde(u)
// 	case 0x64: // INC U
// 		cpu.incRegister16(u)
// 	case 0x65: // LIN U
// 		err = cpu.lin(u)
// 	case 0x66: // DEC U
// 		cpu.decRegister16(u)
// 	case 0x67: // LDE U
// 		err = cpu.lde(u)
// 	case 0x68: // LDI UH, i
// 		*cpu.u.High(), err = cpu.readOp8()
// 	case 0x69: // ANI (U), i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			err = cpu.andMemory(_me0(cpu.u.Value()), o8)
// 		}
// 	case 0x6A: // LDI UL, i
// 		*cpu.u.Low(), err = cpu.readOp8()
// 	case 0x6B: // OR (U), i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			err = cpu.orMemory(_me0(cpu.u.Value()), o8)
// 		}
// 	case 0x6C: // CPI UH, i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			cpu.cpi(*cpu.u.High(), o8)
// 		}
// 	case 0x6D: // BII (U), i
// 		if p8, err = cpu.readOp8(); err == nil {
// 			if o8, err = cpu.Read(_me0(cpu.u.Value())); err == nil {
// 				cpu.bit(o8, p8)
// 			}
// 		}
// 	case 0x6E: // CPI UL, i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			cpu.cpi(*cpu.u.Low(), o8)
// 		}
// 	case 0x6F: // ADI (U), i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			err = cpu.addMemory(_me0(cpu.u.Value()), o8)
// 		}

// 	case 0x80: // SBC XH
// 		cpu.sbc(*cpu.x.High())
// 	case 0x81: // BCR + i
// 		if c, err = cpu.branchForward(cyclesTable.Additional, cpu.t.Value(FlagC) == false); err == nil {
// 			cycles += c
// 		}
// 	case 0x82: // ADC XH
// 		cpu.addAccumulator(*cpu.x.High())
// 	case 0x83: // BCS + i
// 		if c, err = cpu.branchForward(cyclesTable.Additional, cpu.t.Value(FlagC)); err == nil {
// 			cycles += c
// 		}
// 	case 0x84: // LDA XH
// 		a.value = *cpu.x.High()
// 	case 0x85: // BHR + i
// 		if c, err = cpu.branchForward(cyclesTable.Additional, cpu.t.Value(FlagH) == false); err == nil {
// 			cycles += c
// 		}
// 	case 0x86: // CPA XH
// 		cpu.cpi(a.value, *cpu.x.High())
// 	case 0x87: // BHS + i
// 		if c, err = cpu.branchForward(cyclesTable.Additional, cpu.t.Value(FlagH)); err == nil {
// 			cycles += c
// 		}
// 	case 0x88: // LOP UL, i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			if c, err = cpu.lop(cyclesTable.Additional, o8); err == nil {
// 				cycles += c
// 			}
// 		}
// 	case 0x89: // BZR + i
// 		if c, err = cpu.branchForward(cyclesTable.Additional, cpu.t.Value(FlagZ) == false); err == nil {
// 			cycles += c
// 		}
// 	case 0x8A: // RTI
// 		err = cpu.rti()
// 	case 0x8B: // BZS + i
// 		if c, err = cpu.branchForward(cyclesTable.Additional, cpu.t.Value(FlagZ)); err == nil {
// 			cycles += c
// 		}
// 	case 0x8C: // DCA (X)
// 		if o8, err = cpu.Read(_me0(x.value)); err == nil {
// 			cpu.dca(o8)
// 		}
// 	case 0x8D: // BVR + i
// 		if c, err = cpu.branchForward(cyclesTable.Additional, cpu.t.Value(FlagV) == false); err == nil {
// 			cycles += c
// 		}
// 	case 0x8E: // BCH + i
// 		if c, err = cpu.branchForward(cyclesTable.Additional, true); err == nil {
// 			cycles += c
// 		}
// 	case 0x8F: // BVS + i
// 		if c, err = cpu.branchForward(cyclesTable.Additional, cpu.t.Value(FlagV)); err == nil {
// 			cycles += c
// 		}

// 	case 0x90: // SBC YH
// 		cpu.sbc(*cpu.y.High())
// 	case 0x91: // BCR - i
// 		if c, err = cpu.branchBackward(cyclesTable.Additional, cpu.t.Value(FlagC) == false); err == nil {
// 			cycles += c
// 		}
// 	case 0x92: // ADC YH
// 		cpu.addAccumulator(*cpu.y.High())
// 	case 0x93: // BCS - i
// 		if c, err = cpu.branchBackward(cyclesTable.Additional, cpu.t.Value(FlagC)); err == nil {
// 			cycles += c
// 		}
// 	case 0x94: // LDA YH
// 		a.value = *cpu.y.High()
// 	case 0x95: // BHR - i
// 		if c, err = cpu.branchBackward(cyclesTable.Additional, cpu.t.Value(FlagH) == false); err == nil {
// 			cycles += c
// 		}
// 	case 0x96: // CPA YH
// 		cpu.cpi(a.value, *cpu.y.High())
// 	case 0x97: // BHS - i
// 		if c, err = cpu.branchBackward(cyclesTable.Additional, cpu.t.Value(FlagH)); err == nil {
// 			cycles += c
// 		}
// 	case 0x99: // BZR - i
// 		if c, err = cpu.branchBackward(cyclesTable.Additional, cpu.t.Value(FlagZ) == false); err == nil {
// 			cycles += c
// 		}
// 	case 0x9A: // RTN
// 		err = cpu.rtn()
// 	case 0x9B: // BZS - i
// 		if c, err = cpu.branchBackward(cyclesTable.Additional, cpu.t.Value(FlagZ)); err == nil {
// 			cycles += c
// 		}
// 	case 0x9C: // DCA (Y)
// 		if o8, err = cpu.Read(_me0(cpu.y.Value())); err == nil {
// 			cpu.dca(o8)
// 		}
// 	case 0x9D: // BVR - i
// 		if c, err = cpu.branchBackward(cyclesTable.Additional, cpu.t.Value(FlagV) == false); err == nil {
// 			cycles += c
// 		}
// 	case 0x9E: // BCH - i
// 		if c, err = cpu.branchBackward(cyclesTable.Additional, true); err == nil {
// 			cycles += c
// 		}
// 	case 0x9F: // BVS - i
// 		if c, err = cpu.branchBackward(cyclesTable.Additional, cpu.t.Value(FlagV)); err == nil {
// 			cycles += c
// 		}

// 	case 0xA0: // SBC UH
// 		cpu.sbc(*cpu.u.High())
// 	case 0xA1: // SBC (ab)
// 		if o8, err = cpu.readOp16Ind(0); err == nil {
// 			cpu.sbc(o8)
// 		}
// 	case 0xA2: // ADC UH
// 		cpu.addAccumulator(*cpu.u.High())
// 	case 0xA3: // ADC (ab)
// 		if o8, err = cpu.readOp16Ind(0); err == nil {
// 			cpu.addAccumulator(o8)
// 		}
// 	case 0xA4: // LDA UH
// 		a.value = *cpu.u.High()
// 	case 0xA5: // LDA (ab)
// 		if o8, err = cpu.readOp16Ind(0); err == nil {
// 			a.value = o8
// 		}
// 	case 0xA6: // CPA UH
// 		cpu.cpi(a.value, *cpu.u.High())
// 	case 0xA7: // CPA (ab)
// 		if o8, err = cpu.readOp16Ind(0); err == nil {
// 			cpu.cpi(a.value, o8)
// 		}
// 	case 0xA8: // SPV
// 		cpu.PV(true)
// 	case 0xA9: // AND (ab)
// 		if o8, err = cpu.readOp16Ind(0); err == nil {
// 			cpu.andAccumulator(o8)
// 		}
// 	case 0xAA: // LDI S, i, j
// 		if o16, err = cpu.readOp16(); err == nil {
// 			cpu.s.Update(o16)
// 		}
// 	case 0xAB: // ORA (ab)
// 		if o8, err = cpu.readOp16Ind(0); err == nil {
// 			cpu.orAccumulator(o8)
// 		}
// 	case 0xAC: // DCA (U)
// 		if o8, err = cpu.Read(_me0(cpu.u.Value())); err == nil {
// 			cpu.dca(o8)
// 		}
// 	case 0xAD: // EOR (ab)
// 		if o8, err = cpu.readOp16Ind(0); err == nil {
// 			cpu.eor(o8)
// 		}
// 	case 0xAE: // STA (ab)
// 		if o16, err = cpu.readOp16(); err == nil {
// 			err = cpu.Write(_me0(o16), a.value)
// 		}
// 	case 0xAF: // BIT (ab)
// 		if o8, err = cpu.readOp16Ind(0); err == nil {
// 			cpu.bit(a.value, o8)
// 		}

// 	case 0xB1: // SBI i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			cpu.sbc(o8)
// 		}
// 	case 0xB3: // ADI A, i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			cpu.addAccumulator(o8)
// 		}
// 	case 0xB5: // LDI A, i
// 		a.value, err = cpu.readOp8()
// 	case 0xB7: // CPI A, i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			cpu.cpi(a.value, o8)
// 		}
// 	case 0xB8: // RPV
// 		cpu.PV(false)
// 	case 0xB9: // ANI A, i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			cpu.andAccumulator(o8)
// 		}
// 	case 0xBA: // JMP i, j
// 		if o16, err = cpu.readOp16(); err == nil {
// 			cpu.jmp(_me0(o16))
// 		}
// 	case 0xBB: // ORI A, i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			cpu.orAccumulator(o8)
// 		}
// 	case 0xBD: // EAI i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			cpu.eor(o8)
// 		}
// 	case 0xBE: // SJP
// 		if o16, err = cpu.readOp16(); err == nil {
// 			err = cpu.sjp(_me0(o16))
// 		}
// 	case 0xBF: // BII A, i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			cpu.bit(a.value, o8)
// 		}

// 	case 0xC0: // VEJ (C0)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xC0); err == nil {
// 			cycles += c
// 		}
// 	case 0xC1: // VCR i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			if c, err = cpu.vector(cyclesTable.Additional, cpu.t.Value(FlagC) == false, o8); err == nil {
// 				cycles += c
// 			}
// 		}
// 	case 0xC2: // VEJ (C2)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xC2); err == nil {
// 			cycles += c
// 		}
// 	case 0xC3: // VCS i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			if c, err = cpu.vector(cyclesTable.Additional, cpu.t.Value(FlagC), o8); err == nil {
// 				cycles += c
// 			}
// 		}
// 	case 0xC4: // VEJ (C4)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xC4); err == nil {
// 			cycles += c
// 		}
// 	case 0xC5: // VHR i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			if c, err = cpu.vector(cyclesTable.Additional, cpu.t.Value(FlagH) == false, o8); err == nil {
// 				cycles += c
// 			}
// 		}
// 	case 0xC6: // VEJ (C6)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xC6); err == nil {
// 			cycles += c
// 		}
// 	case 0xC7: // VHS i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			if c, err = cpu.vector(cyclesTable.Additional, cpu.t.Value(FlagH), o8); err == nil {
// 				cycles += c
// 			}
// 		}
// 	case 0xC8: // VEJ (C8)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xC8); err == nil {
// 			cycles += c
// 		}
// 	case 0xC9: // VZR i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			if c, err = cpu.vector(cyclesTable.Additional, cpu.t.Value(FlagZ) == false, o8); err == nil {
// 				cycles += c
// 			}
// 		}
// 	case 0xCA: // VEJ (CA)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xCA); err == nil {
// 			cycles += c
// 		}
// 	case 0xCB: // VZS i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			if c, err = cpu.vector(cyclesTable.Additional, cpu.t.Value(FlagZ), o8); err == nil {
// 				cycles += c
// 			}
// 		}
// 	case 0xCC: // VEJ (CC)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xCC); err == nil {
// 			cycles += c
// 		}
// 	case 0xCD: // VMJ i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			if c, err = cpu.vector(cyclesTable.Additional, true, o8); err == nil {
// 				cycles += c
// 			}
// 		}
// 	case 0xCE: // VEJ (CE)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xCE); err == nil {
// 			cycles += c
// 		}
// 	case 0xCF: // VVS i
// 		if o8, err = cpu.readOp8(); err == nil {
// 			if c, err = cpu.vector(cyclesTable.Additional, cpu.t.Value(FlagV), o8); err == nil {
// 				cycles += c
// 			}
// 		}

// 	case 0xD0: // VEJ (D0)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xD0); err == nil {
// 			cycles += c
// 		}
// 	case 0xD1: // ROR
// 		cpu.ror()
// 	case 0xD2: // VEJ (D2)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xD2); err == nil {
// 			cycles += c
// 		}
// 	case 0xD3: // DRR (X)
// 		err = cpu.drr(_me0(x.value))
// 	case 0xD4: // VEJ (D4)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xD4); err == nil {
// 			cycles += c
// 		}
// 	case 0xD5: // SHR
// 		cpu.shr()
// 	case 0xD6: // VEJ (D6)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xD6); err == nil {
// 			cycles += c
// 		}
// 	case 0xD7: // DRL (X)
// 		err = cpu.drl(_me0(x.value))
// 	case 0xD8: // VEJ (D8)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xD8); err == nil {
// 			cycles += c
// 		}
// 	case 0xD9: // SHL
// 		cpu.shl()
// 	case 0xDA: // VEJ (DA)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xDA); err == nil {
// 			cycles += c
// 		}
// 	case 0xDB: // ROL
// 		cpu.rol()
// 	case 0xDC: // VEJ (DC)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xDC); err == nil {
// 			cycles += c
// 		}
// 	case 0xDD: // INC A
// 		cpu.incRegister8(&a.value)
// 	case 0xDE: // VEJ (DE)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xDE); err == nil {
// 			cycles += c
// 		}
// 	case 0xDF: // DEC A
// 		cpu.decRegister8(&a.value)

// 	case 0xE0: // VEJ (E0)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xE0); err == nil {
// 			cycles += c
// 		}
// 	case 0xE1: // SPU
// 		cpu.PU(true)
// 	case 0xE2: // VEJ (E2)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xE2); err == nil {
// 			cycles += c
// 		}
// 	case 0xE3: // RPU
// 		cpu.PU(false)
// 	case 0xE4: // VEJ (E4)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xE4); err == nil {
// 			cycles += c
// 		}
// 	case 0xE6: // VEJ (E6)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xE6); err == nil {
// 			cycles += c
// 		}
// 	case 0xE8: // VEJ (E8)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xE8); err == nil {
// 			cycles += c
// 		}
// 	case 0xE9: // ANI (ab), i
// 		if o16, o8, err = cpu.readOp16Op8(); err == nil {
// 			err = cpu.andMemory(_me0(o16), o8)
// 		}
// 	case 0xEA: // VEJ (EA)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xEA); err == nil {
// 			cycles += c
// 		}
// 	case 0xEB: // ORI (ab), i
// 		if o16, o8, err = cpu.readOp16Op8(); err == nil {
// 			err = cpu.orMemory(_me0(o16), o8)
// 		}
// 	case 0xEC: // VEJ (EC)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xEC); err == nil {
// 			cycles += c
// 		}
// 	case 0xED: // BII (ab), i
// 		if o8, p8, err = cpu.readOp16IndOp8(0); err == nil {
// 			cpu.bit(o8, p8)
// 		}
// 	case 0xEE: // VEJ (EE)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xEE); err == nil {
// 			cycles += c
// 		}
// 	case 0xEF: // ADI (ab), i
// 		if o16, o8, err = cpu.readOp16Op8(); err == nil {
// 			err = cpu.addMemory(_me0(o16), o8)
// 		}

// 	case 0xF0: // VEJ (F0)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xF0); err == nil {
// 			cycles += c
// 		}
// 	case 0xF1: // AEX
// 		cpu.aex()
// 	case 0xF2: // VEJ (F2)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xF2); err == nil {
// 			cycles += c
// 		}
// 	case 0xF4: // VEJ (F4)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xF4); err == nil {
// 			cycles += c
// 		}
// 	case 0xF5: // TIN
// 		err = cpu.tin()
// 	case 0xF6: // VEJ (F6)
// 		if c, err = cpu.vector(cyclesTable.Additional, true, 0xF6); err == nil {
// 			cycles += c
// 		}
// 	case 0xF7: // CIN
// 		err = cpu.cin()
// 	case 0xF9: // REC
// 		cpu.t.Reset(FlagC)
// 	case 0xFB: // SEC
// 		cpu.t.Set(FlagC)

// 	default:
// 		err = fmt.Errorf("lh5801 illegal opcode: %v", opcode)
// 	}

// 	return
// }
}