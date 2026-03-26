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
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

/// The type of home screen shortcut the user chose.
enum ShortcutInstallType { shortcut, app }

/// Shows a bottom sheet to confirm adding a PWA to the home screen.
///
/// Returns true if the user confirms, null if dismissed.
Future<bool?> showPwaInstallBottomSheet(
  BuildContext context, {
  required String name,
  required Uri url,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ShortcutSheetHeader(name: name, url: url),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.install_mobile),
            title: const Text('Install as App'),
            subtitle: const Text('Runs standalone with its own window.'),
            onTap: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ),
  );
}

/// Shows a bottom sheet for non-manifest sites offering a choice between
/// "Add Shortcut" (opens in browser) and "Install as App" (standalone mode).
///
/// [showAppOption] controls whether the "Install as App" option is visible
/// (requires the allowNonManifestPwaInstall setting to be enabled).
///
/// Returns [ShortcutInstallType] or null if dismissed.
Future<ShortcutInstallType?> showShortcutChoiceBottomSheet(
  BuildContext context, {
  required String name,
  required Uri url,
  required bool showAppOption,
}) {
  return showModalBottomSheet<ShortcutInstallType>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ShortcutSheetHeader(name: name, url: url),
          const Divider(height: 1),
          if (showAppOption)
            ListTile(
              leading: const Icon(Icons.install_mobile),
              title: const Text('Install as App'),
              subtitle: const Text('Runs standalone with its own window.'),
              onTap: () =>
                  Navigator.of(context).pop(ShortcutInstallType.app),
            ),
          ListTile(
            leading: const Icon(Icons.shortcut),
            title: const Text('Add Shortcut'),
            subtitle: const Text('Opens as a standard tab in the browser.'),
            onTap: () =>
                Navigator.of(context).pop(ShortcutInstallType.shortcut),
          ),
        ],
      ),
    ),
  );
}

class _ShortcutSheetHeader extends StatelessWidget {
  final String name;
  final Uri url;

  const _ShortcutSheetHeader({required this.name, required this.url});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add to Home Screen', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              RepaintBoundary(child: UrlIcon([url], iconSize: 32)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    UriBreadcrumb(
                      uri: url,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
