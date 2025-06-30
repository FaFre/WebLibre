import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'article_filter.g.dart';

@Riverpod(keepAlive: true)
class ArticleFilter extends _$ArticleFilter {
  void addTag(String tagId) {
    state = {...state, tagId};
  }

  void removeTag(String tagId) {
    if (state.isNotEmpty) {
      state = {...state}..remove(tagId);
    }
  }

  @override
  Set<String> build() {
    return {};
  }
}
