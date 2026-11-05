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
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:weblibre/core/design/window_size_class.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/domain/setup_draft/setup_draft.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/entities/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/providers/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/keyboard_shortcuts/data/models/keyboard_shortcut_settings.dart';
import 'package:weblibre/features/onboarding/domain/entities/setup_goal.dart';
import 'package:weblibre/features/onboarding/domain/services/preset_bindings.dart';
import 'package:weblibre/features/onboarding/domain/services/setup_commit.dart';
import 'package:weblibre/features/onboarding/domain/services/setup_steps.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/onboarding.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('preset bindings', () {
    test('every value other than unchangedAppDefault has a binding', () {
      for (final feature in FeatureId.values) {
        for (final preset in SetupPreset.values) {
          final token = feature.policy.resolvedValue(preset);
          if (token == PolicyToken.unchangedAppDefault) continue;
          expect(
            presetBindings[feature],
            isNotNull,
            reason: '${feature.id} (${preset.name}: ${token.name})',
          );
        }
      }
    });

    test('every binding accepts the tokens the policy gives it', () {
      for (final MapEntry(key: feature, value: binding)
          in presetBindings.entries) {
        for (final preset in SetupPreset.values) {
          final token = feature.policy.resolvedValue(preset);
          if (token == PolicyToken.unchangedAppDefault) continue;
          final reason = '${feature.id} (${preset.name}: ${token.name})';
          switch (binding) {
            case GeneralPresetBinding(:final apply):
              expect(
                () => apply(GeneralSettings.withDefaults(), token),
                returnsNormally,
                reason: reason,
              );
            case EnginePresetBinding(:final apply):
              expect(
                () => apply(EngineSettings.withDefaults(), token),
                returnsNormally,
                reason: reason,
              );
            case CodeDefaultPresetBinding(:final matchesCodeDefault):
              expect(matchesCodeDefault(token), isTrue, reason: reason);
            case NoSettingPresetBinding() || DraftPresetBinding():
              break;
          }
        }
      }
    });

    test('code defaults the bindings rely on in other features', () {
      expect(
        presetValueIs(
          FeatureId.inputKeyboardShortcuts,
          SetupPreset.average,
          PolicyToken.enabled,
        ),
        isTrue,
      );
      expect(KeyboardShortcutSettings.withDefaults().enabled, isTrue);
      expect(GestureSettings.withDefaults().enabled, isFalse);
    });

    for (final preset in SetupPreset.values) {
      test('${preset.name}: the switches match the policy', () {
        final settings = applyGeneralPreset(
          GeneralSettings.withDefaults(),
          preset,
        );
        for (final visibilitySwitch in VisibilitySwitch.values) {
          final expected =
              visibilitySwitch.policy.resolvedValue(preset) ==
              PolicyToken.enabled;
          expect(
            settings.visibilitySwitches[visibilitySwitch],
            expected,
            reason: visibilitySwitch.name,
          );
        }
      });

      test('${preset.name}: applying the preset twice changes nothing', () {
        final once = applyGeneralPreset(GeneralSettings.withDefaults(), preset);
        final twice = applyGeneralPreset(once, preset);
        expect(twice.toJson().toString(), once.toJson().toString());
      });

      test('${preset.name}: JavaScript stays enabled', () {
        expect(
          applyEnginePreset(
            EngineSettings.withDefaults(),
            preset,
          ).javascriptEnabled,
          isTrue,
        );
      });
    }

    test('Average writes its own initial values', () {
      final general = applyGeneralPreset(
        GeneralSettings.withDefaults(),
        SetupPreset.average,
      );
      expect(general.tabBarStackingMode, TabBarStackingMode.lastUsedTabs);
      expect(general.urlCleanerAutoApply, isTrue);
      expect(general.enableLocalAiFeatures, isFalse);
      expect(general.bookmarkOpenSetting, BookmarkOpenSetting.regular);
      expect(general.tabIntentOpenSetting, TabIntentOpenSetting.regular);

      final engine = applyEnginePreset(
        EngineSettings.withDefaults(),
        SetupPreset.average,
      );
      expect(engine.lnaEnabled, isTrue);
      expect(engine.lnaBlocking, isTrue);
    });

    test('Advanced and Expert keep the stacking default and review before '
        'cleaning, with on-device AI off until asked for', () {
      final defaults = GeneralSettings.withDefaults();
      for (final preset in [SetupPreset.advanced, SetupPreset.expert]) {
        final general = applyGeneralPreset(defaults, preset);
        expect(general.tabBarStackingMode, defaults.tabBarStackingMode);
        expect(general.urlCleanerAutoApply, isFalse);
        // Its controls show; turning it on is a choice of its own.
        expect(general.enableLocalAiFeatures, isFalse);
        expect(general.isVisibilitySwitchShown(VisibilitySwitch.ai), isTrue);
      }
    });

    // What a hidden feature falls back to is the code default, so it has to
    // be what someone who never saw the feature gets: Just browsing.
    test('Just browsing matches the fallbacks of AI, URL cleaning and '
        'local network blocking', () {
      final defaults = GeneralSettings.withDefaults();
      final general = applyGeneralPreset(defaults, SetupPreset.average);
      expect(general.enableLocalAiFeatures, defaults.enableLocalAiFeatures);
      expect(general.urlCleanerAutoApply, defaults.urlCleanerAutoApply);

      final engineDefaults = EngineSettings.withDefaults();
      final engine = applyEnginePreset(engineDefaults, SetupPreset.average);
      expect(engine.lnaBlocking, engineDefaults.lnaBlocking);
      expect(engineDefaults.lnaBlocking, isTrue);
    });

    test('a preset never touches the legacy container and isolated flags', () {
      final legacyOff = GeneralSettings.withDefaults(
        showContainerUi: false,
        showIsolatedTabUi: false,
      );
      final settings = applyGeneralPreset(legacyOff, SetupPreset.expert);
      expect(settings.showContainerUi, isFalse);
      expect(settings.showIsolatedTabUi, isFalse);
    });
  });

  group('setup draft', () {
    late ProviderContainer container;

    setUp(() {
      // A profile that never completed an onboarding: the draft is open.
      container = ProviderContainer(
        overrides: [
          completedOnboardingRevisionProvider.overrideWithValue(
            const AsyncData(null),
          ),
        ],
      );
    });
    tearDown(() => container.dispose());

    SetupDraftController draft() =>
        container.read(setupDraftControllerProvider.notifier);
    SetupDraft state() => container.read(setupDraftControllerProvider)!;

    test('starts at Average with nothing changed', () {
      expect(state().preset, SetupPreset.average);
      expect(state().installsUBlock, isTrue);
      expect(state().appliesOptimizedUBlockFilters, isTrue);
      expect(state().appliesHardeningBaseline, isTrue);
    });

    test('a preset change keeps settings and drops visibility edits', () {
      draft()
        ..editGeneral(
          (s) => s.copyWith(tabBarPosition: TabBarPositionSetting.top),
        )
        ..editGeneral((s) => s.copyWith(pureBlack: true))
        ..editEngine((s) => s.copyWith.fontSizeFactor(2))
        ..setLayout(ModuleSurface.home, const [])
        ..setMenuLayout([...defaultMenuLayout.reversed])
        ..setToolbarButtons(
          ToolbarConfigLocation.contextual,
          defaultToolbarButtonConfigsFor(
            ToolbarConfigLocation.contextual,
          ).value.reversed.toList(),
        )
        ..setHardeningBaseline(false)
        ..setInstallUBlock(true)
        ..setOptimizedUBlockFilters(false)
        ..setVisibilitySwitch(VisibilitySwitch.treeTabs, enabled: true);
      final previous = state();
      expect(previous.hasVisibilityChanges, isTrue);

      draft().selectPreset(SetupPreset.expert);
      final changed = state();
      final applied = changed.applyGeneral(GeneralSettings.withDefaults());
      expect(applied.tabBarPosition, TabBarPositionSetting.top);
      expect(applied.pureBlack, isTrue);
      expect(
        changed.applyEngine(EngineSettings.withDefaults()).fontSizeFactor,
        2,
      );
      expect(changed.layouts, previous.layouts);
      expect(changed.menuLayout, previous.menuLayout);
      expect(changed.toolbarButtons, previous.toolbarButtons);
      expect(changed.appliesHardeningBaseline, isFalse);
      expect(changed.installsUBlock, isTrue);
      expect(changed.appliesOptimizedUBlockFilters, isFalse);
      // Only the visibility edit is gone.
      expect(changed.edits, hasLength(2));
      expect(changed.hasVisibilityChanges, isFalse);

      // Back at Average, tree tabs follow the preset again: hidden.
      draft().selectPreset(SetupPreset.average);
      expect(
        state()
            .applyGeneral(GeneralSettings.withDefaults())
            .isVisibilitySwitchShown(VisibilitySwitch.treeTabs),
        isFalse,
      );
    });

    group('the latest choice wins', () {
      TabBarPositionSetting position() =>
          state().applyGeneral(GeneralSettings.withDefaults()).tabBarPosition;

      // The Layout step's answer and the Toolbar & layout editor's write
      // the same setting; both are settings edits now.
      void layoutStep(TabBarPositionSetting value) =>
          draft().editGeneral((s) => s.copyWith(tabBarPosition: value));
      void editor(TabBarPositionSetting value) =>
          draft().editGeneral((s) => s.copyWith.tabBarPosition(value));

      for (final presetChange in [false, true]) {
        final suffix = presetChange ? ', then a preset change' : '';

        test('Layout, then the editor, then Layout$suffix', () {
          layoutStep(TabBarPositionSetting.bottom);
          editor(TabBarPositionSetting.left);
          layoutStep(TabBarPositionSetting.top);
          if (presetChange) draft().selectPreset(SetupPreset.expert);
          expect(position(), TabBarPositionSetting.top);
        });

        test('the editor, then Layout, then the editor$suffix', () {
          editor(TabBarPositionSetting.right);
          layoutStep(TabBarPositionSetting.bottom);
          editor(TabBarPositionSetting.left);
          if (presetChange) draft().selectPreset(SetupPreset.advanced);
          expect(position(), TabBarPositionSetting.left);
        });
      }

      test('a hide after a goal wins, and a later goal shows again', () {
        GeneralSettings applied() =>
            state().applyGeneral(GeneralSettings.withDefaults());
        draft()
          ..setGoal(SetupGoal.keepAccountsApart, selected: true)
          ..setVisibilitySwitch(VisibilitySwitch.containers, enabled: false);
        expect(
          applied().isVisibilitySwitchShown(VisibilitySwitch.containers),
          isFalse,
        );
        draft().setGoal(SetupGoal.keepAccountsApart, selected: true);
        expect(
          applied().isVisibilitySwitchShown(VisibilitySwitch.containers),
          isTrue,
        );
      });
    });

    test('goals turn on exactly their switches', () {
      draft().setGoal(SetupGoal.keepAccountsApart, selected: true);
      final applied = state().applyGeneral(GeneralSettings.withDefaults());
      final average = applyGeneralPreset(
        GeneralSettings.withDefaults(),
        SetupPreset.average,
      );

      for (final visibilitySwitch in VisibilitySwitch.values) {
        expect(
          applied.isVisibilitySwitchEnabled(visibilitySwitch),
          visibilitySwitch == VisibilitySwitch.containers ||
              average.isVisibilitySwitchEnabled(visibilitySwitch),
          reason: visibilitySwitch.name,
        );
      }
    });

    test('a goal that shows features mirrors its switches', () {
      GeneralSettings applied() =>
          state().applyGeneral(GeneralSettings.withDefaults());
      bool selected(SetupGoal goal) => state().goalSelected(goal, applied());

      // Average hides containers; Tinkerer shows them without any goal.
      expect(selected(SetupGoal.keepAccountsApart), isFalse);
      draft().setGoal(SetupGoal.keepAccountsApart, selected: true);
      expect(selected(SetupGoal.keepAccountsApart), isTrue);

      // Hiding containers turns the goal off with them.
      draft().setVisibilitySwitch(VisibilitySwitch.containers, enabled: false);
      expect(selected(SetupGoal.keepAccountsApart), isFalse);

      draft().selectPreset(SetupPreset.advanced);
      expect(selected(SetupGoal.keepAccountsApart), isTrue);
    });

    group('the connection setup', () {
      GeneralSettings applied() =>
          state().applyGeneral(GeneralSettings.withDefaults());
      bool selected() =>
          state().goalSelected(SetupGoal.setUpConnections, applied());
      bool connectionsShown() =>
          applied().isVisibilitySwitchShown(VisibilitySwitch.connections);

      test('opens only when asked for, not because Connections show', () {
        // Tinkerer shows Connections; nobody asked for the setup.
        draft().selectPreset(SetupPreset.advanced);
        expect(connectionsShown(), isTrue);
        expect(selected(), isFalse);
        expect(state().setupsToOpen(applied()), isEmpty);

        draft().setGoal(SetupGoal.setUpConnections, selected: true);
        expect(selected(), isTrue);
        expect(state().setupsToOpen(applied()), [SetupGoal.setUpConnections]);
      });

      test('shows what it needs, whatever the preset', () {
        // Average hides Connections; asking for the setup shows them.
        expect(connectionsShown(), isFalse);
        draft().setGoal(SetupGoal.setUpConnections, selected: true);
        expect(connectionsShown(), isTrue);

        for (final preset in [
          SetupPreset.advanced,
          SetupPreset.average,
          SetupPreset.expert,
          SetupPreset.average,
        ]) {
          draft().selectPreset(preset);
          expect(selected(), isTrue, reason: preset.name);
          expect(connectionsShown(), isTrue, reason: preset.name);
          expect(state().setupsToOpen(applied()), [
            SetupGoal.setUpConnections,
          ], reason: preset.name);
        }
      });

      test('withdrawn, it cancels the setup and hides only what it showed', () {
        draft()
          ..setGoal(SetupGoal.setUpConnections, selected: true)
          ..setGoal(SetupGoal.setUpConnections, selected: false);
        expect(state().setupsToOpen(applied()), isEmpty);
        // Average: shown only for the setup, hidden again.
        expect(connectionsShown(), isFalse);

        // Tinkerer shows them on its own: they stay.
        draft()
          ..selectPreset(SetupPreset.advanced)
          ..setGoal(SetupGoal.setUpConnections, selected: true)
          ..setGoal(SetupGoal.setUpConnections, selected: false);
        expect(connectionsShown(), isTrue);
        expect(state().setupsToOpen(applied()), isEmpty);
      });

      test('hiding what it needs turns it off', () {
        draft()
          ..setGoal(SetupGoal.setUpConnections, selected: true)
          ..setVisibilitySwitch(VisibilitySwitch.connections, enabled: false);
        expect(selected(), isFalse);
        expect(state().setupsToOpen(applied()), isEmpty);

        // Turned off, a preset change does not bring it back.
        draft().selectPreset(SetupPreset.expert);
        expect(connectionsShown(), isTrue);
        expect(selected(), isFalse);
        expect(state().setupsToOpen(applied()), isEmpty);

        // Asking again is the later choice: it shows them again.
        draft()
          ..setGoal(SetupGoal.setUpConnections, selected: false)
          ..setGoal(SetupGoal.setUpConnections, selected: true);
        expect(connectionsShown(), isTrue);
        expect(selected(), isTrue);
      });
    });

    group('on-device AI', () {
      GeneralSettings applied() =>
          state().applyGeneral(GeneralSettings.withDefaults());
      bool selected() =>
          state().goalSelected(SetupGoal.useOnDeviceAi, applied());

      test('is off in every preset, its controls shown where they were', () {
        for (final preset in SetupPreset.values) {
          draft().selectPreset(preset);
          // Applied over settings that had it on: the preset turns it off.
          final settings = state().applyGeneral(
            GeneralSettings.withDefaults(enableLocalAiFeatures: true),
          );
          expect(settings.enableLocalAiFeatures, isFalse, reason: preset.name);
          expect(selected(), isFalse, reason: preset.name);
          expect(
            settings.isVisibilitySwitchShown(VisibilitySwitch.ai),
            preset != SetupPreset.average,
            reason: preset.name,
          );
        }
      });

      test('is turned on by its goal, in step with its own switch', () {
        draft().setGoal(SetupGoal.useOnDeviceAi, selected: true);
        expect(applied().enableLocalAiFeatures, isTrue);
        expect(applied().isFeatureShown(FeatureId.aiLocalAi), isTrue);
        expect(selected(), isTrue);

        // Turning it off keeps its controls shown.
        draft().setGoal(SetupGoal.useOnDeviceAi, selected: false);
        expect(applied().enableLocalAiFeatures, isFalse);
        expect(applied().isVisibilitySwitchShown(VisibilitySwitch.ai), isTrue);
        expect(selected(), isFalse);

        // The settings switch (Settings > AI) is the same setting.
        draft().editGeneral((s) => s.copyWith(enableLocalAiFeatures: true));
        expect(selected(), isTrue);
      });
    });

    test('a preset change after visibility edits can be undone', () {
      draft().selectPreset(SetupPreset.advanced);
      expect(state().hasVisibilityChanges, isFalse);

      draft()
        ..editGeneral((s) => s.copyWith(pureBlack: true))
        ..setGoal(SetupGoal.lockBrowser, selected: true);
      // Settings edits and requested setups survive a preset change.
      expect(state().hasVisibilityChanges, isFalse);

      draft().setGoal(SetupGoal.keepAccountsApart, selected: true);
      final previous = state();
      expect(previous.hasVisibilityChanges, isTrue);

      draft().selectPreset(SetupPreset.expert);
      final changed = state();
      expect(changed.edits, hasLength(1));
      expect(changed.hasVisibilityChanges, isFalse);
      expect(changed.goals, {SetupGoal.lockBrowser});

      draft().undo(changed: changed, previous: previous);
      expect(state(), same(previous));

      // An Undo that comes after another change is ignored.
      draft().selectPreset(SetupPreset.average);
      final later = state();
      draft().undo(changed: changed, previous: previous);
      expect(state(), same(later));
    });

    test('arrangements are not visibility changes', () {
      draft()
        ..setMenuLayout([...defaultMenuLayout.reversed])
        ..setLayout(ModuleSurface.newTab, const [])
        ..setToolbarButtons(
          ToolbarConfigLocation.contextual,
          defaultToolbarButtonConfigsFor(
            ToolbarConfigLocation.contextual,
          ).value.reversed.toList(),
        )
        ..setHardeningBaseline(false)
        ..setInstallUBlock(false)
        ..setOptimizedUBlockFilters(false)
        ..editEngine((s) => s.copyWith.fontSizeFactor(2));
      expect(state().hasVisibilityChanges, isFalse);
    });

    test('Lock and Sync goals change no setting', () {
      draft()
        ..setGoal(SetupGoal.lockBrowser, selected: true)
        ..setGoal(SetupGoal.syncDevices, selected: true);
      final withGoals = state().applyGeneral(GeneralSettings.withDefaults());
      draft()
        ..setGoal(SetupGoal.lockBrowser, selected: false)
        ..setGoal(SetupGoal.syncDevices, selected: false);
      final without = state().applyGeneral(GeneralSettings.withDefaults());
      expect(withGoals.toJson().toString(), without.toJson().toString());
    });

    test('the filter lists are only applied with the install', () {
      draft().setInstallUBlock(false);
      expect(state().appliesOptimizedUBlockFilters, isFalse);
    });

    test('Average writes the calm new-tab layout, the others none', () {
      final layout = state().layoutFor(ModuleSurface.newTab)!;
      final definition = presetNewTabLayout(SetupPreset.average)!;
      expect([
        for (final e in layout) (type: e.type, visible: e.visible),
      ], definition);
      expect(state().layoutFor(ModuleSurface.home), isNull);

      draft().selectPreset(SetupPreset.advanced);
      expect(state().layoutFor(ModuleSurface.newTab), isNull);
    });

    test('applying the draft is idempotent', () {
      draft()
        ..selectPreset(SetupPreset.advanced)
        ..setGoal(SetupGoal.setUpConnections, selected: true)
        ..setGoal(SetupGoal.useOnDeviceAi, selected: true);
      final once = state().applyGeneral(GeneralSettings.withDefaults());
      final twice = state().applyGeneral(once);
      expect(twice.toJson().toString(), once.toJson().toString());
    });
  });

  group('visibility', () {
    test('existing installs see everything they saw before', () {
      final settings = GeneralSettings.withDefaults();
      for (final visibilitySwitch in VisibilitySwitch.values) {
        expect(
          settings.isVisibilitySwitchShown(visibilitySwitch),
          isTrue,
          reason: visibilitySwitch.name,
        );
      }
    });

    test('existing installs that hid container UI keep it hidden', () {
      final settings = GeneralSettings.withDefaults(showContainerUi: false);
      expect(settings.containerEntryPointsShown, isFalse);
      expect(settings.isFeatureShown(FeatureId.containerCore), isFalse);
      expect(settings.isolatedTabEntryPointsShown, isTrue);
    });

    test('locked and always-available features are never hidden', () {
      final allOff = GeneralSettings.withDefaults(
        visibilitySwitches: {
          for (final visibilitySwitch in VisibilitySwitch.values)
            visibilitySwitch: false,
        },
      );
      for (final feature in FeatureId.values) {
        // Switch entries are guarded but need no switch: they are the
        // switches, always listed in Show or hide features.
        expect(
          allOff.isFeatureShown(feature),
          feature.policy.switches.isEmpty,
          reason: feature.id,
        );
      }
    });

    test('a feature needs every one of its switches', () {
      final settings = GeneralSettings.withDefaults(
        visibilitySwitches: {
          VisibilitySwitch.containers: true,
          VisibilitySwitch.connections: false,
        },
      );
      expect(settings.isFeatureShown(FeatureId.containerCore), isTrue);
      expect(settings.isFeatureShown(FeatureId.containerProxyRouting), isFalse);
    });

    test(
      'turning a switch on restores the legacy flag; off touches nothing',
      () {
        final legacyOff = GeneralSettings.withDefaults(
          showContainerUi: false,
          tabBarStackingMode: TabBarStackingMode.accordion,
        );
        final on = legacyOff.withVisibilitySwitch(
          VisibilitySwitch.containers,
          enabled: true,
        );
        expect(on.showContainerUi, isTrue);
        expect(on.containerEntryPointsShown, isTrue);

        final off = on.withVisibilitySwitch(
          VisibilitySwitch.containers,
          enabled: false,
        );
        expect(off.showContainerUi, isTrue);
        expect(off.containerEntryPointsShown, isFalse);
        // P1: hiding never rewrites the stacking mode.
        expect(off.tabBarStackingMode, TabBarStackingMode.accordion);
      },
    );

    test('hiding isolated tabs keeps an isolated default stored, but it '
        'does not apply', () {
      final settings = GeneralSettings.withDefaults(
        tabIntentOpenSetting: TabIntentOpenSetting.isolated,
      ).withVisibilitySwitch(VisibilitySwitch.isolatedTabs, enabled: false);
      expect(settings.tabIntentOpenSetting, TabIntentOpenSetting.isolated);
      expect(settings.effectiveTabIntentOpenSetting, TabIntentOpenSetting.ask);
      expect(
        settings.effective().tabIntentOpenSetting,
        TabIntentOpenSetting.ask,
      );
    });

    test('unknown or malformed switches are dropped on read', () {
      expect(
        parseVisibilitySwitches({
          'containers': false,
          'fromTheFuture': true,
          'gestures': 'yes',
        }),
        {VisibilitySwitch.containers: false},
      );
    });

    test('settings round-trip the switches through JSON', () {
      final settings = GeneralSettings.withDefaults(
        visibilitySwitches: {VisibilitySwitch.treeTabs: false},
      );
      final restored = GeneralSettings.fromJson(settings.toJson());
      expect(restored.visibilitySwitches, {VisibilitySwitch.treeTabs: false});
    });
  });

  group('commit journal', () {
    String plain(Object settings) =>
        jsonEncode(jsonDecode(jsonEncode(settings)));

    SetupCommitJournal persisted(SetupCommitJournal journal) =>
        SetupCommitJournal.fromJson(
          jsonDecode(jsonEncode(journal.toJson())) as Map<String, dynamic>,
        );

    for (final preset in SetupPreset.values) {
      test('${preset.name}: a resumed journal writes what the draft would', () {
        final draft = SetupDraft(
          preset: preset,
          goals: const {SetupGoal.keepAccountsApart},
        );
        final general = GeneralSettings.withDefaults();
        final engine = EngineSettings.withDefaults();
        final journal = persisted(
          SetupCommitJournal.resolve(
            draft,
            general: general,
            engine: engine,
            targetRevision: 3,
          ),
        );

        expect(
          plain(journal.applyGeneral(general).toJson()),
          plain(draft.applyGeneral(general).toJson()),
        );
        expect(
          plain(journal.applyEngine(engine).toJson()),
          plain(draft.applyEngine(engine).toJson()),
        );
        expect(journal.steps, {
          SetupStep.installUBlock,
          SetupStep.optimizedUBlockFilters,
        });
        expect(journal.targetRevision, 3);
      });
    }

    test('only the keys the commit changes are journaled', () {
      final general = GeneralSettings.withDefaults();
      final journal = SetupCommitJournal.resolve(
        const SetupDraft(preset: SetupPreset.average),
        general: general,
        engine: EngineSettings.withDefaults(),
        targetRevision: 3,
      );
      expect(journal.general.keys, contains('visibilitySwitches'));
      expect(journal.general.keys, isNot(contains('themeMode')));
    });

    test('resuming keeps what something else wrote in between', () {
      final general = GeneralSettings.withDefaults();
      final journal = persisted(
        SetupCommitJournal.resolve(
          const SetupDraft(preset: SetupPreset.average),
          general: general,
          engine: EngineSettings.withDefaults(),
          targetRevision: 3,
        ),
      );
      final changedMeanwhile = general.copyWith(urlCleanerLastCheckEpochMs: 42);
      final resumed = journal.applyGeneral(changedMeanwhile);
      expect(resumed.urlCleanerLastCheckEpochMs, 42);
      expect(resumed.tabBarStackingMode, TabBarStackingMode.lastUsedTabs);
    });

    test('applying a journal twice changes nothing', () {
      final general = GeneralSettings.withDefaults();
      final journal = SetupCommitJournal.resolve(
        const SetupDraft(preset: SetupPreset.expert),
        general: general,
        engine: EngineSettings.withDefaults(),
        targetRevision: 3,
      );
      final once = journal.applyGeneral(general);
      expect(plain(journal.applyGeneral(once).toJson()), plain(once.toJson()));
    });

    test('changed toolbar buttons round-trip through the journal', () {
      final defaults = defaultToolbarButtonConfigsFor(
        ToolbarConfigLocation.quickSwitcher,
      ).value;
      final buttons = [
        defaults.first.copyWith(
          isVisible: true,
          longPressAction: Value(BrowserAction.values.last),
        ),
        ...defaults.skip(1),
      ];
      final journal = persisted(
        SetupCommitJournal.resolve(
          SetupDraft(
            preset: SetupPreset.average,
            toolbarButtons: {ToolbarConfigLocation.quickSwitcher: buttons},
          ),
          general: GeneralSettings.withDefaults(),
          engine: EngineSettings.withDefaults(),
          targetRevision: 3,
        ),
      );

      // Only the toolbar the draft changed is written.
      expect(journal.toolbarButtons.keys, ['quickSwitcher']);
      expect(journal.toolbarButtons['quickSwitcher'], buttons);
    });

    test('an arranged menu round-trips through the journal', () {
      final arranged = [
        defaultMenuLayout.first.copyWith(
          visible: !defaultMenuLayout.first.visible,
        ),
        ...defaultMenuLayout.skip(1),
      ];
      SetupCommitJournal resolve(SetupDraft draft) => persisted(
        SetupCommitJournal.resolve(
          draft,
          general: GeneralSettings.withDefaults(),
          engine: EngineSettings.withDefaults(),
          targetRevision: 3,
        ),
      );

      expect(
        resolve(const SetupDraft(preset: SetupPreset.average)).menuLayout,
        isNull,
      );
      expect(
        resolve(
          SetupDraft(preset: SetupPreset.average, menuLayout: arranged),
        ).menuLayout,
        arranged,
      );
    });

    test('a journal written before toolbar buttons were journaled reads', () {
      final json =
          jsonDecode(
                  jsonEncode(
                    SetupCommitJournal.resolve(
                      const SetupDraft(preset: SetupPreset.average),
                      general: GeneralSettings.withDefaults(),
                      engine: EngineSettings.withDefaults(),
                      targetRevision: 3,
                    ).toJson(),
                  ),
                )
                as Map<String, dynamic>
            ..remove('toolbarButtons')
            ..remove('menuLayout');
      final journal = SetupCommitJournal.fromJson(json);
      expect(journal.toolbarButtons, isEmpty);
      expect(journal.menuLayout, isNull);
    });

    test('an opted-out uBlock Origin is not scheduled', () {
      final journal = SetupCommitJournal.resolve(
        const SetupDraft(preset: SetupPreset.average, installUBlock: false),
        general: GeneralSettings.withDefaults(),
        engine: EngineSettings.withDefaults(),
        targetRevision: 3,
      );
      expect(journal.steps, isEmpty);
    });
  });

  group('review fixes', () {
    const window = WindowSizeClass.compact;

    test('Tab Groups do not need containers to be shown', () {
      final settings = GeneralSettings.withDefaults(
        tabBarStackingMode: TabBarStackingMode.tabGroups,
        visibilitySwitches: {VisibilitySwitch.containers: false},
      );
      expect(
        settings.isFeatureShown(FeatureId.layoutStackingTabGroups),
        isTrue,
      );
      expect(
        settings.effectiveTabBarStackingMode(window: window),
        TabBarStackingMode.tabGroups,
      );
    });

    test('hidden layout options draw Tab Groups as the simple row', () {
      final settings = GeneralSettings.withDefaults(
        tabBarStackingMode: TabBarStackingMode.tabGroups,
        visibilitySwitches: {VisibilitySwitch.layoutAdvanced: false},
      );
      expect(
        settings.effectiveTabBarStackingMode(window: window),
        TabBarStackingMode.lastUsedTabs,
      );
      expect(settings.tabBarStackingMode, TabBarStackingMode.tabGroups);
    });

    test(
      'the container menu keeps its ways out while containers are hidden',
      () {
        expect(MenuItemType.containers.feature, isNull);
        expect(MenuItemType.unassignContainer.feature, isNull);
        expect(MenuItemType.unassignUrlFromContainer.feature, isNull);
        expect(MenuItemType.manageContainers.feature, FeatureId.containerCore);
        expect(MenuItemType.assignContainer.feature, FeatureId.containerCore);
      },
    );

    test('hierarchy display is guarded by the tree tabs switch', () {
      expect(FeatureId.tabsHierarchyDisplay.policy.switches, [
        VisibilitySwitch.treeTabs,
      ]);
    });
  });
}
