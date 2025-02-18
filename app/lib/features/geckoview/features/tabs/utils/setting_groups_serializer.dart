// ignore_for_file: avoid_dynamic_calls wo know what we do

import 'package:lensai/features/geckoview/features/preferences/data/models/preference_setting.dart';

enum PreferencePartition {
  user('user'),
  system('system');

  final String key;

  const PreferencePartition(this.key);
}

Map<String, PreferenceSettingGroup> deserializePreferenceSettingGroups(
  PreferencePartition partition,
  Map<String, dynamic> content,
) {
  final parititonedContent = content[partition.key] as Map<String, dynamic>;

  return parititonedContent.map(
    (key, value) => MapEntry(
      key,
      PreferenceSettingGroup(
        description: value['description'] as String?,
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
