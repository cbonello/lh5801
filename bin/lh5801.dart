import 'dart:io';

import 'package:lh5801/lh5801.dart';

const String version = '0.3.0';

void main(List<String> args) {
  if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
    _printUsage();
    exit(args.isEmpty ? 1 : 0);
  }

  if (args.contains('--version') || args.contains('-v')) {
    stdout.writeln('lh5801 $version');
    exit(0);
  }

  final String command = args[0];
  final List<String> rest = args.sublist(1);

  switch (command) {
    case 'asm':
      _assemble(rest);
    case 'dasm':
      _disassemble(rest);
    default:
      stderr.writeln('Unknown command: $command');
      _printUsage();
      exit(1);
  }
}

void _printUsage() {
  stdout.writeln('Usage: lh5801 <command> [options]');
  stdout.writeln();
  stdout.writeln('Commands:');
  stdout.writeln('  asm <input.asm> [-o output.bin]   Assemble source file');
  stdout.writeln('  dasm <input.bin>                  Disassemble binary file');
  stdout.writeln();
  stdout.writeln('Options:');
  stdout.writeln(
    '  -o <file>       Output file (default: stdout for dasm, <input>.bin for '
    'asm)',
  );
  stdout.writeln('  --origin <hex>  Set origin address (default: 0000)');
  stdout.writeln('  -h, --help      Show this help');
  stdout.writeln('  -v, --version   Show version');
}

void _assemble(List<String> args) {
  String? inputPath;
  String? outputPath;
  int origin = 0;

  for (int i = 0; i < args.length; i++) {
    if (args[i] == '-o' && i + 1 < args.length) {
      outputPath = args[++i];
    } else if (args[i] == '--origin' && i + 1 < args.length) {
      origin = int.parse(args[++i], radix: 16);
    } else if (!args[i].startsWith('-')) {
      inputPath = args[i];
    } else {
      stderr.writeln('Unknown option: ${args[i]}');
      exit(1);
    }
  }

  if (inputPath == null) {
    stderr.writeln('Error: no input file specified');
    exit(1);
  }

  final File inputFile = File(inputPath);
  if (!inputFile.existsSync()) {
    stderr.writeln('Error: file not found: $inputPath');
    exit(1);
  }

  final String source = inputFile.readAsStringSync();
  final LH5801ASM asm = LH5801ASM();
  final AsmResult result = asm.assemble(source, origin: origin);

  if (result.hasErrors) {
    for (final AsmError error in result.errors) {
      stderr.writeln('$inputPath:$error');
    }
    exit(1);
  }

  outputPath ??= '${_stripExtension(inputPath)}.bin';
  File(outputPath).writeAsBytesSync(result.bytes);
  stdout.writeln('Assembled ${result.bytes.length} bytes -> $outputPath');
}

void _disassemble(List<String> args) {
  String? inputPath;
  int origin = 0;

  for (int i = 0; i < args.length; i++) {
    if (args[i] == '--origin' && i + 1 < args.length) {
      origin = int.parse(args[++i], radix: 16);
    } else if (!args[i].startsWith('-')) {
      inputPath = args[i];
    } else {
      stderr.writeln('Unknown option: ${args[i]}');
      exit(1);
    }
  }

  if (inputPath == null) {
    stderr.writeln('Error: no input file specified');
    exit(1);
  }

  final File inputFile = File(inputPath);
  if (!inputFile.existsSync()) {
    stderr.writeln('Error: file not found: $inputPath');
    exit(1);
  }

  final List<int> bytes = inputFile.readAsBytesSync();
  int memRead(int address) {
    final int offset = address - origin;
    if (offset < 0 || offset >= bytes.length) {
      return 0;
    }

    return bytes[offset];
  }

  final LH5801DASM dasm = LH5801DASM(memRead: memRead);
  int addr = origin;
  final int end = origin + bytes.length;

  while (addr < end) {
    final Instruction instruction = dasm.dump(addr);
    stdout.writeln(instruction);
    addr += instruction.descriptor.size;
  }
}

String _stripExtension(String path) {
  final int dot = path.lastIndexOf('.');
  if (dot < 0) {
    return path;
  }

  return path.substring(0, dot);
}
