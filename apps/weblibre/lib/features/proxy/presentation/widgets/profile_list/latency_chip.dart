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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/proxy/domain/services/proxy_latency_tester.dart';

class LatencyChip extends StatelessWidget {
  final AsyncValue<ProxyLatencyData> result;

  const LatencyChip({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return switch (result) {
      AsyncLoading() => const _LatencyStatusChip.loading(),
      AsyncError(:final error) => _LatencyStatusChip.error(error),
      AsyncData(:final value) => _LatencySuccessChip(value: value),
    };
  }
}

class _LatencyStatusChip extends StatelessWidget {
  final String label;
  final String tooltip;
  final bool isError;

  const _LatencyStatusChip({
    required this.label,
    required this.tooltip,
    required this.isError,
  });

  const _LatencyStatusChip.loading()
    : this(
        label: 'Testing...',
        tooltip: 'Latency test running',
        isError: false,
      );

  _LatencyStatusChip.error(Object error)
    : this(label: 'Failed', tooltip: error.toString(), isError: true);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _LatencyChipContainer(
      label: label,
      tooltip: tooltip,
      backgroundColor: isError
          ? scheme.errorContainer
          : scheme.surfaceContainerHighest,
      foregroundColor: isError
          ? scheme.onErrorContainer
          : scheme.onSurfaceVariant,
    );
  }
}

class _LatencySuccessChip extends StatelessWidget {
  final ProxyLatencyData value;

  const _LatencySuccessChip({required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = _latencyColors(scheme, value.latency);

    return _LatencyChipContainer(
      label: '${value.latency.inMilliseconds} ms',
      tooltip: 'HTTP ${value.statusCode} in ${value.latency.inMilliseconds} ms',
      backgroundColor: background,
      foregroundColor: foreground,
    );
  }

  static (Color, Color) _latencyColors(ColorScheme scheme, Duration latency) {
    final ms = latency.inMilliseconds;
    if (ms < 500) return (scheme.primaryContainer, scheme.onPrimaryContainer);
    if (ms < 1500) {
      return (scheme.tertiaryContainer, scheme.onTertiaryContainer);
    }
    return (scheme.errorContainer, scheme.onErrorContainer);
  }
}

class _LatencyChipContainer extends StatelessWidget {
  final String label;
  final String tooltip;
  final Color backgroundColor;
  final Color foregroundColor;

  const _LatencyChipContainer({
    required this.label,
    required this.tooltip,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: foregroundColor),
        ),
      ),
    );
  }
}
