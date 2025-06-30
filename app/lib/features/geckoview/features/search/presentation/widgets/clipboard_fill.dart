import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:weblibre/presentation/hooks/cached_future.dart';
import 'package:weblibre/utils/clipboard.dart';

class ClipboardFillLink extends HookWidget {
  final TextEditingController controller;

  const ClipboardFillLink({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final clipboardUrl = useCachedFuture(() => tryGetUriFromClipboard());
    final currentText = useValueListenable(controller);

    return Visibility(
      visible:
          clipboardUrl.hasData &&
          clipboardUrl.data.toString() != currentText.text,
      child: ListTile(
        leading: const Icon(MdiIcons.linkPlus),
        title: const Text('Fill link from clipboard'),
        onTap: () {
          controller.text = clipboardUrl.data.toString();
        },
      ),
    );
  }
}
