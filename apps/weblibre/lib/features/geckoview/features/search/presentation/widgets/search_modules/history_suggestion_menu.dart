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
import 'package:flutter/semantics.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/container_history.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/hidden_history_suggestions.dart';
import 'package:weblibre/features/geckoview/features/top_sites/domain/entities/top_site_host.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/hooks/menu_controller.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

/// Wraps a history suggestion row: a long press (or the screen reader's
/// action) offers to delete [url] from history, as Fenix's address bar does.
///
/// [url] is the address as history stores it: Places deletes by exact match.
/// [builder] gets the long-press handler for its row.
class HistorySuggestionMenu extends HookConsumerWidget {
  final String url;
  final Widget Function(VoidCallback onLongPress) builder;

  const HistorySuggestionMenu({
    super.key,
    required this.url,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = useMenuController();

    Future<void> delete() => deleteHistorySuggestion(context, ref, url);

    return MenuAnchor(
      controller: controller,
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.delete),
          onPressed: delete,
          child: Text(l10n.search_actionDeleteFromHistory),
        ),
      ],
      child: Semantics(
        customSemanticsActions: {
          CustomSemanticsAction(label: l10n.search_actionDeleteFromHistory):
              delete,
        },
        child: builder(() {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        }),
      ),
    );
  }
}

/// Hides the suggestion for [url] and deletes the page from history once the
/// Undo snackbar has gone without being tapped.
Future<void> deleteHistorySuggestion(
  BuildContext context,
  WidgetRef ref,
  String url,
) async {
  final l10n = AppLocalizations.of(context);
  final key = historySuggestionKey(url);
  final hidden = ref.read(hiddenHistorySuggestionsProvider.notifier);
  // Kept alive: the search may have closed by the time the Undo is gone.
  final repository = ref.read(containerHistoryRepositoryProvider.notifier);

  hidden.hide(key);

  final undone = await ui_helper.showUndoMessage(
    context,
    l10n.search_deletedFromHistory(_shortSite(url)),
  );
  if (undone) {
    hidden.unhide(key);
    return;
  }

  try {
    await repository.deleteUrl(url);
  } catch (e, s) {
    logger.e('Could not delete a history suggestion', error: e, stackTrace: s);
    hidden.unhide(key);
  }
}

/// [url] as Fenix names it in the snackbar: the host without "www.".
String _shortSite(String url) {
  final uri = Uri.tryParse(url);
  final host = uri == null ? '' : canonicalTopSiteHost(uri);
  return host.isEmpty ? url : host;
}
