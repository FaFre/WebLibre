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
import 'package:hooks_riverpod/misc.dart';
import 'package:weblibre/core/providers/window_size_class.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/bangs/domain/repositories/data.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_module_order.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/onboarding/domain/providers/setup_draft.dart';
import 'package:weblibre/features/settings/domain/hidden_settings.dart';
import 'package:weblibre/features/settings/domain/providers/hidden_settings.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

/// Points every settings widget below at the onboarding draft.
///
/// The Settings screens the onboarding reuses (Secure DNS, Toolbar & Layout,
/// the module and language screens) read the settings
/// through `storedGeneralSettingsProvider` and `storedEngineSettingsProvider`
/// (their `*WithDefaults` counterparts where something behaves), a few derived
/// `effective*` providers and the module layouts, and write through the two
/// save controllers. This
/// scope overrides exactly those, so the same widgets show the draft and save
/// into it, and nothing reaches the live settings before Done.
///
/// The derived providers have to be overridden too: they declare no
/// dependencies, so they would otherwise be read from the root and resolve
/// against the live settings.
class SetupDraftScope extends StatelessWidget {
  const SetupDraftScope({super.key, required this.step, required this.child});

  /// Where general-settings edits made below are filed in the draft.
  final SetupDraftStep step;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      ProviderScope(overrides: _draftOverrides(step), child: child);
}

/// The overrides of a [SetupDraftScope] filing general-settings edits under
/// [step]. Every override only derives from the draft, which lives in the
/// root container.
List<Override> _draftOverrides(SetupDraftStep step) => [
  // The settings widgets edit the stored values; anything that behaves reads
  // them as they would apply.
  // ignore: riverpod_lint/scoped_providers_should_specify_dependencies
  storedGeneralSettingsProvider.overrideWith(_draftStoredGeneralSettings),
  // ignore: riverpod_lint/scoped_providers_should_specify_dependencies
  storedEngineSettingsProvider.overrideWith(_draftStoredEngineSettings),
  // ignore: riverpod_lint/scoped_providers_should_specify_dependencies
  generalSettingsWithDefaultsProvider.overrideWith(
    _draftEffectiveGeneralSettings,
  ),
  // ignore: riverpod_lint/scoped_providers_should_specify_dependencies
  engineSettingsWithDefaultsProvider.overrideWith(
    _draftEffectiveEngineSettings,
  ),
  // ignore: riverpod_lint/scoped_providers_should_specify_dependencies
  saveGeneralSettingsControllerProvider.overrideWith(
    () => _DraftSaveGeneralSettingsController(step),
  ),
  // ignore: riverpod_lint/scoped_providers_should_specify_dependencies
  saveEngineSettingsControllerProvider.overrideWith(
    _DraftSaveEngineSettingsController.new,
  ),
  // ignore: riverpod_lint/scoped_providers_should_specify_dependencies
  effectiveTabBarPositionProvider.overrideWith(_draftTabBarPosition),
  // ignore: riverpod_lint/scoped_providers_should_specify_dependencies
  effectiveTabBarStackingModeProvider.overrideWith(_draftTabBarStackingMode),
  // ignore: riverpod_lint/scoped_providers_should_specify_dependencies
  effectiveSearchFieldPlacementProvider.overrideWith(
    _draftSearchFieldPlacement,
  ),
  // ignore: riverpod_lint/scoped_providers_should_specify_dependencies
  effectiveHomeSearchBarPlacementProvider.overrideWith(
    _draftHomeSearchBarPlacement,
  ),
  // ignore: riverpod_lint/scoped_providers_should_specify_dependencies
  defaultSearchBangDataProvider.overrideWith(_draftDefaultSearchBangData),
  // ignore: riverpod_lint/scoped_providers_should_specify_dependencies
  shownFeaturesProvider.overrideWith(_DraftShownFeatures.new),
  // A fresh install has nothing changed for a hidden feature to stop
  // applying; the live settings must not mark the draft's rows.
  // ignore: riverpod_lint/scoped_providers_should_specify_dependencies
  suspendedSettingsProvider.overrideWith(_NoSuspendedSettings.new),
  // ignore: riverpod_lint/scoped_providers_should_specify_dependencies
  searchModuleOrderProvider.overrideWith2((_) => _DraftSearchModuleOrder()),
];

GeneralSettings _draftStoredGeneralSettings(Ref ref) =>
    ref.watch(draftGeneralSettingsProvider);

EngineSettings _draftStoredEngineSettings(Ref ref) =>
    ref.watch(draftEngineSettingsProvider);

