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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/providers/window_size_class.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/onboarding/presentation/widgets/setup_section.dart';
import 'package:weblibre/features/settings/presentation/screens/module_surface_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/toolbar_layout_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/tab_bar_position_radio_group.dart';
import 'package:weblibre/features/settings/presentation/widgets/toolbar_preview.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/browser_page.dart';

/// "Layout": a picture of the browser as the draft lays it out, where the
/// tab bar goes, and the layout screens for whoever wants more. Everything
/// here can be skipped; Automatic suits most devices.
///
/// The tab bar position is the Toolbar & layout editor's own control, so
/// the two write the same setting the same way and the later choice wins.
class LayoutStepPage extends ConsumerWidget {
  const LayoutStepPage({super.key});

  /// The picture's height; smaller in a window short on height (a phone in
  /// landscape), where the choice below it must stay within reach.
  static const _previewHeight = 260.0;
  static const _compactPreviewHeight = 160.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final heightConstrained = ref.watch(
      windowSizeClassControllerProvider.select((w) => w.isHeightConstrained),
    );

    return BrowserPage(
      child: BrowserPageContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Text(
                l10n.onboarding_layoutStepTitle,
                style: theme.textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 24),
            // A picture only: no mode, so taps do nothing, and nothing in it
            // is read out apart from the choice below.
            ExcludeSemantics(
              child: SizedBox(
                height: heightConstrained
                    ? _compactPreviewHeight
                    : _previewHeight,
                child: const LayoutPreview(
                  device: PreviewDevice.thisWindow,
                  state: PreviewSampleState.page,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SetupSection(
              title: l10n.onboarding_tabBarPositionTitle,
              children: const [TabBarPositionRadioGroup()],
            ),
            // Supporting text below the choice, as for a text field.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Text(
                l10n.onboarding_layoutReassurance,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            SetupSection(
              title: l10n.onboarding_layoutCustomizeFurtherTitle,
              children: [
                SetupLinkTile(
                  icon: MdiIcons.dockBottom,
                  title: l10n.onboarding_toolbarLayoutTitle,
                  subtitle: l10n.onboarding_toolbarLayoutSubtitle,
                  // The Settings screen itself, editing the draft; its rows
                  // that only work on the live settings leave themselves out.
                  open: (context) => pushSetupScreen(
                    context,
                    const ToolbarLayoutSettingsScreen(),
                  ),
                ),
                SetupLinkTile(
                  icon: Icons.home_outlined,
                  title: l10n.onboarding_customizeHomeSections,
                  open: (context) => pushSetupScreen(
                    context,
                    ModuleSurfaceSettingsScreen(
                      title: l10n.onboarding_customizeHomeSections,
                    ),
                  ),
                ),
                SetupLinkTile(
                  icon: MdiIcons.tabPlus,
                  title: l10n.onboarding_customizeNewTabSections,
                  open: (context) => pushSetupScreen(
                    context,
                    ModuleSurfaceSettingsScreen(
                      surface: ModuleSurface.newTab,
                      title: l10n.onboarding_customizeNewTabSections,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
