import 'package:test/test.dart';

import 'package:lh5801/lh5801.dart';

// See PC-1500 Technical Reference Manual at page 15.
final List<int> expectedCounterValues = <int>[
  0x1FF,
  0x1FE,
  0x1FC,
  0x1F8,
  0x1F0,
  0x1E1,
  0x1C3,
  0x187,
  0x10F,
  0x01E,
  0x03D,
  0x07B,
  0x0F7,
  0x1EE,
  0x1DC,
  0x1B8,
  0x170,
  0x0E1,
  0x1C2,
  0x185,
  0x10B,
  0x016,
  0x02C,
  0x059,
  0x0B3,
  0x166,
  0x0CD,
  0x19B,
  0x136,
  0x06D,
  0x0DB,
  0x1B7,
  0x16F,
  0x0DE,
  0x1BD,
  0x17A,
  0x0F4,
  0x1E8,
  0x1D0,
  0x1A1,
  0x143,
  0x087,
  0x10E,
  0x01C,
  0x039,
  0x073,
  0x0E6,
  0x1CC,
  0x198,
  0x130,
  0x061,
  0x0C2,
  0x184,
  0x109,
  0x012,
  0x024,
  0x048,
  0x091,
  0x122,
  0x045,
  0x08A,
  0x115,
  0x02B,
  0x057,
  0x0AE,
  0x15D,
  0x0BA,
  0x175,
  0x0EB,
  0x1D7,
  0x1AF,
  0x15E,
  0x0BC,
  0x179,
  0x0F2,
  0x1E4,
  0x1C9,
  0x192,
  0x125,
  0x04B,
  0x097,
  0x12E,
  0x05C,
  0x0B9,
  0x173,
  0x0E7,
  0x1CE,
  0x19C,
  0x138,
  0x070,
  0x0E0,
  0x1C0,
  0x181,
  0x103,
  0x007,
  0x00E,
  0x01D,
  0x03B,
  0x077,
  0x0EE,
  0x1DD,
  0x1BA,
  0x174,
  0x0E9,
  0x1D3,
  0x1A7,
  0x14F,
  0x09E,
  0x13D,
  0x07A,
  0x0F5,
  0x1EA,
  0x1D4,
  0x1A9,
  0x152,
  0x0A5,
  0x14A,
  0x094,
  0x128,
  0x050,
  0x0A0,
  0x140,
  0x081,
  0x102,
  0x005,
  0x00A,
  0x015,
  0x02A,
  0x055,
  0x0AA,
  0x155,
  0x0AB,
  0x157,
  0x0AF,
  0x15F,
  0x0BE,
  0x17D,
  0x0FA,
  0x1F5,
  0x1EB,
  0x1D6,
  0x1AD,
  0x15A,
  0x0B4,
  0x168,
  0x0D0,
  0x1A0,
  0x141,
  0x083,
  0x106,
  0x00D,
  0x01B,
  0x037,
  0x06E,
  0x0DD,
  0x1BB,
  0x176,
  0x0ED,
  0x1DB,
  0x1B6,
  0x16D,
  0x0DA,
  0x1B5,
  0x16B,
  0x0D6,
  0x1AC,
  0x158,
  0x0B0,
  0x160,
  0x0C1,
  0x182,
  0x105,
  0x00B,
  0x017,
  0x02E,
  0x05D,
  0x0BB,
  0x177,
  0x0EF,
  0x1DF,
  0x1BE,
  0x17C,
  0x0F8,
  0x1F1,
  0x1E3,
  0x1C7,
  0x18F,
  0x11E,
  0x03C,
  0x079,
  0x0F3,
  0x1E6,
  0x1CD,
  0x19A,
  0x134,
  0x069,
  0x0D3,
  0x1A6,
  0x14D,
  0x09A,
  0x135,
  0x06B,
  0x0D7,
  0x1AE,
  0x15C,
  0x0B8,
  0x171,
  0x0E3,
  0x1C6,
  0x18D,
  0x11A,
  0x034,
  0x068,
  0x0D1,
  0x1A2,
  0x145,
  0x08B,
  0x117,
  0x02F,
  0x05F,
  0x0BF,
  0x17F,
  0x0FE,
  0x1FD,
  0x1FA,
  0x1F4,
  0x1E9,
  0x1D2,
  0x1A5,
  0x14B,
  0x096,
  0x12C,
  0x058,
  0x0B1,
  0x162,
  0x0C5,
  0x18A,
  0x114,
  0x029,
  0x053,
  0x0A6,
  0x14C,
  0x098,
  0x131,
  0x063,
  0x0C6,
  0x18C,
  0x118,
  0x030,
  0x060,
  0x0C0,
  0x180,
  0x101,
  0x003,
  0x006,
  0x00C,
  0x019,
  0x033,
  0x066,
  0x0CC,
  0x199,
  0x132,
  0x065,
  0x0CA,
  0x195,
  0x12B,
  0x056,
  0x0AC,
  0x159,
  0x0B2,
  0x164,
  0x0C9,
  0x193,
  0x127,
  0x04F,
  0x09F,
  0x13F,
  0x07E,
  0x0FD,
  0x1FB,
  0x1F6,
  0x1ED,
  0x1DA,
  0x1B4,
  0x169,
  0x0D2,
  0x1A4,
  0x149,
  0x092,
  0x124,
  0x049,
  0x093,
  0x126,
  0x04D,
  0x09B,
  0x137,
  0x06F,
  0x0DF,
  0x1BF,
  0x17E,
  0x0FC,
  0x1F9,
  0x1F2,
  0x1E5,
  0x1CB,
  0x196,
  0x12D,
  0x05A,
  0x0B5,
  0x16A,
  0x0D4,
  0x1A8,
  0x150,
  0x0A1,
  0x142,
  0x085,
  0x10A,
  0x014,
  0x028,
  0x051,
  0x0A2,
  0x144,
  0x089,
  0x113,
  0x027,
  0x04E,
  0x09D,
  0x13B,
  0x076,
  0x0EC,
  0x1D9,
  0x1B2,
  0x165,
  0x0CB,
  0x197,
  0x12F,
  0x05E,
  0x0BD,
  0x17B,
  0x0F6,
  0x1EC,
  0x1D8,
  0x1B0,
  0x161,
  0x0C3,
  0x186,
  0x10D,
  0x01A,
  0x035,
  0x06A,
  0x0D5,
  0x1AA,
  0x154,
  0x0A9,
  0x153,
  0x0A7,
  0x14E,
  0x09C,
  0x139,
  0x072,
  0x0E4,
  0x1C8,
  0x190,
  0x121,
  0x043,
  0x086,
  0x10C,
  0x018,
  0x031,
  0x062,
  0x0C4,
  0x188,
  0x110,
  0x021,
  0x042,
  0x084,
  0x108,
  0x010,
  0x020,
  0x040,
  0x080,
  0x100,
  0x001,
  0x002,
  0x004,
  0x008,
  0x011,
  0x022,
  0x044,
  0x088,
  0x111,
  0x023,
  0x046,
  0x08C,
  0x119,
  0x032,
  0x064,
  0x0C8,
  0x191,
  0x123,
  0x047,
  0x08E,
  0x11D,
  0x03A,
  0x075,
  0x0EA,
  0x1D5,
  0x1AB,
  0x156,
  0x0AD,
  0x15B,
  0x0B6,
  0x16C,
  0x0D8,
  0x1B1,
  0x163,
  0x0C7,
  0x18E,
  0x11C,
  0x038,
  0x071,
  0x0E2,
  0x1C4,
  0x189,
  0x112,
  0x025,
  0x04A,
  0x095,
  0x12A,
  0x054,
  0x0A8,
  0x151,
  0x0A3,
  0x146,
  0x08D,
  0x11B,
  0x036,
  0x06C,
  0x0D9,
  0x1B3,
  0x167,
  0x0CF,
  0x19F,
  0x13E,
  0x07C,
  0x0F9,
  0x1F3,
  0x1E7,
  0x1CF,
  0x19E,
  0x13C,
  0x078,
  0x0F1,
  0x1E2,
  0x1C5,
  0x18B,
  0x116,
  0x02D,
  0x05B,
  0x0B7,
  0x16E,
  0x0DC,
  0x1B9,
  0x172,
  0x0E5,
  0x1CA,
  0x194,
  0x129,
  0x052,
  0x0A4,
  0x148,
  0x090,
  0x120,
  0x041,
  0x082,
  0x104,
  0x009,
  0x013,
  0x026,
  0x04C,
  0x099,
  0x133,
  0x067,
  0x0CE,
  0x19D,
  0x13A,
  0x074,
  0x0E8,
  0x1D1,
  0x1A3,
  0x147,
  0x08F,
  0x11F,
  0x03E,
  0x07D,
  0x0FB,
  0x1F7,
  0x1EF,
  0x1DE,
  0x1BC,
  0x178,
  0x0F0,
  0x1E0,
  0x1C1,
  0x183,
  0x107,
  0x00F,
  0x01F,
  0x03F,
  0x07F,
  0x0FF,
  0x1FF,
];

