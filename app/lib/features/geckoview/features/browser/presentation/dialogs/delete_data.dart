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

class DeleteDataDialog extends HookConsumerWidget {
  final Set<DeleteBrowsingDataType> initialSettings;

  const DeleteDataDialog({required this.initialSettings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selections = useState(initialSettings);

    return SimpleDialog(
      title: const Text('Delete Browsing Data'),
      children: [
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: FilledButton.icon(
            onPressed: () async {
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
        ),
      ],
    );
  }
}
