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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/bangs/data/providers.dart';
import 'package:weblibre/utils/lru_cache.dart';
import 'package:weblibre/utils/uri_parser.dart' as uri_parser;

part 'reverse_match.g.dart';

const String _placeholder = '{{{s}}}';

/// A URL-safe sentinel inserted in place of the bang's `{{{s}}}` placeholder
/// during template parsing. Picked so it survives URI parsing without
/// re-encoding and is extremely unlikely to appear in real templates.
const String _sentinel = 'wlbangrevxq7p2zsentinel';

/// Where the placeholder sits inside a template.
enum _Slot { mainQuery, mainPath, fragmentQuery, fragmentPath }

/// Path + query pieces of a URL (or fragment) reduced to the parts we care
/// about for reverse matching.
class _Components {
  final List<String> pathSegments;
  final Map<String, String> queryParams;

  const _Components({required this.pathSegments, required this.queryParams});
}

/// Parsed form of a bang URL template suitable for reverse matching.
///
/// The placeholder can sit in one of four slots: main URL query/path or
/// fragment query/path. Everything else in the template becomes a required
/// constant during matching. Hash-router and #key=value fragments are both
/// supported via [_componentsFromFragment].
class BangUrlPattern {
  final String host;

  // Main-URL constraints (always enforced).
  final List<String> mainPathSegments;
  final Map<String, String> mainQueryParams;

  // Fragment constraints (only when the template uses a fragment).
  final List<String>? fragmentPathSegments;
  final Map<String, String>? fragmentQueryParams;

  // Placeholder location + capture descriptors.
  final _Slot _slot;
  final String prefix;
  final String suffix;
  final String? paramName; // for *Query slots
  final int? pathIndex; // for *Path slots

  const BangUrlPattern._({
    required this.host,
    required this.mainPathSegments,
    required this.mainQueryParams,
    required this.fragmentPathSegments,
    required this.fragmentQueryParams,
    required _Slot slot,
    required this.prefix,
    required this.suffix,
    this.paramName,
    this.pathIndex,
  }) : _slot = slot;

  /// Specificity score used to break ties between bangs sharing a host:
  /// more constants matched = more specific template.
  int get constraintCount =>
      mainPathSegments.length +
      mainQueryParams.length +
      (fragmentPathSegments?.length ?? 0) +
      (fragmentQueryParams?.length ?? 0);

  /// Extracts the user query from [input] if it matches this pattern. Returns
  /// null otherwise.
  String? match(Uri input) {
    if (uri_parser.normalizeHost(input.host) != host) return null;

    final mainInput = _componentsFromUri(input);
    if (mainInput == null) return null;
    if (!_pathSegmentsMatchAround(
      mainPathSegments,
      mainInput.pathSegments,
      _slot == _Slot.mainPath ? pathIndex : null,
    )) {
      return null;
    }
    if (!_requiredQueryParamsMatch(mainQueryParams, mainInput.queryParams)) {
      return null;
    }

    _Components? fragmentInput;
    if (fragmentPathSegments != null || fragmentQueryParams != null) {
      fragmentInput = _componentsFromFragment(input.fragment);
      if (fragmentInput == null) return null;

      if (!_pathSegmentsMatchAround(
        fragmentPathSegments ?? const [],
        fragmentInput.pathSegments,
        _slot == _Slot.fragmentPath ? pathIndex : null,
      )) {
        return null;
      }

      if (!_requiredQueryParamsMatch(
        fragmentQueryParams ?? const {},
        fragmentInput.queryParams,
      )) {
        return null;
      }
    }

    switch (_slot) {
      case _Slot.mainQuery:
        return _extractFromQuery(mainInput.queryParams);
      case _Slot.mainPath:
        return _extractFromPath(mainInput.pathSegments);
      case _Slot.fragmentQuery:
        return _extractFromQuery(fragmentInput!.queryParams);
      case _Slot.fragmentPath:
        return _extractFromPath(fragmentInput!.pathSegments);
    }
  }

  String? _extractFromQuery(Map<String, String> params) {
    final value = params[paramName];
    if (value == null) return null;
    if (!value.startsWith(prefix)) return null;
    if (!value.endsWith(suffix)) return null;
    final captured = value.substring(
      prefix.length,
      value.length - suffix.length,
    );
    return captured.isEmpty ? null : captured;
  }

  String? _extractFromPath(List<String> segments) {
    if (pathIndex == null || pathIndex! >= segments.length) return null;
    final segment = segments[pathIndex!];
    if (!segment.startsWith(prefix)) return null;
    if (!segment.endsWith(suffix)) return null;
    final captured = segment.substring(
      prefix.length,
      segment.length - suffix.length,
    );
    return captured.isEmpty ? null : captured;
  }

