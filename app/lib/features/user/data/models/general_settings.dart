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
  final bool enforceReadability;
  final Set<DeleteBrowsingDataType>? deleteBrowsingDataOnQuit;
  final String defaultSearchProvider;
  final bool createChildTabsOption;

  final bool proxyPrivateTabsTor;

  GeneralSettings({
    required this.themeMode,
    required this.enableReadability,
    required this.enforceReadability,
    required this.deleteBrowsingDataOnQuit,
    required this.defaultSearchProvider,
    required this.createChildTabsOption,
    required this.proxyPrivateTabsTor,
  });

  GeneralSettings.withDefaults({
    ThemeMode? themeMode,
    bool? enableReadability,
    bool? enforceReadability,
    this.deleteBrowsingDataOnQuit,
    String? defaultSearchProvider,
    bool? createChildTabsOption,
    bool? proxyPrivateTabsTor,
  }) : themeMode = themeMode ?? ThemeMode.dark,
       enableReadability = enableReadability ?? true,
       enforceReadability = enforceReadability ?? false,
       defaultSearchProvider = defaultSearchProvider ?? 'lais',
       createChildTabsOption = createChildTabsOption ?? false,
       proxyPrivateTabsTor = proxyPrivateTabsTor ?? false;

  factory GeneralSettings.fromJson(Map<String, dynamic> json) =>
      _$GeneralSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$GeneralSettingsToJson(this);

  @override
  List<Object?> get hashParameters => [
    themeMode,
    enableReadability,
    enforceReadability,
    deleteBrowsingDataOnQuit,
    defaultSearchProvider,
    createChildTabsOption,
    proxyPrivateTabsTor,
  ];
}
