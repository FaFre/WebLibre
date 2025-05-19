import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';

part 'add_dialog_blocking.g.dart';

@Riverpod(keepAlive: true)
class AddFeedDialogBlocking extends _$AddFeedDialogBlocking {
  DateTime? _lastIgnore;
  final _ignoredUrls = <Uri, DateTime>{};

  void ignore(Uri url) {
    final date = DateTime.now();

    _lastIgnore = date;
    _ignoredUrls[url] = date;
  }

  bool canPush(Uri url) {
    if (_lastIgnore.mapNotNull(
          (last) =>
              DateTime.now().difference(last) <= const Duration(seconds: 30),
        ) ??
        false) {
      logger.i('Blocking add feed default timeout for $url');
      return false;
    }

    if (_ignoredUrls[url].mapNotNull(
          (last) =>
              DateTime.now().difference(last) <= const Duration(minutes: 5),
        ) ??
        false) {
      logger.i('Blocking add feed url specific for $url');
      return false;
    }

    return true;
  }

  @override
  void build() {}
}
