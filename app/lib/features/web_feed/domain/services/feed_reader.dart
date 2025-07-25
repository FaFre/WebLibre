/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/web_feed/data/models/feed_parse_result.dart';
import 'package:weblibre/features/web_feed/utils/feed_parser.dart';

part 'feed_reader.g.dart';

@Riverpod(keepAlive: true)
class FeedReader extends _$FeedReader {
  Future<FeedParseResult> parseFeed(Uri url) async {
    final rootIsolateToken = ServicesBinding.rootIsolateToken!;

    final result = await compute((args) async {
      // Initialize BackgroundIsolateBinaryMessenger with the token
      BackgroundIsolateBinaryMessenger.ensureInitialized(
        args['token']! as RootIsolateToken,
      );

      final client = http.Client();
      try {
        final url = Uri.parse(args['url']! as String);
        final response = await client
            .get(url)
            .timeout(const Duration(seconds: 30));

        final parser = FeedParser.parse(url: url, xmlString: response.body);
        final result = FeedParseResult(
          feedData: parser.readGeneralData(),
          articleData: parser.readArticles(),
        );

        return result.toJson();
      } finally {
        client.close();
      }
    }, {'token': rootIsolateToken, 'url': url.toString()});

    return FeedParseResult.fromJson(result);
  }

  @override
  void build() {}
}
