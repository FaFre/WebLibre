import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:lensai/features/geckoview/features/preferences/data/models/preference_setting.dart';
import 'package:lensai/features/geckoview/features/tabs/utils/setting_groups_serializer.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'preference_settings.g.dart';

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
) {
  return ref.watch(
    _preferenceSettingGroupsProvider(partition).selectAsync(
      (groups) =>
          groups[groupName] ?? (throw Exception('Unknown setting group')),
    ),
  );
}

@Riverpod()
class _PreferenceRepository extends _$PreferenceRepository {
  final _prefManager = GeckoPrefService();
  // Use BehaviorSubject instead of StreamController
  late BehaviorSubject<Map<String, Object>> _prefSubject;

  Future<void> _updatePrefs() async {
    final prefs = await _prefManager.getAllPrefs();
    _prefSubject.add(prefs);
  }

  Future<void> applyPrefs(Map<String, Object> prefs) async {
    await _prefManager.applyPrefs(prefs);
    await _updatePrefs();
  }

  Future<void> resetPrefs(List<String> prefNames) async {
    await _prefManager.resetPrefs(prefNames);
    await _updatePrefs();
  }

  @override
  Raw<Stream<Map<String, Object>>> build() {
    _prefSubject = BehaviorSubject<Map<String, Object>>();

    ref.onDispose(() async {
      await _prefSubject.close();
    });

    ref.onAddListener(() async {
      await _updatePrefs();
    });

    return _prefSubject.stream;
  }
}

@Riverpod()
class UnifiedPreferenceSettingsRepository
    extends _$UnifiedPreferenceSettingsRepository {
  Map<String, PreferenceSettingGroup>? _statelessGroups;

  Future<void> apply() async {
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

    await ref.read(_preferenceRepositoryProvider.notifier).applyPrefs(prefs);
  }

  Future<void> reset() async {
    _statelessGroups = await ref.read(
      _preferenceSettingGroupsProvider(partition).future,
    );

    final prefs =
        _statelessGroups!.values
            .map((group) => group.settings.keys)
            .flattened
            .toList();

    await ref.read(_preferenceRepositoryProvider.notifier).resetPrefs(prefs);
  }

  @override
  Stream<Map<String, PreferenceSettingGroup>> build(
    PreferencePartition partition,
  ) async* {
    _statelessGroups = await ref.watch(
      _preferenceSettingGroupsProvider(partition).future,
    );

    final prefStream = ref.watch(_preferenceRepositoryProvider);

    yield* prefStream.map(
      (prefs) => _statelessGroups!.map(
        (groupName, group) => MapEntry(
          groupName,
          group.copyWith.settings(
            group.settings.map(
              (prefName, setting) => MapEntry(
                prefName,
                setting.copyWith.actualValue(prefs[prefName]),
              ),
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

    await ref.read(_preferenceRepositoryProvider.notifier).applyPrefs(prefs);
  }

  Future<void> reset({List<String>? filter}) async {
    _statelessSettingGroup ??= await ref.read(
      _preferenceSettingGroupProvider(partition, groupName).future,
    );

    if (filter != null &&
        filter.any(
          (value) => !_statelessSettingGroup!.settings.containsKey(value),
        )) {
      throw Exception('Preference not part of group');
    }

    await ref
        .read(_preferenceRepositoryProvider.notifier)
        .resetPrefs(filter ?? _statelessSettingGroup!.settings.keys.toList());
  }

  @override
  Stream<PreferenceSettingGroup> build(
    PreferencePartition partition,
    String groupName,
  ) async* {
    _statelessSettingGroup = await ref.watch(
      _preferenceSettingGroupProvider(partition, groupName).future,
    );

    final prefStream = ref.watch(_preferenceRepositoryProvider);

    yield* prefStream.map(
      (prefs) => _statelessSettingGroup!.copyWith.settings(
        _statelessSettingGroup!.settings.map(
          (key, value) => MapEntry(key, value.copyWith.actualValue(prefs[key])),
        ),
      ),
    );
  }
}
