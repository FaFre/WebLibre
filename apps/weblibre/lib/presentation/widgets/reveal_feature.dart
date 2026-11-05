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
import 'package:riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/settings/domain/hidden_settings.dart';
import 'package:weblibre/features/settings/domain/providers/hidden_settings.dart';
import 'package:weblibre/features/settings/presentation/dialogs/hide_feature_dialog.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/utils/visibility_switch_l10n.dart';
import 'package:weblibre/utils/ui_helper.dart';

part 'reveal_feature.g.dart';

/// Visibility switches the user declined to show when a deliberate action
/// needed them. The question is asked once per switch; after a "no",
/// the same action only points to Settings > Feature Control.
@Riverpod(keepAlive: true)
class DeclinedVisibilityReveals extends _$DeclinedVisibilityReveals {
  @override
  Set<VisibilitySwitch> build() {
    persist(
      ref.watch(riverpodDatabaseStorageProvider),
      key: 'DeclinedVisibilityReveals',
      options: const StorageOptions(cacheTime: StorageCacheTime.unsafe_forever),
      encode: (state) => state.map((s) => s.name).join(','),
      decode: (encoded) {
        final switches = VisibilitySwitch.values.asNameMap();
        return {for (final name in encoded.split(',')) ?switches[name]};
      },
    );

    return stateOrNull ?? const {};
  }

  void declineAll(Iterable<VisibilitySwitch> switches) {
    state = {...state, ...switches};
  }

  void forget(Iterable<VisibilitySwitch> switches) {
    state = {...state}..removeAll(switches);
  }
}

/// Showing hidden features again, for deliberate actions only — a gesture,
/// shortcut or long press bound to the feature, or picking it in the settings
/// search. Automatic behavior never reveals anything. The dialog is
/// [askToRevealFeature]'s; this holds what it decides on, always against the
/// profile: such a reveal is a live change, never an onboarding draft's.
@Riverpod(keepAlive: true)
class FeatureReveal extends _$FeatureReveal {
  @override
  void build() {}

  /// The visibility switches that hide [feature], empty while it is shown.
  List<VisibilitySwitch> missingSwitches(FeatureId feature) =>
      ref.read(generalSettingsWithDefaultsProvider).hiddenSwitchesFor(feature);

  /// Whether the user declined to show one of [switches] before.
  bool declinedBefore(List<VisibilitySwitch> switches) =>
      switches.any(ref.read(declinedVisibilityRevealsProvider).contains);

  void decline(List<VisibilitySwitch> switches) =>
      ref.read(declinedVisibilityRevealsProvider.notifier).declineAll(switches);

  /// The user's changes that apply again once [switches] are shown
  /// ([changesApplyingAgainOnShow]), for the dialog to list before "Show".
  ///
  /// Waits for the toolbars and containers to load: nothing on screen may be
  /// watching them yet when a gesture or shortcut asks, and read before they
  /// load they would count as unchanged.
  Future<List<HiddenSetting>> applyingAgain(
    List<VisibilitySwitch> switches,
  ) async {
    final snapshot = await readLoadedSettingsSnapshot(ref);
    return changesApplyingAgainOnShow(
      suspended: snapshot.suspended,
      stored: () => snapshot,
      switches: switches,
    );
  }

