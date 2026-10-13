/*
 * Copyright (c) 2024-2026 Fabian Freund.
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

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Keeps the active tab in view in the tab tray without moving a list the
/// user is reading, as Fenix does:
///
/// - The first time the active tab is laid out the list jumps to centre it,
///   so the tray opens on it with no scrolling to watch.
/// - When another tab becomes active, or the layout changes ([layoutKey]: the
///   column count or tile size after a resize), the list scrolls only if the
///   active tab is not fully visible.
/// - Anything else leaves the position alone. Closing, restoring or adding a
///   tab used to centre the active tab again, throwing the user back to it
///   from wherever they were closing tabs.
///
/// [activeItemStart] is the active tab's leading edge in the scroll view, or
/// null while it is not among the rows (still loading, filtered out).
void useScrollToActiveTab({
  required ScrollController scrollController,
  required String? activeTabId,
  required double? activeItemStart,
  required double itemExtent,
  required bool disableAnimations,
  Object? layoutKey,
}) {
  final context = useContext();
  final hasShownActiveTab = useRef(false);
  final lastActiveTabId = useRef<String?>(null);
  final lastLayoutKey = useRef<Object?>(layoutKey);
  // Only the newest scroll runs; an older one waiting for the list would
  // scroll to where the active tab was.
  final scrollRequest = useRef(0);

  useEffect(() {
    final start = activeItemStart;
    if (activeTabId == null || start == null) return null;

    final isFirst = !hasShownActiveTab.value;
    final activeChanged = lastActiveTabId.value != activeTabId;
    final layoutChanged = lastLayoutKey.value != layoutKey;

    lastActiveTabId.value = activeTabId;
    lastLayoutKey.value = layoutKey;

    if (!isFirst && !activeChanged && !layoutChanged) return null;

    final request = ++scrollRequest.value;
    void scroll(Duration _) {
      if (!context.mounted || request != scrollRequest.value) return;

      // Not attached yet: the view was just swapped, or the sheet is still
      // building. The frame that attaches it will have it, or the tray would
      // open away from the active tab.
      if (!scrollController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback(scroll);
        return;
      }
      hasShownActiveTab.value = true;

      final position = scrollController.position;
      final viewport = position.viewportDimension;
      final end = start + itemExtent;

      final isFullyVisible =
          start >= position.pixels && end <= position.pixels + viewport;
      if (!isFirst && isFullyVisible) return;

      final target = (start - viewport / 2 + itemExtent / 2).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      if (target == position.pixels) return;

      // Opening the tray and relayouts land in place; only a change the user
      // can follow (another tab became active) is animated.
      if (isFirst || layoutChanged || disableAnimations) {
        scrollController.jumpTo(target);
      } else {
        scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    }

    WidgetsBinding.instance.addPostFrameCallback(scroll);
    return null;
  }, [activeTabId, activeItemStart, itemExtent, layoutKey]);
}
