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
import 'package:weblibre/domain/setup_draft/setup_draft.dart';
import 'package:weblibre/features/onboarding/presentation/utils/setup_preset_l10n.dart';
import 'package:weblibre/features/settings/domain/hidden_settings.dart';
import 'package:weblibre/features/settings/domain/providers/hidden_settings.dart';
import 'package:weblibre/features/settings/presentation/dialogs/hide_feature_dialog.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/browser_page.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// "How much should WebLibre show?": the three preset cards. Choosing one only
/// changes the draft; Custom is not a fourth card but "Show or hide
/// features", later.
///
/// Choosing another preset drops the features shown or hidden on top of the
/// old one, and nothing else ([SetupDraft.withPreset]); when there were
/// some, a snackbar offers to undo the change. Changed settings stay, but a
/// preset that hides their feature stops them from applying: that is
/// confirmed first, like hiding the feature with its own switch.
class PresetPage extends ConsumerWidget {
  const PresetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(
      setupDraftControllerProvider.select((draft) => draft?.preset),
    );
    // What a preset change is checked against ([_settingsStopping]), loaded
    // before a card is tapped. Listened rather than watched: kept alive
    // without rebuilding the cards on every draft edit.
    ref.listen(storedSettingsSnapshotProvider, (_, _) {});

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
  if (previous == null || preset == previous.preset) return;

  final stopping = _settingsStopping(ref, previous, preset);
  if (stopping.isNotEmpty) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          _PresetStopsApplyingDialog(preset: preset, settings: stopping),
    );
    if (confirmed != true || !context.mounted) return;
    // Changed meanwhile (the dialog does not block the draft): start over.
    if (!identical(ref.read(setupDraftControllerProvider), previous)) return;
  }

  controller.selectPreset(preset);
  if (!previous.hasVisibilityChanges) return;

  final changed = ref.read(setupDraftControllerProvider);
  if (changed == null) return;
  final undo = await showUndoMessage(
    context,
    AppLocalizations.of(context).onboarding_presetChangeResetVisibility,
  );
  if (undo) controller.undo(changed: changed, previous: previous);
}

/// The changed settings that stop applying when [draft] starts again from
/// [preset]: kept by the preset change, but hidden with their feature. Read
/// from the whole of what the commit would write, the engine settings
/// included, so a value the old preset set itself is not mistaken for one
/// the user changed.
List<HiddenSetting> _settingsStopping(
  WidgetRef ref,
  SetupDraft draft,
  SetupPreset preset,
) {
  final stored = ref.read(storedSettingsSnapshotProvider);
  final candidate = draft.withPreset(preset);
  return settingsStoppingBetween(
    stored,
    stored.withGeneral(
      candidate.applyGeneral(ref.read(profileGeneralSettingsProvider)),
      engine: candidate.applyEngine(ref.read(profileEngineSettingsProvider)),
    ),
  );
}

/// Asks before a preset change that stops changed [settings] from applying,
/// naming them.
class _PresetStopsApplyingDialog extends StatelessWidget {
  const _PresetStopsApplyingDialog({
    required this.preset,
    required this.settings,
  });

  final SetupPreset preset;
  final List<HiddenSetting> settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      // A long list, landscape or large text can outgrow the window.
      scrollable: true,
      icon: Icon(preset.icon),
      title: Text(
        l10n.onboarding_presetChangeStopsApplyingTitle(preset.label(context)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.onboarding_presetChangeStopsApplyingContent),
          const SizedBox(height: 8),
          HiddenSettingsList(settings: settings),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.common_cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.onboarding_presetChangeConfirm),
        ),
      ],
    );
  }
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
