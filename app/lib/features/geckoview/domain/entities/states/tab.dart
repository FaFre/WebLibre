/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/data/models/web_page_info.dart';
import 'package:weblibre/domain/entities/equatable_image.dart';
import 'package:weblibre/features/geckoview/domain/entities/browser_icon.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/find_result.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/history.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/readerable.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/security.dart';

part 'tab.g.dart';

@CopyWith()
class TabState extends WebPageInfo {
  @CopyWithField(immutable: true)
  final String id;

  final String? parentId;

  final String? contextId;

  @override
  String get title => super.title!;

  final EquatableImage? icon;

  @override
  BrowserIcon? get favicon => icon.mapNotNull(
    (icon) => BrowserIcon(
      image: icon,
      dominantColor: null,
      source: IconSource.memory,
    ),
  );

  final EquatableImage? thumbnail;

  final int progress;

  final bool isPrivate;
  final bool isFullScreen;
  final bool isLoading;

  bool get isFinishedLoading => !isLoading && progress == 100;

  final SecurityState securityInfoState;
  final HistoryState historyState;
  final ReaderableState readerableState;
  final FindResultState findResultState;

  TabState({
    required this.id,
    required this.parentId,
    required this.contextId,
    required super.url,
    required String title,
    required this.icon,
    required this.thumbnail,
    required this.progress,
    required this.isPrivate,
    required this.isFullScreen,
    required this.isLoading,
    required this.securityInfoState,
    required this.historyState,
    required this.readerableState,
    required this.findResultState,
  }) : super(title: title.trim());

  factory TabState.$default(String tabId) => TabState(
    id: tabId,
    parentId: null,
    contextId: null,
    url: Uri.parse('about:blank'),
    title: "",
    icon: null,
    thumbnail: null,
    progress: 0,
    isPrivate: false,
    isFullScreen: false,
    isLoading: false,
    securityInfoState: SecurityState.$default(),
    historyState: HistoryState.$default(),
    readerableState: ReaderableState.$default(),
    findResultState: FindResultState.$default(),
  );

  @override
  List<Object?> get hashParameters => [
    ...super.hashParameters,
    id,
    parentId,
    contextId,
    icon,
    thumbnail,
    progress,
    isPrivate,
    isFullScreen,
    isLoading,
    securityInfoState,
    historyState,
    readerableState,
    findResultState,
  ];
}
