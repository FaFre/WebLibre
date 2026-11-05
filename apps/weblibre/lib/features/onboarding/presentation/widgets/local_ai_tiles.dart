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
import 'package:weblibre/features/onboarding/presentation/widgets/setup_section.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Turns the on-device models on, with the download notice `ai.local_ai`
/// confirms with in every preset.
class LocalAiTile extends ConsumerWidget {
  const LocalAiTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final value = ref.watch(
      storedGeneralSettingsProvider.select((s) => s.enableLocalAiFeatures),
    );

    return Column(
      children: [
        SwitchListTile.adaptive(
          secondary: const Icon(MdiIcons.creation),
          title: Text(l10n.onboarding_aiUseOnDeviceTitle),
          subtitle: Text(l10n.onboarding_aiOnDeviceSubtitle),
          value: value,
          onChanged: (value) => ref
              .read(saveGeneralSettingsControllerProvider.notifier)
              .save((current) => current.copyWith.enableLocalAiFeatures(value)),
        ),
        if (value) const LocalAiNotice(),
      ],
    );
  }
}

/// What to know about on-device AI, under the switch that turns it on.
class LocalAiNotice extends StatelessWidget {
  const LocalAiNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SetupNotice(
      color: theme.colorScheme.secondaryContainer,
      onColor: theme.colorScheme.onSecondaryContainer,
      title: l10n.onboarding_aiWarningTitle,
      points: [
        l10n.onboarding_aiWarningPoint1,
        l10n.onboarding_aiWarningPoint2,
        l10n.onboarding_aiWarningPoint3,
      ],
    );
  }
}