  /// Applies [update] to the profile's settings; see [showSwitches]. Returns
  /// whether it was saved, like the settings save controllers: a failure is
  /// logged, and the caller tells the user.
  Future<bool> write(UpdateGeneralSettingsFunc update) async {
    try {
      await ref
          .read(generalSettingsRepositoryProvider.notifier)
          .updateSettings(update);
      return true;
    } catch (error, stackTrace) {
      logger.e(
        'Failed to show hidden features',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}

/// What "Show" does, however it was asked for: turns [switches] on through
/// [write], and nothing else. Returns whether the write landed.
///
/// With [committed] the write is a live change: the switches are no longer
/// declined ([DeclinedVisibilityReveals]), and a restart is offered for the
/// changes in [applyingAgain] the engine reads only at start. In the
/// onboarding the write goes into a draft that can still be discarded, so
/// neither happens there.
///
/// [container] is the caller's (`ref.container`), for the restart.
Future<bool> showSwitches(
  BuildContext? context,
  ProviderContainer container,
  List<VisibilitySwitch> switches, {
  required Future<bool> Function(UpdateGeneralSettingsFunc update) write,
  required List<HiddenSetting> applyingAgain,
  required bool committed,
}) async {
  final saved = await write((current) => withSwitchesShown(current, switches));
  // A failed write leaves the switches hidden, so a decline still stands:
  // forgetting it would bring the full dialog back on the next binding.
  if (!committed || !saved) return saved;

  // A switch turned on here is no longer a declined one. Only touched when
  // there is something to forget.
  final declined = container.read(declinedVisibilityRevealsProvider);
  if (switches.any(declined.contains)) {
    container.read(declinedVisibilityRevealsProvider.notifier).forget(switches);
  }

  if (saved && context != null && context.mounted) {
    await offerRestartForStartupSettings(context, container, applyingAgain);
  }
  return saved;
}

/// Asks whether to show the hidden [feature], and shows it on "Show": every
/// visibility switch it needs is turned on, nothing else changes. Returns
/// whether the feature is shown afterwards. Always the profile
/// ([FeatureReveal]).
///
/// [container] is the caller's (`ref.container`), from a widget or a service
/// alike.
///
/// With [askOnce] (bindings), a switch the user declined with "Cancel" before
/// is not asked about again: a short note points to Feature Control and
/// offers "Show" right there. Dismissing the dialog (back, tapping outside) is
/// no answer and is not remembered. Callers that only ask on an explicit
/// request to see the feature pass false.
Future<bool> askToRevealFeature(
  BuildContext context,
  ProviderContainer container,
  FeatureId feature, {
  bool askOnce = true,
}) async {
  final reveal = container.read(featureRevealProvider.notifier);
  final missing = reveal.missingSwitches(feature);
  if (missing.isEmpty) return true;

  if (askOnce && reveal.declinedBefore(missing)) {
    final l10n = AppLocalizations.of(context);
    showInfoMessage(
      context,
      l10n.visibilitySwitch_stillHiddenNote,
      // Shows the feature only; the action that needed it is not replayed,
      // so nothing happens the user did not see coming.
      action: SnackBarAction(
        label: l10n.visibilitySwitch_revealConfirm,
        onPressed: () =>
            unawaited(_revealFromNote(context, container, reveal, missing)),
      ),
    );
    return false;
  }

  final applyingAgain = await reveal.applyingAgain(missing);
  if (!context.mounted) return false;
  final show = await showRevealDialog(
    context,
    missing,
    applyingAgain: applyingAgain,
  );
  if (show != true) {
    // Only an explicit "Cancel" is a decline worth remembering.
    if (askOnce && show == false) reveal.decline(missing);
    return false;
  }

  return await _showSwitchesOrReport(
    context.mounted ? context : null,
    container,
    reveal,
    missing,
    applyingAgain,
  );
}

/// The "Show" of the still-hidden note. A plain tap there shows nothing
/// that the note did not name, so the changes that would apply again are
/// confirmed in the dialog first; with none, it shows the feature at once.
/// Never a decline, and the action that needed the feature is not replayed.
Future<void> _revealFromNote(
  BuildContext context,
  ProviderContainer container,
  FeatureReveal reveal,
  List<VisibilitySwitch> missing,
) async {
  final applyingAgain = await reveal.applyingAgain(missing);
  if (applyingAgain.isNotEmpty) {
    if (!context.mounted) return;
    final show = await showRevealDialog(
      context,
      missing,
      applyingAgain: applyingAgain,
    );
    if (show != true) return;
  }
  await _showSwitchesOrReport(
    context.mounted ? context : null,
    container,
    reveal,
    missing,
    applyingAgain,
  );
}

/// [showSwitches] against the profile, telling the user when the write
/// failed and the feature stays hidden. Returns whether it is shown.
/// [context] is null once the caller's is gone; nothing is shown then.
Future<bool> _showSwitchesOrReport(
  BuildContext? context,
  ProviderContainer container,
  FeatureReveal reveal,
  List<VisibilitySwitch> missing,
  List<HiddenSetting> applyingAgain,
) async {
  // Resolved before the write: the restart offer may await in between.
  void Function()? reportFailure;
  if (context != null) {
    final showError = errorMessengerFor(context);
    final message = AppLocalizations.of(context).visibilitySwitch_showFailed;
    reportFailure = () => showError(message);
  }

  final shown = await showSwitches(
    context,
    container,
    missing,
    write: reveal.write,
    applyingAgain: applyingAgain,
    committed: true,
  );
  if (!shown) reportFailure?.call();
  return shown;
}

/// Asks whether to turn [missing] on: true for "Show", false for "Cancel",
/// null when the dialog was dismissed without an answer. [applyingAgain]
/// are the user's changes that "Show" makes apply again, listed so that
/// nothing comes back unseen.
Future<bool?> showRevealDialog(
  BuildContext context,
  List<VisibilitySwitch> missing, {
  required List<HiddenSetting> applyingAgain,
}) => showDialog<bool>(
  context: context,
  builder: (context) =>
      _RevealDialog(missing: missing, applyingAgain: applyingAgain),
);

/// "Show" turns every switch in [missing] on, so the dialog names them all,
/// each with its description: the user may never have heard of the feature
/// that what they just used belongs to.
class _RevealDialog extends StatelessWidget {
  const _RevealDialog({required this.missing, required this.applyingAgain});

  final List<VisibilitySwitch> missing;
  final List<HiddenSetting> applyingAgain;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final count = missing.length;

    return AlertDialog(
      // Several switches, landscape, split screen or large text can outgrow
      // the window; the actions stay reachable either way.
      scrollable: true,
      icon: const Icon(Icons.visibility_outlined),
      title: Text(l10n.visibilitySwitch_revealTitle(count)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.visibilitySwitch_revealIntro(count)),
          const SizedBox(height: 8),
          for (final visibilitySwitch in missing)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(visibilitySwitch.icon),
              title: Text(visibilitySwitch.label(context)),
              subtitle: Text(visibilitySwitch.description(context)),
            ),
          if (applyingAgain.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(l10n.visibilitySwitch_revealResumesIntro(count)),
            HiddenSettingsList(settings: applyingAgain),
          ],
          const SizedBox(height: 8),
          Text(l10n.visibilitySwitch_revealOutcome(count)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.common_cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.visibilitySwitch_revealConfirm),
        ),
      ],
    );
  }
}
