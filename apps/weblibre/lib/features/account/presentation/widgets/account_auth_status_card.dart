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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/features/account/data/account_adoption.dart';
import 'package:weblibre/features/account/data/account_adoption_provider.dart';
import 'package:weblibre/features/account/data/models/account_auth_state.dart';
import 'package:weblibre/features/account/domain/repositories/account_auth.dart';
import 'package:weblibre/features/account/presentation/utils/account_auth_error_l10n.dart';
import 'package:weblibre/features/account/presentation/utils/unclaimed_account_record_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Body of the "Account" settings entry. Renders the auth state machine:
/// signed-out CTA, signing-in spinner with cancel, signed-in identity with
/// sign-out + sync-key reset, or an error tile with retry.
class AccountAuthStatusCard extends ConsumerWidget {
  const AccountAuthStatusCard({super.key, required this.authState});

  final AccountAuthState authState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (authState.status) {
      AccountAuthStatus.signedOut => _SignedOutSection(authState: authState),
      AccountAuthStatus.signingIn => const _SigningInTile(),
      AccountAuthStatus.signedIn => _SignedInTile(authState: authState),
      AccountAuthStatus.error => _ErrorTile(authState: authState),
    };
  }
}

/// Signed out — but possibly only because the upgrade could not tell which
/// profile the existing session belonged to.
///
/// Qualifying secure-storage keys by profile fixed a real isolation defect (one
/// session was shared by every profile), and the cost was that the pre-existing
/// record has no owner. Nothing on the device records which profile it was for.
/// Rather than guess, or discard it and call that a migration, the session is
/// offered back here by name — the user is the only party who knows.
class _SignedOutSection extends ConsumerWidget {
  const _SignedOutSection({required this.authState});

  final AccountAuthState authState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unclaimed = ref.watch(unclaimedAccountRecordProvider).value;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (unclaimed != null) _AdoptAccountTile(record: unclaimed),
        _SignedOutTile(knownAccount: authState.email ?? authState.displayName),
      ],
    );
  }
}

class _AdoptAccountTile extends ConsumerWidget {
  const _AdoptAccountTile({required this.record});

  final UnclaimedAccountRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    // Watched, not read: the controller is what says whether the answer is
    // still being carried out, and both buttons stay inert-looking without it.
    final adoption = ref.watch(accountAdoptionProvider);
    final busy = adoption.isLoading;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_search_outlined,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    record.isUsable
                        ? l10n.account_adoptTitleUsable
                        : l10n.account_adoptTitleUnusable,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              record.isUsable
                  // Says where it came from, because the moment this card is
                  // most likely to be seen is straight after a restore — and it
                  // has nothing to do with the archive. A restore into a new
                  // profile deliberately leaves the archive's account behind, so
                  // reading this as "your backed-up account" would be exactly
                  // wrong.
                  ? l10n.account_adoptBodyUsable(record.label(context))
                  : l10n.account_adoptBodyUnusable,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            if (adoption.hasError) ...[
              const SizedBox(height: 12),
              Text(
                l10n.account_adoptRetryError,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: busy
                      ? null
                      : () async {
                          final confirmed = await _confirmDiscard(
                            context,
                            record,
                          );
                          if (confirmed != true) return;
                          // The dialog is an async gap, and this `ref` belongs
                          // to the widget: using it after the settings screen
                          // has gone throws. The controller itself is keepAlive,
                          // so a discard already under way is unaffected.
                          if (!context.mounted) return;
                          await ref
                              .read(accountAdoptionProvider.notifier)
                              .discard(record);
                        },
                  child: Text(
                    record.isUsable
                        ? l10n.account_adoptNotMine
                        : l10n.account_adoptRemoveIt,
                  ),
                ),
                if (record.isUsable) ...[
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: busy
                        ? null
                        : () async {
                            await ref
                                .read(accountAdoptionProvider.notifier)
                                .adopt(record);
                          },
                    child: busy
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.account_adoptUseItHere),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Confirmed, because it is the only irreversible half of the choice.
///
/// "Use it here" can be undone by signing out; discarding destroys the only copy
/// of a session that may belong to another profile the user has not opened yet.
Future<bool?> _confirmDiscard(
  BuildContext context,
  UnclaimedAccountRecord record,
) => showDialog<bool>(
  context: context,
  anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
  builder: (context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.account_forgetSignInTitle),
      content: Text(l10n.account_forgetSignInContent(record.label(context))),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.common_cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.account_actionForgetIt),
        ),
      ],
    );
  },
);

