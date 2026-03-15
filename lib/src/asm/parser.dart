import 'lexer.dart';

sealed class ParsedOperand {
  const ParsedOperand();
}

class ParsedReg extends ParsedOperand {
  const ParsedReg(this.name);
  final String name;
}

class ParsedMem0Reg extends ParsedOperand {
  const ParsedMem0Reg(this.name);
  final String name;
}

class ParsedMem1Reg extends ParsedOperand {
  const ParsedMem1Reg(this.name);
  final String name;
}

class ParsedMem0Imm16 extends ParsedOperand {
  const ParsedMem0Imm16(this.value);
  final int value;
}

class ParsedMem1Imm16 extends ParsedOperand {
  const ParsedMem1Imm16(this.value);
  final int value;
}

class ParsedMem0Cst8 extends ParsedOperand {
  const ParsedMem0Cst8(this.value);
  final int value;
}

class ParsedImm extends ParsedOperand {
  const ParsedImm(this.value);
  final int value;
}

class ParsedDispPlus extends ParsedOperand {
  const ParsedDispPlus(this.offset);
  final int offset;
}

class ParsedDispMinus extends ParsedOperand {
  const ParsedDispMinus(this.offset);
  final int offset;
}

class ParsedLabel extends ParsedOperand {
  const ParsedLabel(this.name);
  final String name;
}

class AsmLine {
  const AsmLine({
    this.label,
    this.mnemonic,
    this.operands = const [],
    required this.lineNumber,
  });

  final String? label;
  final String? mnemonic;
  final List<ParsedOperand> operands;
  final int lineNumber;
}

class ParseError {
  const ParseError(this.message, this.column);
  final String message;
  final int column;
}

class ParseResult {
  const ParseResult.success(this.line) : error = null;
  const ParseResult.failure(this.error) : line = null;

  final AsmLine? line;
  final ParseError? error;
}

class Parser {
  ParseResult parse(List<Token> tokens, int lineNumber) {
    int pos = 0;

    Token peek() => tokens[pos];
    Token advance() => tokens[pos++];

    bool check(TokenType type) => peek().type == type;
    bool atEnd() => peek().type == TokenType.eol;

    Token? match(TokenType type) {
      if (check(type)) return advance();
      return null;
    }

    // Try to parse a label at the start of the line.
    String? label;
    if (pos + 1 < tokens.length &&
        (check(TokenType.identifier) || check(TokenType.mnemonic)) &&
        tokens[pos + 1].type == TokenType.colon) {
      label = advance().value;
      advance(); // consume ':'
    }

    // Empty line or comment-only.
    if (atEnd()) {
      return ParseResult.success(AsmLine(label: label, lineNumber: lineNumber));
    }

    // Expect a mnemonic.
    final Token? mnemonicToken = match(TokenType.mnemonic);
    if (mnemonicToken == null) {
      // Could be an identifier that looks like a mnemonic but isn't.
      final Token t = peek();
      return ParseResult.failure(
        ParseError('expected mnemonic, got "${t.value}"', t.column),
      );
    }
    final String mnemonic = mnemonicToken.value;

    // Parse operands.
    final List<ParsedOperand> operands = [];
    if (!atEnd()) {
      final (ParsedOperand? op, ParseError? err) = _parseOperand(
        tokens,
        pos,
        mnemonic,
      );
      if (err != null) return ParseResult.failure(err);
      operands.add(op!);
      pos = _nextPos;

      while (match(TokenType.comma) != null) {
        final (ParsedOperand? op2, ParseError? err2) = _parseOperand(
          tokens,
          pos,
          mnemonic,
        );
        if (err2 != null) return ParseResult.failure(err2);
        operands.add(op2!);
        pos = _nextPos;
      }
    }

    // Check for two consecutive number operands (e.g., LDI S, 13, 57 → imm16).
    if (operands.length == 3 &&
        operands[1] is ParsedImm &&
        operands[2] is ParsedImm) {
      final int high = (operands[1] as ParsedImm).value;
      final int low = (operands[2] as ParsedImm).value;
      operands
        ..removeRange(1, 3)
        ..add(ParsedImm((high << 8) | low));
    }

    return ParseResult.success(
      AsmLine(
        label: label,
        mnemonic: mnemonic,
        operands: operands,
        lineNumber: lineNumber,
      ),
    );
  }

  int _nextPos = 0;

  (ParsedOperand?, ParseError?) _parseOperand(
    List<Token> tokens,
    int pos,
    String mnemonic,
  ) {
    Token peek() => tokens[pos];
    Token advance() => tokens[pos++];
    bool check(TokenType type) => peek().type == type;

    // +offset
    if (check(TokenType.plus)) {
      advance();
      if (!check(TokenType.number)) {
        return (null, ParseError('expected number after "+"', peek().column));
      }
      final int value = int.parse(advance().value, radix: 16);
      _nextPos = pos;
      return (ParsedDispPlus(value), null);
    }

    // -offset
    if (check(TokenType.minus)) {
      advance();
      if (!check(TokenType.number)) {
        return (null, ParseError('expected number after "-"', peek().column));
      }
      final int value = int.parse(advance().value, radix: 16);
      _nextPos = pos;
      return (ParsedDispMinus(value), null);
    }

    // #(reg) or #(imm16)
    if (check(TokenType.hash)) {
      advance();
      if (!check(TokenType.lparen)) {
        return (null, ParseError('expected "(" after "#"', peek().column));
      }
      advance();

      if (check(TokenType.register)) {
        final String name = advance().value;
        if (!check(TokenType.rparen)) {
          return (null, ParseError('expected ")"', peek().column));
        }
        advance();
        _nextPos = pos;
        return (ParsedMem1Reg(name), null);
      }
      if (check(TokenType.number)) {
        final int value = int.parse(advance().value, radix: 16);
        if (!check(TokenType.rparen)) {
          return (null, ParseError('expected ")"', peek().column));
        }
        advance();
        _nextPos = pos;
        return (ParsedMem1Imm16(value), null);
      }
      return (null, ParseError('expected register or number', peek().column));
    }

    // (reg) or (imm16) or (cst8 for VEJ)
    if (check(TokenType.lparen)) {
      advance();

      if (check(TokenType.register)) {
        final String name = advance().value;
        if (!check(TokenType.rparen)) {
          return (null, ParseError('expected ")"', peek().column));
        }
        advance();
        _nextPos = pos;
        return (ParsedMem0Reg(name), null);
      }
      if (check(TokenType.number)) {
        final int value = int.parse(advance().value, radix: 16);
        if (!check(TokenType.rparen)) {
          return (null, ParseError('expected ")"', peek().column));
        }
        advance();
        _nextPos = pos;
        if (mnemonic == 'VEJ') {
          return (ParsedMem0Cst8(value), null);
        }
        return (ParsedMem0Imm16(value), null);
      }
      return (null, ParseError('expected register or number', peek().column));
    }

    // Register.
    if (check(TokenType.register)) {
      final String name = advance().value;
      _nextPos = pos;
      return (ParsedReg(name), null);
    }

    // Number (imm8 or imm16 — resolved later by assembler).
    if (check(TokenType.number)) {
      final int value = int.parse(advance().value, radix: 16);
      _nextPos = pos;
      return (ParsedImm(value), null);
    }

    // Label reference (for branches).
    if (check(TokenType.identifier)) {
      final String name = advance().value;
      _nextPos = pos;
      return (ParsedLabel(name), null);
    }

    return (
      null,
      ParseError('unexpected token "${peek().value}"', peek().column),
    );
  }
}
