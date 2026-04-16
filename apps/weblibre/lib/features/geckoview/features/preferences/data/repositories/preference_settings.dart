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
import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/preferences/data/models/preference_setting.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/setting_groups_serializer.dart';

part 'preference_settings.g.dart';

@Riverpod(keepAlive: true)
class StartupPreferenceEnforcementService
    extends _$StartupPreferenceEnforcementService {
  Future<void> apply() async {
    final content = await ref.read(_preferenceSettingContentProvider.future);
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

    final currentPrefs = await GeckoPrefService().getPrefs(
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
        await GeckoPrefService().applyPrefs(prefsToEnforce);
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

    ref.onDispose(() async {
      await _prefSubject.close();
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
  Map<String, PreferenceSettingGroup>? _statelessGroups;

  Future<void> apply() async {
    final preferenceRepository = ref.read(
      _preferenceRepositoryProvider(partition).notifier,
    );

    _statelessGroups = await ref.read(
      _preferenceSettingGroupsProvider(partition).future,
    );

    final prefs = {
      for (final group in _statelessGroups!.values)
        ...Map.fromEntries(
          group.settings.entries
              .where((e) => !e.value.requireUserOptIn)
              .map((e) => MapEntry(e.key, e.value.value)),
        ),
    };

    await preferenceRepository.applyPrefs(prefs);
  }

  Future<void> reset() async {
    final preferenceRepository = ref.read(
      _preferenceRepositoryProvider(partition).notifier,
    );

    _statelessGroups = await ref.read(
      _preferenceSettingGroupsProvider(partition).future,
    );

    final prefs = _statelessGroups!.values
        .map((group) => group.settings.keys)
        .flattened
        .toList();

    await preferenceRepository.resetPrefs(prefs);
  }

  @override
  Stream<Map<String, PreferenceSettingGroup>> build(
    PreferencePartition partition,
  ) async* {
    _statelessGroups = await ref.watch(
      _preferenceSettingGroupsProvider(partition).future,
    );

    final prefStream = ref.watch(_preferenceRepositoryProvider(partition));

    yield* prefStream.map(
      (prefs) => _statelessGroups!.map(
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
  PreferenceSettingGroup? _statelessSettingGroup;

  Future<void> apply({List<String>? filter}) async {
    final preferenceRepository = ref.read(
      _preferenceRepositoryProvider(partition).notifier,
    );

    _statelessSettingGroup ??= await ref.read(
      _preferenceSettingGroupProvider(partition, groupName).future,
    );

    final prefs = Map.fromEntries(
      filter?.map(
            (e) => MapEntry(
              e,
              _statelessSettingGroup!.settings[e]?.value ??
                  (throw Exception('Preference not part of group')),
            ),
          ) ??
          _statelessSettingGroup!.settings.entries
              .where((e) => !e.value.requireUserOptIn)
              .map((e) => MapEntry(e.key, e.value.value)),
    );

    await preferenceRepository.applyPrefs(prefs);
  }

  Future<void> reset({List<String>? filter}) async {
    final preferenceRepository = ref.read(
      _preferenceRepositoryProvider(partition).notifier,
    );

    _statelessSettingGroup ??= await ref.read(
      _preferenceSettingGroupProvider(partition, groupName).future,
    );

    if (filter != null &&
        filter.any(
          (value) => !_statelessSettingGroup!.settings.containsKey(value),
        )) {
      throw Exception('Preference not part of group');
    }

    await preferenceRepository.resetPrefs(
      filter ?? _statelessSettingGroup!.settings.keys.toList(),
    );
  }

  @override
  Stream<PreferenceSettingGroup> build(
    PreferencePartition partition,
    String groupName,
  ) async* {
    _statelessSettingGroup = await ref.watch(
      _preferenceSettingGroupProvider(partition, groupName).future,
    );

    final prefStream = ref.watch(_preferenceRepositoryProvider(partition));

    yield* prefStream.map(
      (prefs) => _statelessSettingGroup!.copyWith.settings(
        _statelessSettingGroup!.settings.map(
          (key, value) => MapEntry(key, value.copyWith.current(prefs[key])),
        ),
      ),
    );
  }
}
