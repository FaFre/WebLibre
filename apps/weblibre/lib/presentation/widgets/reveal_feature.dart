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
/// [askToRevealFeature]'s; this holds what it decides on.
@Riverpod(keepAlive: true)
class FeatureReveal extends _$FeatureReveal {
  @override
  void build() {}

  /// The container this lives in, for the restart [revealAndOfferRestart]
  /// may offer.
  ProviderContainer get container => ref.container;

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
  List<HiddenSetting> applyingAgain(List<VisibilitySwitch> switches) =>
      changesApplyingAgainOnShow(
        // One-off reads that hold nothing open; the settings behind them are
        // kept alive.
        // ignore: riverpod_lint/only_use_keep_alive_inside_keep_alive
        suspended: ref.read(suspendedSettingsProvider),
        // ignore: riverpod_lint/only_use_keep_alive_inside_keep_alive
        stored: () => ref.read(storedSettingsSnapshotProvider),
        switches: switches,
      );

  /// Turns [switches] on, and nothing else. Returns the changes that apply
  /// again ([applyingAgain], read before saving): [revealAndOfferRestart]
  /// offers a restart for the ones read at engine start.
  Future<List<HiddenSetting>> reveal(List<VisibilitySwitch> switches) async {
    final resumed = applyingAgain(switches);
    await ref
        .read(generalSettingsRepositoryProvider.notifier)
        .updateSettings((current) => withSwitchesShown(current, switches));
    ref.read(declinedVisibilityRevealsProvider.notifier).forget(switches);
    return resumed;
  }
}

/// [FeatureReveal.reveal], then the restart the settings rows offer when a
/// setting that applies again is read only at engine start.
Future<void> revealAndOfferRestart(
  BuildContext context,
  FeatureReveal reveal,
  List<VisibilitySwitch> switches,
) async {
  final applyingAgain = await reveal.reveal(switches);
  if (context.mounted) {
    await offerRestartForStartupSettings(
      context,
      reveal.container,
      applyingAgain,
    );
  }
}

/// Asks whether to show the hidden [feature], and shows it on "Show": every
/// visibility switch it needs is turned on, nothing else changes. Returns
/// whether the feature is shown afterwards.
///
/// [reveal] is `ref.read(featureRevealProvider.notifier)`, from a widget or a
/// service alike.
///
/// With [askOnce] (bindings), a switch the user declined with "Cancel" before
/// is not asked about again: a short note points to Feature Control and
/// offers "Show" right there. Dismissing the dialog (back, tapping outside) is
/// no answer and is not remembered. Callers that only ask on an explicit
/// request to see the feature pass false.
Future<bool> askToRevealFeature(
  BuildContext context,
  FeatureReveal reveal,
  FeatureId feature, {
  bool askOnce = true,
}) async {
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
        onPressed: () => unawaited(_revealFromNote(context, reveal, missing)),
      ),
    );
    return false;
  }

  final show = await showRevealDialog(
    context,
    missing,
    applyingAgain: reveal.applyingAgain(missing),
  );
  if (show != true) {
    // Only an explicit "Cancel" is a decline worth remembering.
    if (askOnce && show == false) reveal.decline(missing);
    return false;
  }

  if (context.mounted) {
    await revealAndOfferRestart(context, reveal, missing);
  } else {
    await reveal.reveal(missing);
  }
  return true;
}

/// The "Show" of the still-hidden note. A plain tap there shows nothing
/// that the note did not name, so the changes that would apply again are
/// confirmed in the dialog first; with none, it shows the feature at once.
/// Never a decline, and the action that needed the feature is not replayed.
Future<void> _revealFromNote(
  BuildContext context,
  FeatureReveal reveal,
  List<VisibilitySwitch> missing,
) async {
  final applyingAgain = reveal.applyingAgain(missing);
  if (applyingAgain.isNotEmpty) {
    if (!context.mounted) return;
    final show = await showRevealDialog(
      context,
      missing,
      applyingAgain: applyingAgain,
    );
    if (show != true) return;
  }
  if (context.mounted) {
    await revealAndOfferRestart(context, reveal, missing);
  } else {
    await reveal.reveal(missing);
  }
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
