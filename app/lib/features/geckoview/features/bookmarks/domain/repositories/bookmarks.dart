import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_item.dart';

part 'bookmarks.g.dart';

@Riverpod(keepAlive: true)
class BookmarksRepository extends _$BookmarksRepository {
  final _service = GeckoBookmarksService();

  Future<void> addBookmark({
    required String parentGuid,
    required Uri url,
    required String title,
  }) async {
    await _service.addItem(parentGuid, url, title, null);
    ref.invalidateSelf();
  }

  Future<void> addFolder({
    required String parentGuid,
    required String title,
  }) async {
    await _service.addFolder(parentGuid, title, null);
    ref.invalidateSelf();
  }

  Future<void> editBookmark({
    required String guid,
    String? title,
    Uri? url,
    String? parentGuid,
  }) async {
    await _service.updateNode(
      guid,
      BookmarkInfo(title: title, url: url?.toString(), parentGuid: parentGuid),
    );
    ref.invalidateSelf();
  }

  Future<void> editFolder({required String guid, required String title}) async {
    await _service.updateNode(guid, BookmarkInfo(title: title));
    ref.invalidateSelf();
  }

  Future<void> delete(String guid) async {
    await _service.deleteNode(guid);
    ref.invalidateSelf();
  }

  @override
  Future<BookmarkItem?> build() async {
    final node = await _service.getTree(
      BookmarkRoot.mobile.id,
      recursive: true,
    );
    return node.mapNotNull(BookmarkItem.parseRecursive);
  }
}
