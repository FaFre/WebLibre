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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/core/providers/provider_read.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/protected_activity_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// What a row of the freeze blocker list does when tapped.
enum FreezeBlockerAction { showTab, viewDownloads }

/// Lists what kept a container from freezing ([blockers]): each tab with its
/// reason and Show tab, each download with View downloads. Returns the
/// chosen action with the blocker's tab, or null when closed.
Future<(FreezeBlockerAction, String?)?> showFreezeBlockersDialog(
  BuildContext context,
  ProviderRead read,
  List<FreezeBlocker> blockers,
) {
  final tabs = read(tabStatesProvider);

  return showDialog<(FreezeBlockerAction, String?)>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      return AlertDialog(
        icon: const Icon(MdiIcons.pause),
        title: Text(l10n.browser_freezeBlockedTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final blocker in blockers)
                _BlockerTile(
                  blocker: blocker,
                  tabTitle: blocker.tabId == null
                      ? null
                      : (tabs[blocker.tabId]?.titleOrAuthority ??
                            l10n.browser_freezeBlockedTabGone),
                  onAction: (action) =>
                      Navigator.of(context).pop((action, blocker.tabId)),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.common_close),
          ),
        ],
      );
    },
  );
}

class _BlockerTile extends StatelessWidget {
  final FreezeBlocker blocker;
  final String? tabTitle;
  final void Function(FreezeBlockerAction action) onAction;

  const _BlockerTile({
    required this.blocker,
    required this.tabTitle,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reason = blocker.activity.describeFreezeBlocker(l10n);
    final isDownload =
        blocker.downloadId != null ||
        blocker.activity == ProtectedActivity.download ||
        blocker.activity == ProtectedActivity.unattributedDownload;
    final tabTitle = this.tabTitle;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(isDownload ? MdiIcons.download : MdiIcons.tab),
      title: Text(tabTitle ?? reason),
      subtitle: tabTitle == null ? null : Text(reason),
      trailing: isDownload
          ? TextButton(
              onPressed: () => onAction(FreezeBlockerAction.viewDownloads),
              child: Text(l10n.browser_freezeBlockedViewDownloads),
            )
          : blocker.tabId == null
          ? null
          : TextButton(
              onPressed: () => onAction(FreezeBlockerAction.showTab),
              child: Text(l10n.browser_freezeBlockedShowTab),
            ),
    );
  }
}
