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

import 'dart:convert';

/// Parser for the browsing history that Chrome ships in a Google Takeout
/// export.
///
/// Takeout writes `BrowserHistory.json` as a single object whose
/// `Browser History` key holds one record per visit:
///
/// ```json
/// { "Browser History": [
///     { "url": "...", "title": "...", "time_usec": 1330000000000000,
///       "page_transition": "LINK", "favicon_url": "..." } ] }
/// ```
///
/// Unlike the bookmarks HTML export, this file records every visit, so the
/// same URL appears many times. [parse] folds those into one entry per URL,
/// keeping the most recent visit time and counting the visits, which is what
/// a history store wants.
class ChromeHistoryParser {
  /// Parse a Takeout `BrowserHistory.json` string into deduplicated entries,
  /// newest visit first.
  static List<ImportedHistoryEntry> parse(String jsonContent) {
    Object? decoded;
    try {
      decoded = jsonDecode(jsonContent);
    } on FormatException {
      return const [];
    }

    if (decoded is! Map) return const [];
    final visits = decoded['Browser History'];
    if (visits is! List) return const [];

    final byUrl = <String, ImportedHistoryEntry>{};

    for (final raw in visits) {
      if (raw is! Map) continue;

      final url = raw['url'];
      if (url is! String || url.isEmpty) continue;

      // History also records internal pages and file:// loads; only keep what
      // a web history can meaningfully re-open.
      if (!url.startsWith('http://') && !url.startsWith('https://')) continue;

      final title = raw['title'] is String ? raw['title'] as String : url;

      final timeUsec = raw['time_usec'];
      final visitTime = timeUsec is int
          ? DateTime.fromMicrosecondsSinceEpoch(timeUsec)
          : DateTime.now();

      final existing = byUrl[url];
      if (existing == null) {
        byUrl[url] = ImportedHistoryEntry(
          url: url,
          title: title,
          lastVisit: visitTime,
          visitCount: 1,
          source: 'chrome_takeout_history',
        );
      } else {
        byUrl[url] = existing.copyWith(
          title: existing.title.isEmpty ? title : existing.title,
          lastVisit: visitTime.isAfter(existing.lastVisit)
              ? visitTime
              : existing.lastVisit,
          visitCount: existing.visitCount + 1,
        );
      }
    }

    final entries = byUrl.values.toList()
      ..sort((a, b) => b.lastVisit.compareTo(a.lastVisit));
    return entries;
  }

  /// Keep only entries newer than [since], if given.
  static List<ImportedHistoryEntry> since(
    List<ImportedHistoryEntry> entries,
    DateTime? since,
  ) {
    if (since == null) return entries;
    return entries.where((e) => e.lastVisit.isAfter(since)).toList();
  }
}

/// A single browsing-history entry imported from an external source.
class ImportedHistoryEntry {
  final String url;
  final String title;
  final DateTime lastVisit;
  final int visitCount;
  final String source;

  const ImportedHistoryEntry({
    required this.url,
    required this.title,
    required this.lastVisit,
    required this.visitCount,
    required this.source,
  });

  ImportedHistoryEntry copyWith({
    String? url,
    String? title,
    DateTime? lastVisit,
    int? visitCount,
    String? source,
  }) {
    return ImportedHistoryEntry(
      url: url ?? this.url,
      title: title ?? this.title,
      lastVisit: lastVisit ?? this.lastVisit,
      visitCount: visitCount ?? this.visitCount,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'title': title,
        'lastVisit': lastVisit.toIso8601String(),
        'visitCount': visitCount,
        'source': source,
      };

  factory ImportedHistoryEntry.fromJson(Map<String, dynamic> json) =>
      ImportedHistoryEntry(
        url: json['url'] as String,
        title: json['title'] as String,
        lastVisit: DateTime.parse(json['lastVisit'] as String),
        visitCount: json['visitCount'] as int,
        source: json['source'] as String,
      );
}
