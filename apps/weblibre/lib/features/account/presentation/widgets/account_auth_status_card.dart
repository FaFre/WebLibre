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
import 'package:weblibre/features/account/data/models/account_auth_state.dart';
import 'package:weblibre/features/account/domain/repositories/account_auth.dart';

/// Body of the "Account" settings entry. Renders the auth state machine:
/// signed-out CTA, signing-in spinner with cancel, signed-in identity with
/// sign-out + sync-key reset, or an error tile with retry.
class AccountAuthStatusCard extends ConsumerWidget {
  const AccountAuthStatusCard({super.key, required this.authState});

  final AccountAuthState authState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (authState.status) {
      AccountAuthStatus.signedOut => const _SignedOutTile(),
      AccountAuthStatus.signingIn => const _SigningInTile(),
      AccountAuthStatus.signedIn => _SignedInTile(authState: authState),
      AccountAuthStatus.error => _ErrorTile(authState: authState),
    };
  }
}

class _SignedOutTile extends ConsumerWidget {
  const _SignedOutTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.login),
      title: const Text('Sign in to WebLibre Account'),
      subtitle: const Text('Sync your settings across devices'),
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
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          const Text('Signing in...'),
          const SizedBox(height: 8),
          Text(
            'Complete sign-in in WebLibre',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () async {
              await ref
                  .read(accountAuthRepositoryProvider.notifier)
                  .cancelSignIn();
            },
            child: const Text('Cancel'),
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
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.account_circle),
          title: Text(authState.displayName ?? authState.email ?? 'Signed in'),
          subtitle:
              authState.email != null &&
                  authState.email != authState.displayName
              ? Text(authState.email!)
              : null,
          trailing: IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
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
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign out?'),
          content: const Text(
            'Are you sure you want to sign out of your WebLibre Account?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sign Out'),
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
                'Sign-in failed',
                style: TextStyle(
                  color: colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (authState.lastError != null) ...[
                const SizedBox(height: 8),
                Text(
                  authState.lastError!,
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
                child: const Text('Try Again'),
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
    return ListTile(
      leading: const Icon(Icons.key_off_outlined),
      title: const Text('Reset Sync Key'),
      subtitle: const Text(
        'Re-enter your password if you mistyped it or changed it',
      ),
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reset Sync Key'),
            content: const Text(
              'You will need to re-enter your account password. '
              'If your password changed, existing snapshots '
              'encrypted with the old password will no longer '
              'be decryptable.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Reset'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await ref.read(accountAuthRepositoryProvider.notifier).clearSyncKey();
        }
      },
    );
  }
}
