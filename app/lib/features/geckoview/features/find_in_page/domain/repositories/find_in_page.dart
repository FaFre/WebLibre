import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'find_in_page.g.dart';

@Riverpod(keepAlive: true)
class FindInPageRepository extends _$FindInPageRepository
    implements GeckoFindInPageService {
  @override
  String? build(String? tabId) {
    return null;
  }

  @override
  Future<void> clearMatches() {
    final service = GeckoFindInPageService(tabId: tabId);

    state = null;

    return service.clearMatches();
  }

  @override
  Future<void> findAll(String text) {
    final service = GeckoFindInPageService(tabId: tabId);

    state = text;

    return service.findAll(text);
  }

  @override
  Future<void> findNext(bool forward) {
    final service = GeckoFindInPageService(tabId: tabId);
    return service.findNext(forward);
  }
}
