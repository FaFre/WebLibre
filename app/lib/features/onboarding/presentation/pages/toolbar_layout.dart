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
import 'package:weblibre/features/settings/presentation/widgets/toolbar_layout_content.dart';
import 'package:weblibre/features/settings/presentation/widgets/toolbar_preview.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/widgets/browser_page.dart';

class ToolbarLayoutPage extends HookConsumerWidget {
  const ToolbarLayoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(generalSettingsWithDefaultsProvider);

    return BrowserPage(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 32, 12, 16),
              child: Center(
                child: Text(
                  'Toolbar & Layout',
                  style: theme.textTheme.headlineMedium,
                ),
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: TabBarPreviewHeaderDelegate(
              settings: settings,
              backgroundColor: Colors.transparent,
              compact: true,
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: const ListTileTheme(
                    contentPadding: EdgeInsets.zero,
                    child: ToolbarLayoutContent(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
