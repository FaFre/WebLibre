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
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_data.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';

/// Shows a bottom sheet to select and delete browsing data.
Future<void> showDeleteDataDialog(
  BuildContext context, {
  Set<DeleteBrowsingDataType> initialSettings = const {},
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _DeleteDataSheet(initialSettings: initialSettings),
  );
}

class _DeleteDataSheet extends HookConsumerWidget {
  final Set<DeleteBrowsingDataType> initialSettings;

  const _DeleteDataSheet({required this.initialSettings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selections = useState(initialSettings);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Delete Browsing Data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            for (final type in DeleteBrowsingDataType.values)
              CheckboxListTile.adaptive(
                value: selections.value.contains(type),
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(type.title),
                subtitle: type.description.mapNotNull(
                  (description) => Text(description),
                ),
                onChanged: (value) {
                  if (value == true) {
                    selections.value = {...selections.value, type};
                  } else {
                    selections.value = {...selections.value}..remove(type);
                  }
                },
              ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: selections.value.isEmpty
                  ? null
                  : () async {
                      await ref
                          .read(browserDataServiceProvider.notifier)
                          .deleteData(selections.value);

                      if (context.mounted) {
                        context.pop();
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              label: const Text('Delete'),
              icon: const Icon(Icons.delete_forever),
            ),
          ],
        ),
      ),
    );
  }
}
