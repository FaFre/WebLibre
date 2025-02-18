import 'package:flutter/material.dart';
import 'package:lensai/features/geckoview/domain/entities/web_extension_state.dart';

class ExtensionBadgeIcon extends StatelessWidget {
  final WebExtensionState state;

  const ExtensionBadgeIcon(this.state);

  @override
  Widget build(BuildContext context) {
    final hasBadge = state.badgeText?.isNotEmpty ?? false;

    return Badge(
      isLabelVisible: hasBadge,
      label: hasBadge ? Text(state.badgeText!) : null,
      textColor: state.badgeTextColor,
      backgroundColor: state.badgeBackgroundColor,
      child: RawImage(image: state.icon?.value, width: 24, height: 24),
    );
  }
}
