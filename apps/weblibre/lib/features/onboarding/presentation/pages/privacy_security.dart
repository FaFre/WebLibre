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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/locale.dart' as intl;
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/domain/repositories/locale_resolver.dart';
import 'package:weblibre/extensions/locale.dart';
import 'package:weblibre/features/onboarding/presentation/widgets/protection_tiles.dart';
import 'package:weblibre/features/onboarding/presentation/widgets/setup_section.dart';
import 'package:weblibre/features/settings/presentation/screens/doh_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/locale_settings.dart';
import 'package:weblibre/features/settings/presentation/utils/doh_settings_mode_l10n.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/browser_page.dart';

/// "Privacy & security": every protection choice of the onboarding. A step
/// for a preset that shows Advanced privacy (Tinkerer and Expert), which
/// guards the fine-grained ones anyway; opened from Your setup instead
/// ([PrivacySecurityScreen]) when Advanced privacy is shown later. The
/// recommended security settings and uBlock Origin are on Your setup too,
/// for everyone else.
class PrivacySecurityStepPage extends ConsumerWidget {
  const PrivacySecurityStepPage({super.key, this.showTitle = true});

  /// Off where an app bar already names the page.
  final bool showTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final general = ref.watch(displayedGeneralSettingsProvider);
    final engine = ref.watch(displayedEngineSettingsProvider);

    final dohMode = engine.dohSettingsMode;

    return BrowserPage(
      child: BrowserPageContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            if (showTitle) ...[
              Center(
                child: Text(
                  l10n.onboarding_customizeGroupPrivacy,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (general.isFeatureShown(FeatureId.privacyBrowserLanguages) &&
                engine.locales.length > 1)
              _LanguageFingerprintWarning(locales: engine.locales),
            SetupSection(
              children: [
                const HardeningBaselineTile(),
                const UBlockInstallTile(),
                const UBlockFiltersTile(),
                if (general.isFeatureShown(
                  FeatureId.privacyLocalNetworkBlockingSwitch,
                ))
                  const LocalNetworkBlockingTile(),
                if (general.isFeatureShown(FeatureId.privacyFpHardenedDefaults))
                  const FingerprintHardeningTile(),
                if (general.isFeatureShown(FeatureId.privacyDohProviderControl))
                  SetupLinkTile(
                    icon: MdiIcons.dns,
                    title: l10n.onboarding_dohTitle,
                    // What is set, not a promise: the default level falls
                    // back to unencrypted lookups. Off and Default
                    // Protection use no configured resolver (Default is
                    // Gecko's native DNS), so none is named.
                    subtitle: switch (dohMode) {
                      DohSettingsMode.off ||
                      DohSettingsMode.geckoDefault => dohMode.label(context),
                      DohSettingsMode.increased ||
                      DohSettingsMode.max => l10n.onboarding_dohCurrentSubtitle(
                        dohMode.label(context),
                        dohProviderName(engine),
                      ),
                    },
                    // The Settings screen itself, editing the draft.
                    open: (context) =>
                        pushSetupScreen(context, const DohSettingsScreen()),
                  ),
                if (general.isFeatureShown(FeatureId.privacyBrowserLanguages))
                  SetupLinkTile(
                    icon: Icons.translate,
                    title: l10n.onboarding_privacyBrowserLanguagesTitle,
                    subtitle: l10n.onboarding_privacyBrowserLanguagesSubtitle,
                    open: (context) =>
                        pushSetupScreen(context, const LocaleSettingsScreen()),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// [PrivacySecurityStepPage] pushed from Your setup, for a preset without the
/// step once Advanced privacy is shown. Back returns to the summary with
/// every change kept in the draft.
class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.onboarding_customizeGroupPrivacy)),
      body: const SafeArea(child: PrivacySecurityStepPage(showTitle: false)),
    );
  }
}

/// Several preferred languages make the browser easier to tell apart: asks
/// to keep one, with the way to the language list. Above the section, as
/// it concerns what websites see rather than one switch.
class _LanguageFingerprintWarning extends HookConsumerWidget {
  const _LanguageFingerprintWarning({required this.locales});

  /// Language tags, as the engine stores them.
  final List<String> locales;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final displayLocale = Localizations.localeOf(context).toIntlLocale();

    // CLDR names in the UI language; the tag stands in until (or unless) the
    // platform resolves it. The repository is keepAlive and caches.
    final names = useFuture(
      useMemoized(
        () => Future.wait(
          locales.map((tag) async {
            final locale = intl.Locale.tryParse(tag);
            if (locale == null) return tag;
            try {
              final resolved = await ref
                  .read(
                    localeResolverRepositoryProvider(displayLocale).notifier,
                  )
                  .resolve(locale);
              final country = resolved.countryName;
              return country == null
                  ? resolved.languageName
                  : '${resolved.languageName} ($country)';
            } catch (_) {
              return tag;
            }
          }),
        ),
        [locales.join(','), displayLocale],
      ),
    ).data;

    return SetupNotice(
      color: theme.colorScheme.errorContainer,
      onColor: theme.colorScheme.onErrorContainer,
      margin: const EdgeInsets.only(bottom: 24),
      title: l10n.onboarding_severalLanguagesTitle,
      points: [
        l10n.onboarding_multipleLanguagesWarning(
          locales.length,
          (names ?? locales).join(', '),
        ),
        l10n.onboarding_multipleLanguagesSuggestion,
      ],
      action: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.onErrorContainer,
          foregroundColor: theme.colorScheme.errorContainer,
        ),
        onPressed: () => pushSetupScreen(context, const LocaleSettingsScreen()),
        icon: const Icon(Icons.translate),
        label: Text(l10n.onboarding_reviewLanguages),
      ),
    );
  }
}
