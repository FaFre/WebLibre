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
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/geckoview/domain/entities/browser_icon.dart';

part 'web_page_info.g.dart';

@CopyWith()
class WebPageInfo with FastEquatable {
  final Uri url;
  final String? title;
  final BrowserIcon? favicon;
  final Set<Uri>? feeds;

  bool get isPageInfoComplete =>
      title.isNotEmpty && favicon != null && feeds != null;

  WebPageInfo({required this.url, this.title, this.favicon, this.feeds});

  @override
  List<Object?> get hashParameters => [url, title, favicon, feeds];
}
