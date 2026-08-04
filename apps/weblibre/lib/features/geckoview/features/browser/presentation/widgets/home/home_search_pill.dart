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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/widgets/qr_scanner_button.dart';
import 'package:weblibre/presentation/widgets/speech_to_text_button.dart';

/// The home surface's entry into search.
///
/// Deliberately not a real text field: it pushes the search screen, which owns
/// the actual input, its autofocus and its keyboard-inset handling. A second
/// live field here would compete with all three. Its only job is to make the
/// home surface read as the same page as the new-tab screen.
///
/// The QR and voice buttons are the same widgets [SearchField] mounts, but they
/// cannot write into a controller here because there is no field to write to —
/// they hand their result to the search screen as its initial text instead.
/// Neither auto-submits: speech recognition misfires, and a scanned code is
/// untrusted input that should not navigate on its own.
///
/// Rendered pinned by the home surface, so it is opaque and carries a shadow:
/// the module list scrolls underneath it.
class HomeSearchPill extends ConsumerWidget {
  const HomeSearchPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Selector, not the whole settings object: this rebuilds on every
    // settings write otherwise, and it sits above the module list.
    final defaultTabType = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.effectiveDefaultCreateTabType,
      ),
    );

    void openSearch([String? initialText]) {
      unawaited(
        SearchRoute(
          tabType: defaultTabType,
          // The route encodes this into a path segment, so an empty string
          // would leave a trailing slash that no longer matches the pattern.
          searchText: (initialText == null || initialText.isEmpty)
              ? SearchRoute.emptySearchText
              : initialText,
        ).push(context),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Material(
        color: colorScheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shadowColor: colorScheme.shadow,
        elevation: 3,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: openSearch,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Search or enter URL',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            QrScannerButton(
              onScanResult: (scanResult) {
                final code = scanResult?.code;
                if (code == null || !context.mounted) return;

                openSearch(code);
              },
            ),
            SpeechToTextButton(
              onTextReceived: (text) {
                if (!context.mounted) return;

                openSearch(text);
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
