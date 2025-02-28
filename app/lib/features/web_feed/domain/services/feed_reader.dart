import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:lensai/features/web_feed/data/models/feed_parse_result.dart';
import 'package:lensai/features/web_feed/utils/feed_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
          articleData: await parser.readArticles(),
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
