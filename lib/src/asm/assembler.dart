import '../../lh5801.dart';
import 'lexer.dart';
import 'opcode_lookup.dart';
import 'parser.dart';

class AsmError {
  const AsmError(this.line, this.message);

  final int line;
  final String message;

  @override
  String toString() => 'line $line: $message';
}

class AsmResult {
  const AsmResult(this.bytes, this.errors);

  final List<int> bytes;
  final List<AsmError> errors;

  bool get hasErrors => errors.isNotEmpty;
}

class LH5801ASM {
  LH5801ASM()
    : _lookup = OpcodeLookup(),
      _lexer = Lexer(_extractMnemonics()),
      _parser = Parser();

  final OpcodeLookup _lookup;
  final Lexer _lexer;
  final Parser _parser;

  static Set<String> _extractMnemonics() {
    final Set<String> mnemonics = {};
    for (final InstructionDescriptor desc in instructionTable) {
      if (desc.category != InstructionCategory.illegal) {
        mnemonics.add(desc.mnemonic);
      }
    }
    for (final InstructionDescriptor desc in instructionTableFD) {
      if (desc.category != InstructionCategory.illegal) {
        mnemonics.add(desc.mnemonic);
      }
    }

    return mnemonics;
  }

  AsmResult assemble(String source, {int origin = 0}) {
    final List<String> lines = source.split('\n');
    final List<AsmLine> parsedLines = [];
    final List<AsmError> errors = [];

    // Lex and parse all lines.
    for (int i = 0; i < lines.length; i++) {
      final List<Token> tokens = _lexer.tokenize(lines[i]);
      final ParseResult result = _parser.parse(tokens, i + 1);
      if (result.error != null) {
        errors.add(AsmError(i + 1, result.error!.message));
        parsedLines.add(AsmLine(lineNumber: i + 1));
      } else {
        parsedLines.add(result.line!);
      }
    }

    if (errors.isNotEmpty) {
      return AsmResult([], errors);
    }

    // Pass 1: collect labels and compute instruction sizes.
    final Map<String, int> labels = {};
    int pc = origin;

    for (final AsmLine line in parsedLines) {
      if (line.label != null) {
        if (labels.containsKey(line.label)) {
          errors.add(
            AsmError(line.lineNumber, 'duplicate label "${line.label}"'),
          );
        } else {
          labels[line.label!] = pc;
        }
      }
      if (line.mnemonic != null) {
        final int? size = _instructionSize(line, errors);
        if (size != null) pc += size;
      }
    }

    if (errors.isNotEmpty) {
      return AsmResult([], errors);
    }

    // Pass 2: emit bytes.
    final List<int> bytes = [];
    pc = origin;

    for (final AsmLine line in parsedLines) {
      if (line.mnemonic == null) {
        continue;
      }

      final List<ParsedOperand> resolved = _resolveOperands(
        line,
        pc,
        labels,
        errors,
      );
      if (errors.isNotEmpty) {
        return AsmResult([], errors);
      }

      final String sig = _buildSignature(line.mnemonic!, resolved);
      final OpcodeEntry? entry = _lookup.lookup(sig);
      if (entry == null) {
        errors.add(
          AsmError(
            line.lineNumber,
            'no matching opcode for "${line.mnemonic} '
            '${_operandsDebug(resolved)}"',
          ),
        );

        return AsmResult([], errors);
      }

      // Emit opcode bytes.
      bytes.addAll(entry.opcodeBytes);

      // Emit operand data bytes.
      for (final ParsedOperand op in resolved) {
        switch (op) {
          case ParsedImm(:final value):
            if (value > 0xFF) {
              // 16-bit immediate (e.g., JMP, SJP, LDI S).
              bytes.add((value >> 8) & 0xFF);
              bytes.add(value & 0xFF);
            } else {
              bytes.add(value & 0xFF);
            }
          case ParsedDispPlus(:final offset):
            bytes.add(offset & 0xFF);
          case ParsedDispMinus(:final offset):
            bytes.add(offset & 0xFF);
          case ParsedMem0Imm16(:final value):
            bytes.add((value >> 8) & 0xFF);
            bytes.add(value & 0xFF);
          case ParsedMem1Imm16(:final value):
            bytes.add((value >> 8) & 0xFF);
            bytes.add(value & 0xFF);
          default:
            break; // Registers and constants are encoded in the opcode.
        }
      }

      pc += entry.size;
    }

    return AsmResult(bytes, []);
  }

  int? _instructionSize(AsmLine line, List<AsmError> errors) {
    // Try to determine instruction size without resolving labels.
    // For label operands, try both dispPlus and dispMinus variants.
    final List<ParsedOperand> operands = line.operands;
    final bool hasLabel = operands.any((op) => op is ParsedLabel);

    if (!hasLabel) {
      final String sig = _buildSignature(line.mnemonic!, operands);
      final OpcodeEntry? entry = _lookup.lookup(sig);
      if (entry == null) {
        // Try resolving ambiguous immediates.
        final String sig16 = _buildSignatureWithImm16(line.mnemonic!, operands);
        final OpcodeEntry? entry16 = _lookup.lookup(sig16);
        if (entry16 != null) {
          return entry16.size;
        }

        errors.add(
          AsmError(
            line.lineNumber,
            'unknown instruction "${line.mnemonic} '
            '${_operandsDebug(operands)}"',
          ),
        );

        return null;
      }

      return entry.size;
    }

    // Has a label — try dispPlus first, then dispMinus.
    for (final ParsedOperand replacement in [
      const ParsedDispPlus(0),
      const ParsedDispMinus(0),
    ]) {
      final List<ParsedOperand> trial = operands
          .map((op) => op is ParsedLabel ? replacement : op)
          .toList();
      final String sig = _buildSignature(line.mnemonic!, trial);
      final OpcodeEntry? entry = _lookup.lookup(sig);
      if (entry != null) {
        return entry.size;
      }
    }

    errors.add(
      AsmError(line.lineNumber, 'unknown instruction "${line.mnemonic}"'),
    );

    return null;
  }

