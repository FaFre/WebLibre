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
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/settings/domain/hidden_settings.dart';
import 'package:weblibre/features/settings/domain/providers/hidden_settings.dart';
import 'package:weblibre/features/settings/domain/providers/kept_when.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/reveal_feature.dart';

export 'package:weblibre/features/settings/domain/providers/kept_when.dart'
    show HiddenFeatureCondition, KeptWhen;

/// Marks everything below it as configuring [feature]: every
/// [HiddenFeatureGate] inside, including the ones the settings section list
/// puts around its entries, is grayed out while [feature] is hidden.
///
/// For screens that configure one feature as a whole (Tor, Gestures, Secure
/// DNS…). Scopes nest; a route pushed from inside starts without one.
class HiddenFeatureScope extends StatelessWidget {
  const HiddenFeatureScope({
    super.key,
    required this.feature,
    this.keptWhen,
    required this.child,
  });

  final FeatureId feature;
  final KeptWhen? keptWhen;
  final Widget child;

  /// The conditions of every scope around [context], outermost first.
  static List<HiddenFeatureCondition> conditionsOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_HiddenFeatureScopeData>()
          ?.conditions ??
      const [];

  @override
  Widget build(BuildContext context) => _HiddenFeatureScopeData(
    conditions: [
      ...conditionsOf(context),
      (feature: feature, keptWhen: keptWhen),
    ],
    child: child,
  );
}

class _HiddenFeatureScopeData extends InheritedWidget {
  const _HiddenFeatureScopeData({
    required this.conditions,
    required super.child,
  });

  final List<HiddenFeatureCondition> conditions;

  @override
  bool updateShouldNotify(_HiddenFeatureScopeData oldWidget) =>
      !const ListEquality<HiddenFeatureCondition>().equals(
        conditions,
        oldWidget.conditions,
      );
}

/// A settings control that stays in place while its feature is hidden:
/// grayed out, showing its current value, but not changeable. Tapping it asks
/// to show the feature; "Show" turns on the visibility switches it needs and
/// changes nothing else, so the user then makes the change themselves.
/// "Cancel" changes nothing and asks again next time.
///
/// Hidden means: [conditions], or a [HiddenFeatureScope] above, names a
/// feature that is not shown and not kept. With nothing hidden this is just
/// [child].
///
/// With [opensScreen] the child only leads to another screen, which is gated
/// itself: it is grayed out but stays tappable, so hidden settings can still
/// be looked at.
///
/// With [omitWhenHidden] the child is left out instead of grayed out. For
/// task screens reached while browsing (the container editor, the bang
/// editor, the add-connection sheet): settings show what can be turned on,
/// a task shows only what the user has chosen to see. What is in force or
/// kept still shows, so it can be checked and undone (P5); only for what
/// keeps applying while hidden (H1).
///
/// With [indicator] the child is a full-width row, and a hidden one ends with
/// an eye-off icon at full strength: grayed out alone, it would read as
/// disabled, and nobody taps a disabled control.
///
/// Reads the settings through `displayedGeneralSettingsProvider` and saves
/// through `saveGeneralSettingsControllerProvider`, so in the onboarding it
/// gates and reveals the draft, never the live settings.
class HiddenFeatureGate extends ConsumerWidget {
  const HiddenFeatureGate({
    super.key,
    this.conditions = const [],
    this.opensScreen = false,
    this.omitWhenHidden = false,
    this.inForce = false,
    this.hiddenSettings = const [],
    this.indicator = false,
    required this.child,
  }) : assert(
         !(opensScreen && omitWhenHidden),
         'An omitted child opens nothing',
       );

  /// Gated by [feature] alone (plus any scope).
  HiddenFeatureGate.feature(
    FeatureId feature, {
    super.key,
    KeptWhen? keptWhen,
    this.opensScreen = false,
    this.omitWhenHidden = false,
    this.inForce = false,
    this.hiddenSettings = const [],
    this.indicator = false,
    required this.child,
  }) : assert(
         !(opensScreen && omitWhenHidden),
         'An omitted child opens nothing',
       ),
       conditions = [(feature: feature, keptWhen: keptWhen)];

