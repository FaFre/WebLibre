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

/// The feature policy: which visibility switches guard each feature, what the
/// onboarding writes for it per preset, and what showing it needs.
///
/// Hand-maintained Dart. The values sit on [FeatureId] in
/// `feature_policy_registry.dart`; this file holds the types. What the
/// compiler cannot check (a guarded feature names its switches, a value that
/// says "shown" agrees with the switches, …) is checked by
/// `test/domain/feature_policy/feature_policy_registry_test.dart`.
///
/// The preset is never stored: it only decides the initial values the
/// onboarding commit writes once, and afterwards every value is an ordinary
/// setting. Existing installs are never changed.
///
/// Code cites these rules by id:
///
/// - **P1.** Hiding never rewrites or erases what is stored: settings stay as
///   stored and apply again once shown (H1). It never changes cookies,
///   storage contexts or account separation; removes containers or profiles;
///   changes proxy routing or falls back to a direct connection; changes
///   clean-up policies or erases data; installs, removes or disables
///   extensions; or changes an installed web app's storage or profile.
/// - **H1.** Hidden means default: while a feature is hidden, its settings
///   apply at their hidden values, the values used while nothing is stored
///   (`GeneralSettings.effective`, `EngineSettings.effective`, …, read
///   through the `*WithDefaults` providers; settings screens read the
///   `stored*` ones). Exempt, and applying as stored: where data goes
///   (connections, routes, Tor, the per-container route and bypass, the sync
///   server, Secure DNS), what the user created, settings stored only in
///   Gecko, and the startup profile prompt. Turning a switch off asks first
///   when changes would stop applying (`settingsStoppingToApply`).
/// - **P2.** Initial values are written only by the onboarding commit on a
///   fresh install.
/// - **P3.** Values the commit wrote are ordinary settings; nothing resets
///   them later, so no provenance is tracked.
/// - **P4.** Onboarding defaults are never reapplied after an upgrade.
/// - **P5.** Safety and access to existing contexts override hiding.
///   Visibility switches hide only optional creation and configuration entry
///   points. The profile switcher (while more than one profile exists),
///   container and isolated-session indicators, the status of a connection a
///   tab needs, and safe-exit controls always stay. Existing containers,
///   isolated tabs, profiles, web apps and running connections keep their
///   status, access, recovery and a way out.
/// - **P6.** Really disabling a feature at runtime describes its effects,
///   keeps stored configuration where it makes sense, and confirms when the
///   change has consequences.
/// - **P7.** A tab that needs a connection that is not running is blocked;
///   it never falls back to a direct connection.
/// - **S1.** Settings search finds every feature, hidden ones included, and
///   explains their status. It may offer to reveal, configure or enable one
///   explicitly, but never activates anything silently or skips a warning or
///   an authentication step.
/// - **S2.** Paid entitlements are checked where a feature is used, never
///   through visibility.
library;

part 'feature_policy_registry.dart';

/// The three ordered presets the onboarding offers. Custom is not a fourth
/// value: it is one of these as a starting point plus individual switch
/// changes.
///
/// Never stored: the preset only decides which initial values the
/// onboarding commit writes once.
enum SetupPreset { average, advanced, expert }

/// What showing or hiding features (Feature Control, the onboarding's
/// "Show or hide features") may do with a feature.
enum FeatureAvailability {
  /// Average tier: never hidden. Its runtime settings still work as usual.
  locked,

  /// Guarded by the visibility switches in [FeaturePolicy.switches].
  guarded,

  /// A deliberate exception that is always shown; the entry says why.
  alwaysAvailable,

  /// Not user-facing.
  notUserFacing,
}

/// An initial value the onboarding commit writes for a feature. Where each
/// one lands in the settings is `presetBindings`.
enum PolicyToken {
  enabled,
  disabled,
  ask,
  uiShown,
  uiHidden,
  hiddenShowSummary,
  shown,
  regularTab,
  recentlyUsedTabs,
  autoApply,
  recommendInstall,
  recommend,

  /// Asked in the onboarding's Search and Layout steps.
  userChoice,
  days90,

  /// The calm new-tab module layout (`calmNewTabLayout`).
  calmNewTab,
  platformDependent,

  /// Writes nothing; the code default stays in effect.
  unchangedAppDefault,
}

