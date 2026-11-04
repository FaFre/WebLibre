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
import 'package:flutter/widgets.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

extension SetupPresetL10n on SetupPreset {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      SetupPreset.average => l10n.onboarding_presetAverageTitle,
      SetupPreset.advanced => l10n.onboarding_presetAdvancedTitle,
      SetupPreset.expert => l10n.onboarding_presetExpertTitle,
    };
  }

  String description(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      SetupPreset.average => l10n.onboarding_presetAverageSubtitle,
      SetupPreset.advanced => l10n.onboarding_presetAdvancedSubtitle,
      SetupPreset.expert => l10n.onboarding_presetExpertSubtitle,
    };
  }

  IconData get icon => switch (this) {
    SetupPreset.average => MdiIcons.shieldCheckOutline,
    SetupPreset.advanced => MdiIcons.tuneVariant,
    SetupPreset.expert => MdiIcons.flaskOutline,
  };

  /// The line above [highlights] for a preset that builds on the one before
  /// it, so its card lists only what it adds; null for the first.
  String? includes(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      SetupPreset.average => null,
      SetupPreset.advanced => l10n.onboarding_presetAdvancedIncludes,
      SetupPreset.expert => l10n.onboarding_presetExpertIncludes,
    };
  }

  /// The three or four concrete things the preset's card lists. Each names
  /// only features that the preset's switch values in the feature policy
  /// show; keep them in step when those change.
  List<String> highlights(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      SetupPreset.average => [
        l10n.onboarding_presetAveragePoint1,
        l10n.onboarding_presetAveragePoint2,
        l10n.onboarding_presetAveragePoint3,
        l10n.onboarding_presetAveragePoint4,
      ],
      SetupPreset.advanced => [
        l10n.onboarding_presetAdvancedPoint1,
        l10n.onboarding_presetAdvancedPoint2,
        l10n.onboarding_presetAdvancedPoint3,
        l10n.onboarding_presetAdvancedPoint4,
      ],
      SetupPreset.expert => [
        l10n.onboarding_presetExpertPoint1,
        l10n.onboarding_presetExpertPoint2,
        l10n.onboarding_presetExpertPoint3,
      ],
    };
  }
}
