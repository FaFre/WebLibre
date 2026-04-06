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
import 'package:weblibre/features/geckoview/features/top_sites/domain/entities/top_site_item.dart';
import 'package:weblibre/features/geckoview/features/top_sites/domain/repositories/top_site_repository.dart';

part 'providers.g.dart';

const defaultTopSites = [
  (title: 'Wikipedia', url: 'https://wikipedia.org/'),
  (title: 'OpenStreetMap', url: 'https://www.openstreetmap.org/'),
  (
    title:
        'Internet Archive: Digital Library of Free & Borrowable Texts, Movies, Music & Wayback Machine',
    url: 'https://archive.org/',
  ),
  (
    title: 'Mozilla - Internet for people, not profit',
    url: 'https://www.mozilla.org/',
  ),
  (title: 'Tor Project | Anonymity Online', url: 'https://www.torproject.org/'),
];

@Riverpod()
Stream<List<TopSiteItem>> topSiteList(Ref ref, {int limit = 8}) {
  return ref
      .watch(topSiteRepositoryProvider.notifier)
      .watchTopSites(limit: limit);
}

@Riverpod()
Stream<List<TopSiteItem>> pinnedTopSiteList(Ref ref) {
  return ref.watch(topSiteRepositoryProvider.notifier).watchPinnedTopSites();
}
