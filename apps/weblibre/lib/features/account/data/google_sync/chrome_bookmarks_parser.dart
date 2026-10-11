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

/// Parser for Chrome/Chromium bookmarks HTML export files.
///
/// Chrome exports bookmarks as a Netscape Bookmark File Format HTML document
/// via chrome://bookmarks → ⋮ → Export bookmarks. This parser extracts all
/// bookmark entries with their folder hierarchy, URLs, titles, and timestamps.
///
/// The format is standardized and used by all Chromium-based browsers,
/// Firefox, Safari, and most bookmark managers. No Google API access required.
class ChromeBookmarksParser {
  /// Parse a Chrome bookmarks HTML export string into structured entries.
  static List<ImportedBookmark> parse(String htmlContent) {
    final entries = <ImportedBookmark>[];
    final lines = htmlContent.split('\n');
    var currentFolder = '';
    final folderStack = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();

      // Detect folder start: <DT><H3 ...>Folder Name</H3>
      final folderMatch = RegExp(
        r'<DT><H3[^>]*>(.*?)</H3>',
        caseSensitive: false,
      ).firstMatch(trimmed);
      if (folderMatch != null) {
        final folderName = _decodeHtmlEntities(folderMatch.group(1) ?? '');
        folderStack.add(currentFolder);
        currentFolder = currentFolder.isEmpty
            ? folderName
            : '$currentFolder/$folderName';
        continue;
      }

      // Detect folder end: </DL>
      if (trimmed.toUpperCase().contains('</DL>')) {
        if (folderStack.isNotEmpty) {
          currentFolder = folderStack.removeLast();
        }
        continue;
      }

      // Detect bookmark entry: <DT><A HREF="url" ADD_DATE="...">title</A>
      final bookmarkMatch = RegExp(
        r'<DT><A\s+HREF="([^"]*)"([^>]*)>(.*?)</A>',
        caseSensitive: false,
      ).firstMatch(trimmed);
      if (bookmarkMatch != null) {
        final url = bookmarkMatch.group(1) ?? '';
        final attrs = bookmarkMatch.group(2) ?? '';
        final title = _decodeHtmlEntities(bookmarkMatch.group(3) ?? url);

        // Extract ADD_DATE (Chrome uses microseconds since epoch)
        final dateMatch = RegExp(r'ADD_DATE="(\d+)"').firstMatch(attrs);
        final addDateMicros =
            dateMatch != null ? int.tryParse(dateMatch.group(1) ?? '') : null;
        final dateAdded = addDateMicros != null
            ? DateTime.fromMicrosecondsSinceEpoch(addDateMicros)
            : DateTime.now();

        // Skip invalid or empty URLs
        if (url.isNotEmpty &&
            (url.startsWith('http://') ||
                url.startsWith('https://') ||
                url.startsWith('chrome://') ||
                url.startsWith('about:'))) {
          entries.add(ImportedBookmark(
            title: title,
            url: url,
            folderPath: currentFolder.isEmpty ? '/' : '/$currentFolder/',
            dateAdded: dateAdded,
            source: 'chrome_html_export',
          ));
        }
      }
    }

    return entries;
  }

  /// Decode common HTML entities found in bookmark exports.
  static String _decodeHtmlEntities(String input) {
    return input
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'");
  }
}

/// A bookmark entry imported from an external source.
class ImportedBookmark {
  final String title;
  final String url;
  final String folderPath;
  final DateTime dateAdded;
  final String source;

  const ImportedBookmark({
    required this.title,
    required this.url,
    required this.folderPath,
    required this.dateAdded,
    required this.source,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'url': url,
        'folderPath': folderPath,
        'dateAdded': dateAdded.toIso8601String(),
        'source': source,
      };

  factory ImportedBookmark.fromJson(Map<String, dynamic> json) =>
      ImportedBookmark(
        title: json['title'] as String,
        url: json['url'] as String,
        folderPath: json['folderPath'] as String,
        dateAdded: DateTime.parse(json['dateAdded'] as String),
        source: json['source'] as String,
      );
}
