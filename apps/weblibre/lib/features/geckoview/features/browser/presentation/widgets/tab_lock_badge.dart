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
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/tab_badge_frame.dart';

/// The lock glyph on a tab that cannot be closed until it is unlocked (tab
/// tray, tab tree, quick switcher). Takes no space for any other tab.
///
/// A tab whose unlock did not finish keeps it, with a warning sign: it is
/// still locked. An outlined padlock, so it is told apart from the filled one
/// of the address bar's security indicator and of the profile lock.
class TabLockBadge extends HookConsumerWidget {
  final String tabId;
  final double size;
  final EdgeInsetsGeometry padding;
  final bool withBackground;

  const TabLockBadge({
    required this.tabId,
    this.size = 14,
    this.padding = EdgeInsets.zero,
    this.withBackground = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLocked = ref.watch(isTabLockedProvider(tabId));
    final unlockIncomplete = ref.watch(isTabUnlockIncompleteProvider(tabId));
    if (!isLocked) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final icon = Icon(
      unlockIncomplete ? MdiIcons.lockAlertOutline : MdiIcons.lockOutline,
      size: size,
      color: unlockIncomplete ? colorScheme.error : colorScheme.primary,
      semanticLabel: unlockIncomplete
          ? l10n.browser_tabUnlockIncompleteLabel
          : l10n.browser_tabLockedLabel,
    );

    return TabBadgeFrame(
      padding: padding,
      withBackground: withBackground,
      child: icon,
    );
  }
}
