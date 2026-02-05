/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/cached_future.dart';
import 'package:weblibre/utils/clipboard.dart';

class ClipboardFillLink extends HookConsumerWidget {
  final TextEditingController controller;

  const ClipboardFillLink({super.key, required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowClipboardAccess = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.allowClipboardAccess),
    );

    if (!allowClipboardAccess) {
      return const SizedBox.shrink();
    }

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