/// The initial value of a feature for each preset;
/// [PolicyToken.unchangedAppDefault] where none is given.
final class PresetValues {
  const PresetValues({
    this.average = PolicyToken.unchangedAppDefault,
    this.advanced = PolicyToken.unchangedAppDefault,
    this.expert = PolicyToken.unchangedAppDefault,
  }) : follows = null;

  const PresetValues.all(PolicyToken token)
    : average = token,
      advanced = token,
      expert = token,
      follows = null;

  /// Takes the values of [feature], preset for preset.
  const PresetValues.follows(FeatureId this.follows)
    : average = PolicyToken.unchangedAppDefault,
      advanced = PolicyToken.unchangedAppDefault,
      expert = PolicyToken.unchangedAppDefault;

  final PolicyToken average;
  final PolicyToken advanced;
  final PolicyToken expert;

  /// The feature whose values these are, if any. Read through
  /// [FeaturePolicy.resolvedValue].
  final FeatureId? follows;

  PolicyToken _of(SetupPreset preset) => switch (preset) {
    SetupPreset.average => average,
    SetupPreset.advanced => advanced,
    SetupPreset.expert => expert,
  };
}

/// A setting users could hide UI with before visibility switches existed.
/// The switch that replaces it copies it on existing installs, and turns it
/// back on with itself.
enum LegacyVisibilitySetting { showContainerUi, showIsolatedTabUi }

/// How a feature is shown, and what the onboarding writes for it.
final class FeaturePolicy {
  /// Average tier: never hidden.
  const FeaturePolicy.locked({
    this.initial = const PresetValues(),
    this.uiRequires = const [],
  }) : availability = FeatureAvailability.locked,
       switches = const [];

  /// Shown while every one of [switches] is on.
  const FeaturePolicy.guarded(
    this.switches, {
    this.initial = const PresetValues(),
    this.uiRequires = const [],
  }) : availability = FeatureAvailability.guarded;

  /// Never hidden, as a deliberate exception: the entry says why.
  const FeaturePolicy.alwaysAvailable({
    this.initial = const PresetValues(),
    this.uiRequires = const [],
  }) : availability = FeatureAvailability.alwaysAvailable,
       switches = const [];

  /// No UI of its own.
  const FeaturePolicy.notUserFacing({
    this.initial = const PresetValues(),
    this.uiRequires = const [],
  }) : availability = FeatureAvailability.notUserFacing,
       switches = const [];

  /// A [VisibilitySwitch]'s own entry: [initial] is the switch's value per
  /// preset, `enabled` or `disabled`.
  const FeaturePolicy.visibilitySwitch(this.initial)
    : availability = FeatureAvailability.guarded,
      switches = const [],
      uiRequires = const [];

  final FeatureAvailability availability;

  /// Every switch here must be on for a [FeatureAvailability.guarded]
  /// feature to be shown.
  final List<VisibilitySwitch> switches;

  /// What the onboarding commit writes once, per preset.
  final PresetValues initial;

  /// Features that must be shown to configure this one. Turning a switch on
  /// also turns on theirs (`GeneralSettings.withVisibilitySwitch`).
  final List<FeatureId> uiRequires;

  /// Whether no switch can hide this feature.
  bool get isAlwaysShown => availability != FeatureAvailability.guarded;

  /// Whether this feature is shown while [isEnabled] says which switches are
  /// on.
  bool isShownWith(bool Function(VisibilitySwitch) isEnabled) =>
      isAlwaysShown || switches.every(isEnabled);

  /// This feature's initial value for [preset], with
  /// [PresetValues.follows] resolved. A `follows` cycle does not compile.
  PolicyToken resolvedValue(SetupPreset preset) {
    var values = initial;
    for (var target = values.follows; target != null; target = values.follows) {
      values = target.policy.initial;
    }
    return values._of(preset);
  }
}

/// Reads back `GeneralSettings.visibilitySwitches`, dropping what this version
/// does not know: a switch from a newer build, or a non-boolean value, falls
/// back to its existing-install value instead of failing to decode every
/// setting (acceptance scenario 17).
Map<VisibilitySwitch, bool> parseVisibilitySwitches(
  Map<String, dynamic>? json,
) {
  if (json == null) return const {};
  final switches = VisibilitySwitch.values.asNameMap();
  return {
    for (final MapEntry(:key, :value) in json.entries)
      if (switches[key] case final visibilitySwitch?)
        if (value is bool) visibilitySwitch: value,
  };
}
