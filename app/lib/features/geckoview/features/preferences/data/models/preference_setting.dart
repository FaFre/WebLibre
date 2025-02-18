import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'preference_setting.g.dart';

@CopyWith()
class PreferenceSettingGroup with FastEquatable {
  final String? description;

  final Map<String, PreferenceSetting> settings;

  bool get isActive => settings.values.every(
    (setting) => setting.requireUserOptIn || setting.isActive,
  );

  bool get isPartlyActive => settings.values.any((setting) => setting.isActive);

  PreferenceSettingGroup({required this.description, required this.settings});

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [description, settings];
}

@JsonSerializable()
@CopyWith()
class PreferenceSetting with FastEquatable {
  final Object value;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final Object? actualValue;

  bool get isActive => value == actualValue;

  final String? title;
  final String? description;

  final bool requireUserOptIn;
  final bool shouldBeDefault;

  PreferenceSetting({
    required this.value,
    required this.title,
    required this.description,
    this.actualValue,
    this.requireUserOptIn = false,
    this.shouldBeDefault = false,
  });

  factory PreferenceSetting.fromJson(Map<String, dynamic> json) =>
      _$PreferenceSettingFromJson(json);

  Map<String, dynamic> toJson() => _$PreferenceSettingToJson(this);

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [
    value,
    actualValue,
    title,
    description,
    requireUserOptIn,
    shouldBeDefault,
  ];
}
