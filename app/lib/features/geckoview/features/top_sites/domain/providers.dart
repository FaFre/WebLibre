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

@Riverpod(keepAlive: true)
List<({String title, Uri url})> topSiteDefaultSeeds(Ref ref) {
  return [
    (title: 'Wikipedia', url: Uri.parse('https://wikipedia.org')),
    (title: 'OpenStreetMap', url: Uri.parse('https://www.openstreetmap.org')),
    (title: 'Project Gutenberg', url: Uri.parse('https://www.gutenberg.org/')),
  ];
}

@Riverpod()
Stream<List<TopSiteItem>> topSiteList(Ref ref, {int limit = 8}) {
  return ref
      .watch(topSiteRepositoryProvider.notifier)
      .watchTopSites(limit: limit);
}

@Riverpod()
Stream<List<TopSiteItem>> persistedTopSiteList(Ref ref) {
  return ref.watch(topSiteRepositoryProvider.notifier).watchPersistedTopSites();
}
