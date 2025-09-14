import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tor_settings.g.dart';

enum TorConnectionConfig { auto, direct, obfs4, snowflake }

@CopyWith()
@JsonSerializable(includeIfNull: true, constructor: 'withDefaults')
class TorSettings with FastEquatable {
  final bool proxyPrivateTabsTor;
  final TorConnectionConfig config;
  final bool requireBridge;
  final bool fetchRemoteBridges;

  TorSettings({
    required this.proxyPrivateTabsTor,
    required this.config,
    required this.requireBridge,
    required this.fetchRemoteBridges,
  });

  TorSettings.withDefaults({
    bool? proxyPrivateTabsTor,
    TorConnectionConfig? config,
    bool? requireBridge,
    bool? fetchRemoteBridges,
  }) : proxyPrivateTabsTor = proxyPrivateTabsTor ?? false,
       config = config ?? TorConnectionConfig.auto,
       requireBridge = requireBridge ?? false,
       fetchRemoteBridges = fetchRemoteBridges ?? true;

  factory TorSettings.fromJson(Map<String, dynamic> json) =>
      _$TorSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$TorSettingsToJson(this);

  @override
  List<Object?> get hashParameters => [
    proxyPrivateTabsTor,
    config,
    requireBridge,
    fetchRemoteBridges,
  ];
}
