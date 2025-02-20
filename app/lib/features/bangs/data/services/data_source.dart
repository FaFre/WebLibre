import 'dart:convert';

import 'package:exceptions/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:lensai/core/http_error_handler.dart';
import 'package:lensai/features/bangs/data/models/bang.dart';
import 'package:lensai/features/bangs/data/models/bang_group.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_source.g.dart';

@Riverpod()
class BangDataSourceService extends _$BangDataSourceService {
  late http.Client _client;

  @override
  void build() {
    _client = http.Client();
  }

  Future<Result<List<Bang>>> getBangs(Uri url, BangGroup? group) async {
    return Result.fromAsync(() async {
      final response = await _client
          .get(url)
          .timeout(const Duration(seconds: 30));
      return await compute((args) => jsonDecode(utf8.decode(args[0])) as List, [
        response.bodyBytes,
      ]).then(
        (json) =>
            json.map((e) {
              var bang = Bang.fromJson(e as Map<String, dynamic>);

              if (group != null) {
                bang = bang.copyWith.group(group);
              }

              return bang;
            }).toList(),
      );
    }, exceptionHandler: handleHttpError);
  }
}
