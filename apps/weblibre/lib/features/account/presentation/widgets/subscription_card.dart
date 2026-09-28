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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weblibre/features/account/data/models/subscription_status.dart';
import 'package:weblibre/features/account/data/supabase_config.dart';
import 'package:weblibre/features/account/domain/repositories/subscription_repository.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Visual presentation of one subscription state. All branches of the
/// subscription UI render through the same ListTile + badge + note + manage
/// button structure — the differences boil down to these fields, which the
/// state machine selects in `_resolvePresentation`.
class _SubscriptionPresentation {
  final IconData leadingIcon;
  final Color? leadingIconColor;
  final String planTitle;
  final String badgeLabel;
  final Color badgeColor;
  final Color badgeTextColor;
  final String? note;
  final Color? noteColor;
  final String manageLabel;
  final String? subtitle;
  final DateTime? expiryHint;

  const _SubscriptionPresentation({
    required this.leadingIcon,
    required this.planTitle,
    required this.badgeLabel,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.manageLabel,
    this.leadingIconColor,
    this.note,
    this.noteColor,
    this.subtitle,
    this.expiryHint,
  });
}

class SubscriptionCard extends HookConsumerWidget {
  const SubscriptionCard({super.key, required this.subscriptionAsync});

  final AsyncValue<SubscriptionStatus> subscriptionAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Refresh on resume regardless of which branch is currently rendered.
    // Keeping the hook at the top level means a stale error tile (e.g. the
    // user opened the screen offline, then reconnected and returned to the
    // app) still gets a fresh fetch — previously the hook only ran in the
    // `data` branch and never fired from the error state.
    useOnAppLifecycleStateChange((previous, current) async {
      if (current == AppLifecycleState.resumed) {
        await ref.read(subscriptionRepositoryProvider.notifier).refresh();
      }
    });

    return subscriptionAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      // Render a dedicated error tile so the user can tell "fetch failed"
      // apart from "no subscription" — they have different fixes (retry
      // vs. subscribe).
      error: (_, _) => _SubscriptionErrorTile(
        onRetry: () =>
            ref.read(subscriptionRepositoryProvider.notifier).refresh(),
      ),
      data: (status) {
        final presentation = _resolvePresentation(context, status);
        return _SubscriptionStateBody(presentation: presentation);
      },
    );
  }
}

class _SubscriptionErrorTile extends StatelessWidget {
  const _SubscriptionErrorTile({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: Icon(Icons.error_outline, color: scheme.error),
      title: Text(l10n.account_subscriptionLoadFailed),
      subtitle: Text(l10n.account_checkConnectionRetry),
      trailing: IconButton(
        icon: const Icon(Icons.refresh),
        tooltip: l10n.common_retry,
        onPressed: onRetry,
      ),
    );
  }
}

_SubscriptionPresentation _resolvePresentation(
  BuildContext context,
  SubscriptionStatus status,
) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;
  final l10n = AppLocalizations.of(context);
  final planTitle = status.planLabel ?? l10n.account_planFallbackSupporter;

  if (status.isActive) {
    final isWindingDown = status.isWindingDown;
    final endDate = status.currentPeriodEnd ?? status.entitledUntil;
    return _SubscriptionPresentation(
      leadingIcon: Icons.verified,
      leadingIconColor: scheme.primary,
      planTitle: planTitle,
      badgeLabel: isWindingDown
          ? l10n.account_badgeWillNotRenew
          : l10n.account_badgeActive,
      badgeColor: isWindingDown
          ? scheme.surfaceContainerHighest
          : scheme.primaryContainer,
      badgeTextColor: isWindingDown
          ? scheme.onSurface
          : scheme.onPrimaryContainer,
      subtitle: status.entitledUntil != null
          ? l10n.account_untilDate(_formatDate(status.entitledUntil!))
          : null,
      expiryHint: isWindingDown ? endDate : null,
      manageLabel: l10n.account_actionManageSubscription,
    );
  }
  if (status.isPaused) {
    return _SubscriptionPresentation(
      leadingIcon: Icons.pause_circle_outline,
      leadingIconColor: scheme.onSurfaceVariant,
      planTitle: planTitle,
      badgeLabel: l10n.account_badgePaused,
      badgeColor: scheme.tertiaryContainer,
      badgeTextColor: scheme.onTertiaryContainer,
      note: l10n.account_pausedNote,
      noteColor: scheme.onSurfaceVariant,
      manageLabel: l10n.account_actionManageSubscription,
    );
  }
  if (status.isPastDue) {
    return _SubscriptionPresentation(
      leadingIcon: Icons.error_outline,
      leadingIconColor: scheme.onSurfaceVariant,
      planTitle: planTitle,
      badgeLabel: l10n.account_badgePastDue,
      badgeColor: scheme.errorContainer,
      badgeTextColor: scheme.onErrorContainer,
      note: l10n.account_pastDueNote,
      noteColor: scheme.error,
      manageLabel: l10n.account_actionUpdatePaymentMethod,
    );
  }
  if (status.isWindingDown) {
    // No active entitlement remains (isActive was false above) — the
    // grace period has ended or there never was one. Offer renewal.
    return _SubscriptionPresentation(
      leadingIcon: Icons.history_toggle_off,
      leadingIconColor: scheme.onSurfaceVariant,
      planTitle: planTitle,
      badgeLabel: l10n.account_badgeWillNotRenew,
      badgeColor: scheme.surfaceContainerHighest,
      badgeTextColor: scheme.onSurface,
      note: l10n.account_endedNote,
      noteColor: scheme.onSurfaceVariant,
      manageLabel: l10n.account_actionRenewSubscription,
    );
  }
  return _inactivePresentation(context);
}

_SubscriptionPresentation _inactivePresentation(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  final l10n = AppLocalizations.of(context);
  return _SubscriptionPresentation(
    leadingIcon: Icons.card_membership,
    leadingIconColor: scheme.onSurfaceVariant,
    planTitle: l10n.account_planSupporterSubscription,
    subtitle: l10n.account_subscribeSubtitle,
    badgeLabel: l10n.account_badgeInactive,
    badgeColor: scheme.surfaceContainerHighest,
    badgeTextColor: scheme.onSurface,
    manageLabel: l10n.account_actionSubscribe,
  );
}

String _formatDate(DateTime date) => DateFormat.yMMMd().format(date);

class _SubscriptionStateBody extends ConsumerWidget {
  const _SubscriptionStateBody({required this.presentation});

  final _SubscriptionPresentation presentation;

  Future<void> _openPortal() async {
    await launchUrl(
      Uri.parse(SupabaseConfig.accountWebUrl),
      mode: LaunchMode.inAppBrowserView,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        ListTile(
          leading: Icon(
            presentation.leadingIcon,
            color: presentation.leadingIconColor,
          ),
          title: Row(
            children: [
              Text(presentation.planTitle),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: presentation.badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  presentation.badgeLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: presentation.badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          subtitle: presentation.subtitle != null
              ? Text(presentation.subtitle!)
              : null,
          trailing: IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.account_tooltipRefreshStatus,
            onPressed: () async {
              await ref.read(subscriptionRepositoryProvider.notifier).refresh();
            },
          ),
        ),
        if (presentation.expiryHint != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Icon(Icons.warning_amber, size: 16, color: scheme.error),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    l10n.account_subscriptionEndsOn(
                      _formatDate(presentation.expiryHint!),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (presentation.note != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              presentation.note!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: presentation.noteColor,
              ),
            ),
          ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.open_in_new),
          title: Text(presentation.manageLabel),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          onTap: _openPortal,
        ),
      ],
    );
  }
}
