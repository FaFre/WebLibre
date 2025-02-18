import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lensai/data/database/converters/icon_data.dart';

part 'container_data.g.dart';

@CopyWith()
@JsonSerializable()
class ContainerAuthSettings with FastEquatable {
  final bool authenticationRequired;
  final bool lockOnAppBackground;
  final Duration? lockTimeout;

  ContainerAuthSettings({
    required this.authenticationRequired,
    required this.lockOnAppBackground,
    required this.lockTimeout,
  });

  ContainerAuthSettings.withDefaults({
    bool? authenticationRequired,
    bool? lockOnAppBackground,
    Duration? lockTimeout,
  }) : this(
         authenticationRequired: authenticationRequired ?? false,
         lockOnAppBackground: lockOnAppBackground ?? false,
         lockTimeout: lockTimeout,
       );

  factory ContainerAuthSettings.fromJson(Map<String, dynamic> json) =>
      _$ContainerAuthSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$ContainerAuthSettingsToJson(this);

  @override
  List<Object?> get hashParameters => [
    authenticationRequired,
    lockOnAppBackground,
    lockTimeout,
  ];

  @override
  bool get cacheHash => true;
}

@CopyWith()
@JsonSerializable(constructor: 'withDefaults')
class ContainerMetadata with FastEquatable {
  @IconDataJsonConverter()
  final IconData? iconData;
  final String? contextualIdentity;
  final ContainerAuthSettings authSettings;

  @JsonKey(defaultValue: false)
  final bool useProxy;

  ContainerMetadata({
    required this.iconData,
    required this.contextualIdentity,
    required this.authSettings,
    required this.useProxy,
  });

  ContainerMetadata.withDefaults({
    IconData? iconData,
    String? contextualIdentity,
    ContainerAuthSettings? authSettings,
    bool? useProxy,
  }) : this(
         iconData: iconData,
         contextualIdentity: contextualIdentity,
         authSettings: authSettings ?? ContainerAuthSettings.withDefaults(),
         useProxy: useProxy ?? false,
       );

  factory ContainerMetadata.fromJson(Map<String, dynamic> json) =>
      _$ContainerMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$ContainerMetadataToJson(this);

  @override
  List<Object?> get hashParameters => [
    iconData,
    contextualIdentity,
    authSettings,
    useProxy,
  ];

  @override
  bool get cacheHash => true;
}

@CopyWith()
class ContainerData with FastEquatable {
  final String id;
  final String? name;
  final Color color;
  final ContainerMetadata metadata;

  ContainerData({
    required this.id,
    this.name,
    required this.color,
    ContainerMetadata? metadata,
  }) : metadata = metadata ?? ContainerMetadata.withDefaults();

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [id, name, color, metadata];
}

class ContainerDataWithCount extends ContainerData {
  final int? tabCount;

  ContainerDataWithCount({
    required super.id,
    super.name,
    required super.color,
    super.metadata,
    required this.tabCount,
  });

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [...super.hashParameters, tabCount];
}
