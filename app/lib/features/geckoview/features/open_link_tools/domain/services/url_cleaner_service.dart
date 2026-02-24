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
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/entities/url_cleaner_result.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/services/url_cleaner_rule.dart';

UrlCleanerResult cleanUrl(
  String url,
  List<UrlCleanerRule> rules, {
  bool allowReferral = false,
}) {
  var currentUrl = url;
  var blocked = false;
  final removedParams = <RemovedParam>[];
  final matchedProviders = <String>[];
  final uniqueMatchedProviders = <String>{};
  String? redirectedFrom;
  var redirectionCount = 0;
  final maxRedirections = rules.length * 4;

  for (var ruleIndex = 0; ruleIndex < rules.length; ruleIndex++) {
    final rule = rules[ruleIndex];
    final name = rule.name;
    final data = rule.data;
    final patternRegex = data.compiledUrlPattern;
    if (patternRegex == null) continue;
    if (!patternRegex.hasMatch(currentUrl)) continue;

    if (uniqueMatchedProviders.add(name)) {
      matchedProviders.add(name);
    }

    // 1. Check completeProvider
    if (data.completeProvider) {
      blocked = true;
      continue;
    }

    // 2. Check exceptions
    var exceptionMatched = false;
    for (final exceptionRegex in data.compiledExceptions) {
      if (exceptionRegex.hasMatch(currentUrl)) {
        exceptionMatched = true;
        break;
      }
    }
    if (exceptionMatched) continue;

    // 3. Apply redirections
    var redirected = false;
    var redirectionMatched = false;
    for (final redirectRegex in data.compiledRedirections) {
      final match = redirectRegex.firstMatch(currentUrl);
      if (match != null && match.groupCount >= 1) {
        redirectionMatched = true;
        final extracted = Uri.decodeComponent(match.group(1)!);
        if (extracted != currentUrl && _hasSafeScheme(extracted)) {
          redirectedFrom ??= currentUrl;
          currentUrl = extracted;
          redirected = true;
        }
        break;
      }
    }
    if (redirected) {
      redirectionCount++;
      if (redirectionCount <= maxRedirections) {
        // Restart provider scan so earlier providers also apply on redirected URL.
        ruleIndex = -1;
      }
      continue;
    }
    if (redirectionMatched) continue;

    // 4. Apply rawRules
    for (var i = 0; i < data.compiledRawRules.length; i++) {
      final rawRegex = data.compiledRawRules[i];
      if (rawRegex == null) continue;
      final rawRule = data.rawRules[i];
      final matches = rawRegex
          .allMatches(currentUrl)
          .map((m) => m.group(0))
          .whereType<String>()
          .where((match) => match.isNotEmpty)
          .toList();
      if (matches.isNotEmpty) {
        currentUrl = currentUrl.replaceAll(rawRegex, '');
        for (final match in matches) {
          removedParams.add(
            RemovedParam(
              provider: name,
              param: rawRule,
              match: match,
              type: UrlCleanerMatchType.rawRule,
            ),
          );
        }
      }
    }

    // 5. Apply rules (query parameter removal)
    for (var i = 0; i < data.compiledRules.length; i++) {
      final compiledRule = data.compiledRules[i];
      if (compiledRule == null) continue;
      final paramRule = data.rules[i];
      final removalResult = _removeQueryParamWithRegex(
        currentUrl,
        compiledRule,
      );
      currentUrl = removalResult.url;
      for (final match in removalResult.matches) {
        removedParams.add(
          RemovedParam(
            provider: name,
            param: paramRule,
            match: match,
            type: UrlCleanerMatchType.queryRule,
          ),
        );
      }
    }

    // 6. Apply referralMarketing (if !allowReferral)
    for (var i = 0; i < data.compiledReferralMarketing.length; i++) {
      final compiledRule = data.compiledReferralMarketing[i];
      if (compiledRule == null) continue;
      final referralRule = data.referralMarketing[i];
      if (!allowReferral) {
        final removalResult = _removeQueryParamWithRegex(
          currentUrl,
          compiledRule,
        );
        currentUrl = removalResult.url;
        for (final match in removalResult.matches) {
          removedParams.add(
            RemovedParam(
              provider: name,
              param: referralRule,
              match: match,
              type: UrlCleanerMatchType.referralRule,
            ),
          );
        }
      } else {
        final referralMatches = _findQueryParamMatchesWithRegex(
          currentUrl,
          compiledRule,
        );
        for (final match in referralMatches) {
          removedParams.add(
            RemovedParam(
              provider: name,
              param: referralRule,
              match: match,
              type: UrlCleanerMatchType.referralRule,
            ),
          );
        }
      }
    }
  }

  currentUrl = _normalizeUrl(currentUrl);

  return UrlCleanerResult(
    cleanedUrl: currentUrl,
    changed: currentUrl != url,
    blocked: blocked,
    removedParams: removedParams,
    matchedProviders: matchedProviders,
    redirectedFrom: redirectedFrom,
  );
}

