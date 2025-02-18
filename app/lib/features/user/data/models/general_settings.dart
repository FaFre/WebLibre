import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'general_settings.g.dart';

enum DeleteBrowsingDataType {
  tabs('Open tabs'),
  history('Browsing history'),
  cookies('Cookies and site data', 'You’ll be logged out of most sites'),
  cache('Cached images and files', 'Frees up storage space'),
  permissions('Site permissions'),
  downloads('Downloads');

  final String title;
  final String? description;

  const DeleteBrowsingDataType(this.title, [this.description]);
}

@CopyWith()
@JsonSerializable(includeIfNull: true, constructor: 'withDefaults')
class GeneralSettings with FastEquatable {
  final ThemeMode themeMode;
  final bool enableReadability;
  final Set<DeleteBrowsingDataType>? deleteBrowsingDataOnQuit;

  GeneralSettings({
    required this.themeMode,
    required this.enableReadability,
    required this.deleteBrowsingDataOnQuit,
  });

  GeneralSettings.withDefaults({
    ThemeMode? themeMode,
    bool? enableReadability,
    this.deleteBrowsingDataOnQuit,
  }) : themeMode = themeMode ?? ThemeMode.dark,
       enableReadability = enableReadability ?? true;

  factory GeneralSettings.fromJson(Map<String, dynamic> json) =>
      _$GeneralSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$GeneralSettingsToJson(this);

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [
    themeMode,
    enableReadability,
    deleteBrowsingDataOnQuit,
  ];
}
