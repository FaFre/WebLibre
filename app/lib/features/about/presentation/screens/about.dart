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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/about/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';

class AboutDialogScreen extends HookConsumerWidget {
  const AboutDialogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref.watch(
      packageInfoProvider.select(
        //During startup we make sure
        (value) => value.value!,
      ),
    );

    return AboutDialog(
      applicationIcon: SizedBox.square(
        dimension: IconTheme.of(context).size,
        child: SvgPicture.asset('assets/icon/icon.svg'),
      ),
      applicationName: packageInfo.appName,
      applicationVersion: packageInfo.version,
      applicationLegalese: 'Copyright © Fabian Freund, 2024-2026',
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Gecko Version'),
          subtitle: Consumer(
            builder: (context, ref, child) {
              final geckoVersion = ref.watch(geckoVersionProvider);

              return Text(geckoVersion.value ?? 'N/A');
            },
          ),
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(MdiIcons.charity),
          title: const Text('Feedback'),
          onTap: () async {
            await ref
                .read(tabRepositoryProvider.notifier)
                .addTab(
                  url: Uri.https('feedback.weblibre.eu'),
                  private: false,
                  selectTab: true,
                );

            if (context.mounted) {
              const BrowserRoute().go(context);
            }
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(MdiIcons.handHeart),
          title: const Text('Donate'),
          onTap: () async {
            await ref
                .read(tabRepositoryProvider.notifier)
                .addTab(
                  url: Uri.https('github.com').replace(path: 'FaFre/WebLibre'),
                  private: false,
                  selectTab: true,
                );

            if (context.mounted) {
              const BrowserRoute().go(context);
            }
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          // ignore: deprecated_member_use
          leading: const Icon(Icons.book),
          title: const Text('Documentation'),
          onTap: () async {
            await ref
                .read(tabRepositoryProvider.notifier)
                .addTab(
                  url: Uri.https('docs.weblibre.eu'),
                  private: false,
                  selectTab: true,
                );

            if (context.mounted) {
              const BrowserRoute().go(context);
            }
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          // ignore: deprecated_member_use
          leading: const Icon(MdiIcons.github),
          title: const Text('Github'),
          onTap: () async {
            await ref
                .read(tabRepositoryProvider.notifier)
                .addTab(
                  url: Uri.https('github.com').replace(path: 'FaFre/WebLibre'),
                  private: false,
                  selectTab: true,
                );

            if (context.mounted) {
              const BrowserRoute().go(context);
            }
          },
        ),
      ],
    );
  }
}
