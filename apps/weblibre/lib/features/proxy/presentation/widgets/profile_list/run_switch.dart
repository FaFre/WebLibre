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

class RunSwitch extends StatelessWidget {
  final bool isRunning;
  final bool disabled;
  final VoidCallback onTap;

  const RunSwitch({
    super.key,
    required this.isRunning,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = isRunning
        ? scheme.primary
        : scheme.surfaceContainerHighest;
    final foreground = isRunning ? scheme.onPrimary : scheme.onSurface;

    return IconButton.filled(
      tooltip: isRunning ? 'Stop' : 'Start',
      onPressed: disabled ? null : onTap,
      style: IconButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        disabledBackgroundColor: scheme.surfaceContainerHighest.withValues(
          alpha: 0.5,
        ),
      ),
      icon: Icon(isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded),
    );
  }
}
