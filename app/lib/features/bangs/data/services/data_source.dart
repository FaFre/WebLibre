import 'dart:convert';

import 'package:exceptions/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/http_error_handler.dart';
import 'package:weblibre/features/bangs/data/models/bang.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';

part 'data_source.g.dart';

@Riverpod()
class BangDataSourceService extends _$BangDataSourceService {
  @override
  void build() {}

  Future<Result<List<Bang>>> getBangs(Uri url, BangGroup? group) {
    return Result.fromAsync(() async {
      return await compute((args) async {
        final client = http.Client();
        try {
          final url = Uri.parse(args[0]);
          final response = await client
              .get(url)
              .timeout(const Duration(seconds: 30));

          return jsonDecode(utf8.decode(response.bodyBytes)) as List;
        } finally {
          client.close();
        }
      }, [url.toString()]).then(
        (json) => json.map((e) {
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