  final List<HiddenFeatureCondition> conditions;
  final bool opensScreen;
  final bool omitWhenHidden;

  /// Like a `keptWhen` that holds, for a condition the caller already knows,
  /// e.g. the option that is the current choice: never gated. Only for what
  /// keeps applying while hidden (where data goes, what the user created).
  final bool inForce;

  /// The settings [child] shows that stop applying while it is hidden. While
  /// one of them is changed from its hidden value, the grayed-out child says
  /// so below it ("Not applied while hidden").
  final List<HiddenSetting> hiddenSettings;

  /// Whether [child] is a full-width row that ends with the hidden-feature
  /// eye while hidden. Off for compact controls (an app bar action, a
  /// floating button, a switch inside a tile) and for whole blocks, which a
  /// trailing icon does not fit.
  final bool indicator;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HiddenSwitchesBuilder(
      conditions: [...HiddenFeatureScope.conditionsOf(context), ...conditions],
      builder: (context, missing) => _gated(context, ref, missing),
    );
  }

  Widget _gated(
    BuildContext context,
    WidgetRef ref,
    List<VisibilitySwitch> missing,
  ) {
    if (inForce || missing.isEmpty) return child;
    if (omitWhenHidden) return const SizedBox.shrink();

    // Inside a gate that already grays its part out, graying again would
    // only darken it further.
    final alreadyDimmed =
        context.dependOnInheritedWidgetOfExactType<_DimmedByGate>() != null;
    final grayed = alreadyDimmed
        ? child
        : Opacity(
            opacity: hiddenFeatureOpacity,
            child: _DimmedByGate(child: child),
          );
    // Inside a grayed-out part the eye of the part already says it.
    final dimmed = !indicator || alreadyDimmed
        ? grayed
        : Row(
            children: [
              Expanded(child: grayed),
              const _HiddenFeatureEye(),
            ],
          );
    Widget withNote(Widget gated) => hiddenSettings.isEmpty
        ? gated
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [gated, NotAppliedWhileHiddenNote(hiddenSettings)],
          );

    if (opensScreen) return withNote(dimmed);

    final l10n = AppLocalizations.of(context);
    Future<void> ask() => revealHiddenSwitches(context, ref, missing);

    return withNote(
      MergeSemantics(
        child: Semantics(
          hint: l10n.visibilitySwitch_hiddenControlHint,
          onTap: ask,
          // Transparent, so the ink has something to draw on wherever the gate
          // sits (an app bar action, a floating button).
          child: Material(
            type: MaterialType.transparency,
            // Takes the control's place for pointer and keyboard alike: it can
            // be focused, and Enter or Space asks like a tap does.
            child: InkWell(
              excludeFromSemantics: true,
              onTap: ask,
              // The control keeps its labels and value for screen readers, but
              // neither a pointer, a key nor an accessibility action reaches it.
              child: ExcludeFocus(child: IgnorePointer(child: dimmed)),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Not applied while hidden", while one of [settings] is changed from the
/// value it has while its feature is hidden; nothing otherwise. At full
/// strength below a grayed-out setting: it explains the value shown.
///
/// [HiddenFeatureGate.hiddenSettings] puts it under a gated setting; this is
/// for a setting with only some options gated, like a choice of tab types.
class NotAppliedWhileHiddenNote extends ConsumerWidget {
  const NotAppliedWhileHiddenNote(this.settings, {super.key});

  final List<HiddenSetting> settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Nothing can be suspended while every feature is shown.
    final somethingHidden = ref.watch(
      displayedGeneralSettingsProvider.select(
        (s) => !VisibilitySwitch.values.every(s.isVisibilitySwitchShown),
      ),
    );
    final notApplied = ref.watch(
      suspendedSettingsProvider.select(
        (suspended) => settings.any(suspended.contains),
      ),
    );
    if (settings.isEmpty || !somethingHidden || !notApplied) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(
                context,
              ).visibilitySwitch_notAppliedWhileHidden,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Marks a subtree a [HiddenFeatureGate] has grayed out already.
class _DimmedByGate extends InheritedWidget {
  const _DimmedByGate({required super.child});

  @override
  bool updateShouldNotify(_DimmedByGate oldWidget) => false;
}

/// How hidden settings are grayed out. For options a [HiddenFeatureGate]
/// cannot wrap, like one segment of a `SegmentedButton`.
const hiddenFeatureOpacity = 0.5;

/// For an option a [HiddenFeatureGate] grays out inside a group that also
/// picks options without a tap on them, like a `RadioGroup`, which selects
/// with the arrow keys: call it from the group's `onChanged` before saving.
/// While [feature] is hidden (and not [keptWhen]) it asks to show it, the
/// way a tap on the option does, and returns false: the change is not made
/// either way.
Future<bool> mayPickHiddenOption(
  BuildContext context,
  WidgetRef ref,
  FeatureId feature, {
  KeptWhen? keptWhen,
}) async {
  final missing = ref
      .read(displayedGeneralSettingsProvider)
      .hiddenSwitchesFor(feature);
  if (missing.isEmpty) return true;
  if (keptWhen != null && ref.read(keptWhenHoldsProvider(keptWhen))) {
    return true;
  }

  await revealHiddenSwitches(context, ref, missing);
  return false;
}

/// Builds with the visibility switches that hide something gated by
/// [conditions], in [VisibilitySwitch] order, empty while it is shown
/// ([missingSwitches]): one watch, of the displayed settings and the
/// [KeptWhen] of every condition that is hidden.
class HiddenSwitchesBuilder extends ConsumerWidget {
  const HiddenSwitchesBuilder({
    super.key,
    required this.conditions,
    required this.builder,
  });

  final List<HiddenFeatureCondition> conditions;
  final Widget Function(BuildContext context, List<VisibilitySwitch> missing)
  builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missing = ref.watch(
      missingSwitchesProvider(HiddenFeatureConditions(conditions)),
    );
    return builder(context, missing.value);
  }
}

/// Asks to show [missing], listing the changes that would apply again, and
/// on "Show" turns them on and nothing else ([showSwitches]). Never
/// remembered as declined: tapping a hidden control is a deliberate request
/// every time.
///
/// Writes through the settings save controller, so in the onboarding into
/// its draft, as a visibility edit a preset change drops: nothing is
/// suspended there, so the dialog lists nothing, and no restart is offered
/// and no decline forgotten until the commit.
Future<void> revealHiddenSwitches(
  BuildContext context,
  WidgetRef ref,
  List<VisibilitySwitch> missing,
) async {
  // Read before asking, and so before saving.
  final applyingAgain = changesApplyingAgainOnShow(
    suspended: ref.read(suspendedSettingsProvider),
    stored: () => ref.read(storedSettingsSnapshotProvider),
    switches: missing,
  );
  final committed = ref.read(settingsEditsAreLiveProvider);

  final show = await showRevealDialog(
    context,
    missing,
    applyingAgain: applyingAgain,
  );
  if (show != true || !context.mounted) return;

  await showSwitches(
    context,
    ref.container,
    missing,
    write: ref
        .read(saveGeneralSettingsControllerProvider.notifier)
        .saveVisibility,
    applyingAgain: applyingAgain,
    committed: committed,
  );
}

/// The eye that ends a hidden row ([HiddenFeatureGate.indicator]). Not
/// grayed out: it explains the gray. Screen readers hear the gate's hint.
class _HiddenFeatureEye extends StatelessWidget {
  const _HiddenFeatureEye();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 16),
      child: ExcludeSemantics(
        child: Icon(
          Icons.visibility_off_outlined,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
