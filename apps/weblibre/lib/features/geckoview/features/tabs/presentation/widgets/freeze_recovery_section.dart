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
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/container_freeze.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// "Restoring frozen containers" at the top of the containers screen while
/// native is in recovery mode (D23, 5.6): every container with its own
/// storage stays frozen until it is restored, and Resume is refused, so this
/// says why. After an attempt that did not finish, it offers Retry. A
/// sliver; nothing outside recovery mode.
class FreezeRecoverySection extends HookConsumerWidget {
  const FreezeRecoverySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recovery = ref.watch(freezeRecoveryModeProvider);
    final status = ref.watch(freezeRecoveryProgressProvider);
    if (!recovery) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final l10n = AppLocalizations.of(context);
    final failed = status == FreezeRecoveryStatus.failed;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      sliver: SliverToBoxAdapter(
        child: Card.filled(
          margin: EdgeInsets.zero,
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ListTile(
                  leading: const Icon(MdiIcons.pause),
                  title: Text(
                    l10n.tabs_freezeRecoveryTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    failed
                        ? l10n.tabs_freezeRecoveryFailed
                        : l10n.tabs_freezeRecoveryRestoring,
                  ),
                ),
                if (failed)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextButton(
                      onPressed: () => ref
                          .read(containerFreezeServiceProvider.notifier)
                          .retryRecovery(),
                      child: Text(l10n.common_retry),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
