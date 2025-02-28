import 'dart:convert';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/features/geckoview/features/contextmenu/domain/converters/hit_result_converter.dart';

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

  bool get hasSrc => tryGetLink() != null;

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
    return (this is UnknownHitResult && hasSrc) || this is ImageSrcHitResult;
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
        hasSrc &&
        tryGetLink()?.scheme == 'intent';
  }

  bool isMailto() {
    return this is UnknownHitResult &&
        hasSrc &&
        tryGetLink()?.scheme == 'mailto';
  }
}
