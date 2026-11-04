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
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/features/onboarding/domain/providers.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/utils/localized_spans.dart';
import 'package:weblibre/presentation/widgets/browser_page.dart';
import 'package:weblibre/presentation/widgets/pointer_scrollable_sheet.dart';

class WelcomePage extends ConsumerWidget {
  final bool isReturningUser;

  /// Restores a backup into this profile. Offered to new users only; null
  /// hides the button.
  final VoidCallback? onRestore;

  const WelcomePage({super.key, this.isReturningUser = false, this.onRestore});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final accepted = ref.watch(eulaAcceptedProvider);

    return BrowserPage(
      child: BrowserPageContent(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            BrandHeader(colorScheme: colorScheme),
            const SizedBox(height: 24),
            Text(
              isReturningUser
                  ? l10n.onboarding_welcomeBackTitle
                  : l10n.onboarding_welcomeTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (isReturningUser) ...[
              const SizedBox(height: 16),
              _UpdateNotice(colorScheme: colorScheme, theme: theme),
            ],
            const SizedBox(height: 40),
            _EulaCheckbox(
              accepted: accepted,
              onAcceptedChanged: (value) =>
                  ref.read(eulaAcceptedProvider.notifier).accept(value),
            ),
            if (!isReturningUser && onRestore != null) ...[
              const SizedBox(height: 24),
              _RestoreOption(enabled: accepted, onTap: onRestore!),
            ],
          ],
        ),
      ),
    );
  }
}

/// Restoring replaces this profile with a backup at once, so it is an action
/// of its own rather than a preset: the backup brings its own settings
/// and skips the Preset step.
class _RestoreOption extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _RestoreOption({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      enabled: enabled,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      leading: const Icon(Icons.settings_backup_restore),
      title: Text(l10n.onboarding_modeRestoreTitle),
      subtitle: Text(
        enabled
            ? l10n.onboarding_modeRestoreSubtitle
            : l10n.onboarding_restoreRequiresEula,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _UpdateNotice extends StatelessWidget {
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _UpdateNotice({required this.colorScheme, required this.theme});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          // Opaque tonal role, like the onboarding's other notices.
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: AppColors.of(context).brandLink,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.onboarding_updateNoticeTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l10n.onboarding_updateNoticeBody,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.extension,
                    size: 16,
                    color: colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.onboarding_updateNoticeExtensions,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 16,
                    color: colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.onboarding_updateNoticeSettingsPreserved,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EulaCheckbox extends StatelessWidget {
  final bool accepted;
  final ValueChanged<bool> onAcceptedChanged;

  const _EulaCheckbox({
    required this.accepted,
    required this.onAcceptedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return CheckboxListTile.adaptive(
      // Lined up with the restore card below, whose content sits 17 dp in
      // (1 dp border + 16 dp padding) on both sides: the 40 dp checkbox is
      // centered on the card's 24 dp icon (17 - 8 = 9), and the text starts
      // where the card's title does (9 + 40 + 8 = 17 + 24 + 16).
      contentPadding: const EdgeInsetsDirectional.only(start: 9, end: 17),
      horizontalTitleGap: 8,
      value: accepted,
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (value) => onAcceptedChanged(value ?? false),
      title: Text.rich(
        TextSpan(
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          children: localizedSpans(
            l10n.onboarding_eulaAcceptance,
            tags: {
              'eula': (text) => _legalDocumentLink(
                context,
                label: text,
                title: l10n.onboarding_eulaDocumentTitle,
                assetPath: 'assets/legal/EULA.md',
              ),
              'privacy': (text) => _legalDocumentLink(
                context,
                label: text,
                title: l10n.onboarding_privacyPolicy,
                assetPath: 'assets/legal/PRIVACY_POLICY.md',
              ),
            },
          ),
        ),
      ),
    );
  }

  InlineSpan _legalDocumentLink(
    BuildContext context, {
    required String label,
    required String title,
    required String assetPath,
  }) {
    final linkColor = AppColors.of(context).brandLink;

    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: GestureDetector(
        onTap: () =>
            _showLegalDocument(context, title: title, assetPath: assetPath),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: linkColor,
            decoration: TextDecoration.underline,
            decorationColor: linkColor,
          ),
        ),
      ),
    );
  }

  Future<void> _showLegalDocument(
    BuildContext context, {
    required String title,
    required String assetPath,
  }) async {
    final content = await rootBundle.loadString(assetPath);

    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => PointerScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: FadingScroll(
                controller: scrollController,
                fadingSize: 25,
                builder: (context, controller) {
                  return Markdown(controller: controller, data: content);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
