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
import 'package:markdown/markdown.dart';
import 'package:nullability/nullability.dart';
import 'package:path/path.dart' as p;

List<Uri> extractImagesFromMarkdown(String markdownText) {
  final imageUrls = <Uri>[];

  final nodes = Document().parse(markdownText);

  void findImages(List<Node> nodes) {
    for (final node in nodes) {
      if (node is Element && node.tag == 'img') {
        final url = node.attributes['src'];

        if (url.mapNotNull((url) => Uri.tryParse(url)) case final Uri url) {
          if (p.extension(url.path)
              case '.png' || '.jpg' || '.jpeg' || '.webp') {
            imageUrls.add(url);
          }
        }
      }

      if (node is Element && node.children != null) {
        findImages(node.children!);
      }
    }
  }

  findImages(nodes);

  return imageUrls;
}
