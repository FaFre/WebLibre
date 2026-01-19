/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/repositories/tracking_protection.dart';
import 'package:weblibre/features/settings/presentation/dialogs/delete_all_exceptions_dialog.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// Screen to view and manage tracking protection exceptions
///
/// Shows list of all sites where ETP is disabled, with options
/// to remove individual exceptions or remove all exceptions.
class TrackingProtectionExceptionsScreen extends HookConsumerWidget {
  const TrackingProtectionExceptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exceptionsAsync = ref.watch(trackingProtectionRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking Protection Exceptions'),
        actions: [
          exceptionsAsync.maybeWhen(
            data: (exceptions) => exceptions.isNotEmpty
                ? MenuAnchor(
                    builder: (context, controller, child) => IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      },
                    ),
                    menuChildren: [
                      MenuItemButton(
                        leadingIcon: const Icon(Icons.delete_sweep),
                        onPressed: () => _showDeleteAllDialog(context, ref),
                        child: const Text('Delete All'),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: exceptionsAsync.when(
        data: (exceptions) {
          if (exceptions.isEmpty) {
            return const _EmptyState();
          }

          return ListView.builder(
            itemCount: exceptions.length,
            itemBuilder: (context, index) {
              final exception = exceptions[index];
              return _ExceptionTile(
                exception: exception,
                onDelete: () => _deleteException(context, ref, exception),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorState(error: error.toString()),
      ),
    );
  }

  Future<void> _showDeleteAllDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDeleteAllExceptionsDialog(context);

    if (confirmed == true) {
      try {
        await ref
            .read(trackingProtectionRepositoryProvider.notifier)
            .removeAllExceptions();
      } catch (e) {
        if (context.mounted) {
          showErrorMessage(context, 'Failed to delete exceptions: $e');
        }
      }
    }
  }

  Future<void> _deleteException(
    BuildContext context,
    WidgetRef ref,
    TrackingProtectionException exception,
  ) async {
    try {
      await ref
          .read(trackingProtectionRepositoryProvider.notifier)
          .removeExceptionByUrl(exception.url);
    } catch (e) {
      if (context.mounted) {
        showErrorMessage(context, 'Failed to remove exception: $e');
      }
    }
  }
}

class _ExceptionTile extends StatelessWidget {
  final TrackingProtectionException exception;
  final VoidCallback onDelete;

  const _ExceptionTile({required this.exception, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(exception.url);

    return ListTile(
      leading: uri != null
          ? UrlIcon([uri], iconSize: 24)
          : const Icon(MdiIcons.shieldOutline),
      title: Text(exception.url),
      trailing: IconButton(
        icon: const Icon(Icons.close),
        onPressed: onDelete,
        tooltip: 'Remove exception',
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text('No exceptions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Sites added to exceptions will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64),
          const SizedBox(height: 16),
          Text(
            'Error loading exceptions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
