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
import 'dart:convert';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/extensions/uri.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/domain/converters/hit_result_converter.dart';

extension HitResultJson on HitResult {
  String toJson() {
    const codec = HitResultConverter();
    return jsonEncode(codec.encode(this));
  }

  static HitResult fromJson(String json) {
    const codec = HitResultConverter();
    return codec.decode(jsonDecode(json) as Map<String, dynamic>);
  }
}

extension HitResultX on HitResult {
  String? getLinkText() {
    return switch (this) {
      UnknownHitResult(:final linkText) => linkText,
      _ => null,
    };
  }

  Uri? tryGetLink() {
    const maxTitleLength = 2500;

    final uri = switch (this) {
      UnknownHitResult(:final src) => src,
      ImageHitResult(:final src, :final title) =>
        title.isEmpty ? (src.length > maxTitleLength ? 'image' : src) : title!,
      VideoHitResult(:final src, :final title) => title.isEmpty ? src : title!,
      AudioHitResult(:final src, :final title) => title.isEmpty ? src : title!,
      ImageSrcHitResult(:final uri) => uri,
      PhoneHitResult() => 'about:blank',
      EmailHitResult() => 'about:blank',
      GeoHitResult() => 'about:blank',
    };

    return Uri.tryParse(uri);
  }

  Uri? tryGetSource() {
    final uri = switch (this) {
      UnknownHitResult(:final src) => src,
      ImageHitResult(:final src) => src,
      VideoHitResult(:final src) => src,
      AudioHitResult(:final src) => src,
      ImageSrcHitResult(:final src) => src,
      PhoneHitResult(:final src) => src,
      EmailHitResult(:final src) => src,
      GeoHitResult(:final src) => src,
    };

    return Uri.tryParse(uri);
  }

  String getTitle() {
    const maxTitleLength = 2500;

    return switch (this) {
      UnknownHitResult(:final src) => src.uriDisplayString,
      ImageSrcHitResult(:final uri) => uri.uriDisplayString,
      ImageHitResult(:final src, :final title) =>
        title.isEmpty
            ? (src.length > maxTitleLength ? 'image' : src.uriDisplayString)
            : title!,
      VideoHitResult(:final src, :final title) =>
        (title.isEmpty) ? src.uriDisplayString : title!,
      AudioHitResult(:final src, :final title) =>
        (title.isEmpty) ? src.uriDisplayString : title!,
      _ => 'about:blank',
    };
  }

  bool get hasSrc => tryGetSource() != null;

  bool get hasLink => tryGetLink() != null;

  bool get hasLinkText => getLinkText()?.isNotEmpty == true;

  bool isImage() {
    return (this is ImageHitResult || this is ImageSrcHitResult) && hasSrc;
  }

  bool isVideoAudio() {
    return (this is VideoHitResult || this is AudioHitResult) && hasSrc;
  }

  bool isFile() {
    return this is UnknownHitResult && hasSrc;
  }

  bool isUri() {
    return (this is UnknownHitResult && hasLink) ||
        (this is ImageSrcHitResult && hasLink);
  }

  bool isHttpLink() {
    return isUri() &&
        switch (tryGetLink()?.scheme) {
          'http' => true,
          'https' => true,
          _ => false,
        };
  }

  bool isIntent() {
    return this is UnknownHitResult &&
        hasLink &&
        tryGetLink()?.scheme == 'intent';
  }

  bool isMailto() {
    return this is UnknownHitResult &&
        hasLink &&
        tryGetLink()?.scheme == 'mailto';
  }

  HitResult withCleanedLink(String cleanedUrl) {
    return switch (this) {
      UnknownHitResult(:final linkText) => UnknownHitResult(
        src: cleanedUrl,
        linkText: linkText,
      ),
      ImageSrcHitResult(:final src) => ImageSrcHitResult(
        src: src,
        uri: cleanedUrl,
      ),
      _ => this,
    };
  }
}
