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

/// Hands every key that reaches it to the web content in [child].
///
/// Android gives hardware keys to Flutter first and only redispatches to the
/// focused native view what the framework reports as unhandled. A focused
/// platform view is an ordinary focus node on the Flutter side, so without
/// this its keys bubble up to `WidgetsApp`'s default shortcuts, which *do*
/// handle them: Tab moves Flutter focus off the page (and with it native
/// focus), arrows and Page Up/Down go to directional focus and scrolling,
/// Escape dismisses. The page never sees any of them.
///
/// [KeyEventResult.skipRemainingHandlers] stops that walk while still
/// reporting the key as unhandled, which is exactly what sends it on to the
/// page. Browser shortcuts never get here: they are taken by an early key
/// event handler before the focus tree is walked at all.
///
/// Key releases go to the page too, including the release of a chord the
/// browser consumed. Swallowing one could only be done safely by knowing its
/// press was handled, and a page seeing a stray key-up is harmless.
///
/// Must sit *above* the `PlatformViewLink`: focus handlers are consulted from
/// the focused node upwards, so anything below it is never asked.
class WebContentKeyPassthrough extends StatelessWidget {
  final Widget child;

  const WebContentKeyPassthrough({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (node, event) => KeyEventResult.skipRemainingHandlers,
      child: child,
    );
  }
}
