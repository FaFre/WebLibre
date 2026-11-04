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
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/onboarding/domain/providers/setup_draft.dart';
import 'package:weblibre/features/onboarding/presentation/utils/setup_preset_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/browser_page.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// "How much should WebLibre show?": the three preset cards. Choosing one only
/// changes the draft; Custom is not a fourth card but Customize, later.
///
/// Choosing another preset drops what was changed in Customize on top of the
/// old one; when there was something, a snackbar offers to undo the change.
class PresetPage extends ConsumerWidget {
  const PresetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(
      setupDraftControllerProvider.select((draft) => draft.preset),
    );

    return BrowserPage(
      child: BrowserPageContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Text(
                l10n.onboarding_presetTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 24),
            for (final preset in SetupPreset.values) ...[
              _PresetCard(
                preset: preset,
                selected: preset == selected,
                onTap: () => _select(context, ref, preset),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              l10n.onboarding_presetChangeLater,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _select(
  BuildContext context,
  WidgetRef ref,
  SetupPreset preset,
) async {
  // Read before the await: the page may have been swiped away by the time the
  // snackbar closes, while the draft lives on with the onboarding.
  final controller = ref.read(setupDraftControllerProvider.notifier);
  final previous = ref.read(setupDraftControllerProvider);
  if (preset == previous.preset) return;

  controller.selectPreset(preset);
  if (!previous.hasCustomizeChanges) return;

  final changed = ref.read(setupDraftControllerProvider);
  final undo = await showUndoMessage(
    context,
    AppLocalizations.of(context).onboarding_presetChangeResetCustomize,
  );
  if (undo) controller.undo(changed: changed, previous: previous);
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final SetupPreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // One choice of three, read out like a radio button.
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.secondaryContainer
              : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        // The ink draws on the nearest Material: a transparent one above the
        // card's fill, or the fill would cover the ripple.
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        preset.icon,
                        color: selected
                            ? AppColors.of(context).brandLink
                            : colorScheme.onSurfaceVariant,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              preset.label(context),
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              preset.description(context),
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        Icon(Icons.check_circle, color: colorScheme.primary),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (preset.includes(context) case final includes?)
                    Padding(
                      padding: const EdgeInsets.only(left: 44, bottom: 4),
                      child: Text(
                        includes,
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  for (final point in preset.highlights(context))
                    Padding(
                      padding: const EdgeInsets.only(left: 44, bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(point, style: textTheme.bodySmall),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
