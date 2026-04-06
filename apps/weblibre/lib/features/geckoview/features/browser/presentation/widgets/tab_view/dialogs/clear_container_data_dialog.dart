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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class ClearContainerDataResult {
  final bool confirmed;
  final bool reopenTabs;

  const ClearContainerDataResult({
    required this.confirmed,
    required this.reopenTabs,
  });
}

Future<ClearContainerDataResult?> showClearContainerDataDialog(
  BuildContext context,
  int tabCount,
) {
  return showDialog<ClearContainerDataResult?>(
    context: context,
    builder: (BuildContext context) {
      return _ClearContainerDataDialog(tabCount: tabCount);
    },
  );
}

class _ClearContainerDataDialog extends HookWidget {
  final int tabCount;

  const _ClearContainerDataDialog({required this.tabCount});

  @override
  Widget build(BuildContext context) {
    final reopenTabs = useState(false);

    return AlertDialog(
      icon: const Icon(MdiIcons.databaseRemove),
      title: const Text('Clear Container Data'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('This will clear all data for this container:'),
          const SizedBox(height: 8),
          const Text('• Cookies'),
          const Text('• Site data'),
          const Text('• Cache'),
          const Text('• Permissions'),
          const SizedBox(height: 8),
          Text(
            '$tabCount tab(s) will be closed.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          CheckboxListTile(
            value: reopenTabs.value,
            onChanged: (value) {
              if (value != null) {
                reopenTabs.value = value;
              }
            },
            title: const Text('Recreate tabs after clearing'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.trailing,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              const ClearContainerDataResult(
                confirmed: false,
                reopenTabs: false,
              ),
            );
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              ClearContainerDataResult(
                confirmed: true,
                reopenTabs: reopenTabs.value,
              ),
            );
          },
          child: const Text('Clear Data'),
        ),
      ],
    );
  }
}
