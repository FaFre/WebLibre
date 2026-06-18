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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/providers/persisted_bool.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/account/domain/repositories/account_auth.dart';
import 'package:weblibre/features/account/domain/repositories/subscription_repository.dart';

/// Promotional banner shown above the quote card on the browser home page,
/// inviting non-subscribers to become a WebLibre Supporter.
///
/// It hides itself when the user already has an active subscription or has
/// dismissed it. Includes its own bottom spacing so the host layout doesn't
/// leave a gap when the banner is absent.
class SupporterHomeBanner extends ConsumerWidget {
  const SupporterHomeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dismissed = ref.watch(
      persistedBoolProvider(PersistedBoolKey.supporterBannerDismissed),
    );

    // Only nudge people who aren't already supporting, and only once we have a
    // definitive answer. The subscription provider reports `inactive` while the
    // account session is still being restored from the secure store, so gating
    // on it alone would flash the banner at a subscriber until auth settles.
    // We therefore wait for auth to resolve first:
    //  - still loading / signing in / error  -> stay hidden
    //  - signed out                          -> definitely no subscription
    //  - signed in                           -> wait for subscription status
    final authAsync = ref.watch(accountAuthRepositoryProvider);
    final subscriptionAsync = ref.watch(subscriptionRepositoryProvider);

    final shouldShow =
        // In debug builds, bypass the subscriber/auth auto-hide so the banner
        // is always available to work on regardless of account state.
        kDebugMode ||
        switch (authAsync) {
          AsyncData(value: final auth) when auth.isSignedOut => true,
          AsyncData(value: final auth) when auth.isSignedIn =>
            subscriptionAsync.maybeWhen(
              data: (status) => !status.isActive,
              orElse: () => false,
            ),
          _ => false,
        };

    if (dismissed || !shouldShow) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    void dismiss() {
      ref
          .read(
            persistedBoolProvider(
              PersistedBoolKey.supporterBannerDismissed,
            ).notifier,
          )
          .set(true);
    }

    Future<void> openAccount() {
      return AccountSettingsRoute().push(context);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.alphaBlend(
                AppColors.brandPurple.withValues(alpha: 0.16),
                colorScheme.surfaceContainerHigh,
              ),
              colorScheme.surfaceContainer.withValues(alpha: 0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.brandPurple.withValues(alpha: 0.45),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.brandPurple.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    MdiIcons.heartOutline,
                    size: 18,
                    color: AppColors.brandPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Support WebLibre, unlock premium features',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _DismissButton(onPressed: dismiss),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Help fund our independent browser by becoming a Supporter and '
              'unlock:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            const _FeatureBullet(
              label: 'Anonymous Premium Search',
              description:
                  'Cryptographically blinded tokens — with optional Tor '
                  'routing — keep your queries unlinkable to your account.',
            ),
            const SizedBox(height: 8),
            const _FeatureBullet(
              label: 'Encrypted Sync',
              description:
                  'Securely sync your settings and preferences across profiles '
                  'and devices.',
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: openAccount,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandPurple,
                  foregroundColor: colorScheme.surface,
                ),
                icon: const Icon(MdiIcons.heart, size: 18),
                label: const Text('Become a Supporter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  final String label;
  final String description;

  const _FeatureBullet({required this.label, required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final baseStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
      height: 1.4,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 7),
          child: Icon(Icons.circle, size: 6, color: AppColors.brandPurple),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: baseStyle?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: description, style: baseStyle),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DismissButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _DismissButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Dismiss',
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      iconSize: 18,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      icon: const Icon(Icons.close_rounded),
    );
  }
}
