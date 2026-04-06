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
import 'package:weblibre/core/providers/router.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';

Future<void> openSmallWebAttributionUri(BuildContext context, Uri uri) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final router = await container.read(routerProvider.future);

  if (context.mounted) {
    Navigator.of(context).pop();
  }

  await container
      .read(tabRepositoryProvider.notifier)
      .addTab(url: uri, tabMode: TabMode.regular, selectTab: true);

  router.go(const BrowserRoute().location);
}
