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
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

class SyncDetailsTable extends StatelessWidget {
  final int? count;
  final DateTime? lastSync;

  const SyncDetailsTable(this.count, this.lastSync);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: GoogleFonts.robotoMono(
        textStyle: DefaultTextStyle.of(context).style,
      ),
      child: Table(
        columnWidths: const {0: FixedColumnWidth(100)},
        children: [
          TableRow(
            children: [const Text('Entries'), Text(count?.toString() ?? 'N/A')],
          ),
          TableRow(
            children: [
              const Text('Last Sync'),
              Text((lastSync != null) ? timeago.format(lastSync!) : 'N/A'),
            ],
          ),
        ],
      ),
    );
  }
}
