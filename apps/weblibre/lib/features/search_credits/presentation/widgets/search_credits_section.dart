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
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:weblibre/features/account/data/supabase_config.dart';
import 'package:weblibre/features/search_credits/domain/controllers/search_token_issuance_controller.dart';
import 'package:weblibre/features/search_credits/domain/repositories/search_credits_repository.dart';
import 'package:weblibre/features/search_credits/domain/repositories/search_token_stash_repository.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_content_card.dart';

class SearchCreditsSection extends HookConsumerWidget {
  final bool embedded;

  const SearchCreditsSection({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final creditsAsync = ref.watch(searchCreditsRepositoryProvider);
    final stashAsync = ref.watch(searchTokenStashCountProvider);
    final issuance = ref.watch(searchTokenIssuanceControllerProvider);

    // Refresh the credits balance whenever the app returns to the
    // foreground. `launchUrl` for the checkout flow returns immediately,
    // long before the purchase completes, so refreshing right after the
    // tap would just re-read a stale 0. The user coming back into the
    // app is the signal that something may have changed.
    useOnAppLifecycleStateChange((previous, current) async {
      if (current == AppLifecycleState.resumed) {
        await ref.read(searchCreditsRepositoryProvider.notifier).refresh();
      }
    });

    final creditsValue = creditsAsync.value;
    final creditsError = creditsAsync.hasError && !creditsAsync.isLoading;
    final credits = creditsValue?.availableCredits ?? 0;
    final monthlyAllowance = creditsValue?.monthlyAllowance ?? 0;
    final stash = stashAsync.value ?? 0;
    final lastIssuanceAt = creditsValue?.lastIssuanceAt;
    final currentPeriodEnd = creditsValue?.currentPeriodEnd;

    final isRequesting = issuance is SearchTokenIssuanceRequesting;
    final canIssue =
        credits > 0 &&
        (issuance is SearchTokenIssuanceIdle ||
            issuance is SearchTokenIssuanceFailed);

    Future<void> openBuyMore() async {
      final uri = Uri.parse('${SupabaseConfig.accountWebUrl}?view=search-pack');
      // No refresh here — launchUrl returns as soon as the browser opens,
      // not when the user finishes checkout. The app-lifecycle listener
      // above handles the refresh on return.
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    }

    Future<void> onIssue() async {
      final count = min(25, credits);
      await ref
          .read(searchTokenIssuanceControllerProvider.notifier)
          .issue(count: count);
    }

    final isEmpty = credits == 0 && stash == 0;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: Icon(
            creditsError ? Icons.error_outline : Icons.search,
            color: creditsError
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
          ),
          title: Text(
            creditsError ? 'Could not load credits' : 'Search credits',
          ),
          subtitle: creditsError
              ? const Text('Check your connection and tap refresh to retry.')
              : isEmpty
              ? const Text('Buy a search pack to get started')
              : Text(
                  monthlyAllowance > 0
                      ? 'Credits: $credits / $monthlyAllowance  ·  '
                            'Stashed tokens: $stash'
                      : 'Credits: $credits  ·  Stashed tokens: $stash',
                ),
          trailing: IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () async {
              await ref
                  .read(searchCreditsRepositoryProvider.notifier)
                  .refresh();
            },
          ),
        ),
        if (currentPeriodEnd != null && monthlyAllowance > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              'Resets on '
              '${DateFormat.yMMMd().format(currentPeriodEnd.toLocal())}',
              style: theme.textTheme.bodySmall,
            ),
          ),
        if (lastIssuanceAt != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Last issuance: ${timeago.format(lastIssuanceAt)}  '
              '(${DateFormat.yMMMd().add_Hm().format(lastIssuanceAt.toLocal())})',
              style: theme.textTheme.bodySmall,
            ),
          ),
        if (isRequesting)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Requesting tokens...'),
              ],
            ),
          ),
        if (issuance is SearchTokenIssuanceFailed)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              'Token issuance failed: ${issuance.error}',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        if (issuance is SearchTokenIssuanceNeedsReauth)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              'Please sign in again to request tokens.',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        const Divider(height: 1),
        if (isEmpty)
          ListTile(
            leading: const Icon(Icons.shopping_cart_outlined),
            title: const Text('Buy a search pack'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            onTap: openBuyMore,
          )
        else ...[
          ListTile(
            leading: const Icon(Icons.download_for_offline_outlined),
            enabled: canIssue,
            title: const Text('Get tokens'),
            subtitle: credits > 0
                ? Text('Request ${min(25, credits)} tokens')
                : const Text('No credits remaining'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            onTap: canIssue ? onIssue : null,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.shopping_cart_outlined),
            title: const Text('Buy more'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            onTap: openBuyMore,
          ),
        ],
      ],
    );

    return SettingsContentCard(embedded: embedded, child: content);
  }
}
