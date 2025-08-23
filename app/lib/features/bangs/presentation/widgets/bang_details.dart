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
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

class BangDetails extends HookConsumerWidget {
  final BangData bangData;
  final void Function()? onTap;

  const BangDetails(this.bangData, {this.onTap, super.key});

  String? _categoryString(BangData bang) {
    if (bang.category == null) {
      return null;
    } else if (bang.subCategory == null) {
      return bang.category;
    } else {
      return '${bang.category} / ${bang.subCategory}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UrlIcon([bangData.getTemplateUrl('')], iconSize: 34.0),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bangData.websiteName.trim(),
                          style: theme.textTheme.titleMedium,
                        ),
                        if (bangData.category != null)
                          Text(
                            _categoryString(bangData)!,
                            style: theme.textTheme.titleSmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FilledButton.tonalIcon(
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () async {
                      final url = Uri.parse(bangData.getTemplateUrl('').origin);
                      final isPrivate =
                          ref
                              .read(generalSettingsWithDefaultsProvider)
                              .defaultCreateTabType ==
                          TabType.private;

                      await ref
                          .read(tabRepositoryProvider.notifier)
                          .addTab(url: url, private: isPrivate);

                      if (context.mounted) {
                        BrowserRoute().go(context);
                      }
                    },
                    label: Text(bangData.domain),
                    icon: const Icon(Icons.open_in_new),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '!${bangData.trigger}',
                      style: theme.textTheme.titleSmall,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
