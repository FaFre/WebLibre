import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';

part 'feed_filter.g.dart';

@CopyWith()
class FeedFilter with FastEquatable {
  final Uri? feedId;
  final String? query;
  final Set<String>? tags;

  FeedFilter({this.feedId, this.query, this.tags});

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [feedId, query, tags];
}