GeneralSettings _draftEffectiveGeneralSettings(Ref ref) {
  final general = ref.watch(draftGeneralSettingsProvider);
  return general.effective();
}

EngineSettings _draftEffectiveEngineSettings(Ref ref) {
  final engine = ref.watch(draftEngineSettingsProvider);
  final general = ref.watch(draftGeneralSettingsProvider);
  return engine.effective(general.isFeatureShown);
}

TabBarPosition _draftTabBarPosition(Ref ref) {
  final general = ref.watch(draftGeneralSettingsProvider);
  final window = ref.watch(windowSizeClassControllerProvider);
  return general.effectiveTabBarPosition(window: window);
}

TabBarStackingMode _draftTabBarStackingMode(Ref ref) {
  final general = ref.watch(draftGeneralSettingsProvider);
  final window = ref.watch(windowSizeClassControllerProvider);
  final sideRailWidthOverride = ref.watch(sideRailDragWidthProvider);
  return general.effectiveTabBarStackingMode(
    window: window,
    sideRailWidthOverride: sideRailWidthOverride,
  );
}

SearchFieldPlacement _draftSearchFieldPlacement(Ref ref) {
  final general = ref.watch(draftGeneralSettingsProvider);
  final window = ref.watch(windowSizeClassControllerProvider);
  return general.effectiveSearchFieldPlacement(window: window);
}

HomeSearchBarPlacement _draftHomeSearchBarPlacement(Ref ref) {
  final general = ref.watch(draftGeneralSettingsProvider);
  final window = ref.watch(windowSizeClassControllerProvider);
  return general.effectiveHomeSearchBarPlacement(window: window);
}

Stream<BangData?> _draftDefaultSearchBangData(Ref ref) {
  final repository = ref.watch(bangDataRepositoryProvider.notifier);
  final defaultSearchProvider = ref.watch(
    draftGeneralSettingsProvider.select((s) => s.defaultSearchProvider),
  );
  return repository.watchBang(defaultSearchProvider);
}

class _NoSuspendedSettings extends SuspendedSettings {
  @override
  Set<HiddenSetting> build() => const {};
}

class _DraftShownFeatures extends ShownFeatures {
  @override
  Set<FeatureId> build() =>
      ref.watch(draftGeneralSettingsProvider).shownFeatures;
}

/// Pushes [page] so that it still edits the draft of the [SetupDraftScope]
/// around [context]. A plain push builds the page in the navigator's overlay,
/// above the scope, where it would read and write the live settings.
///
/// The page gets a scope of its own, with the same step, rather than the
/// container of the one around [context]. A container shared by several
/// routes refreshes its providers while building whichever of their scopes
/// comes first, and notifying a widget on another route from there is a
/// `markNeedsBuild` during build (switching the tab bar position under
/// Toolbar & layout did it). Every override only derives from the draft,
/// which lives in the root container, so each scope reads the same draft.
Future<T?> pushInSetupDraftScope<T>(BuildContext context, Widget page) {
  final scope = context.findAncestorWidgetOfExactType<SetupDraftScope>();
  assert(scope != null, 'pushInSetupDraftScope needs a SetupDraftScope');
  return Navigator.of(context).push<T>(
    MaterialPageRoute(
      builder: (_) => SetupDraftScope(step: scope!.step, child: page),
    ),
  );
}

class _DraftSaveGeneralSettingsController extends SaveGeneralSettingsController
    implements SavesToDraft {
  _DraftSaveGeneralSettingsController(this.step);

  final SetupDraftStep step;

  @override
  Future<bool> save(UpdateGeneralSettingsFunc updateSettings) async {
    ref
        .read(setupDraftControllerProvider.notifier)
        .editGeneral(step, updateSettings);
    return true;
  }
}

class _DraftSaveEngineSettingsController extends SaveEngineSettingsController
    implements SavesToDraft {
  @override
  Future<void> save(UpdateEngineSettingsFunc updateSettings) async {
    ref.read(setupDraftControllerProvider.notifier).editEngine(updateSettings);
  }
}

/// A module layout held in the draft. Starts from what the commit would write
/// (the preset's layout, or the code default) and files every change back
/// into the draft instead of persisting it.
class _DraftSearchModuleOrder extends SearchModuleOrder {
  @override
  List<ModuleOrderEntry> build(ModuleSurface surface) {
    listenSelf((previous, next) {
      if (previous == null) return;
      ref.read(setupDraftControllerProvider.notifier).setLayout(surface, next);
    });

    return ref.read(setupDraftControllerProvider).layoutFor(surface) ??
        mergeModuleOrderWithDefaults(null, surface.defaultModules);
  }
}
