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
import 'package:collection/collection.dart';
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:weblibre/extensions/uri.dart';

/// A URI as crumbs: the host in bold, then the path segments (`host › a › b`).
///
/// By default one line that scrolls sideways with a fade, for list rows. With
/// [wrap] it wraps instead, for places that show the whole address (a dialog
/// title). The query and fragment are left out unless [showQuery] is set; the
/// tooltip always carries the full address.
class UriBreadcrumb extends StatelessWidget {
  final Uri uri;
  final Widget? icon;
  final TextStyle? style;

  /// Whether a leading `https ›` is shown. Off where it would be a crumb that
  /// never varies. Only `https` is ever hidden: `http` always shows, so a
  /// plaintext address never looks like a secure one, and so do other schemes.
  final bool showHttpScheme;

  /// Appends the query and fragment (`?a=1#top`) after the path, dimmed. Set
  /// it where they tell addresses apart or are what the user checks: a feed
  /// URL, a DNS endpoint, a link about to be opened.
  final bool showQuery;

  /// Wraps over several lines instead of scrolling one, so nothing is hidden
  /// behind the fade. Long runs without spaces (a query) break anywhere.
  final bool wrap;

  /// Only with [wrap]: the line limit, after which the text is ellipsized.
  final int? maxLines;

  final void Function()? onTooltipTriggered;

  const UriBreadcrumb({
    super.key,
    required this.uri,
    this.icon,
    this.style,
    this.showHttpScheme = true,
    this.showQuery = false,
    this.wrap = false,
    this.maxLines,
    this.onTooltipTriggered,
  });

  static const _bold = TextStyle(fontWeight: FontWeight.bold);
  static const _separator = ' › ';

  bool get _showsScheme => !uri.isHttps || showHttpScheme;

  String? get _pathText {
    final segments = _decodedPathSegments().whereNot((s) => s.isEmpty);
    return segments.isEmpty ? null : '$_separator${segments.join(_separator)}';
  }

  /// [Uri.pathSegments] throws for a path that is not valid UTF-8 once
  /// decoded (`/%FF`), which [Uri.tryParse] accepts. Then each segment is
  /// decoded on its own, and one that cannot be keeps its encoded form, as
  /// [UriX.displayString] does for the whole path.
  Iterable<String> _decodedPathSegments() {
    try {
      return uri.pathSegments;
    } on FormatException {
      return uri.path.split('/').map((segment) {
        try {
          return Uri.decodeComponent(segment);
        } on FormatException {
          return segment;
        }
      });
    }
  }

  String? get _queryText {
    if (!showQuery) {
      return null;
    }
    final buffer = StringBuffer();
    if (uri.query.isNotEmpty) {
      buffer
        ..write('?')
        ..write(uri.query);
    }
    if (uri.fragment.isNotEmpty) {
      buffer
        ..write('#')
        ..write(uri.fragment);
    }
    return buffer.isEmpty ? null : buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? DefaultTextStyle.of(context).style;
    final baseColor =
        effectiveStyle.color ?? DefaultTextStyle.of(context).style.color;
    final queryStyle = TextStyle(
      color: baseColor?.withValues(alpha: baseColor.a * 0.7),
    );
    final pathText = _pathText;
    final queryText = _queryText;

    return Tooltip(
      message: uri.displayString,
      onTriggered: onTooltipTriggered,
      child: DefaultTextStyle(
        style: effectiveStyle,
        child: wrap
            ? Text.rich(
                TextSpan(
                  children: [
                    if (icon != null)
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(end: 6),
                          child: icon,
                        ),
                      ),
                    if (_showsScheme)
                      TextSpan(text: '${uri.scheme}$_separator', style: _bold),
                    TextSpan(text: uri.authority, style: _bold),
                    if (pathText != null) TextSpan(text: pathText),
                    if (queryText != null)
                      TextSpan(text: queryText, style: queryStyle),
                  ],
                ),
                maxLines: maxLines,
                overflow: maxLines != null ? TextOverflow.ellipsis : null,
              )
            : FadingScroll(
                fadingSize: 15,
                builder: (context, controller) {
                  return SingleChildScrollView(
                    controller: controller,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ?icon,
                        if (icon != null) const SizedBox(width: 6),
                        if (_showsScheme) ...[
                          Text(
                            uri.scheme,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.visible,
                            style: _bold,
                          ),
                          const Text(
                            _separator,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.visible,
                            style: _bold,
                          ),
                        ],
                        Text(
                          uri.authority,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.visible,
                          style: _bold,
                        ),
                        if (pathText != null)
                          Text(
                            pathText,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.visible,
                          ),
                        if (queryText != null)
                          Text(
                            queryText,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.visible,
                            style: queryStyle,
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// A [UriBreadcrumb] for an address stored as a string. A string that does not
/// parse, or has no host to lead the crumbs, is shown as plain text instead.
class UrlStringBreadcrumb extends StatelessWidget {
  final String url;
  final TextStyle? style;

  /// See [UriBreadcrumb.showHttpScheme].
  final bool showHttpScheme;
  final bool showQuery;

  const UrlStringBreadcrumb({
    super.key,
    required this.url,
    this.style,
    this.showHttpScheme = true,
    this.showQuery = false,
  });

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.authority.isEmpty) {
      return Text(
        url.uriDisplayString,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    return UriBreadcrumb(
      uri: uri,
      style: style,
      showHttpScheme: showHttpScheme,
      showQuery: showQuery,
    );
  }
}
