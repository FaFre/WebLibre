/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
/// Parses Firefox-compatible `user.js` text into a map of pref name to value.
///
/// Accepts the Firefox `user.js` subset used by WebLibre:
/// - blank lines and whitespace
/// - `//`, `#`, and `/* ... */` comments
/// - `user_pref("name", value);`
/// - string, boolean, and integer values
///
/// Duplicate pref names use last-write-wins semantics.
class UserJsParseResult {
  final Map<String, Object> prefs;
  final int? schemaVersion;
  final String? exportedAt;

  UserJsParseResult({required this.prefs, this.schemaVersion, this.exportedAt});
}

UserJsParseResult parseUserJs(String text) {
  final parser = _UserJsParser(text);
  return parser.parse();
}

class _UserJsParser {
  final String _text;
  int _index = 0;
  final Map<String, Object> _prefs = <String, Object>{};
  int? _schemaVersion;
  String? _exportedAt;

  _UserJsParser(this._text);

  UserJsParseResult parse() {
    while (true) {
      _skipTrivia();
      if (_isEof) {
        break;
      }

      final identifier = _parseIdentifier();
      if (identifier != 'user_pref') {
        _skipToStatementEnd();
        continue;
      }

      if (!_consumeChar('(')) {
        _skipToStatementEnd();
        continue;
      }

      final name = _parseStringLiteral();
      if (name == null) {
        _skipToStatementEnd();
        continue;
      }

      if (!_consumeChar(',')) {
        _skipToStatementEnd();
        continue;
      }

      final value = _parseValue();
      if (value == null) {
        _skipToStatementEnd();
        continue;
      }

      if (!_consumeChar(')')) {
        _skipToStatementEnd();
        continue;
      }

      _skipTrivia();
      if (!_consumeRawChar(';')) {
        _skipToStatementEnd();
        continue;
      }

      _prefs[name] = value;
    }

    return UserJsParseResult(
      prefs: _prefs,
      schemaVersion: _schemaVersion,
      exportedAt: _exportedAt,
    );
  }

  bool get _isEof => _index >= _text.length;

  String? _peek([int offset = 0]) {
    final position = _index + offset;
    if (position >= _text.length) {
      return null;
    }
    return _text[position];
  }

  String? _advance() {
    if (_isEof) {
      return null;
    }
    return _text[_index++];
  }

  bool _consumeRawChar(String char) {
    if (_peek() != char) {
      return false;
    }
    _index++;
    return true;
  }

  bool _consumeChar(String char) {
    _skipTrivia();
    return _consumeRawChar(char);
  }

  void _skipTrivia() {
    while (!_isEof) {
      final char = _peek();
      if (char == null) {
        return;
      }

      if (_isWhitespace(char)) {
        _advance();
        continue;
      }

      if (char == '#') {
        _skipLineComment(isSlashComment: false);
        continue;
      }

      if (char == '/' && _peek(1) == '/') {
        _skipLineComment(isSlashComment: true);
        continue;
      }

      if (char == '/' && _peek(1) == '*') {
        _skipBlockComment();
        continue;
      }

      return;
    }
  }

  void _skipLineComment({required bool isSlashComment}) {
    final prefixLength = isSlashComment ? 2 : 1;
    final start = _index + prefixLength;
    _index += prefixLength;

    while (!_isEof) {
      final char = _peek();
      if (char == '\n' || char == '\r') {
        break;
      }
      _index++;
    }

    if (isSlashComment) {
      _parseMetadataComment(_text.substring(start, _index).trim());
    }

    if (_peek() == '\r') {
      _index++;
      if (_peek() == '\n') {
        _index++;
      }
    } else if (_peek() == '\n') {
      _index++;
    }
  }

  void _skipBlockComment() {
    _index += 2;
    while (!_isEof) {
      if (_peek() == '*' && _peek(1) == '/') {
        _index += 2;
        return;
      }
      _index++;
    }
  }

  void _parseMetadataComment(String comment) {
    if (comment.startsWith('schema_version=')) {
      _schemaVersion = int.tryParse(
        comment.substring('schema_version='.length),
      );
      return;
    }
    if (comment.startsWith('exported_at=')) {
      _exportedAt = comment.substring('exported_at='.length);
    }
  }

  String? _parseIdentifier() {
    _skipTrivia();
    final start = _index;
    while (!_isEof) {
      final char = _peek();
      if (char == null || !_isIdentifierChar(char)) {
        break;
      }
      _index++;
    }
    if (_index == start) {
      return null;
    }
    return _text.substring(start, _index);
  }

