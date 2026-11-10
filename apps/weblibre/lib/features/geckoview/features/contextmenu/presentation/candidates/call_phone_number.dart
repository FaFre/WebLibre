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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/extensions/hit_result.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// Hands the number to the phone app (a `tel:` VIEW intent), which opens the
/// dialer with it filled in: the call itself is still the user's to place.
class CallPhoneNumber extends HookConsumerWidget {
  final HitResult hitResult;

  const CallPhoneNumber({super.key, required this.hitResult});

  static bool isSupported(HitResult hitResult) {
    return hitResult.isTel();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: const Icon(Icons.call),
      title: Text(l10n.contextmenu_callPhoneNumber),
      onTap: () async {
        final uri = hitResult.tryGetPhoneUri();
        if (uri != null) {
          await launchUrlFeedback(context, uri);

          if (context.mounted) {
            context.pop();
          }
        }
      },
    );
  }
}
