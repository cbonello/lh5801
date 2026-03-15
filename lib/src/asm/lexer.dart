enum TokenType {
  mnemonic,
  register,
  number,
  lparen,
  rparen,
  hash,
  comma,
  plus,
  minus,
  colon,
  identifier,
  eol,
}

class Token {
  const Token(this.type, this.value, this.column);

  final TokenType type;
  final String value;
  final int column;

  @override
  String toString() => 'Token($type, "$value", col:$column)';
}

const Set<String> _registers = {
  'A',
  'S',
  'P',
  'X',
  'Y',
  'U',
  'XH',
  'XL',
  'YH',
  'YL',
  'UH',
  'UL',
  'PH',
  'PL',
  'SH',
  'SL',
};

class Lexer {
  Lexer(this._mnemonics);

  final Set<String> _mnemonics;

  List<Token> tokenize(String line) {
    final List<Token> tokens = [];
    int i = 0;

    while (i < line.length) {
      final String ch = line[i];

      // Skip whitespace.
      if (ch == ' ' || ch == '\t') {
        i++;
        continue;
      }

      // Comment — stop tokenizing.
      if (ch == ';') {
        break;
      }

      // Single-character tokens.
      if (ch == '(') {
        tokens.add(Token(TokenType.lparen, '(', i));
        i++;
        continue;
      }
      if (ch == ')') {
        tokens.add(Token(TokenType.rparen, ')', i));
        i++;
        continue;
      }
      if (ch == '#') {
        tokens.add(Token(TokenType.hash, '#', i));
        i++;
        continue;
      }
      if (ch == ',') {
        tokens.add(Token(TokenType.comma, ',', i));
        i++;
        continue;
      }
      if (ch == '+') {
        tokens.add(Token(TokenType.plus, '+', i));
        i++;
        continue;
      }
      if (ch == '-') {
        tokens.add(Token(TokenType.minus, '-', i));
        i++;
        continue;
      }
      if (ch == ':') {
        tokens.add(Token(TokenType.colon, ':', i));
        i++;
        continue;
      }

      // Alphanumeric word — could be mnemonic, register, hex number, or identifier.
      if (_isAlphaNumeric(ch)) {
        final int start = i;
        while (i < line.length && _isAlphaNumeric(line[i])) {
          i++;
        }
        final String word = line.substring(start, i);
        final String upper = word.toUpperCase();

        if (_mnemonics.contains(upper)) {
          tokens.add(Token(TokenType.mnemonic, upper, start));
        } else if (_registers.contains(upper)) {
          tokens.add(Token(TokenType.register, upper, start));
        } else if (_isHexNumber(word)) {
          tokens.add(Token(TokenType.number, upper, start));
        } else {
          tokens.add(Token(TokenType.identifier, word, start));
        }
        continue;
      }

      // Unknown character — skip (errors handled by parser).
      i++;
    }

    tokens.add(Token(TokenType.eol, '', line.length));
    return tokens;
  }

  static bool _isAlphaNumeric(String ch) {
    final int c = ch.codeUnitAt(0);
    return (c >= 0x30 && c <= 0x39) || // 0-9
        (c >= 0x41 && c <= 0x5A) || // A-Z
        (c >= 0x61 && c <= 0x7A) || // a-z
        c == 0x5F; // _
  }

  static bool _isHexNumber(String s) {
    for (int i = 0; i < s.length; i++) {
      final int c = s.codeUnitAt(i);
      if (!((c >= 0x30 && c <= 0x39) || // 0-9
          (c >= 0x41 && c <= 0x46) || // A-F
          (c >= 0x61 && c <= 0x66))) {
        // a-f
        return false;
      }
    }
    return s.isNotEmpty;
  }
}
