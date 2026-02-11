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
  Uri? tryGetLink() {
    const maxTitleLength = 2500;

    final uri = switch (this) {
      UnknownHitResult(src: final src) => src,
      ImageHitResult(src: final src, title: final title) =>
        title.isEmpty ? (src.length > maxTitleLength ? 'image' : src) : title!,
      VideoHitResult(src: final src, title: final title) =>
        title.isEmpty ? src : title!,
      AudioHitResult(src: final src, title: final title) =>
        title.isEmpty ? src : title!,
      ImageSrcHitResult(uri: final uri) => uri,
      PhoneHitResult() => 'about:blank',
      EmailHitResult() => 'about:blank',
      GeoHitResult() => 'about:blank',
    };

    return Uri.tryParse(uri);
  }

  Uri? tryGetSource() {
    final uri = switch (this) {
      UnknownHitResult(src: final src) => src,
      ImageHitResult(src: final src) => src,
      VideoHitResult(src: final src) => src,
      AudioHitResult(src: final src) => src,
      ImageSrcHitResult(src: final src) => src,
      PhoneHitResult(src: final src) => src,
      EmailHitResult(src: final src) => src,
      GeoHitResult(src: final src) => src,
    };

    return Uri.tryParse(uri);
  }

  String getTitle() {
    const maxTitleLength = 2500;

    return switch (this) {
      UnknownHitResult(src: final src) => src,
      ImageSrcHitResult(uri: final uri) => uri,
      ImageHitResult(src: final src, title: final title) =>
        title.isEmpty ? (src.length > maxTitleLength ? 'image' : src) : title!,
      VideoHitResult(src: final src, title: final title) =>
        (title.isEmpty) ? src : title!,
      AudioHitResult(src: final src, title: final title) =>
        (title.isEmpty) ? src : title!,
      _ => 'about:blank',
    };
  }

  bool get hasSrc => tryGetSource() != null;

  bool get hasLink => tryGetLink() != null;

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
}
