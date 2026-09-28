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
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/features/proxy/presentation/utils/proxy_log_level_l10n.dart';
import 'package:weblibre/features/user/data/models/proxy_diagnostics_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_diagnostics_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// How much the proxy runtimes write to the log, asked where the log is read.
///
/// A sheet rather than a screen: the choice is one list of five, it is always
/// made while looking at the log it changes, and coming back to the same lines
/// afterwards is the point.
Future<void> showProxyLogLevelSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => const _ProxyLogLevelSheet(),
  );
}

class _ProxyLogLevelSheet extends ConsumerWidget {
  const _ProxyLogLevelSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final logLevel = ref
        .watch(proxyDiagnosticsSettingsWithDefaultsProvider)
        .logLevel;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
              child: Text(
                l10n.proxy_logLevelSheetTitle,
                style: theme.textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Text(
                l10n.proxy_logLevelSheetExplanation,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            RadioGroup(
              groupValue: logLevel,
              onChanged: (value) async {
                if (value == null) return;

                await ref
                    .read(proxyDiagnosticsSettingsRepositoryProvider.notifier)
                    .setLogLevel(value);
              },
              child: Column(
                children: [
                  for (final level in ProxyLogLevel.values)
                    RadioListTile.adaptive(
                      value: level,
                      title: Text(level.label(context)),
                      subtitle: Text(level.description(context)),
                    ),
                ],
              ),
            ),
            if (logLevel.isVerbose)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_outlined,
                      size: 20,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.proxy_verboseLoggingWarning,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
