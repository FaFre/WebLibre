import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';

part 'desktop_mode.g.dart';

@Riverpod(keepAlive: true)
class DesktopMode extends _$DesktopMode {
  // ignore: use_setters_to_change_properties
  void enabled(bool value) {
    state = value;
  }

  void toggle() {
    state = !state;
  }

  @override
  bool build(String tabId) {
    listenSelf((previous, next) async {
      if (previous != null) {
        await ref
            .read(tabSessionProvider(tabId: tabId).notifier)
            .requestDesktopSite(next);
      }
    });

    return false;
  }
}
