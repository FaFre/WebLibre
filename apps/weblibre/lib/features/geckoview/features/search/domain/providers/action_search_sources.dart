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
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/profile.dart';
import 'package:weblibre/features/web_feed/data/database/definitions.drift.dart';
import 'package:weblibre/features/web_feed/domain/providers.dart';

part 'action_search_sources.g.dart';

typedef ActionSearchSources = ({
  List<ContainerDataWithCount> containers,
  List<Profile> profiles,
  List<FeedData> feeds,
});

const ActionSearchSources _noSources = (
  containers: [],
  profiles: [],
  feeds: [],
);

/// The containers, profiles and feeds the Actions section matches a query
/// against.
///
/// Nothing is watched until [hasQuery]: the new-tab page lists browser actions
/// only, so opening it starts none of these streams. Containers are left out
/// while the Containers feature is hidden.
@Riverpod()
ActionSearchSources actionSearchSources(Ref ref, {required bool hasQuery}) {
  if (!hasQuery) return _noSources;

  final containersShown = ref.watch(
    shownFeaturesProvider.select(
      (features) => features.contains(FeatureId.containerCore),
    ),
  );
  final containers = containersShown
      ? ref.watch(
          watchContainersWithCountProvider.select(
            (value) => value.value ?? const <ContainerDataWithCount>[],
          ),
        )
      : const <ContainerDataWithCount>[];
  final profiles = ref.watch(
    profileRepositoryProvider.select(
      (value) => value.value ?? const <Profile>[],
    ),
  );
  final feeds = ref.watch(
    feedListProvider.select((value) => value.value ?? const <FeedData>[]),
  );

  return (containers: containers, profiles: profiles, feeds: feeds);
}
