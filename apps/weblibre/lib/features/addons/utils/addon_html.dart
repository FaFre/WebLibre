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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';

/// AMO descriptions mix raw HTML tags with entity-escaped ones
/// (e.g. `&lt;b&gt;not&lt;/b&gt;` next to `<ul><li>…</li></ul>`). DOMParser
/// would decode the entities to literal text characters, so turndown would
/// emit them verbatim. Decode entities once here so the escaped tags become
/// real markup before the extension runs.
String _decodeHtmlEntities(String input) {
  return input
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&apos;', "'")
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&');
}

Future<String> turndownAddonHtml(String description) async {
  if (description.isEmpty) return '';

  final results = await GeckoBrowserExtensionService.turndownHtml([
    _decodeHtmlEntities(description),
  ], timeout: const Duration(seconds: 3));

  final markdown = results.firstOrNull?.markdown?.trim();
  return (markdown == null || markdown.isEmpty) ? description : markdown;
}
