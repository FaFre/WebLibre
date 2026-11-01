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
import 'package:weblibre/core/branding/proxy_brands.dart';
import 'package:weblibre/core/providers/defaults.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/about/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

class AboutDialogScreen extends HookConsumerWidget {
  const AboutDialogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
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
      applicationLegalese: l10n.about_copyright,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.about_componentVersionsTitle),
          subtitle: const _ComponentVersions(),
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(MdiIcons.charity),
          title: Text(l10n.about_feedbackTitle),
          onTap: () async {
            await ref
                .read(tabRepositoryProvider.notifier)
                .addTab(
                  url: Uri.https('feedback.weblibre.eu'),
                  tabMode: TabMode.regular,
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
          title: Text(l10n.about_donateTitle),
          onTap: () async {
            await ref
                .read(tabRepositoryProvider.notifier)
                .addTab(
                  url: Uri.https('github.com').replace(path: 'FaFre/WebLibre'),
                  tabMode: TabMode.regular,
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
          title: Text(l10n.about_documentationTitle),
          onTap: () async {
            await ref
                .read(tabRepositoryProvider.notifier)
                .addTab(
                  url: ref.read(docsUriProvider),
                  tabMode: TabMode.regular,
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
          title: Text(l10n.about_githubTitle),
          onTap: () async {
            await ref
                .read(tabRepositoryProvider.notifier)
                .addTab(
                  url: Uri.https('github.com').replace(path: 'FaFre/WebLibre'),
                  tabMode: TabMode.regular,
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

/// The bundled engine and proxy components, each with its version.
///
/// Every source is read on its own, so one that fails or is still loading
/// leaves the others readable.
class _ComponentVersions extends HookConsumerWidget {
  const _ComponentVersions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    final gecko = ref.watch(geckoComponentVersionsProvider);
    final tor = ref.watch(torComponentVersionsProvider);
    final singbox = ref.watch(singboxVersionProvider);

    // Blank while loading, so a version that is on its way never flashes N/A.
    // A failure counts even while Riverpod still reports it as loading (a
    // provider that retries does until it gives up).
    String version<T>(AsyncValue<T> source, String? Function(T value) read) {
      return switch (source) {
        AsyncData(:final value) => read(value) ?? l10n.about_notAvailable,
        _ when source.hasError => l10n.about_notAvailable,
        _ => '',
      };
    }

    // Product names, never translated.
    final rows = [
      ('Gecko', version(gecko, (v) => v.gecko)),
      ('Android Components', version(gecko, (v) => v.androidComponents)),
      ('Application Services', version(gecko, (v) => v.applicationServices)),
      (torBrand, version(tor, (v) => v.tor)),
      ('Snowflake', version(tor, (v) => v.snowflake)),
      ('Lyrebird', version(tor, (v) => v.lyrebird)),
      ('sing-box', version(singbox, (v) => v)),
    ];

    final nameStyle = TextStyle(color: Theme.of(context).colorScheme.onSurface);

    // A row per component rather than a table: with large text or on a narrow
    // phone the names would claim the width and squeeze the versions out of a
    // column. A row that does not fit puts the version under its name instead.
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (name, value) in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Wrap(
                spacing: 12,
                children: [
                  Text(name, style: nameStyle),
                  Text(value),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