  List<ParsedOperand> _resolveOperands(
    AsmLine line,
    int pc,
    Map<String, int> labels,
    List<AsmError> errors,
  ) {
    final List<ParsedOperand> resolved = [];

    // First, determine instruction size for branch offset calculation.
    final int instrSize = _instructionSize(line, []) ?? 0;

    for (final ParsedOperand op in line.operands) {
      if (op is ParsedLabel) {
        final int? target = labels[op.name];
        if (target == null) {
          errors.add(AsmError(line.lineNumber, 'undefined label "${op.name}"'));

          return resolved;
        }
        final int offset = target - (pc + instrSize);
        if (offset >= 0) {
          if (offset > 0xFF) {
            errors.add(
              AsmError(
                line.lineNumber,
                'forward branch offset $offset out of range (max 255)',
              ),
            );

            return resolved;
          }
          resolved.add(ParsedDispPlus(offset));
        } else {
          final int absOffset = -offset;
          if (absOffset > 0xFF) {
            errors.add(
              AsmError(
                line.lineNumber,
                'backward branch offset $absOffset out of range (max 255)',
              ),
            );

            return resolved;
          }
          resolved.add(ParsedDispMinus(absOffset));
        }
      } else if (op is ParsedImm) {
        // Resolve ambiguous immediates: check if imm8 or imm16 matches.
        final List<ParsedOperand> trialOps = [
          ...resolved,
          op,
          ...line.operands.sublist(resolved.length + 1),
        ];
        final String sig8 = _buildSignature(line.mnemonic!, trialOps);
        if (_lookup.lookup(sig8) != null) {
          resolved.add(op);
        } else {
          // Try as imm16.
          resolved.add(op);
        }
      } else {
        resolved.add(op);
      }
    }

    return resolved;
  }

  String _buildSignature(String mnemonic, List<ParsedOperand> operands) {
    final StringBuffer buf = StringBuffer(mnemonic);
    for (final ParsedOperand op in operands) {
      final String part = switch (op) {
        ParsedReg(:final name) => '|reg:$name',
        ParsedMem0Reg(:final name) => '|mem0reg:$name',
        ParsedMem0Imm16() => '|mem0imm16',
        ParsedMem1Reg(:final name) => '|mem1reg:$name',
        ParsedMem1Imm16() => '|mem1imm16',
        ParsedImm(:final value) => value > 0xFF ? '|imm16' : '|imm8',
        ParsedDispPlus() => '|dispplus',
        ParsedDispMinus() => '|dispminus',
        ParsedMem0Cst8(:final value) =>
          '|mem0cst8:${value.toRadixString(16).toUpperCase()}',
        ParsedLabel() => '|dispplus', // Placeholder for size estimation.
      };
      buf.write(part);
    }

    return buf.toString();
  }

  String _buildSignatureWithImm16(
    String mnemonic,
    List<ParsedOperand> operands,
  ) {
    final StringBuffer buf = StringBuffer(mnemonic);
    for (final ParsedOperand op in operands) {
      final String part = switch (op) {
        ParsedReg(:final name) => '|reg:$name',
        ParsedMem0Reg(:final name) => '|mem0reg:$name',
        ParsedMem0Imm16() => '|mem0imm16',
        ParsedMem1Reg(:final name) => '|mem1reg:$name',
        ParsedMem1Imm16() => '|mem1imm16',
        ParsedImm() => '|imm16',
        ParsedDispPlus() => '|dispplus',
        ParsedDispMinus() => '|dispminus',
        ParsedMem0Cst8(:final value) =>
          '|mem0cst8:${value.toRadixString(16).toUpperCase()}',
        ParsedLabel() => '|dispplus',
      };
      buf.write(part);
    }

    return buf.toString();
  }

  String _operandsDebug(List<ParsedOperand> operands) {
    return operands
        .map(
          (op) => switch (op) {
            ParsedReg(:final name) => name,
            ParsedMem0Reg(:final name) => '($name)',
            ParsedMem0Imm16(:final value) =>
              '(${value.toRadixString(16).toUpperCase()})',
            ParsedMem1Reg(:final name) => '#($name)',
            ParsedMem1Imm16(:final value) =>
              '#(${value.toRadixString(16).toUpperCase()})',
            ParsedImm(:final value) => value.toRadixString(16).toUpperCase(),
            ParsedDispPlus(:final offset) =>
              '+${offset.toRadixString(16).toUpperCase()}',
            ParsedDispMinus(:final offset) =>
              '-${offset.toRadixString(16).toUpperCase()}',
            ParsedMem0Cst8(:final value) =>
              '(${value.toRadixString(16).toUpperCase()})',
            ParsedLabel(:final name) => name,
          },
        )
        .join(', ');
  }
}