class _SignedOutTile extends ConsumerWidget {
  const _SignedOutTile({this.knownAccount});

  /// The account this profile was last signed in as, when the stored record
  /// still says. Present after a session expired or was revoked — including the
  /// common case of restoring a backup old enough that its refresh token no
  /// longer works — where "Sign in" alone leaves the user guessing which account
  /// the restore was supposed to bring back.
  final String? knownAccount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: const Icon(Icons.login),
      title: Text(
        knownAccount == null
            ? l10n.account_signInTitle
            : l10n.account_signInAgainAs(knownAccount!),
      ),
      subtitle: Text(
        knownAccount == null
            ? l10n.account_syncAcrossDevicesSubtitle
            : l10n.account_signInExpiredSubtitle,
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await ref.read(accountAuthRepositoryProvider.notifier).startSignIn();
      },
    );
  }
}

class _SigningInTile extends ConsumerWidget {
  const _SigningInTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(l10n.account_signingInEllipsis),
          const SizedBox(height: 8),
          Text(
            l10n.account_completeSignInInApp,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () async {
              await ref
                  .read(accountAuthRepositoryProvider.notifier)
                  .cancelSignIn();
            },
            child: Text(l10n.common_cancel),
          ),
        ],
      ),
    );
  }
}

class _SignedInTile extends ConsumerWidget {
  const _SignedInTile({required this.authState});

  final AccountAuthState authState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.account_circle),
          title: Text(
            authState.displayName ??
                authState.email ??
                l10n.account_signedInFallback,
          ),
          subtitle:
              authState.email != null &&
                  authState.email != authState.displayName
              ? Text(authState.email!)
              : null,
          trailing: IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.account_tooltipSignOut,
            onPressed: () async {
              final confirmed = await _showSignOutConfirmation(context);
              if (confirmed == true) {
                await ref
                    .read(accountAuthRepositoryProvider.notifier)
                    .signOut();
              }
            },
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ),
        ),
        if (authState.hasSyncKey) ...[
          const Divider(height: 1),
          const _ResetSyncKeyTile(),
        ],
      ],
    );
  }

  static Future<bool?> _showSignOutConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
      builder: (context) {
        final l10n = AppLocalizations.of(context);

        return AlertDialog(
          title: Text(l10n.account_signOutConfirmTitle),
          content: Text(l10n.account_signOutConfirmContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.common_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.account_actionSignOut),
            ),
          ],
        );
      },
    );
  }
}

class _ErrorTile extends ConsumerWidget {
  const _ErrorTile({required this.authState});

  final AccountAuthState authState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // A session that expired under a known account is a different
                // situation from a sign-in that failed, and saying "Sign-in
                // failed" over a restored profile reads as though the restore
                // itself went wrong.
                authState.email == null
                    ? l10n.account_signInFailedTitle
                    : l10n.account_signInAgainAs(authState.email!),
                style: TextStyle(
                  color: colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (authState.lastError != null) ...[
                const SizedBox(height: 8),
                Text(
                  authState.lastError!.describe(AppLocalizations.of(context)),
                  style: TextStyle(color: colorScheme.onErrorContainer),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () async {
                  await ref
                      .read(accountAuthRepositoryProvider.notifier)
                      .startSignIn();
                },
                child: Text(l10n.account_actionTryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResetSyncKeyTile extends ConsumerWidget {
  const _ResetSyncKeyTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: const Icon(Icons.key_off_outlined),
      title: Text(l10n.account_resetSyncKeyTitle),
      subtitle: Text(l10n.account_resetSyncKeySubtitle),
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
          builder: (context) {
            final l10n = AppLocalizations.of(context);

            return AlertDialog(
              title: Text(l10n.account_resetSyncKeyTitle),
              content: Text(l10n.account_resetSyncKeyConfirmContent),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.common_cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l10n.common_reset),
                ),
              ],
            );
          },
        );
        if (confirmed == true) {
          await ref.read(accountAuthRepositoryProvider.notifier).clearSyncKey();
        }
      },
    );
  }
}
