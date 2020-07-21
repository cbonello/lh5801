import 'package:freezed_annotation/freezed_annotation.dart';

part 'lh5801_clock.freezed.dart';

@freezed
abstract class ClockFrequency with _$ClockFrequency {
  const factory ClockFrequency.frequency2Mhz() = _ClockFrequency2Mhz;
  const factory ClockFrequency.frequency1Mhz() = _ClockFrequency1Mhz;
  const factory ClockFrequency.frequency500Khz() = _ClockFrequency500Khz;
  const factory ClockFrequency.frequency250Khz() = _ClockFrequency250Khz;
  const factory ClockFrequency.frequency125Khz() = _ClockFrequency125Khz;
  const factory ClockFrequency.frequency62Khz() = _ClockFrequency62Khz;
  const factory ClockFrequency.frequency31Khz() = _ClockFrequency31Khz;
}

class ClockControl {
  ClockControl() : subClocks = <SubClock>[];

  final List<SubClock> subClocks;

  void addSubClock(SubClock subClock) => subClocks.add(subClock);

  void incrementClocks(int cpuCycles) {
    for (final SubClock subClock in subClocks) {
      subClock.incrementClock(cpuCycles);
    }
  }
}

class SubClock {
  void incrementClock(int cpuCycles) {}
  bool isInterruptRaised() => false;
}

// type clockControl struct {
// 	subClocks []subClock
// }

// type subClock interface {
// 	incrementClock(cpuCycles uint)
// 	isInterruptRaised() bool
// }

// func newClockControl(cpuClockFrequency uint) *clockControl {
// 	return &clockControl{}
// }

// func (c *clockControl) incrementClocks(cpuCycles uint) {
// 	for _, subClock := range c.subClocks {
// 		subClock.incrementClock(cpuCycles)
// 	}
// }

// type clockFrequency uint

// // Assumption: A 4Mhz cristal oscillator is used.
// const (
// 	frequency2Mhz   clockFrequency = 2000000
// 	frequency1Mhz                  = 1000000
// 	frequency500Khz                = 500000
// 	frequency250Khz                = 250000
// 	frequency125Khz                = 125000
// 	frequency62Khz                 = 62500
// 	frequency31Khz                 = 31250
// )

// func (c *clockControl) addSubClock(s subClock) {
// 	c.subClocks = append(c.subClocks, s)
// }

class ClockTimer {
  ClockTimer._({this.value, this.cpuCyclesPerTick, this.cpuCycles, this.interruptRaised});

//  factory ClockTimer({int cpuClockFrequency, ClockFrequency timerClockFrequency}) {
// 	final int cpuCyclesPerTick = (cpuClockFrequency.toDouble() / timerClockFrequency.toDouble()).round();

// return ClockTimer._(
// value:0,
// cpuCyclesPerTick: cpuCyclesPerTick,
// cpuCycles:        0,
// 		interruptRaised:  false,
// );
//   }

  int value;
  final int cpuCyclesPerTick;
  int cpuCycles;
  bool interruptRaised;
}

// type clockTimer struct {
// 	value uint16
// 	// Number of CPU cycles during one timer clock tick.
// 	cpuCyclesPerTick uint
// 	cpuCycles        uint
// 	interruptRaised  bool
// }

// func newClockTimer(cpuClockFrequency uint, timerClockFrequency clockFrequency) *clockTimer {
// 	cpuCyclesPerTick := math.Round(float64(cpuClockFrequency) / float64(timerClockFrequency))
// 	c := &clockTimer{
// 		value:            0,
// 		cpuCyclesPerTick: uint(cpuCyclesPerTick),
// 		cpuCycles:        0,
// 		interruptRaised:  false,
// 	}
// 	return c
// }

// func (c *clockTimer) set(value uint16) {
// 	c.value = value
// 	c.interruptRaised = (value == 0x1FF)
// }

// func (c *clockTimer) incrementClock(cpuCycles uint) {
// 	if c.cpuCycles+cpuCycles >= c.cpuCyclesPerTick {
// 		c.cpuCycles = (c.cpuCycles + cpuCycles) % c.cpuCyclesPerTick
// 		// A 9-bit linear-feedback shift register with taps at bits 9 and 3.
// 		nextValue := uint16(((c.value << 1) & 0x1FE) | (((c.value >> 8) ^ (c.value >> 3)) & 1))
// 		c.set(nextValue)
// 	}
// }

// func (c *clockTimer) isInterruptRaised() bool {
// 	return c.interruptRaised
// }

// type interruptTimer struct {
// 	// Number of CPU cycles during one timer clock tick.
// 	cpuCyclesPerTick uint
// 	cpuCycles        uint
// 	interruptRaised  bool
// }

// func newInterruptTimer(cpuClockFrequency uint, timerClockFrequency clockFrequency) *interruptTimer {
// 	cpuCyclesPerTick := math.Round(float64(cpuClockFrequency) / float64(timerClockFrequency))
// 	i := &interruptTimer{
// 		cpuCyclesPerTick: uint(cpuCyclesPerTick),
// 		cpuCycles:        0,
// 		interruptRaised:  false,
// 	}
// 	return i
// }

// func (i *interruptTimer) incrementClock(cpuCycles uint) {
// 	i.interruptRaised = false
// 	if i.cpuCycles+cpuCycles >= i.cpuCyclesPerTick {
// 		i.cpuCycles = (i.cpuCycles + cpuCycles) % i.cpuCyclesPerTick
// 		i.interruptRaised = true
// 	}
// }

// func (i *interruptTimer) isInterruptRaised() bool {
// 	return i.interruptRaised
// }
