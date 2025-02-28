import 'package:lensai/data/models/web_page_info.dart';
import 'package:lensai/domain/services/generic_website.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'website_title.g.dart';

@Riverpod()
Future<WebPageInfo> pageInfo(Ref ref, Uri url) async {
  final websiteService = ref.watch(genericWebsiteServiceProvider.notifier);

  final result = await websiteService.fetchPageInfo(url);

  if (result.isSuccess) {
    ref.keepAlive();
  }

  return result.value;
}
