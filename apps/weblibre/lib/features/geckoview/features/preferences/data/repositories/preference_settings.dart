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
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/preferences/data/models/preference_setting.dart';
import 'package:weblibre/features/geckoview/features/preferences/data/repositories/preference_migrations.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/setting_groups_serializer.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'preference_settings.g.dart';

const _preferenceMigrationVersionKey = 'preferenceMigrationVersion';
const _preferenceMigrationPartitionKey = 'preferenceMigration';
const _preferenceMigrationSchemaVersion = 4;
const _mainProcessDisableJitPref =
    'javascript.options.main_process_disable_jit';

/// Preferences we used to ship and have since dropped from `settings.json`.
///
/// Applying a preference writes it to the user branch, so removing the entry
/// only stops new profiles from getting it — every profile that already
/// applied it keeps the value forever. Resetting hands them back to Gecko's
/// default branch.
const _retiredPrefs = [
  // Was raised to 65536 KiB (8x Gecko's default), which buffers any media
  // resource under 64 MiB entirely in content-process memory.
  'media.memory_cache_max_size',
  // Only read by desktop Firefox's SessionStore, which GeckoView does not
  // ship, so it never did anything here.
  'browser.sessionstore.privacy_level',
];

/// Preferences nothing in Gecko 159 reads any more, dropped from
/// `settings.json` together. Same reasoning as [_retiredPrefs]; a separate
/// list because that step has already run on existing profiles.
const _retiredGecko159Prefs = [
  // SpiderMonkey removed asm.js; the pref has no reader.
  'javascript.options.asmjs',
  // The network predictor was removed from necko.
  'network.predictor.enabled',
  // No reader left in Gecko 159.
  'privacy.partition.network_state.ocsp_cache',
  'privacy.partition.network_state.ocsp_cache.pbmode',
  'dom.private-attribution.submission.enabled',
  'network.trr.confirmation_telemetry_enabled',
  'extensions.telemetry.EnvironmentAddonBuilder',
  'toolkit.coverage.enabled',
  'toolkit.coverage.endpoint.base',
  'toolkit.telemetry.collectInterval',
  'toolkit.telemetry.dap_enabled',
  'toolkit.telemetry.dap_task1_enabled',
  'toolkit.telemetry.dap_task1_taskid',
  'toolkit.telemetry.dap_visit_counting_enabled',
  'toolkit.telemetry.dap_visit_counting_experiment_list',
  // Read only by desktop Firefox, Fenix or Marionette, never by GeckoView.
  'browser.crashReports.crashPull',
  'browser.tabs.crashReporting.sendReport',
  'general.useragent.updates.enabled',
  // Linux GIO only.
  'network.gio.supported-protocols',
];

/// Preferences we set and now leave at Gecko's default on purpose.
const _restoredGeckoDefaults = [
  // We set it to false to keep add-ons from being granted the optional
  // technical and interaction data consent. Turned off, Gecko skips the
  // data-collection checks altogether, so `permissions.contains()` answers
  // true for that consent. Kept on, the install prompt
  // (`WebExtensionPromptFeature`) declines it instead.
  'extensions.dataCollectionPermissions.enabled',
];

/// Every preference a migration resets because `settings.json` dropped it.
/// A test keeps them out of `settings.json`: bringing one back takes a new
/// migration step, not just the entry, or it would reach new profiles only.
@visibleForTesting
const retiredPreferences = [
  ..._retiredPrefs,
  ..._retiredGecko159Prefs,
  ..._restoredGeckoDefaults,
];

