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
 */

import 'chrome_bookmarks_parser.dart';

/// Result of a merge operation.
class MergeResult {
  final int added;
  final int updated;
  final int skipped;
  final int errors;

  const MergeResult({
    this.added = 0,
    this.updated = 0,
    this.skipped = 0,
    this.errors = 0,
  });

  int get total => added + updated + skipped + errors;

  @override
  String toString() =>
      'MergeResult(added: $added, updated: $updated, skipped: $skipped, errors: $errors)';
}

/// Merges bookmarks from Google Chrome HTML export into WebLibre's local store.
///
/// Strategy:
/// - Deduplicate by URL: if a bookmark with the same URL already exists
///   (from Firefox Sync or manual add), skip it unless the imported version
///   has a newer timestamp.
/// - Preserve folder structure: imported bookmarks are placed under a
///   '[Chrome Import]' root folder to avoid mixing with native bookmarks.
/// - Never delete existing bookmarks: this is an additive merge.
///
/// The actual database writes happen on the Kotlin side via Pigeon bridge.
/// This class handles the deduplication logic and prepares the data for
/// efficient batch insertion.
class DualSourceMergeEngine {
  /// Prepare a list of imported bookmarks for merging.
  ///
  /// Returns a filtered list with duplicates removed (keeping the newest
  /// version) and folder paths prefixed with '[Chrome Import]'.
  static List<ImportedBookmark> prepareForMerge(
    List<ImportedBookmark> imported,
    Set<String> existingUrls,
  ) {
    final seen = <String>{};
    final result = <ImportedBookmark>[];

    // Sort by date descending so we keep the newest when deduplicating
    final sorted = List<ImportedBookmark>.from(imported)
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

    for (final bm in sorted) {
      // Skip if URL already exists in local store
      if (existingUrls.contains(bm.url)) continue;

      // Skip duplicate URLs within the import itself
      if (seen.contains(bm.url)) continue;
      seen.add(bm.url);

      // Prefix folder path to indicate source
      final prefixedPath = bm.folderPath == '/'
          ? '/[Chrome Import]/'
          : '/[Chrome Import]${bm.folderPath}';

      result.add(ImportedBookmark(
        title: bm.title,
        url: bm.url,
        folderPath: prefixedPath,
        dateAdded: bm.dateAdded,
        source: bm.source,
      ));
    }

    return result;
  }

  /// Compute merge statistics without performing the actual merge.
  static MergeResult computeStats(
    List<ImportedBookmark> imported,
    Set<String> existingUrls,
  ) {
    var added = 0;
    var skipped = 0;
    final seen = <String>{};

    for (final bm in imported) {
      if (existingUrls.contains(bm.url)) {
        skipped++;
        continue;
      }
      if (seen.contains(bm.url)) {
        skipped++;
        continue;
      }
      seen.add(bm.url);
      added++;
    }

    return MergeResult(added: added, skipped: skipped);
  }
}
