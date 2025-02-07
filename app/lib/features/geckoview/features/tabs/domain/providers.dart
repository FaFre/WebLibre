import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:lensai/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:lensai/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:lensai/features/geckoview/features/tabs/data/providers.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:lensai/features/geckoview/features/tabs/utils/color_palette.dart';
import 'package:lensai/features/search/util/tokenized_filter.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod()
Future<Color> unusedRandomContainerColor(
  Ref ref,
) async {
  final repository = ref.watch(containerRepositoryProvider.notifier);

  final allColors = colorTypes.flattened.toList();
  final usedColors = await repository.getDistinctColors();

  Color randomColor;
  do {
    randomColor = randomColorShade(allColors);
  } while (usedColors.contains(randomColor));

  return randomColor;
}

@Riverpod()
Stream<List<ContainerDataWithCount>> containersWithCount(
  Ref ref,
) {
  final db = ref.watch(tabDatabaseProvider);
  return db.containersWithCount().watch();
}

@Riverpod()
AsyncValue<List<ContainerDataWithCount>> matchSortedContainersWithCount(
  Ref ref,
  String? searchText,
) {
  return ref.watch(
    containersWithCountProvider.select((value) {
      if (searchText?.isEmpty ?? true) {
        return value;
      }

      return value.whenData(
        (cb) => TokenizedFilter.sort(
          items: cb,
          toString: (item) => item.name,
          query: searchText!,
        ).filtered,
      );
    }),
  );
}

@Riverpod()
Stream<List<String>> containerTabIds(
  Ref ref,
  ContainerFilter containerFilter,
) {
  final db = ref.watch(tabDatabaseProvider);

  switch (containerFilter) {
    case ContainerFilterById(:final containerId):
      return db.tabDao.containerTabIds(containerId).watch();
    case ContainerFilterDisabled():
      return db.tabDao.allTabIds().watch();
  }
}