  Object? _parseValue() {
    _skipTrivia();
    final char = _peek();
    if (char == null) {
      return null;
    }

    if (char == '"' || char == "'") {
      return _parseStringLiteral();
    }

    if (char == 't' || char == 'f') {
      final identifier = _parseIdentifier();
      if (identifier == 'true') {
        return true;
      }
      if (identifier == 'false') {
        return false;
      }
      return null;
    }

    return _parseIntLiteral();
  }

  int? _parseIntLiteral() {
    _skipTrivia();
    final start = _index;

    var sign = 1;
    if (_peek() == '+') {
      _index++;
    } else if (_peek() == '-') {
      sign = -1;
      _index++;
    }

    // Firefox tokenizes +/- separately, then skips whitespace/comments before
    // reading the integer literal.
    _skipTrivia();

    final digitStart = _index;
    while (!_isEof) {
      final char = _peek();
      if (char == null || !_isDigit(char)) {
        break;
      }
      _index++;
    }

    if (_index == digitStart) {
      _index = start;
      return null;
    }

    final trailing = _peek();
    if (trailing != null && _isIdentifierChar(trailing)) {
      _index = start;
      return null;
    }

    final digits = _text.substring(digitStart, _index);
    final value = int.tryParse(digits);
    if (value == null) {
      _index = start;
      return null;
    }

    final signedValue = sign * value;
    if (signedValue < -2147483648 || signedValue > 2147483647) {
      _index = start;
      return null;
    }

    return signedValue;
  }

  String? _parseStringLiteral() {
    _skipTrivia();
    final quote = _peek();
    if (quote != '"' && quote != "'") {
      return null;
    }

    _index++;
    final buffer = StringBuffer();

    while (!_isEof) {
      final char = _advance();
      if (char == null) {
        return null;
      }

      if (char == quote) {
        return buffer.toString();
      }

      if (char != '\\') {
        buffer.write(char);
        continue;
      }

      final escaped = _parseEscape();
      if (escaped == null) {
        return null;
      }
      buffer.write(escaped);
    }

    return null;
  }

  String? _parseEscape() {
    final char = _advance();
    switch (char) {
      case '"':
        return '"';
      case "'":
        return "'";
      case '\\':
        return '\\';
      case 'n':
        return '\n';
      case 'r':
        return '\r';
      case 'x':
        final value = _parseHexValue(length: 2);
        if (value == null || value == 0) {
          return null;
        }
        return String.fromCharCode(value);
      case 'u':
        final value = _parseUnicodeEscape();
        if (value == null || value == 0) {
          return null;
        }
        return String.fromCharCode(value);
      default:
        return null;
    }
  }

  int? _parseUnicodeEscape() {
    final value = _parseHexValue(length: 4);
    if (value == null) {
      return null;
    }

    if (_isHighSurrogate(value)) {
      if (_advance() != '\\' || _advance() != 'u') {
        return null;
      }
      final lowValue = _parseHexValue(length: 4);
      if (lowValue == null || !_isLowSurrogate(lowValue)) {
        return null;
      }
      return 0x10000 + ((value - 0xD800) << 10) + (lowValue - 0xDC00);
    }

    if (_isLowSurrogate(value)) {
      return null;
    }

    return value;
  }

  int? _parseHexValue({required int length}) {
    var value = 0;
    for (var i = 0; i < length; i++) {
      final char = _advance();
      final digit = char == null ? null : _hexDigitValue(char);
      if (digit == null) {
        return null;
      }
      value = (value << 4) + digit;
    }
    return value;
  }

  int? _hexDigitValue(String char) {
    final code = char.codeUnitAt(0);
    if (code >= 0x30 && code <= 0x39) {
      return code - 0x30;
    }
    if (code >= 0x41 && code <= 0x46) {
      return code - 0x41 + 10;
    }
    if (code >= 0x61 && code <= 0x66) {
      return code - 0x61 + 10;
    }
    return null;
  }

  void _skipToStatementEnd() {
    while (!_isEof) {
      final char = _advance();
      if (char == ';') {
        return;
      }
    }
  }

  bool _isWhitespace(String char) {
    return char == ' ' ||
        char == '\t' ||
        char == '\n' ||
        char == '\r' ||
        char == '\v' ||
        char == '\f';
  }

  bool _isIdentifierChar(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 0x41 && code <= 0x5A) ||
        (code >= 0x61 && code <= 0x7A) ||
        (code >= 0x30 && code <= 0x39) ||
        code == 0x5F;
  }

  bool _isDigit(String char) {
    final code = char.codeUnitAt(0);
    return code >= 0x30 && code <= 0x39;
  }

  bool _isHighSurrogate(int value) => value >= 0xD800 && value <= 0xDBFF;

  bool _isLowSurrogate(int value) => value >= 0xDC00 && value <= 0xDFFF;
}
