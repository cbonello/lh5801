# Sharp LH5801 

[![build](https://github.com/cbonello/lh5801/workflows/CI/badge.svg)](https://github.com/cbonello/lh5801/actions)
[![codecov](https://codecov.io/gh/cbonello/lh5801/branch/master/graph/badge.svg)](https://codecov.io/gh/cbonello/lh5801)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

Sharp [LH5801](docs/PC1500.TechnicalReferenceManual.pdf?raw=true) 8-bit Microprocessor emulator written in Dart.

This package is part of an ongoing project of writing a [Sharp PC-1500](https://en.wikipedia.org/wiki/Sharp_PC-1500) emulator with Dart/Flutter.

## Features

- **Emulator** — cycle-accurate LH5801 CPU emulation.
- **Assembler** — assemble LH5801 source files into binary.
- **Disassembler** — disassemble binary back to LH5801 mnemonics.
- **CLI tool** — command-line interface for assembling and disassembling files.

## Requirements

Dart SDK `>=3.10.0 <4.0.0`

## Installation

Add `lh5801` as a dependency in your `pubspec.yaml`:

```yaml
dependencies:
  lh5801:
    git:
      url: https://github.com/cbonello/lh5801.git
```

Then run:

```bash
$ dart pub get
```

## Usage

See `example/` folder for a complete example that inverts the LCD screen of a Sharp PC-1500.

```bash
$ dart run example/main.dart
```

## CLI

The package includes a command-line tool for assembling and disassembling files.

```bash
# Assemble a source file
$ dart run lh5801 asm input.asm -o output.bin

# Disassemble a binary file
$ dart run lh5801 dasm input.bin

# Set a custom origin address
$ dart run lh5801 dasm input.bin --origin 4000
```

## Testing

```bash
$ dart test
00:03 +474: All tests passed!
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/cbonello/lh5801/issues
