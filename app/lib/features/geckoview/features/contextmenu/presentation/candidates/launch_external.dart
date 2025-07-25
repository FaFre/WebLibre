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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/extensions/hit_result.dart';
import 'package:weblibre/utils/ui_helper.dart';

class LaunchExternal extends HookConsumerWidget {
  final HitResult hitResult;

  const LaunchExternal({super.key, required this.hitResult});

  static Future<bool> isSupported(HitResult hitResult) async {
    return hitResult.tryGetLink().mapNotNull((url) => canLaunchUrl(url)) ??
        false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.open_in_browser),
      title: const Text('Launch External'),
      onTap: () async {
        await hitResult.tryGetLink().mapNotNull((url) async {
          await launchUrlFeedback(context, url);

          if (context.mounted) {
            context.pop();
          }
        });
      },
    );
  }
}