  static BangUrlPattern? parse(String urlTemplate) {
    final placeholderCount = _placeholder.allMatches(urlTemplate).length;
    if (placeholderCount != 1) {
      // Multi-placeholder templates are out of scope.
      return null;
    }

    final substituted = urlTemplate.replaceAll(_placeholder, _sentinel);
    final Uri parsed;
    try {
      parsed = Uri.parse(substituted);
    } on FormatException {
      return null;
    }

    if (!parsed.hasScheme || parsed.host.isEmpty) return null;
    if (parsed.host.contains(_sentinel)) return null;

    // Normalize so a template host and a redirected results host that differ
    // only by a generic subdomain (www./m.) still match.
    final host = uri_parser.normalizeHost(parsed.host);

    final fragmentSlot = parsed.fragment.contains(_sentinel);
    final templateMain = _componentsFromUri(parsed);
    if (templateMain == null) return null;

    if (fragmentSlot) {
      final fragmentComponents = _componentsFromFragment(parsed.fragment);
      if (fragmentComponents == null) return null;

      return _withPlaceholderInScope(
        host: host,
        mainPathSegments: templateMain.pathSegments,
        mainQueryParams: templateMain.queryParams,
        scopeComponents: fragmentComponents,
        queryslot: _Slot.fragmentQuery,
        pathSlot: _Slot.fragmentPath,
        isFragment: true,
      );
    }

    // Placeholder lives in the main URL.
    return _withPlaceholderInScope(
      host: host,
      mainPathSegments: templateMain.pathSegments,
      mainQueryParams: templateMain.queryParams,
      scopeComponents: templateMain,
      queryslot: _Slot.mainQuery,
      pathSlot: _Slot.mainPath,
      isFragment: false,
    );
  }

  /// Locates the sentinel inside [scopeComponents] (which may be the main URL
  /// components or the fragment's components) and assembles a [BangUrlPattern]
  /// with all required constants extracted.
  static BangUrlPattern? _withPlaceholderInScope({
    required String host,
    required List<String> mainPathSegments,
    required Map<String, String> mainQueryParams,
    required _Components scopeComponents,
    required _Slot queryslot,
    required _Slot pathSlot,
    required bool isFragment,
  }) {
    // Try query slot first.
    String? sentinelParam;
    for (final entry in scopeComponents.queryParams.entries) {
      if (entry.value.contains(_sentinel)) {
        if (sentinelParam != null) return null; // ambiguous
        sentinelParam = entry.key;
      }
    }

    if (sentinelParam != null) {
      final placeholderValue = scopeComponents.queryParams[sentinelParam]!;
      final sentinelStart = placeholderValue.indexOf(_sentinel);
      final prefix = placeholderValue.substring(0, sentinelStart);
      final suffix = placeholderValue.substring(
        sentinelStart + _sentinel.length,
      );

      // The other params in the same scope become required constants.
      final required = <String, String>{
        for (final e in scopeComponents.queryParams.entries)
          if (e.key != sentinelParam) e.key: e.value,
      };

      // We already required exactly one sentinel occurrence in [parse], so
      // if it lives in this scope's queries no path segment can also carry it.
      // The guard remains as defensive insurance.
      if (scopeComponents.pathSegments.any((s) => s.contains(_sentinel))) {
        return null;
      }

      return BangUrlPattern._(
        host: host,
        mainPathSegments: mainPathSegments,
        mainQueryParams: isFragment ? mainQueryParams : required,
        fragmentPathSegments: isFragment ? scopeComponents.pathSegments : null,
        fragmentQueryParams: isFragment ? required : null,
        slot: queryslot,
        prefix: prefix,
        suffix: suffix,
        paramName: sentinelParam,
      );
    }

    // Otherwise the placeholder must be inside a single path segment.
    final segments = scopeComponents.pathSegments;
    final pathIndex = segments.indexWhere((s) => s.contains(_sentinel));
    if (pathIndex < 0) return null;

    final segment = segments[pathIndex];
    final sentinelStart = segment.indexOf(_sentinel);
    final prefix = segment.substring(0, sentinelStart);
    final suffix = segment.substring(sentinelStart + _sentinel.length);

    final pathSegments = List<String>.from(segments);

    final required = scopeComponents.queryParams;
    if (required.values.any((v) => v.contains(_sentinel))) return null;

    return BangUrlPattern._(
      host: host,
      mainPathSegments: isFragment ? mainPathSegments : pathSegments,
      mainQueryParams: isFragment ? mainQueryParams : required,
      fragmentPathSegments: isFragment ? pathSegments : null,
      fragmentQueryParams: isFragment ? required : null,
      slot: pathSlot,
      prefix: prefix,
      suffix: suffix,
      pathIndex: pathIndex,
    );
  }
}

