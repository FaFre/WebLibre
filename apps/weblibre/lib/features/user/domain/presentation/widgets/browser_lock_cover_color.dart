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

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:weblibre/core/logger.dart';

/// Hands the app's background colour to the native lock cover.
///
/// The cover hides a locked profile's window from leaving until the lock
/// screen is drawn, and Android 13 and later paint the same colour where the
/// window's screenshot would be. Native knows only the window's theme, which
/// follows the system's day and night: with the app set to dark on a light
/// system, every return would flash white before the dark lock screen.
class BrowserLockCoverColor extends HookWidget {
  final Widget child;

  const BrowserLockCoverColor({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).scaffoldBackgroundColor.toARGB32();

    useEffect(() {
      unawaited(
        GeckoProfileService().setBrowserLockCoverColor(background).catchError((
          Object error,
          StackTrace stackTrace,
        ) {
          logger.w(
            'Could not hand the background colour to the browser lock cover',
            error: error,
            stackTrace: stackTrace,
          );
        }),
      );
      return null;
    }, [background]);

    return child;
  }
}
