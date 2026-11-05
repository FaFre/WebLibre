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
import 'package:weblibre/features/onboarding/presentation/widgets/customize_setup.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/browser_page.dart';

/// The one page profiles set up at onboarding revision 1 see after an
/// update: the on-device AI features came later, and everything else they
/// already chose. A review opens no draft, so the switch writes the
/// live setting, like any page of a review.
class AiConfigurationPage extends StatelessWidget {
  const AiConfigurationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return BrowserPage(
      child: BrowserPageContent(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Icon(MdiIcons.creation, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              l10n.onboarding_aiFeaturesTitle,
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const LocalAiTile(),
          ],
        ),
      ),
    );
  }
}
