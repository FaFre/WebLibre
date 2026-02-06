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
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:riverpod/riverpod.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';

Future<void> exitApp(ProviderContainer container) async {
  logger.i('Preparing exit');

  await container
      .read(tabDataRepositoryProvider.notifier)
      .closeAllTabs(includeRegular: false);

  await SystemNavigator.pop();
  logger.i('SystemNavigator popped');

  container.dispose();
  logger.i('Provider container disposed');

  await Future.delayed(const Duration(seconds: 1)).whenComplete(() {
    logger.i('Bye !!1');
    exit(0);
  });
}