@Riverpod(keepAlive: true)
class StartupPreferenceEnforcementService
    extends _$StartupPreferenceEnforcementService {
  final _prefManager = GeckoPrefService();

  PreferenceMigrationRunner get _migrationRunner => PreferenceMigrationRunner(
    schemaVersion: _preferenceMigrationSchemaVersion,
    steps: {
      0: () => _prefManager.resetPrefs([_mainProcessDisableJitPref]),
      1: _removeFxaProfileDomainFromLocalDnsBlocks,
      2: () => _prefManager.resetPrefs(_retiredPrefs),
      3: () => _prefManager.resetPrefs([
        ..._retiredGecko159Prefs,
        ..._restoredGeckoDefaults,
      ]),
    },
  );

  /// The `system` partition of `settings.json`: engine baseline values no
  /// setting toggles. They go to Gecko's default branch on every start, so
  /// they reach existing profiles without a migration, leave nothing behind
  /// once dropped, and yield to a user-branch value of the same preference.
  Future<void> _applyEngineBaseline(Map<String, dynamic> content) async {
    final prefs = {
      for (final group in deserializePreferenceSettingGroups(
        PreferencePartition.system,
        content,
      ).values)
        for (final entry in group.settings.entries)
          entry.key: entry.value.value,
    };

    if (prefs.isEmpty) {
      return;
    }

    try {
      await _prefManager.applyDefaultPrefs(prefs);
    } catch (e, s) {
      logger.w(
        'Failed to apply the engine baseline, will retry on next launch',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> _removeFxaProfileDomainFromLocalDnsBlocks() async {
    const dnsLocalDomainsPref = 'network.dns.localDomains';
    const fxaProfileDomain = 'profile.accounts.firefox.com';

    final pref = (await _prefManager.getPrefs([
      dnsLocalDomainsPref,
    ]))[dnsLocalDomainsPref];
    final value = pref?.userValue;

    if (value is! String || !value.contains(fxaProfileDomain)) {
      return;
    }

    final updatedValue = value
        .split(',')
        .where((domain) => domain != fxaProfileDomain)
        .join(',');

    await _prefManager.applyPrefs({dnsLocalDomainsPref: updatedValue});
  }

  Future<int> _readPreferenceMigrationVersion() async {
    final db = ref.read(userDatabaseProvider);
    final value = await db.settingDao.getSettingValue(
      _preferenceMigrationVersionKey,
    );

    return value?.readAs<int>(DriftSqlType.int, db.typeMapping) ?? 0;
  }

  Future<void> _writePreferenceMigrationVersion(int version) async {
    await ref
        .read(userDatabaseProvider)
        .settingDao
        .updateSetting(
          _preferenceMigrationVersionKey,
          _preferenceMigrationPartitionKey,
          version,
        );
  }

  Future<void> _runMigrations() async {
    final previousVersion = await _readPreferenceMigrationVersion();
    final currentVersion = await _migrationRunner.run(
      readVersion: _readPreferenceMigrationVersion,
      writeVersion: _writePreferenceMigrationVersion,
    );

    if (currentVersion > previousVersion) {
      logger.i(
        'Applied preference migrations '
        '$previousVersion -> $currentVersion',
      );
    }
  }

  Future<void> apply() async {
    final content = await ref.read(_preferenceSettingContentProvider.future);
    await _applyEngineBaseline(content);

    try {
      await _runMigrations();
    } catch (e, s) {
      logger.w(
        'Failed to run preference migrations, will retry on next launch',
        error: e,
        stackTrace: s,
      );
    }

    final groups = deserializePreferenceSettingGroups(
      PreferencePartition.user,
      content,
    );

    final startupPrefs = {
      for (final group in groups.values)
        ...Map.fromEntries(
          group.settings.entries
              .where(
                (entry) =>
                    entry.value.enforceOnStartup &&
                    !entry.value.requireUserOptIn,
              )
              .map((entry) => MapEntry(entry.key, entry.value.value)),
        ),
    };

    if (startupPrefs.isEmpty) {
      return;
    }

    final currentPrefs = await _prefManager.getPrefs(
      startupPrefs.keys.toList(),
    );

    // Respect persisted user opt-outs by only enforcing startup values if the
    // profile already carries the same user-branch value.
    final prefsToEnforce = Map.fromEntries(
      startupPrefs.entries.where((entry) {
        final current = currentPrefs[entry.key];
        if (current == null) {
          return true;
        }

        return current.hasUserChangedValue && current.userValue == entry.value;
      }),
    );

    if (prefsToEnforce.isNotEmpty) {
      try {
        await _prefManager.applyPrefs(prefsToEnforce);
      } catch (e) {
        logger.w(
          'Failed to enforce startup preferences, will retry on next launch',
          error: e,
        );
      }
    }
  }

  @override
  void build() {}
}

@Riverpod(keepAlive: true)
Future<Map<String, dynamic>> _preferenceSettingContent(Ref ref) async {
  return await rootBundle
          .loadString('assets/preferences/settings.json')
          .then(jsonDecode)
      as Map<String, dynamic>;
}

@Riverpod(keepAlive: true)
Future<Map<String, PreferenceSettingGroup>> _preferenceSettingGroups(
  Ref ref,
  PreferencePartition partition,
) async {
  final content = await ref.read(_preferenceSettingContentProvider.future);
  return deserializePreferenceSettingGroups(partition, content);
}

@Riverpod(keepAlive: true)
Future<PreferenceSettingGroup> _preferenceSettingGroup(
  Ref ref,
  PreferencePartition partition,
  String groupName,
) async {
  return await ref.watch(
    _preferenceSettingGroupsProvider(partition).selectAsync(
      (groups) =>
          groups[groupName] ?? (throw Exception('Unknown setting group')),
    ),
  );
}

@Riverpod()
class _PreferenceRepository extends _$PreferenceRepository {
  final _prefManager = GeckoPrefService();

  late List<String> _prefNames;
  late BehaviorSubject<Map<String, GeckoPref>> _prefSubject;
  late Future<void> _ready;

  Future<void> _updatePrefs() async {
    final prefs = _prefNames.isEmpty
        ? <String, GeckoPref>{}
        : await _prefManager.getPrefs(_prefNames);

    if (!ref.mounted || _prefSubject.isClosed) {
      return;
    }

    _prefSubject.add(prefs);
  }

  Future<void> applyPrefs(Map<String, Object> prefs) async {
    await _ready;
    await _prefManager.applyPrefs(prefs);
    await _updatePrefs();
  }

  Future<void> resetPrefs(List<String> prefNames) async {
    await _ready;
    await _prefManager.resetPrefs(prefNames);
    await _updatePrefs();
  }

  Future<void> _init(
    Future<Map<String, PreferenceSettingGroup>> groupsFuture,
  ) async {
    final groups = await groupsFuture;

    _prefNames = groups.values
        .map((group) => group.settings.keys)
        .flattened
        .toList();

    await _updatePrefs();
  }

  Future<void> _refreshAfterReady() async {
    await _ready;
    await _updatePrefs();
  }

  @override
  Raw<Stream<Map<String, GeckoPref>>> build(PreferencePartition partition) {
    final groupsFuture = ref.watch(
      _preferenceSettingGroupsProvider(partition).future,
    );

    _prefSubject = BehaviorSubject<Map<String, GeckoPref>>();

    ref.onDispose(() {
      unawaited(_prefSubject.close());
    });

    ref.onAddListener(() {
      unawaited(_refreshAfterReady());
    });

    _ready = _init(groupsFuture);

    return _prefSubject.stream;
  }
}

@Riverpod()
class UnifiedPreferenceSettingsRepository
    extends _$UnifiedPreferenceSettingsRepository {
  Future<void> apply() async {
    final groups = await ref.read(
      _preferenceSettingGroupsProvider(partition).future,
    );

    final prefs = {
      for (final group in groups.values)
        ...Map.fromEntries(
          group.settings.entries
              .where((e) => !e.value.requireUserOptIn)
              .map((e) => MapEntry(e.key, e.value.value)),
        ),
    };

    if (ref.mounted) {
      await ref
          .read(_preferenceRepositoryProvider(partition).notifier)
          .applyPrefs(prefs);
    } else {
      // This auto-dispose wrapper was torn down during the await (e.g.
      // invoked from an unawaited future before any UI is watching us).
      // Apply directly so the prefs still land.
      await GeckoPrefService().applyPrefs(prefs);
    }
  }

  Future<void> reset() async {
    final groups = await ref.read(
      _preferenceSettingGroupsProvider(partition).future,
    );

    final prefs = groups.values
        .map((group) => group.settings.keys)
        .flattened
        .toList();

    if (ref.mounted) {
      await ref
          .read(_preferenceRepositoryProvider(partition).notifier)
          .resetPrefs(prefs);
    } else {
      await GeckoPrefService().resetPrefs(prefs);
    }
  }

  @override
  Stream<Map<String, PreferenceSettingGroup>> build(
    PreferencePartition partition,
  ) async* {
    final prefStream = ref.watch(_preferenceRepositoryProvider(partition));
    final groups = await ref.watch(
      _preferenceSettingGroupsProvider(partition).future,
    );

    yield* prefStream.map(
      (prefs) => groups.map(
        (groupName, group) => MapEntry(
          groupName,
          group.copyWith.settings(
            group.settings.map(
              (prefName, setting) =>
                  MapEntry(prefName, setting.copyWith.current(prefs[prefName])),
            ),
          ),
        ),
      ),
    );
  }
}

@Riverpod()
class PreferenceSettingsGroupRepository
    extends _$PreferenceSettingsGroupRepository {
  Future<void> apply({List<String>? filter}) async {
    final settingGroup = await ref.read(
      _preferenceSettingGroupProvider(partition, groupName).future,
    );

    final prefs = Map.fromEntries(
      filter?.map(
            (e) => MapEntry(
              e,
              settingGroup.settings[e]?.value ??
                  (throw Exception('Preference not part of group')),
            ),
          ) ??
          settingGroup.settings.entries
              .where((e) => !e.value.requireUserOptIn)
              .map((e) => MapEntry(e.key, e.value.value)),
    );

    if (ref.mounted) {
      await ref
          .read(_preferenceRepositoryProvider(partition).notifier)
          .applyPrefs(prefs);
    } else {
      await GeckoPrefService().applyPrefs(prefs);
    }
  }

  Future<void> reset({List<String>? filter}) async {
    final settingGroup = await ref.read(
      _preferenceSettingGroupProvider(partition, groupName).future,
    );

    if (filter != null &&
        filter.any((value) => !settingGroup.settings.containsKey(value))) {
      throw Exception('Preference not part of group');
    }

    final prefs = filter ?? settingGroup.settings.keys.toList();

    if (ref.mounted) {
      await ref
          .read(_preferenceRepositoryProvider(partition).notifier)
          .resetPrefs(prefs);
    } else {
      await GeckoPrefService().resetPrefs(prefs);
    }
  }

  @override
  Stream<PreferenceSettingGroup> build(
    PreferencePartition partition,
    String groupName,
  ) async* {
    final prefStream = ref.watch(_preferenceRepositoryProvider(partition));
    final settingGroup = await ref.watch(
      _preferenceSettingGroupProvider(partition, groupName).future,
    );

    yield* prefStream.map(
      (prefs) => settingGroup.copyWith.settings(
        settingGroup.settings.map(
          (key, value) => MapEntry(key, value.copyWith.current(prefs[key])),
        ),
      ),
    );
  }
}
