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

Future<bool?> showCloseAllPrivateTabsDialog(BuildContext context) {
  return showDialog<bool?>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        icon: const Icon(Icons.warning),
        title: const Text('Close All Private Tabs'),
        content: const Text(
          'Are you sure you want to close all displayed private tabs?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}
