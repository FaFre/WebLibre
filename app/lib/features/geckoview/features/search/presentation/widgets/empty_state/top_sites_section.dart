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
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_reorderable_grid_view/widgets/custom_draggable.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/dialogs/edit_top_site_dialog.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_module_section.dart';
import 'package:weblibre/features/geckoview/features/top_sites/domain/entities/top_site_item.dart';
import 'package:weblibre/features/geckoview/features/top_sites/domain/entities/top_site_source.dart';
import 'package:weblibre/features/geckoview/features/top_sites/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/top_sites/domain/repositories/top_site_repository.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

const _gridMainAxisSpacing = 8.0;
const _gridCrossAxisSpacing = 8.0;
const _topSitesPreviewLimit = 8;
const _topSitesMaxLimit = 25;

class _TopSitesGridLayout {
  final int crossAxisCount;
  final double childAspectRatio;

  const _TopSitesGridLayout({
    required this.crossAxisCount,
    required this.childAspectRatio,
  });
}

_TopSitesGridLayout _resolveGridLayout(double width) {
  const minTileWidth = 74.0;
  const effectiveTileWidth = minTileWidth + _gridCrossAxisSpacing;
  final rawCount = (width / effectiveTileWidth).floor();
  final crossAxisCount = rawCount.clamp(4, 7);

  // Keep cells compact on phones and allow slightly wider tiles on large screens.
  final childAspectRatio = switch (crossAxisCount) {
    4 => 0.92,
    5 => 0.96,
    _ => 1.0,
  };

  return _TopSitesGridLayout(
    crossAxisCount: crossAxisCount,
    childAspectRatio: childAspectRatio,
  );
}

class TopSitesSection extends HookConsumerWidget {
  final void Function(Uri uri) onUriSelected;

  const TopSitesSection({super.key, required this.onUriSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topSites = ref.watch(
      topSiteListProvider(
        limit: _topSitesMaxLimit,
      ).select((value) => value.value ?? []),
    );

    if (topSites.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final reorderMode = useState(false);
    final reorderBusy = useState(false);

    final persistedItems = topSites.where((s) => s.isPersisted).toList();
    final historyItems = topSites.where((s) => !s.isPersisted).toList();

    return SearchModuleSection(
      title: 'Top Sites',
      moduleType: SearchModuleType.topSites,
      totalCount: topSites.length,
      previewLimit: _topSitesPreviewLimit,
      headerTrailing: persistedItems.length >= 2
          ? IconButton.filledTonal(
              icon: const Icon(Icons.swap_vert),
              visualDensity: VisualDensity.compact,
              isSelected: reorderMode.value,
              iconSize: 18,
              padding: EdgeInsets.zero,
              tooltip: reorderMode.value
                  ? 'Disable reordering mode'
                  : 'Enable reordering mode',
              onPressed: () {
                final wasEnabled = reorderMode.value;
                reorderMode.value = !wasEnabled;
                if (!wasEnabled && context.mounted) {
                  ui_helper.showInfoMessage(
                    context,
                    'Drag and drop top sites to reorder',
                  );
                }
              },
            )
          : null,
      contentSliverBuilder:
          ({required bool isCollapsed, required int visibleCount}) => [
            if (!isCollapsed)
              if (reorderMode.value)
                _ReorderableTopSitesGrid(
                  persistedItems: persistedItems,
                  historyItems: historyItems,
                  reorderBusy: reorderBusy,
                  onUriSelected: onUriSelected,
                )
              else
                _TopSitesGrid(
                  items: topSites,
                  visibleCount: visibleCount,
                  onUriSelected: onUriSelected,
                ),
          ],
    );
  }
}

class _TopSitesGrid extends ConsumerWidget {
  final List<TopSiteItem> items;
  final int visibleCount;
  final void Function(Uri uri) onUriSelected;

  const _TopSitesGrid({
    required this.items,
    required this.visibleCount,
    required this.onUriSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayItems = items.take(visibleCount).toList();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final layout = _resolveGridLayout(constraints.crossAxisExtent);
          return SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: layout.crossAxisCount,
              mainAxisSpacing: _gridMainAxisSpacing,
              crossAxisSpacing: _gridCrossAxisSpacing,
              childAspectRatio: layout.childAspectRatio,
            ),
            itemCount: displayItems.length,
            itemBuilder: (context, index) {
              final item = displayItems[index];
              return _TopSiteGridTile(
                item: item,
                onTap: () => onUriSelected(item.url),
                onPin: () => _pinItem(context, ref, item),
                onEdit: () => _editItem(context, ref, item),
                onRemove: () => _removeItem(context, ref, item),
              );
            },
          );
        },
      ),
    );
  }
}

