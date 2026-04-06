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

class ShareTile extends StatelessWidget {
  final void Function()? onTap;
  final void Function()? onTapQr;

  const ShareTile({super.key, this.onTap, this.onTapQr});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.share),
      title: const Text('Share link'),
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const VerticalDivider(indent: 4, endIndent: 4),
          IconButton(icon: const Icon(Icons.qr_code), onPressed: onTapQr),
        ],
      ),
    );
  }
}
