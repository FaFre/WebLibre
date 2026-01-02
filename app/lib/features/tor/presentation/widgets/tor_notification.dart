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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/features/geckoview/domain/controllers/overlay.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/presentation/icons/tor_icons.dart';
import 'package:weblibre/presentation/widgets/animate_gradient_shader.dart';

class TorNotification extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(torProxyServiceProvider, (previous, next) {
      if (!next.isLoading) {
        ref.read(overlayControllerProvider.notifier).dismiss();
      }
    });

    return SafeArea(
      child: ColoredBox(
        color: AppColors.torPurple,
        child: SizedBox(
          height: 56,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                AnimateGradientShader(
                  duration: const Duration(milliseconds: 500),
                  primaryEnd: Alignment.bottomLeft,
                  secondaryEnd: Alignment.topRight,
                  primaryColors: const [
                    AppColors.torActiveGreen,
                    AppColors.torActiveGreen,
                  ],
                  secondaryColors: const [Colors.white, Colors.white],
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(TorIcons.onionAlt),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Tor Proxy is connecting...',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ref.read(overlayControllerProvider.notifier).dismiss();
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
