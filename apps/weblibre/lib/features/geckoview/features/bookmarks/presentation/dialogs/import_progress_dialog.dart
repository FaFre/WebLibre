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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/import_bookmark_node.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Shows how far a running bookmark import has got.
///
/// A large file takes long enough that the app would otherwise look frozen.
/// The dialog cannot be dismissed: storage work is already under way and there
/// is no way to call it back, so offering a cancel button would be a lie.
///
/// [progress] is driven by the import itself; the dialog closes when the caller
/// pops it.
class ImportProgressDialog extends StatelessWidget {
  final ValueListenable<BookmarkImportProgress> progress;

  const ImportProgressDialog({required this.progress, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(l10n.bookmarks_importProgressTitle),
        content: ValueListenableBuilder<BookmarkImportProgress>(
          valueListenable: progress,
          builder: (context, value, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(switch (value.phase) {
                  BookmarkImportPhase.parsing =>
                    l10n.bookmarks_importPhaseParsing,
                  BookmarkImportPhase.erasing =>
                    l10n.bookmarks_importPhaseErasing,
                  BookmarkImportPhase.inserting when value.total > 0 =>
                    l10n.bookmarks_importPhaseInsertingProgress(
                      value.inserted,
                      value.total,
                    ),
                  BookmarkImportPhase.inserting =>
                    l10n.bookmarks_importPhaseInsertingIndeterminate,
                }),
                const SizedBox(height: 16.0),
                LinearProgressIndicator(value: value.fraction),
              ],
            );
          },
        ),
      ),
    );
  }
}
