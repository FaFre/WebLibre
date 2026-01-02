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

class SelectableChips<T extends S, S, K> extends StatelessWidget {
  final Iterable<T> availableItems;
  final List<Widget> prefixListItems;
  final S? selectedItem;
  final int maxCount;
  final bool enableDelete;
  final bool sortSelectedFirst;

  final ScrollController? scrollController;

  final K Function(S item) itemId;
  final Widget Function(T item) itemLabel;
  final Widget? Function(T item)? itemAvatar;
  final String? Function(T item)? itemTooltip;
  final int? Function(T item)? itemBadgeCount;
  final Color? Function(T item)? itemBackgroundColor;
  final Color? selectedBorderColor;

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
    this.itemBackgroundColor,
    this.selectedBorderColor,
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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var items = availableItems.take(maxCount).toList();
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
          //Improve list performance by not rendering outside screen at all
          cacheExtent: 0,
          scrollDirection: Axis.horizontal,
          itemCount: prefixListItems.length + items.length,
          itemBuilder: (context, index) {
            if (index < prefixListItems.length) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 4.0),
                child: prefixListItems[index],
              );
            }

            final item = items[index - prefixListItems.length];
            final isSelected =
                selectedItem != null &&
                itemId(item) == itemId(selectedItem as S);
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
                    selected: selectedBorderColor == null && isSelected,
                    showCheckmark: false,
                    onSelected: (value) {
                      if (value) {
                        onSelected?.call(item);
                      } else {
                        onDeleted?.call(item);
                      }
                    },
                    onDeleted: enableDelete
                        ? () {
                            onDeleted?.call(item);
                          }
                        : null,
                    label: itemLabel.call(item),
                    avatar: itemAvatar?.call(item),
                    tooltip: itemTooltip?.call(item),
                    backgroundColor: itemBackgroundColor?.call(item),
                    side: isSelected && selectedBorderColor != null
                        ? BorderSide(color: selectedBorderColor!, width: 2.0)
                        : null,
                  ),
                ),
              ),
            );

            return (itemWrap != null) ? itemWrap!(child, item) : child;
          },
        );
      },
    );
  }
}