/// Compares path segments. When [placeholderIndex] is non-null, the segment
/// at that index is the placeholder and is skipped here (the caller verifies
/// it against the stored prefix/suffix).
bool _pathSegmentsMatchAround(
  List<String> required,
  List<String> actual,
  int? placeholderIndex,
) {
  if (actual.length != required.length) return false;
  for (var i = 0; i < required.length; i++) {
    if (i == placeholderIndex) continue;
    if (actual[i] != required[i]) return false;
  }
  return true;
}

bool _requiredQueryParamsMatch(
  Map<String, String> required,
  Map<String, String> actual,
) {
  if (required.isEmpty) return true;
  for (final entry in required.entries) {
    if (actual[entry.key] != entry.value) return false;
  }
  return true;
}

/// Reduces a [Uri] to the constraint set we care about. Bails on
/// duplicate-keyed query params (multi-map semantics aren't worth the
/// complexity for our use case).
_Components? _componentsFromUri(Uri uri) {
  final segments = uri.pathSegments
      .where((s) => s.isNotEmpty)
      .toList(growable: false);
  final all = uri.queryParametersAll;
  final params = <String, String>{};
  for (final entry in all.entries) {
    if (entry.value.length != 1) return null;
    params[entry.key] = entry.value.first;
  }
  return _Components(pathSegments: segments, queryParams: params);
}

/// Parses a fragment string into pseudo-URI components.
///
/// Two common shapes are handled:
/// - hash-router style: starts with `/` (e.g. `/s/search/foo`)
/// - hash-query style: contains `=` without leading `/` (e.g. `s=foo&t=bar`)
/// Plain fragments without `/` or `=` are treated as a single path segment.
_Components? _componentsFromFragment(String fragment) {
  if (fragment.isEmpty) return null;
  final String synthetic;
  if (fragment.startsWith('/')) {
    synthetic = 'http://x$fragment';
  } else if (fragment.contains('=')) {
    synthetic = 'http://x/?$fragment';
  } else {
    synthetic = 'http://x/$fragment';
  }
  try {
    return _componentsFromUri(Uri.parse(synthetic));
  } on FormatException {
    return null;
  }
}

/// Cached parsed patterns. `null` entries are cached too, so unsupported
/// templates aren't re-parsed.
final LRUCache<String, BangUrlPattern?> _patternCache = LRUCache(256);

BangUrlPattern? _patternFor(String urlTemplate) {
  if (_patternCache.contains(urlTemplate)) {
    return _patternCache.get(urlTemplate);
  }
  final parsed = BangUrlPattern.parse(urlTemplate);
  _patternCache.set(urlTemplate, parsed);
  return parsed;
}

/// Reverse-match result: the bang whose template best matches [url] together
/// with the extracted user query.
class ReverseBangMatch {
  final BangData bang;
  final String query;

  const ReverseBangMatch({required this.bang, required this.query});
}

@Riverpod(keepAlive: true)
class ReverseBangMatcher extends _$ReverseBangMatcher {
  @override
  void build() {}

  /// Looks up a bang whose template produces [url] and extracts the query.
  /// Returns null when no candidate matches.
  Future<ReverseBangMatch?> match(Uri url) async {
    final host = url.host;
    if (host.isEmpty) return null;

    final scheme = url.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') return null;

    final candidates = await ref
        .read(bangDatabaseProvider)
        .bangDao
        .getBangDataByTemplateHost(host)
        .get();

    if (candidates.isEmpty) return null;

    ReverseBangMatch? best;
    int bestScore = -1;
    int bestFrequency = -1;

    for (final bang in candidates) {
      final pattern = _patternFor(bang.urlTemplate);
      if (pattern == null) continue;

      final captured = pattern.match(url);
      if (captured == null) continue;

      // Don't auto-select when the captured text is itself a URL — usually
      // means we matched a redirector/shortener and the user wouldn't expect
      // the address bar to "edit" that.
      if (uri_parser.tryParseUrl(captured)?.hasScheme == true) continue;

      final score = pattern.constraintCount;
      final frequency = bang.frequency;
      if (score > bestScore ||
          (score == bestScore && frequency > bestFrequency)) {
        best = ReverseBangMatch(bang: bang, query: captured);
        bestScore = score;
        bestFrequency = frequency;
      }
    }

    return best;
  }
}
