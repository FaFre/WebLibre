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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/pwa/domain/providers.dart';
import 'package:weblibre/utils/ui_helper.dart';

Future<void> showPwaInstallDialog(BuildContext context, WidgetRef ref) async {
  final manifest = ref.read(currentTabManifestProvider);
  final name = manifest?.name ?? manifest?.shortName ?? 'this web app';

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add to Home Screen'),
      content: Text('Add "$name" to your home screen?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Add'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    try {
      final success = await ref.read(installCurrentWebAppProvider.future);

      if (context.mounted) {
        if (success) {
          showInfoMessage(context, '$name added to home screen');
        } else {
          showErrorMessage(
            context,
            'Failed to add $name. The site may not support installation.',
          );
        }
      }
    } catch (e, stackTrace) {
      logger.e('Failed to install PWA', error: e, stackTrace: stackTrace);

      if (context.mounted) {
        var errorMessage = 'Failed to add $name to home screen';

        if (e is StateError) {
          errorMessage = 'No tab selected. Please try again.';
        }

        showErrorMessage(context, errorMessage);
      }
    }
  }
}
