import 'dart:ui';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:lensai/domain/entities/equatable_image.dart';

part 'web_extension.g.dart';

@CopyWith()
class WebExtensionState with FastEquatable {
  String extensionId;

  String? title;
  bool enabled;
  String? badgeText;
  Color? badgeTextColor;
  Color? badgeBackgroundColor;

  final EquatableImage? icon;

  WebExtensionState({
    required this.extensionId,
    required this.enabled,
    this.title,
    this.badgeText,
    this.badgeTextColor,
    this.badgeBackgroundColor,
    this.icon,
  });

  @override
  List<Object?> get hashParameters => [
    extensionId,
    title,
    enabled,
    badgeText,
    badgeTextColor,
    badgeBackgroundColor,
    icon,
  ];
}
