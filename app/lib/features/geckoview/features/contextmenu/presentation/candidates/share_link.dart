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
import 'package:share_plus/share_plus.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/qr_code.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/extensions/hit_result.dart';
import 'package:weblibre/presentation/widgets/share_tile.dart';

class ShareLink extends HookConsumerWidget {
  final HitResult hitResult;

  const ShareLink({super.key, required this.hitResult});

  static bool isSupported(HitResult hitResult) {
    return hitResult.isUri() || hitResult.isImage() || hitResult.isVideoAudio();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final link = hitResult.tryGetLink();

    return ShareTile(
      onTap: () async {
        await link.mapNotNull(
          (url) => SharePlus.instance.share(ShareParams(uri: url)),
        );

        if (context.mounted) {
          context.pop();
        }
      },
      onTapQr: link.mapNotNull(
        (url) => () async {
          await showQrCode(context, url.toString());
        },
      ),
    );
  }
}
