import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tor_settings.g.dart';

@CopyWith()
@JsonSerializable(includeIfNull: true, constructor: 'withDefaults')
class TorSettings with FastEquatable {
  final bool proxyPrivateTabsTor;
  final bool autoConfig;

  TorSettings({required this.proxyPrivateTabsTor, required this.autoConfig});

  TorSettings.withDefaults({bool? proxyPrivateTabsTor, bool? autoConfig})
    : proxyPrivateTabsTor = proxyPrivateTabsTor ?? false,
      autoConfig = autoConfig ?? true;

  factory TorSettings.fromJson(Map<String, dynamic> json) =>
      _$TorSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$TorSettingsToJson(this);

  @override
  List<Object?> get hashParameters => [proxyPrivateTabsTor, autoConfig];
}
