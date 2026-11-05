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
import 'package:weblibre/domain/setup_draft/setup_draft.dart';
import 'package:weblibre/features/onboarding/presentation/widgets/setup_section.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/domain/entities/fingerprint_overrides.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

// The protection choices of the onboarding: the parts of the draft that are
// not plain settings (hardening, uBlock Origin) and the engine settings a new
// install starts from. The Privacy & security step offers them all; Your
// setup repeats the three every preset has, hardening and uBlock Origin with
// its filters, for presets without that step.

/// The recommended security settings, applied at the commit.
class HardeningBaselineTile extends ConsumerWidget {
  const HardeningBaselineTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final value = ref.watch(
      setupDraftControllerProvider.select(
        (d) => d?.appliesHardeningBaseline ?? false,
      ),
    );

    return SwitchListTile.adaptive(
      secondary: const Icon(MdiIcons.shieldLock),
      title: Text(l10n.onboarding_webEngineHardeningTitle),
      subtitle: Text(l10n.onboarding_webEngineHardeningSubtitle),
      value: value,
      onChanged: (value) => ref
          .read(setupDraftControllerProvider.notifier)
          .setHardeningBaseline(value),
    );
  }
}

/// Installing uBlock Origin after the commit. [subtitle] replaces what it
/// blocks, where the row says when it happens instead.
class UBlockInstallTile extends ConsumerWidget {
  const UBlockInstallTile({super.key, this.subtitle});

  final String? subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final value = ref.watch(
      setupDraftControllerProvider.select((d) => d?.installsUBlock ?? false),
    );

    return SwitchListTile.adaptive(
      secondary: const Icon(MdiIcons.advertisementsOff),
      title: Text(l10n.onboarding_ublockInstallTitle),
      subtitle: Text(subtitle ?? l10n.onboarding_ublockInstallSubtitle),
      value: value,
      onChanged: (value) => ref
          .read(setupDraftControllerProvider.notifier)
          .setInstallUBlock(value),
    );
  }
}

/// uBlock Origin's recommended filter lists: only with the install, so
/// disabled while it is off ([SetupDraft.appliesOptimizedUBlockFilters]).
class UBlockFiltersTile extends ConsumerWidget {
  const UBlockFiltersTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final (:applies, :installs) = ref.watch(
      setupDraftControllerProvider.select(
        (d) => (
          applies: d?.appliesOptimizedUBlockFilters ?? false,
          installs: d?.installsUBlock ?? false,
        ),
      ),
    );

    return SwitchListTile.adaptive(
      secondary: const Icon(MdiIcons.filterOutline),
      title: Text(l10n.onboarding_ublockApplyDefaultsTitle),
      subtitle: Text(l10n.onboarding_ublockApplyDefaultsSubtitle),
      value: applies,
      onChanged: installs
          ? (value) => ref
                .read(setupDraftControllerProvider.notifier)
                .setOptimizedUBlockFilters(value)
          : null,
    );
  }
}

class LocalNetworkBlockingTile extends ConsumerWidget {
  const LocalNetworkBlockingTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final value = ref.watch(
      storedEngineSettingsProvider.select((s) => s.lnaBlocking ?? false),
    );

    return SwitchListTile.adaptive(
      secondary: const Icon(MdiIcons.lanPending),
      title: Text(l10n.onboarding_blockAllLocalNetworkTitle),
      subtitle: Text(l10n.onboarding_blockAllLocalNetworkSubtitle),
      value: value,
      onChanged: (value) => ref
          .read(saveEngineSettingsControllerProvider.notifier)
          .save((current) => current.copyWith.lnaBlocking(value)),
    );
  }
}

class FingerprintHardeningTile extends ConsumerWidget {
  const FingerprintHardeningTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isHardened = ref.watch(
      storedEngineSettingsProvider.select(
        (s) =>
            s.fingerprintingProtectionOverrides ==
            FingerprintOverrides.hardenedDefaults().toString(),
      ),
    );

    return Column(
      children: [
        SwitchListTile.adaptive(
          secondary: const Icon(MdiIcons.fingerprint),
          title: Text(l10n.onboarding_fingerprintProtectionTitle),
          subtitle: Text(l10n.onboarding_fingerprintProtectionSubtitle),
          value: isHardened,
          onChanged: (value) async {
            final overrides = value
                ? FingerprintOverrides.hardenedDefaults()
                : FingerprintOverrides.defaults();
            await ref
                .read(saveEngineSettingsControllerProvider.notifier)
                .save(
                  (current) => current.copyWith
                      .fingerprintingProtectionOverrides(overrides.toString()),
                );
          },
        ),
        if (isHardened)
          // A caveat, not an error: the tertiary role, not the error one.
          SetupNotice(
            color: theme.colorScheme.tertiaryContainer,
            onColor: theme.colorScheme.onTertiaryContainer,
            title: l10n.onboarding_compatibilityWarningTitle,
            points: [
              l10n.onboarding_fingerprintWarningPoint1,
              l10n.onboarding_fingerprintWarningPoint2,
            ],
          ),
      ],
    );
  }
}
