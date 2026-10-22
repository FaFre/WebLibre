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
import 'package:flutter/material.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

class RunSwitch extends StatelessWidget {
  final bool isRunning;

  /// The connection is on its way up — started a moment ago, or restarted
  /// because another connection started or stopped. Shown as on, with progress
  /// in place of the icon, and not tappable until it settles.
  final bool isStarting;
  final bool disabled;
  final VoidCallback onTap;

  const RunSwitch({
    super.key,
    required this.isRunning,
    required this.disabled,
    required this.onTap,
    this.isStarting = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isOn = isRunning || isStarting;
    final background = isOn ? scheme.primary : scheme.surfaceContainerHighest;
    final foreground = isOn ? scheme.onPrimary : scheme.onSurface;

    return IconButton.filled(
      tooltip: isStarting
          ? l10n.proxy_connectionStarting
          : isRunning
          ? l10n.proxy_actionStop
          : l10n.proxy_actionStart,
      onPressed: disabled || isStarting ? null : onTap,
      style: IconButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        disabledBackgroundColor: isStarting
            ? scheme.primary.withValues(alpha: 0.7)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      ),
      icon: isStarting
          ? SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: scheme.onPrimary,
              ),
            )
          : Icon(isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded),
    );
  }
}