String removeUrlCleanerMatch(String url, RemovedParam removedParam) {
  if (removedParam.match.isEmpty) return url;

  switch (removedParam.type) {
    case UrlCleanerMatchType.rawRule:
      return _normalizeUrl(url.replaceFirst(removedParam.match, ''));
    case UrlCleanerMatchType.queryRule:
    case UrlCleanerMatchType.referralRule:
      final escapedMatch = RegExp.escape(removedParam.match);
      final regex = RegExp(
        '([?&#])$escapedMatch(?=(&|#|\$))',
        caseSensitive: false,
      );
      final match = regex.firstMatch(url);
      if (match == null) return url;
      final result = url.replaceRange(match.start, match.end, match.group(1)!);
      return _normalizeUrl(result);
  }
}

_QueryParamRemovalResult _removeQueryParamWithRegex(
  String url,
  RegExp paramRegex,
) {
  final regex = RegExp(
    '([?&#])(${paramRegex.pattern})=([^&#]*)',
    caseSensitive: false,
  );
  var result = url;
  final matches = <String>[];

  while (true) {
    final match = regex.firstMatch(result);
    if (match == null) break;
    matches.add('${match.group(2)}=${match.group(3)}');
    result = result.replaceRange(match.start, match.end, match.group(1)!);
  }

  return _QueryParamRemovalResult(url: result, matches: matches);
}

List<String> _findQueryParamMatchesWithRegex(String url, RegExp paramRegex) {
  final regex = RegExp(
    '([?&#])(${paramRegex.pattern})=([^&#]*)',
    caseSensitive: false,
  );
  return regex
      .allMatches(url)
      .map((match) => '${match.group(2)}=${match.group(3)}')
      .toList();
}

bool _hasSafeScheme(String url) {
  final parsed = Uri.tryParse(url);
  if (parsed == null || !parsed.hasScheme) return true; // schemeless is ok
  final scheme = parsed.scheme.toLowerCase();
  return scheme == 'http' || scheme == 'https';
}

// Pre-compiled regexes for URL normalization — avoids recompiling on every call.
final _questionAmpersand = RegExp(r'\?&+');
final _trailingQuestion = RegExp(r'\?$');
final _doubleAmpersand = RegExp('&&+');
final _trailingAmpersand = RegExp(r'&$');
final _hashAmpersand = RegExp('#&+');
final _trailingHash = RegExp(r'#$');

String _normalizeUrl(String url) {
  var normalized = url
      .replaceAll(_questionAmpersand, '?')
      .replaceAll('?#', '#')
      .replaceAll(_trailingQuestion, '')
      .replaceAll(_doubleAmpersand, '&')
      .replaceAll('&#', '#')
      .replaceAll(_trailingAmpersand, '')
      .replaceAll(_hashAmpersand, '#')
      .replaceAll(_trailingHash, '');

  // Only prepend https:// for genuinely schemeless URLs.
  final parsed = Uri.tryParse(normalized);
  if (parsed == null || !parsed.hasScheme) {
    normalized = 'https://$normalized';
  }

  return normalized;
}

class _QueryParamRemovalResult {
  final String url;
  final List<String> matches;

  const _QueryParamRemovalResult({required this.url, required this.matches});
}
