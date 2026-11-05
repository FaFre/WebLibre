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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/domain/entities/remembered_prompt.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_addon.dart';
import 'package:weblibre/features/proxy/domain/providers/connection_activity.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/user/data/models/proxy_routing_settings.dart';
import 'package:weblibre/features/user/data/models/tor_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_routing_settings.dart';
import 'package:weblibre/features/user/domain/repositories/tor_settings.dart';

part 'kept_when.g.dart';

/// What keeps a hidden feature's control usable: something it configures is
/// already in place. Only for what keeps applying while hidden (H1: where
/// data goes, what the user created), so it can be checked and undone (P5).
///
/// An enum rather than a provider passed around as widget data: each value
/// is read through one statically known provider ([keptWhenHolds]).
enum KeptWhen {
  /// Tor is set up in any way ([torInUse]).
  torInUse,

  /// A connection is saved, routed or running ([connectionsInUse]).
  connectionsInUse,

  /// Regular or private tabs are routed through a connection.
  globalRouteInUse,

  /// A sync server of the user's own is set.
  syncServerOverrideSet,

  /// Tor connects through a bridge the user chose.
  torManualTransportInUse,

  /// Tor's entry or exit country is pinned.
  torCountriesInUse,

  /// Unsigned extensions are allowed.
  unsignedExtensionsAllowed,

  /// An answer to closing isolated tabs is remembered.
  closeIsolatedTabsRemembered,

  /// An answer to starting Tor is remembered.
  startTorRemembered,

  /// An answer to starting a proxy connection is remembered.
  startProxyConnectionRemembered,
}

/// Whether [kept] holds now.
@Riverpod()
bool keptWhenHolds(Ref ref, KeptWhen kept) {
  bool remembered(RememberedPrompt prompt) => ref.watch(
    storedGeneralSettingsProvider.select(
      (s) => s.rememberedPrompts.containsKey(prompt),
    ),
  );

  return switch (kept) {
    KeptWhen.torInUse => ref.watch(torInUseProvider),
    KeptWhen.connectionsInUse => ref.watch(connectionsInUseProvider),
    KeptWhen.globalRouteInUse => ref.watch(
      proxyRoutingSettingsWithDefaultsProvider.select(
        (s) =>
            s.regularTabsMode == ProxyRegularTabRoutingMode.all ||
            s.privateTabsProxyConnectionId != null,
      ),
    ),
    KeptWhen.syncServerOverrideSet => ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) =>
            s.syncServerOverride.isNotEmpty ||
            s.syncTokenServerOverride.isNotEmpty,
      ),
    ),
    KeptWhen.torManualTransportInUse => ref.watch(
      torSettingsWithDefaultsProvider.select(
        (s) =>
            s.config == TorConnectionConfig.obfs4 ||
            s.config == TorConnectionConfig.snowflake,
      ),
    ),
    KeptWhen.torCountriesInUse => ref.watch(
      torSettingsWithDefaultsProvider.select(
        (s) => s.entryNodeCountry != null || s.exitNodeCountry != null,
      ),
    ),
    KeptWhen.unsignedExtensionsAllowed => ref.watch(
      allowUnsignedExtensionsProvider.select((s) => s.value ?? false),
    ),
    KeptWhen.closeIsolatedTabsRemembered => remembered(
      RememberedPrompt.closeIsolatedTabs,
    ),
    KeptWhen.startTorRemembered => remembered(RememberedPrompt.startTor),
    KeptWhen.startProxyConnectionRemembered => remembered(
      RememberedPrompt.startProxyConnection,
    ),
  };
}

/// What hides a gated control: [feature] while its visibility switches are
/// off, unless [keptWhen] holds. A hidden setting that does not apply is
/// grayed out with its note instead (`HiddenFeatureGate.hiddenSettings`).
typedef HiddenFeatureCondition = ({FeatureId feature, KeptWhen? keptWhen});

/// [conditions] as a value, for keying [missingSwitches]: two lists with the
/// same conditions are equal.
final class HiddenFeatureConditions with FastEquatable {
  HiddenFeatureConditions(this.conditions);

  final List<HiddenFeatureCondition> conditions;

  @override
  List<Object?> get hashParameters => [conditions];
}

/// The visibility switches that hide something gated by [conditions], in
/// [VisibilitySwitch] order, empty while it is shown. Follows the displayed
/// settings, so in the onboarding the draft's; a condition's [KeptWhen] is
/// followed only while its feature is hidden.
@Riverpod()
EquatableValue<List<VisibilitySwitch>> missingSwitches(
  Ref ref,
  HiddenFeatureConditions conditions,
) {
  final settings = ref.watch(displayedGeneralSettingsProvider);

  final hidden = <VisibilitySwitch>{};
  for (final (:feature, :keptWhen) in conditions.conditions) {
    final switches = settings.hiddenSwitchesFor(feature);
    if (switches.isEmpty) continue;
    if (keptWhen != null && ref.watch(keptWhenHoldsProvider(keptWhen))) {
      continue;
    }
    hidden.addAll(switches);
  }
  return EquatableValue([
    for (final visibilitySwitch in VisibilitySwitch.values)
      if (hidden.contains(visibilitySwitch)) visibilitySwitch,
  ]);
}

/// Whether there are connections to come back to: a saved profile, a global
/// route, one running, or Tor set up in any way ([torInUse] — autostart that
/// failed and container or isolated-group routes included). The Proxy
/// category then stays in Settings even while connections are hidden, so the
/// existing ones keep their status, repair and stop controls (P5); the list
/// itself hides adding new ones.
@Riverpod()
bool connectionsInUse(Ref ref) {
  // All watched up front, not behind `||`, so none is dropped and reloaded
  // as another one changes.
  final hasProfiles = ref.watch(
    singboxProxyProfilesRepositoryProvider.select(
      (profiles) => profiles.value?.isNotEmpty ?? false,
    ),
  );
  final globalRoute = ref.watch(
    keptWhenHoldsProvider(KeptWhen.globalRouteInUse),
  );
  final active = ref.watch(anyConnectionActiveProvider);
  final tor = ref.watch(torInUseProvider);

  return hasProfiles || globalRoute || active || tor;
}
