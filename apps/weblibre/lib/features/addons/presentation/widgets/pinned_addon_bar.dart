/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/addons/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/web_extensions_state.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/extension_badge_icon.dart';

class PinnedAddonBar extends ConsumerWidget {
  const PinnedAddonBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinnedIds = ref.watch(pinnedAddonIdsProvider);
    if (pinnedIds.isEmpty) return const SizedBox.shrink();

    final extensions = ref.watch(
      webExtensionsStateProvider(
        WebExtensionActionType.browser,
      ).select((value) => value.values.toList()),
    );

    final pinned = extensions
        .where((e) => pinnedIds.contains(e.extensionId))
        .toList();
    if (pinned.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final extension in pinned)
            InkResponse(
              radius: 22,
              onTap: () async {
                await ref
                    .read(addonServiceProvider)
                    .invokeAddonAction(
                      extension.extensionId,
                      WebExtensionActionType.browser,
                    );
              },
              onLongPress: () async {
                await AddonDetailsRoute(
                  addonId: extension.extensionId,
                ).push<void>(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6.0,
                  vertical: 8.0,
                ),
                child: ExtensionBadgeIcon(extension),
              ),
            ),
        ],
      ),
    );
  }
}
