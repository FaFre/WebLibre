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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:intl/intl.dart';
import 'package:weblibre/features/addons/extensions/addon_info.dart';

class AddonIconView extends StatelessWidget {
  final AddonInfo addon;
  final double size;

  const AddonIconView({required this.addon, this.size = 40, super.key});

  @override
  Widget build(BuildContext context) {
    final bytes = addon.icon;
    final borderRadius = BorderRadius.circular(12);

    if (bytes != null && bytes.isNotEmpty) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _FallbackIcon(size: size),
        ),
      );
    }

    return _FallbackIcon(size: size);
  }
}

class _FallbackIcon extends StatelessWidget {
  final double size;

  const _FallbackIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.extension, color: theme.colorScheme.onSurfaceVariant),
    );
  }
}

class AddonStatusBanner extends StatelessWidget {
  final AddonInfo addon;

  const AddonStatusBanner({required this.addon, super.key});

  @override
  Widget build(BuildContext context) {
    final message = addon.statusBannerMessage;
    if (message == null) {
      return const SizedBox.shrink();
    }

    final isWarning = addon.disabledReason == AddonDisabledReason.softBlocked;
    final theme = Theme.of(context);
    final background = isWarning
        ? theme.colorScheme.tertiaryContainer
        : theme.colorScheme.errorContainer;
    final foreground = isWarning
        ? theme.colorScheme.onTertiaryContainer
        : theme.colorScheme.onErrorContainer;
    final icon = isWarning ? Icons.warning_amber_rounded : Icons.error_outline;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

String formatAddonDate(String raw) {
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) {
    return raw.isEmpty ? 'Unknown' : raw;
  }

  return DateFormat.yMMMd().format(parsed.toLocal());
}

String formatUpdateAttemptDate(AddonUpdateAttemptInfo attempt) {
  final date = DateTime.fromMillisecondsSinceEpoch(
    attempt.dateMillisecondsSinceEpoch,
  ).toLocal();
  return DateFormat.yMMMd().add_jm().format(date);
}

String formatUpdateAttemptStatus(AddonUpdateAttemptInfo? attempt) {
  return switch (attempt?.status) {
    AddonUpdateStatus.successfullyUpdated =>
      attempt?.message?.isNotEmpty == true
          ? attempt!.message!
          : 'Updated successfully',
    AddonUpdateStatus.noUpdateAvailable => 'No update available',
    AddonUpdateStatus.notInstalled => 'Extension not installed',
    AddonUpdateStatus.error =>
      attempt?.message?.isNotEmpty == true
          ? 'Update failed: ${attempt!.message}'
          : 'Update failed',
    null => 'No update checks recorded yet',
  };
}
