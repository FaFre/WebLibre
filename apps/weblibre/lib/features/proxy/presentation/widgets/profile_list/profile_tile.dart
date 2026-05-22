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
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/proxy/data/models/proxy_share.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/extensions/singbox_proxy_profile_type_x.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_credentials.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/proxy/domain/services/proxy_latency_tester.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_list/menu_row.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_list/profile_subtitle.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_list/protocol_badge.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_list/run_switch.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_list/share_profile_dialog.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ProxyProfile;
import 'package:weblibre/utils/ui_helper.dart';

enum ProfileAction { edit, testLatency, share, delete }

class ProfileTile extends ConsumerWidget {
  final ProxyProfile profile;
  final bool isRunning;
  final bool isDeleting;
  final bool runtimeBusy;
  final void Function(String profileId, bool deleting) onDeletingChanged;

  const ProfileTile({
    super.key,
    required this.profile,
    required this.isRunning,
    required this.isDeleting,
    required this.runtimeBusy,
    required this.onDeletingChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = runtimeBusy || isDeleting;
    final latencyResult = ref.watch(
      proxyLatencyResultsProvider.select(
        (map) => map[SingboxProxyConnectionId(profile.id)],
      ),
    );

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: isDeleting
          ? const SizedBox.square(
              dimension: 36,
              child: Padding(
                padding: EdgeInsets.all(6),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : ProtocolBadge(type: profile.type, active: isRunning),
      title: Text(
        profile.name,
        style: TextStyle(
          fontWeight: isRunning ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      subtitle: ProfileSubtitle(
        typeLabel: profile.type.label,
        latency: latencyResult,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PopupMenuButton<ProfileAction>(
            enabled: !isBusy,
            onSelected: (action) => _onAction(context, ref, action),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ProfileAction.edit,
                child: MenuRow(icon: Icons.edit_outlined, label: 'Edit'),
              ),
              PopupMenuItem(
                value: ProfileAction.testLatency,
                enabled: isRunning,
                child: MenuRow(
                  icon: latencyResult is AsyncLoading
                      ? Icons.hourglass_bottom
                      : Icons.network_check,
                  label: 'Test connection',
                ),
              ),
              const PopupMenuItem(
                value: ProfileAction.share,
                child: MenuRow(icon: Icons.share_outlined, label: 'Share'),
              ),
              const PopupMenuItem(
                value: ProfileAction.delete,
                child: MenuRow(icon: Icons.delete_outline, label: 'Delete'),
              ),
            ],
          ),
          RunSwitch(
            isRunning: isRunning,
            disabled: isBusy,
            onTap: () => _toggleRunState(context, ref),
          ),
        ],
      ),
      onTap: () =>
          SingboxProxyProfileEditorRoute(profileId: profile.id).push(context),
    );
  }

  Future<void> _toggleRunState(BuildContext context, WidgetRef ref) async {
    try {
      final notifier = ref.read(singboxProxyRuntimeRepositoryProvider.notifier);
      if (isRunning) {
        await notifier.stopProfiles([profile.id]);
        ref
            .read(proxyLatencyResultsProvider.notifier)
            .clear(SingboxProxyConnectionId(profile.id));
      } else {
        await notifier.startProfile(profile.id);
      }
    } catch (error, stackTrace) {
      logger.e(
        'Failed to toggle singbox proxy run state for ${profile.id}',
        error: error,
        stackTrace: stackTrace,
      );
      if (context.mounted) {
        showErrorMessage(
          context,
          isRunning
              ? 'Failed to stop proxy: $error'
              : 'Failed to start proxy: $error',
        );
      }
    }
  }

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    ProfileAction action,
  ) async {
    switch (action) {
      case ProfileAction.edit:
        await _handleEdit(context);
      case ProfileAction.testLatency:
        await _handleTestLatency(ref);
      case ProfileAction.share:
        await _handleShare(context, ref);
      case ProfileAction.delete:
        await _handleDelete(context, ref);
    }
  }

  Future<void> _handleEdit(BuildContext context) {
    return SingboxProxyProfileEditorRoute(profileId: profile.id).push(context);
  }

  Future<void> _handleTestLatency(WidgetRef ref) {
    return ref.read(proxyLatencyResultsProvider.notifier).test(profile.id);
  }

  Future<void> _handleShare(BuildContext context, WidgetRef ref) async {
    final secret = await ref
        .read(singboxProxyCredentialsRepositoryProvider.notifier)
        .readSecretJson(profile.id);
    final shareUri = encodeProxyShareUri(
      ProxyShareEnvelope(
        name: profile.name,
        type: profile.type,
        configJson: profile.configJson,
        secretJson: secret,
        dnsOverrideJson: profile.dnsOverrideJson,
      ),
    );
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) =>
          ShareProfileDialog(profileName: profile.name, shareUri: shareUri),
    );
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile?'),
        content: Text(
          isRunning
              ? 'Stop ${profile.name}, then delete it and its stored secrets? Tabs and containers assigned to this profile will be blocked until you choose another proxy or clear the assignment.'
              : 'Delete ${profile.name} and its stored secrets? Tabs and containers assigned to this profile will be blocked until you choose another proxy or clear the assignment.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(isRunning ? 'Stop and Delete' : 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    onDeletingChanged(profile.id, true);
    try {
      await ref
          .read(singboxProxyRuntimeRepositoryProvider.notifier)
          .deleteProfile(profile.id);
      ref
          .read(proxyLatencyResultsProvider.notifier)
          .clear(SingboxProxyConnectionId(profile.id));
    } catch (error, stackTrace) {
      logger.e(
        'Failed to delete singbox proxy profile ${profile.id}',
        error: error,
        stackTrace: stackTrace,
      );
      if (context.mounted) {
        showErrorMessage(context, 'Failed to delete profile: $error');
      }
    } finally {
      if (context.mounted) onDeletingChanged(profile.id, false);
    }
  }
}
