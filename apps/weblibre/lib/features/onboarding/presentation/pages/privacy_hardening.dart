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
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/preferences/data/repositories/preference_settings.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/setting_groups_serializer.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/domain/entities/fingerprint_overrides.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/browser_page.dart';

class PrivacyHardeningPage extends ConsumerWidget {
  const PrivacyHardeningPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return BrowserPage(
      child: BrowserPageContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Text(
                l10n.onboarding_privacyTitle,
                style: theme.textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 24),
            const _LanguageFingerprintWarning(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.onboarding_privacyBrowserLanguagesTitle),
              subtitle: Text(l10n.onboarding_privacyBrowserLanguagesSubtitle),
              leading: const Icon(Icons.translate),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await LocaleSettingsRoute().push(context);
              },
            ),
            const SizedBox(height: 16),
            const _WebEngineHardeningToggle(),
            const SizedBox(height: 16),
            const _FingerprintProtectionToggle(),
            const SizedBox(height: 16),
            const _LocalNetworkAccessSection(),
          ],
        ),
      ),
    );
  }
}

class _LanguageFingerprintWarning extends ConsumerWidget {
  const _LanguageFingerprintWarning();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final configuredLocales = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.locales),
    );

    if (configuredLocales.length <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: '${l10n.onboarding_multipleLanguagesDetectedTitle}\n\n',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: '• '),
                TextSpan(
                  text:
                      '${l10n.onboarding_multipleLanguagesWarning(configuredLocales.length, configuredLocales.join(', '))}\n\n',
                ),
                const TextSpan(text: '• '),
                TextSpan(text: l10n.onboarding_multipleLanguagesSuggestion),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.onErrorContainer,
                foregroundColor: theme.colorScheme.errorContainer,
              ),
              onPressed: () async {
                await LocaleSettingsRoute().push(context);
              },
              icon: const Icon(Icons.translate),
              label: Text(l10n.onboarding_reviewLanguages),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebEngineHardeningToggle extends ConsumerWidget {
  const _WebEngineHardeningToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    final preferenceGroups = ref.watch(
      unifiedPreferenceSettingsRepositoryProvider(PreferencePartition.user),
    );

    final allGroupsActive = preferenceGroups.maybeWhen(
      data: (data) =>
          data.values.every((element) => element.isActiveOrOptional),
      orElse: () => false,
    );

    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(l10n.onboarding_webEngineHardeningTitle),
      subtitle: Text(l10n.onboarding_webEngineHardeningSubtitle),
      secondary: const Icon(MdiIcons.shieldLock),
      value: allGroupsActive,
      onChanged: preferenceGroups.hasValue
          ? (value) async {
              final notifier = ref.read(
                unifiedPreferenceSettingsRepositoryProvider(
                  PreferencePartition.user,
                ).notifier,
              );

              if (value) {
                await notifier.apply();
              } else {
                await notifier.reset();
              }
            }
          : null,
    );
  }
}

class _FingerprintProtectionToggle extends ConsumerWidget {
  const _FingerprintProtectionToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final currentOverrides = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.fingerprintingProtectionOverrides,
      ),
    );

    final isHardened =
        currentOverrides == FingerprintOverrides.hardenedDefaults().toString();

    return Column(
      children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.onboarding_fingerprintProtectionTitle),
          subtitle: Text(l10n.onboarding_fingerprintProtectionSubtitle),
          secondary: const Icon(MdiIcons.fingerprint),
          value: isHardened,
          onChanged: (value) async {
            final overrides = value
                ? FingerprintOverrides.hardenedDefaults()
                : FingerprintOverrides.defaults();

            await ref
                .read(saveEngineSettingsControllerProvider.notifier)
                .save(
                  (currentSettings) => currentSettings.copyWith
                      .fingerprintingProtectionOverrides(overrides.toString()),
                );
          },
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: isHardened
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  margin: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text.rich(
                    TextSpan(
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onError,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text:
                              '${l10n.onboarding_compatibilityWarningTitle}\n\n',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onError,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: '• '),
                        TextSpan(
                          text:
                              '${l10n.onboarding_fingerprintWarningPoint1}\n\n',
                        ),
                        const TextSpan(text: '• '),
                        TextSpan(
                          text: l10n.onboarding_fingerprintWarningPoint2,
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _LocalNetworkAccessSection extends ConsumerWidget {
  const _LocalNetworkAccessSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    final lnaBlocking = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.lnaBlocking),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(l10n.onboarding_localNetworkProtectionTitle),
          subtitle: Text(l10n.onboarding_localNetworkProtectionSubtitle),
          leading: const Icon(MdiIcons.lanDisconnect),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.onboarding_blockAllLocalNetworkTitle),
          subtitle: Text(l10n.onboarding_blockAllLocalNetworkSubtitle),
          secondary: const Icon(MdiIcons.shieldLockOpen),
          value: lnaBlocking ?? false,
          onChanged: (value) async {
            await ref
                .read(saveEngineSettingsControllerProvider.notifier)
                .save(
                  (currentSettings) =>
                      currentSettings.copyWith.lnaBlocking(value),
                );
          },
        ),
      ],
    );
  }
}
