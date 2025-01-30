import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:lensai/features/geckoview/features/preferences/data/models/preference_setting.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'preference_settings.g.dart';

@Riverpod(keepAlive: true)
Future<Map<String, PreferenceSettingGroup>> _preferenceSettingGroups(
  Ref ref,
) async {
  final content = await rootBundle
      .loadString('assets/preferences/settings.json')
      .then(jsonDecode) as Map<String, dynamic>;

  final userContent = content['user'] as Map<String, dynamic>;

  return userContent.map(
    (key, value) => MapEntry(
      key,
      PreferenceSettingGroup(
        // ignore: avoid_dynamic_calls
        description: value['description'] as String?,
        // ignore: avoid_dynamic_calls
        settings: (value['preferences'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            key,
            PreferenceSetting.fromJson(value as Map<String, dynamic>),
          ),
        ),
      ),
    ),
  );
}

@Riverpod(keepAlive: true)
Future<PreferenceSettingGroup> _preferenceSettingGroup(
  Ref ref,
  String groupName,
) {
  return ref.watch(
    _preferenceSettingGroupsProvider.selectAsync(
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

    ref.onDispose(() {
      unawaited(_prefSubject.close());
    });

    ref.onAddListener(() async {
      await _updatePrefs();
    });

    return _prefSubject.stream;
  }
}

@Riverpod()
class PreferenceSettingsGeneralRepository
    extends _$PreferenceSettingsGeneralRepository {
  late Map<String, PreferenceSettingGroup> _statelessGroups;

  Future<void> apply() async {
    final prefs = {
      for (final group in _statelessGroups.values)
        ...Map.fromEntries(
          group.settings.entries
              .where((e) => !e.value.requireUserOptIn)
              .map((e) => MapEntry(e.key, e.value.value)),
        ),
    };

    await ref.read(_preferenceRepositoryProvider.notifier).applyPrefs(prefs);
  }

  Future<void> reset() async {
    final prefs = _statelessGroups.values
        .map((group) => group.settings.keys)
        .flattened
        .toList();

    await ref.read(_preferenceRepositoryProvider.notifier).resetPrefs(prefs);
  }

  @override
  Stream<Map<String, PreferenceSettingGroup>> build() async* {
    _statelessGroups = await ref.watch(_preferenceSettingGroupsProvider.future);

    final prefStream = ref.watch(_preferenceRepositoryProvider);

    yield* prefStream.map(
      (prefs) => _statelessGroups.map(
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
  late PreferenceSettingGroup _statelessSettingGroup;

  Future<void> apply({List<String>? filter}) async {
    final prefs = Map.fromEntries(
      filter?.map(
            (e) => MapEntry(
              e,
              _statelessSettingGroup.settings[e]?.value ??
                  (throw Exception('Preference not part of group')),
            ),
          ) ??
          _statelessSettingGroup.settings.entries
              .where((e) => !e.value.requireUserOptIn)
              .map((e) => MapEntry(e.key, e.value.value)),
    );

    await ref.read(_preferenceRepositoryProvider.notifier).applyPrefs(prefs);
  }

  Future<void> reset({List<String>? filter}) async {
    if (filter != null &&
        filter.any(
          (value) => !_statelessSettingGroup.settings.containsKey(value),
        )) {
      throw Exception('Preference not part of group');
    }

    await ref
        .read(_preferenceRepositoryProvider.notifier)
        .resetPrefs(filter ?? _statelessSettingGroup.settings.keys.toList());
  }

  @override
  Stream<PreferenceSettingGroup> build(String groupName) async* {
    _statelessSettingGroup =
        await ref.watch(_preferenceSettingGroupProvider(groupName).future);

    final prefStream = ref.watch(_preferenceRepositoryProvider);

    yield* prefStream.map(
      (prefs) => _statelessSettingGroup.copyWith.settings(
        _statelessSettingGroup.settings.map(
          (key, value) => MapEntry(key, value.copyWith.actualValue(prefs[key])),
        ),
      ),
    );
  }
}
