import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

class BangIcon extends ConsumerWidget {
  final String trigger;
  final double iconSize;

  const BangIcon({super.key, required this.trigger, this.iconSize = 20});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bang = ref.watch(
      bangDataProvider(trigger).select((value) => value.valueOrNull),
    );

    return UrlIcon([
      if (bang != null) bang.getTemplateUrl(''),
    ], iconSize: iconSize);
  }
}
