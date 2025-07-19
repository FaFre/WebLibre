import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/web_extensions_state.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/extension_badge_icon.dart';

class ExtensionShortcutMenu extends HookConsumerWidget {
  final Widget child;
  final MenuController controller;

  const ExtensionShortcutMenu({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final browserExtensions = ref.watch(
      webExtensionsStateProvider(
        WebExtensionActionType.browser,
      ).select((value) => value.values.toList()),
    );

    return MenuAnchor(
      controller: controller,
      builder: (context, controller, child) {
        return child!;
      },
      menuChildren: [
        ...browserExtensions.map(
          (extension) => MenuItemButton(
            onPressed: () async {
              //Use parents .ref because after onPressed this consumer gets disposed already
              await ref
                  .read(addonServiceProvider)
                  .invokeAddonAction(
                    extension.extensionId,
                    WebExtensionActionType.browser,
                  );
            },
            leadingIcon: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: ExtensionBadgeIcon(extension),
            ),
            child: Text(extension.title ?? ''),
          ),
        ),
      ],
      child: Visibility(visible: browserExtensions.isNotEmpty, child: child),
    );
  }
}
