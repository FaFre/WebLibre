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
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:nullability/nullability.dart';

class _BadgeWrapper extends StatelessWidget {
  final Widget child;
  final int? count;

  const _BadgeWrapper({required this.child, this.count});

  @override
  Widget build(BuildContext context) {
    return count != null
        ? Badge.count(
            count: count!,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            textColor: Theme.of(context).colorScheme.onPrimaryContainer,
            child: child,
          )
        : child;
  }
}

class _GestureWrapper extends StatelessWidget {
  final Widget child;
  final GestureLongPressCallback? onLongPress;

  const _GestureWrapper({required this.child, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return onLongPress != null
        ? InkWell(onLongPress: onLongPress, child: child)
        : child;
  }
}

/// Per-item visual / delete-button overrides for [SelectableChips].
///
/// Grouped into a single value so the [SelectableChips] constructor
/// doesn't grow another knob every time a new variant adds a per-item
/// override. Pass via [SelectableChips.decoration]; any callback left
/// null falls back to the [FilterChip] default for that property.
///
/// All callbacks receive the item and (where applicable) its current
/// `isSelected` flag so the decoration can branch on selection state.
class SelectableChipDecoration<T> {
  final Color? Function(T item, bool isSelected)? color;
  final BorderSide? Function(T item, bool isSelected)? side;
  final Widget? Function(T item)? deleteIcon;
  final EdgeInsetsGeometry? Function(T item)? labelPadding;

  /// Per-item override for the global [SelectableChips.enableDelete] toggle.
  /// When [SelectableChips.enableDelete] is false, no item shows a delete
  /// button regardless of this callback. When it's true, this callback
  /// can hide the delete button for individual items (returning false).
  final bool Function(T item)? canDelete;

  const SelectableChipDecoration({
    this.color,
    this.side,
    this.deleteIcon,
    this.labelPadding,
    this.canDelete,
  });
}

class SelectableChips<T extends S, S, K> extends StatelessWidget {
  final Iterable<T> availableItems;
  final List<Widget> prefixListItems;
  final S? selectedItem;
  final int? maxCount;
  final bool enableDelete;
  final bool sortSelectedFirst;

  final ScrollController? scrollController;
  final GlobalKey? activeItemKey;
  final double? cacheExtent;

  final K Function(S item) itemId;
  final Widget Function(T item) itemLabel;
  final Widget? Function(T item)? itemAvatar;
  final String? Function(T item)? itemTooltip;
  final int? Function(T item)? itemBadgeCount;
  final Color? selectedBorderColor;
  final SelectableChipDecoration<T>? decoration;

  final Widget Function(Widget child, S item)? itemWrap;

  final void Function(T item)? onSelected;
  final void Function(T item)? onDeleted;
  final void Function(T item)? onLongPress;

  const SelectableChips({
    required this.itemId,
    required this.itemLabel,
    this.itemAvatar,
    this.itemBadgeCount,
    this.itemWrap,
    this.itemTooltip,
    this.selectedBorderColor,
    this.decoration,
    this.prefixListItems = const [],
    required this.availableItems,
    this.selectedItem,
    this.maxCount = 25,
    this.enableDelete = true,
    this.onSelected,
    this.onDeleted,
    this.onLongPress,
    this.sortSelectedFirst = true,
    this.scrollController,
    this.activeItemKey,
    this.cacheExtent = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var items = (maxCount != null)
        ? availableItems.take(maxCount!).toList()
        : availableItems.toList();

    if (sortSelectedFirst) {
      if (selectedItem case final T selectedItem) {
        final selectedIndex = items.indexWhere(
          (item) => itemId(item) == itemId(selectedItem),
        );
        if (selectedIndex < 0) {
          items = [selectedItem, ...items];
        } else {
          items = [items.removeAt(selectedIndex), ...items];
        }
      }
    }

    return FadingScroll(
      controller: scrollController,
      fadingSize: 15,
      builder: (context, controller) {
        return ListView.builder(
          controller: controller,
          cacheExtent: cacheExtent,
          scrollDirection: Axis.horizontal,
          itemCount: prefixListItems.length + items.length,
          itemBuilder: (context, index) {
            if (index < prefixListItems.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 4.0, right: 4),
                child: prefixListItems[index],
              );
            }

            final item = items[index - prefixListItems.length];
            final isSelected =
                selectedItem != null &&
                itemId(item) == itemId(selectedItem as S);
            final deco = decoration;
            final itemColorValue = deco?.color?.call(item, isSelected);
            final canDeleteItem =
                enableDelete && (deco?.canDelete?.call(item) ?? true);
            final child = Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 4.0),
              child: _BadgeWrapper(
                count: itemBadgeCount?.call(item),
                child: _GestureWrapper(
                  onLongPress: onLongPress.mapNotNull(
                    (callback) =>
                        () => callback(item),
                  ),
                  child: FilterChip(
                    color: itemColorValue != null
                        ? WidgetStatePropertyAll(itemColorValue)
                        : null,
                    selected: selectedBorderColor == null && isSelected,
                    showCheckmark: false,
                    labelPadding: deco?.labelPadding?.call(item),
                    deleteIcon: deco?.deleteIcon?.call(item),
                    onSelected: (value) {
                      if (value) {
                        onSelected?.call(item);
                      } else {
                        onDeleted?.call(item);
                      }
                    },
                    onDeleted: canDeleteItem
                        ? () {
                            onDeleted?.call(item);
                          }
                        : null,
                    label: itemLabel.call(item),
                    avatar: itemAvatar?.call(item),
                    tooltip: itemTooltip?.call(item),
                    side:
                        deco?.side?.call(item, isSelected) ??
                        (isSelected && selectedBorderColor != null
                            ? BorderSide(
                                color: selectedBorderColor!,
                                width: 2.0,
                              )
                            : null),
                  ),
                ),
              ),
            );

            final wrappedChild = (itemWrap != null)
                ? itemWrap!(child, item)
                : child;

            return isSelected && activeItemKey != null
                ? KeyedSubtree(key: activeItemKey, child: wrappedChild)
                : wrappedChild;
          },
        );
      },
    );
  }
}
