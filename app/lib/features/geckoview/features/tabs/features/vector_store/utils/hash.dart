import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

String sha2(String input) {
  return sha256.convert(utf8.encode(input)).toString();
}

Future<String> sha2Isolated(String input) async {
  if (input.length < 1048576) {
    // Less than 1MB
    return sha2(input);
  } else {
    return await compute(sha2, input);
  }
}