class _ReorderableTopSitesGrid extends HookConsumerWidget {
  final List<TopSiteItem> persistedItems;
  final List<TopSiteItem> historyItems;
  final ValueNotifier<bool> reorderBusy;
  final void Function(Uri uri) onUriSelected;

  const _ReorderableTopSitesGrid({
    required this.persistedItems,
    required this.historyItems,
    required this.reorderBusy,
    required this.onUriSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localItems = useState(persistedItems);

    useEffect(() {
      localItems.value = persistedItems;
      return null;
    }, [persistedItems]);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final layout = _resolveGridLayout(constraints.maxWidth);
            return ReorderableBuilder.builder(
              itemCount: localItems.value.length,
              onReorderPositions: (positions) async {
                if (reorderBusy.value || positions.isEmpty) return;

                final oldIndex = positions.first.oldIndex;
                final newIndex = positions.first.newIndex;
                if (oldIndex < 0 || oldIndex >= localItems.value.length) return;
                if (newIndex < 0 || newIndex > localItems.value.length) return;

                final items = localItems.value.toList();
                final movedItem = items.removeAt(oldIndex);
                if (movedItem.id == null) return;

                final targetIndex = newIndex.clamp(0, items.length);

                // The grid package reports target indices in the final order.
                items.insert(targetIndex, movedItem);
                localItems.value = items;

                reorderBusy.value = true;
                try {
                  final repo = ref.read(topSiteRepositoryProvider.notifier);

                  final String key;
                  if (targetIndex <= 0) {
                    key = await repo.getLeadingOrderKey();
                  } else if (targetIndex >= items.length - 1) {
                    key = await repo.getTrailingOrderKey();
                  } else if (targetIndex < oldIndex) {
                    final previousId = items[targetIndex - 1].id;
                    final nextId = items[targetIndex + 1].id;
                    final afterPrevious = previousId == null
                        ? null
                        : await repo.getOrderKeyAfterSite(previousId);
                    if (afterPrevious != null) {
                      key = afterPrevious;
                    } else if (nextId != null) {
                      key = await repo.getOrderKeyBeforeSite(nextId);
                    } else {
                      key = await repo.getTrailingOrderKey();
                    }
                  } else {
                    key = await repo.getOrderKeyBeforeSite(
                      items[targetIndex + 1].id!,
                    );
                  }

                  await repo.assignOrderKey(movedItem.id!, key);
                } catch (e) {
                  localItems.value = persistedItems;
                  if (context.mounted) {
                    ui_helper.showErrorMessage(
                      context,
                      'Failed to reorder top site',
                    );
                  }
                } finally {
                  reorderBusy.value = false;
                }
              },
              childBuilder: (reorderableItemBuilder) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GridView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: layout.crossAxisCount,
                        mainAxisSpacing: _gridMainAxisSpacing,
                        crossAxisSpacing: _gridCrossAxisSpacing,
                        childAspectRatio: layout.childAspectRatio,
                      ),
                      itemCount: localItems.value.length,
                      itemBuilder: (context, index) {
                        final item = localItems.value[index];
                        final draggable = CustomDraggable(
                          key: ValueKey(item.id ?? 'top-site-$index'),
                          data: item.id ?? 'top-site-$index',
                          child: _TopSiteGridTile(
                            item: item,
                            onTap: () => onUriSelected(item.url),
                            showDragHandle: true,
                          ),
                        );
                        return reorderableItemBuilder(draggable, index);
                      },
                    ),
                    if (historyItems.isNotEmpty) ...[
                      const SizedBox(height: 8.0),
                      GridView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: layout.crossAxisCount,
                          mainAxisSpacing: _gridMainAxisSpacing,
                          crossAxisSpacing: _gridCrossAxisSpacing,
                          childAspectRatio: layout.childAspectRatio,
                        ),
                        itemCount: historyItems.length,
                        itemBuilder: (context, index) {
                          final item = historyItems[index];
                          return Opacity(
                            opacity: 0.5,
                            child: _TopSiteGridTile(
                              item: item,
                              onTap: () => onUriSelected(item.url),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _TopSiteGridTile extends StatefulWidget {
  final TopSiteItem item;
  final VoidCallback onTap;
  final VoidCallback? onPin;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;
  final bool showDragHandle;

  const _TopSiteGridTile({
    required this.item,
    required this.onTap,
    this.onPin,
    this.onEdit,
    this.onRemove,
    this.showDragHandle = false,
  });

  static const _iconSize = 40.0;
  static const _borderRadius = BorderRadius.all(Radius.circular(12.0));

  @override
  State<_TopSiteGridTile> createState() => _TopSiteGridTileState();
}

class _TopSiteGridTileState extends State<_TopSiteGridTile> {
  final _menuController = MenuController();

  bool get _hasMenu =>
      (widget.item.isPersisted &&
          (widget.onEdit != null || widget.onRemove != null)) ||
      (!widget.item.isPersisted && widget.onPin != null);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return MenuAnchor(
      controller: _menuController,
      menuChildren: [
        if (!widget.item.isPersisted && widget.onPin != null)
          MenuItemButton(onPressed: widget.onPin, child: const Text('Pin')),
        if (widget.item.isPersisted && widget.onEdit != null)
          MenuItemButton(onPressed: widget.onEdit, child: const Text('Edit')),
        if (widget.item.isPersisted && widget.onRemove != null)
          MenuItemButton(
            onPressed: widget.onRemove,
            child: const Text('Remove'),
          ),
      ],
      child: Material(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: _TopSiteGridTile._borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: _TopSiteGridTile._borderRadius,
          onTap: widget.onTap,
          onLongPress: _hasMenu ? () => _menuController.open() : null,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 10.0,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final titleStyle = textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                    );
                    final lineHeight =
                        (titleStyle?.fontSize ?? 12.0) *
                        (titleStyle?.height ?? 1.2);
                    const textLines = 2;
                    const gap = 6.0;
                    const minIconSize = 18.0;
                    const textHeightPadding = 16.0;
                    final minTextHeight = lineHeight + textHeightPadding;
                    final maxTextHeight =
                        lineHeight * textLines + textHeightPadding;
                    final iconSize =
                        (constraints.maxHeight - minTextHeight - gap).clamp(
                          minIconSize,
                          _TopSiteGridTile._iconSize,
                        );

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          child: SizedBox.square(
                            dimension: iconSize,
                            child: RepaintBoundary(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                child: UrlIcon([
                                  widget.item.url,
                                ], iconSize: iconSize),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: gap),
                        Flexible(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: maxTextHeight,
                            ),
                            child: Text(
                              widget.item.title,
                              maxLines: textLines,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: titleStyle,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              if (widget.item.source == TopSiteSource.pinned)
                Positioned(
                  top: 4,
                  right: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Icon(
                        Icons.push_pin,
                        size: 12,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              if (widget.showDragHandle)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Icon(
                    Icons.drag_indicator,
                    size: 16,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _pinItem(
  BuildContext context,
  WidgetRef ref,
  TopSiteItem item,
) async {
  try {
    await ref
        .read(topSiteRepositoryProvider.notifier)
        .addPinnedSite(title: item.title, url: item.url);
    if (context.mounted) {
      ui_helper.showInfoMessage(context, 'Pinned "${item.title}"');
    }
  } catch (e) {
    if (context.mounted) {
      ui_helper.showErrorMessage(context, 'Failed to pin site');
    }
  }
}

Future<void> _editItem(
  BuildContext context,
  WidgetRef ref,
  TopSiteItem item,
) async {
  if (item.id == null) return;

  final result = await showEditTopSiteDialog(
    context,
    initialTitle: item.title,
    initialUrl: item.url,
  );

  if (result == null || !context.mounted) return;

  try {
    await ref
        .read(topSiteRepositoryProvider.notifier)
        .updatePersistedSite(
          id: item.id!,
          title: result.title,
          url: result.url,
        );
    if (context.mounted) {
      ui_helper.showInfoMessage(context, 'Top site updated');
    }
  } catch (e) {
    if (context.mounted) {
      ui_helper.showErrorMessage(context, 'Failed to update top site');
    }
  }
}

Future<void> _removeItem(
  BuildContext context,
  WidgetRef ref,
  TopSiteItem item,
) async {
  if (item.id == null) return;

  try {
    await ref
        .read(topSiteRepositoryProvider.notifier)
        .removePersistedSite(item.id!);
    if (context.mounted) {
      ui_helper.showInfoMessage(
        context,
        'Removed "${item.title}"',
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            try {
              await ref
                  .read(topSiteRepositoryProvider.notifier)
                  .addPinnedSite(title: item.title, url: item.url);
            } catch (_) {}
          },
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ui_helper.showErrorMessage(context, 'Failed to remove top site');
    }
  }
}
