import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/features/web_feed/data/models/feed_filter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'article_filter.g.dart';

@Riverpod(keepAlive: true)
class ArticleFilter extends _$ArticleFilter {
  void addTag(String tagId) {
    final tags = {...?state.tags, tagId};

    state = state.copyWith.tags(tags);
  }

  void removeTag(String tagId) {
    if (state.tags.isNotEmpty) {
      final tags = {...state.tags!}..remove(tagId);
      state = state.copyWith.tags(tags);
    }
  }

  @override
  FeedFilter build() {
    return FeedFilter();
  }
}
