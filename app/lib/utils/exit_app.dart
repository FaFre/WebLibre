import 'dart:io';

import 'package:flutter/services.dart';
import 'package:riverpod/riverpod.dart';
import 'package:weblibre/core/logger.dart';

Future<void> exitApp(ProviderContainer container) async {
  logger.i('Preparing exit');

  await SystemNavigator.pop();
  logger.i('SystemNavigator popped');

  container.dispose();
  logger.i('Provider container disposed');

  await Future.delayed(const Duration(seconds: 1)).whenComplete(() {
    logger.i('Bye !!1');
    exit(0);
  });
}
