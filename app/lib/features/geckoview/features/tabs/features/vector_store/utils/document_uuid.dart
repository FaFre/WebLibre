import 'dart:typed_data';

import 'package:lensai/core/uuid.dart';
import 'package:uuid/data.dart';
import 'package:uuid/parsing.dart';
import 'package:uuid/rng.dart';

final _rng = CryptoRNG();

class DocumentUuid {
  final Uint8List _baseBytes;

  DocumentUuid([Uint8List? baseBytes])
    : _baseBytes = baseBytes ?? _rng.generate();

  factory DocumentUuid.fromUuid(String uuid) {
    return DocumentUuid(UuidParsing.parseAsByteList(uuid));
  }

  String getDocumentPartUuid(int sequence) {
    final bytes = Uint8List.fromList(_baseBytes);
    bytes.buffer.asByteData().setInt16(14, sequence);

    return uuid.v8g(config: V8GenericOptions(bytes));
  }
}
