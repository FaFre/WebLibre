import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class HardeningGroupIcon extends StatelessWidget {
  final bool isActive;
  final bool isPartlyActive;

  const HardeningGroupIcon({
    super.key,
    required this.isActive,
    this.isPartlyActive = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return Icon(
        MdiIcons.shieldLockOutline,
        color: Theme.of(context).colorScheme.secondary,
      );
    } else if (isPartlyActive) {
      return Icon(
        MdiIcons.shieldLockOpenOutline,
        color: Theme.of(context).colorScheme.secondary,
      );
    }

    return Icon(
      MdiIcons.shieldOffOutline,
      color: Theme.of(context).colorScheme.error,
    );
  }
}
