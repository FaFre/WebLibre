import 'package:flutter/material.dart';

class RoundedBackground extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const RoundedBackground({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: backgroundColor ?? Theme.of(context).colorScheme.primary,
      ),
      child: child,
    );
  }
}
