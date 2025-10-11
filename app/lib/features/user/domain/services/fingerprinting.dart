import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/user/data/models/rfp_target.dart';

part 'fingerprinting.g.dart';

@Riverpod(keepAlive: true)
Future<List<RFPTarget>> fingerprintTargets(Ref ref) async {
  final json =
      await rootBundle
              .loadString('assets/preferences/rfp_targets.json')
              .then(jsonDecode)
          as List<dynamic>;

  return json
      .map((e) => RFPTarget.fromJson(e as Map<String, dynamic>))
      .toList();
}
