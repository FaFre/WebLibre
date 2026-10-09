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
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_bar.g.dart';

const _channel = MethodChannel('eu.weblibre.gecko/navigation_bar');

/// How the system navigation bar sits relative to the Flutter UI, measured by
/// MainActivity from view geometry.
///
/// - `outsideFlutter`: Flutter isn't laid out behind the bar, so it cannot
///   paint there and the bar shows the native window background instead
///   (#657).
/// - `buttonsAtBottom`: the bar along the bottom edge holds navigation buttons
///   rather than a gesture handle, so ordinary screens end above it
///   (`NavigationBarProtection`, #651).
typedef NavigationBarLayout = ({bool outsideFlutter, bool buttonsAtBottom});

const _unknownLayout = (outsideFlutter: false, buttonsAtBottom: false);

NavigationBarLayout _layoutFromMap(Object? arguments) {
  final map = arguments! as Map<Object?, Object?>;
  return (
    outsideFlutter: map['outsideFlutter']! as bool,
    buttonsAtBottom: map['buttonsAtBottom']! as bool,
  );
}

/// The current [NavigationBarLayout]. MainActivity pushes every change;
/// without the channel (tests, other hosts) neither condition holds.
///
/// Kept alive so a screen that mounts again (the browser leaving fullscreen)
/// starts from the known value, not from the default until the native reply
/// lands.
@Riverpod(keepAlive: true)
class NavigationBarLayoutController extends _$NavigationBarLayoutController {
  /// The channel takes one handler per process, but every [ProviderContainer]
  /// builds its own notifier, and an old container can outlive a new one's
  /// build. The handler therefore serves all live notifiers and is removed
  /// only with the last of them.
  static final _instances = <NavigationBarLayoutController>{};

  static Future<void> _handleCall(MethodCall call) async {
    if (call.method == 'layoutChanged') {
      final layout = _layoutFromMap(call.arguments);
      for (final instance in _instances.toList()) {
        instance.state = layout;
      }
    }
  }

  @override
  NavigationBarLayout build() {
    _instances.add(this);
    _channel.setMethodCallHandler(_handleCall);
    ref.onDispose(() {
      _instances.remove(this);
      if (_instances.isEmpty) _channel.setMethodCallHandler(null);
    });

    // A change pushed before the handler existed is lost, so read the current
    // value once. Replies and pushes share one ordered channel, so a later
    // push can't be overwritten by this older reading.
    unawaited(
      _channel
          .invokeMethod<Object?>('getLayout')
          .then((layout) {
            if (ref.mounted && layout != null) state = _layoutFromMap(layout);
          })
          .catchError((Object _) {}, test: (e) => e is MissingPluginException),
    );

    return _unknownLayout;
  }
}
