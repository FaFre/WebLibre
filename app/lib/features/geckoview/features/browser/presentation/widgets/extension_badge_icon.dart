import 'package:flutter/material.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/web_extension.dart';

class ExtensionBadgeIcon extends StatelessWidget {
  final WebExtensionState state;

  const ExtensionBadgeIcon(this.state);

  @override
  Widget build(BuildContext context) {
    final hasBadge = state.badgeText.isNotEmpty;

    return Badge(
      isLabelVisible: hasBadge,
      label: hasBadge ? Text(state.badgeText!) : null,
      textColor: state.badgeTextColor,
      backgroundColor: state.badgeBackgroundColor,
      child: RawImage(image: state.icon?.value, width: 24, height: 24),
    );
  }
}