void main() {
  group('LH5801Timer', () {
    test('should be initialized properly', () {
      final LH5801Timer timer = LH5801Timer(
        cpuClockFrequency: 1300000,
        timerClockFrequency: 31250,
      );

      expect(timer.value, isZero);
      expect(timer.isInterruptRaised, isFalse);
    });

    test('should generate the expected values', () {
      final LH5801Timer timer = LH5801Timer(
        cpuClockFrequency: 1300000,
        timerClockFrequency: 31250,
      );

      timer.value = LH5801Timer.maxCounterValue;
      for (final int expected in expectedCounterValues) {
        expect(timer.value, equals(expected));
        final bool ir2 = timer.incrementClock();
        expect(ir2, equals(timer.value == LH5801Timer.maxCounterValue));
      }
    });

    test('should raise an interrupt whenever a new timer value is generated',
        () {
      final LH5801Timer timer = LH5801Timer(
        cpuClockFrequency: 1300000,
        timerClockFrequency: 31250,
      );

      // Setting the timer to 0x1FF will require 510 clock cycles to raise the
      // interrupt.
      timer.value = 0x1FF;
      for (int i = 0; i < 511; i++) {
        timer.incrementClock();
      }
      expect(timer.isInterruptRaised, isTrue);
    });

    test('reset() should reset the timer', () {
      final LH5801Timer timer = LH5801Timer(
        cpuClockFrequency: 1300000,
        timerClockFrequency: 31250,
      );

      timer.value = 0x1FF;
      for (int i = 0; i < 511; i++) {
        timer.incrementClock();
      }
      timer.reset();
      expect(timer.isInterruptRaised, isFalse);
    });

    test('clone() should return an identical LH5801Pins instance', () {
      final LH5801Timer timer1 = LH5801Timer(
        cpuClockFrequency: 1300000,
        timerClockFrequency: 31250,
      );
      final LH5801Timer timer2 = timer1.clone();

      expect(timer1 == timer2, isTrue);
    });

    test('should be serialized/deserialized successfully', () {
      final LH5801Timer timer1 = LH5801Timer(
        cpuClockFrequency: 1300000,
        timerClockFrequency: 31250,
      )..incrementClock(10000);

      final Map<String, dynamic> state = timer1.saveState();
      final LH5801Timer timer2 = timer1.clone();

      timer1.reset();
      expect(timer1 == timer2, isFalse);

      timer1.restoreState(state);
      expect(timer1 == timer2, isTrue);
      expect(timer1.hashCode, equals(timer2.hashCode));
    });

    test('toString() should return the expected value', () {
      final LH5801Timer timer = LH5801Timer(
        cpuClockFrequency: 1300000,
        timerClockFrequency: 31250,
      );

      timer.value = 0x1FF;
      for (int i = 0; i < 511; i++) {
        timer.incrementClock();
      }

      expect(
        timer.toString(),
        equals('LH5801Timer(value: 1FF, interrupt: true)'),
      );
    });
  });
}
