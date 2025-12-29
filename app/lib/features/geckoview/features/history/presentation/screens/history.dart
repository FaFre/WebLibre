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
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fading_scroll/fading_scroll.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:nullability/nullability.dart';
import 'package:path/path.dart' as p;
import 'package:sliver_tools/sliver_tools.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/delete_data.dart';
import 'package:weblibre/features/geckoview/features/history/domain/entities/history_filter_options.dart';
import 'package:weblibre/features/geckoview/features/history/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/history.dart';
import 'package:weblibre/features/geckoview/features/history/presentation/dialogs/delete_file.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/presentation/hooks/menu_controller.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

class Section extends MultiSliver {
  static final _datePattern = DateFormat.MMMd().addPattern('Hm');

  Section({
    super.key,
    required BuildContext context,
    required String title,
    required List<VisitInfo> items,
    required Set<VisitInfo> selectedItems,
    required void Function(VisitInfo) onTap,
    required void Function(VisitInfo) onLongPress,
  }) : super(
         pushPinnedChildren: true,
         children: [
           SliverPinnedHeader(
             child: Container(
               padding: const EdgeInsets.only(left: 24, top: 8),
               color: Theme.of(context).canvasColor,
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(title, style: Theme.of(context).textTheme.bodyLarge),
                   const Divider(),
                 ],
               ),
             ),
           ),
           SliverList.builder(
             itemCount: items.length,
             itemBuilder: (context, index) {
               final item = items[index];
               final uri = Uri.parse(item.url);

               return Column(
                 key: ValueKey(item.hashCode),
                 mainAxisSize: MainAxisSize.min,
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   ListTile(
                     leading: selectedItems.contains(item)
                         ? const CircleAvatar(
                             radius: 12,
                             child: Icon(Icons.check, size: 12),
                           )
                         : UrlIcon([uri], iconSize: 24),
                     title: item.title.mapNotNull(
                       (title) => Text(
                         switch (item.visitType) {
                           VisitType.download => p.basename(title),
                           _ => title,
                         },
                         maxLines: 2,
                         overflow: TextOverflow.ellipsis,
                       ),
                     ),
                     subtitle: UriBreadcrumb(uri: uri),
                     trailing: Consumer(
                       builder: (context, ref, _) {
                         return IconButton(
                           onPressed: () async {
                             await ref
                                 .read(historyRepositoryProvider.notifier)
                                 .deleteVisit(item);

                             final downloadedFile = item.title.mapNotNull(
                               (title) => File(title),
                             );

                             if (await downloadedFile?.exists() == true) {
                               if (context.mounted) {
                                 final delete = await showDeleteFileDialog(
                                   context,
                                   downloadedFile.toString(),
                                 );

                                 if (delete?.delete == true) {
                                   await downloadedFile!.delete();
                                 }
                               }
                             }

                             // ignore: unused_result
                             await ref.refresh(browsingHistoryProvider.future);
                           },
                           icon: const Icon(MdiIcons.closeCircle),
                         );
                       },
                     ),
                     onTap: () {
                       onTap(item);
                     },
                     onLongPress: () {
                       onLongPress(item);
                     },
                   ),
                   Padding(
                     padding: const EdgeInsets.only(left: 54, right: 16),
                     child: Wrap(
                       spacing: 8.0,
                       children: [
                         Chip(
                           avatar: switch (item.visitType) {
                             VisitType.link => const Icon(MdiIcons.openInNew),
                             VisitType.download => const Icon(
                               MdiIcons.fileDownload,
                             ),
                             VisitType.reload => const Icon(MdiIcons.reload),
                             _ => null,
                           },
                           label: switch (item.visitType) {
                             VisitType.link => const Text('Followed Link'),
                             VisitType.typed => const Text('Typed Address'),
                             VisitType.embed => const Text(
                               'Embedded Page Element',
                             ),
                             VisitType.redirectPermanent => const Text(
                               'Temporary Redirect',
                             ),
                             VisitType.redirectTemporary => const Text(
                               'Permanent Redirect',
                             ),
                             VisitType.download => const Text('Download'),
                             VisitType.framedLink => const Text('Frame'),
                             VisitType.reload => const Text('Page Reload'),
                             VisitType.bookmark => throw UnimplementedError(),
                           },
                         ),
                         Chip(
                           label: Text(
                             _datePattern.format(
                               DateTime.fromMillisecondsSinceEpoch(
                                 item.visitTime,
                               ),
                             ),
                           ),
                         ),
                       ],
                     ),
                   ),
                 ],
               );
             },
           ),
         ],
       );
}

class HistoryScreen extends HookConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyFilter = ref.watch(historyFilterProvider);

    final textFilterEnabled = useState(false);
    final textFilterController = useTextEditingController();

    final menuController = useMenuController();

    final historyEntries = ref.watch(browsingHistoryProvider);

    final selectedItems = useState(<VisitInfo>{});

    return Scaffold(
      appBar: AppBar(
        title: textFilterEnabled.value
            ? TextField(
                controller: textFilterController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(top: 12),
                  border: InputBorder.none,
                  hintText: 'Filter history...',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  suffixIcon: IconButton(
                    onPressed: () {
                      if (textFilterController.text.isNotEmpty) {
                        textFilterController.clear();
                      } else {
                        textFilterEnabled.value = false;
                      }
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ),
              )
            : selectedItems.value.isEmpty
            ? const Text('History')
            : Text('${selectedItems.value.length} selected'),
        actions: [
          if (selectedItems.value.isNotEmpty)
            IconButton(
              onPressed: () async {
                DeleteDecision? deleteDecision;

                for (final item in selectedItems.value) {
                  await ref
                      .read(historyRepositoryProvider.notifier)
                      .deleteVisit(item);

                  final downloadedFile = item.title.mapNotNull(
                    (title) => File(title),
                  );

                  if (await downloadedFile?.exists() == true) {
                    if (deleteDecision?.remember == true) {
                      if (deleteDecision?.delete == true) {
                        await downloadedFile!.delete();
                      }
                    } else if (context.mounted) {
                      deleteDecision = await showDeleteFileDialog(
                        context,
                        downloadedFile.toString(),
                        multiFileMode: true,
                      );

                      if (deleteDecision?.delete == true) {
                        await downloadedFile!.delete();
                      }
                    }
                  }
                }

                selectedItems.value = {};
                // ignore: unused_result
                await ref.refresh(browsingHistoryProvider.future);
              },
              icon: const Icon(Icons.delete),
            )
          else
            IconButton(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return const DeleteDataDialog(
                      initialSettings: {DeleteBrowsingDataType.history},
                    );
                  },
                );

                // ignore: unused_result
                await ref.refresh(browsingHistoryProvider.future);
              },
              icon: const Icon(Icons.delete),
            ),
          MenuAnchor(
            controller: menuController,
            consumeOutsideTap: true,
            menuChildren: [
              MenuItemButton(
                leadingIcon: const Icon(Icons.search),
                child: const Text('Text Filter'),
                onPressed: () {
                  textFilterEnabled.value = true;
                },
              ),
              MenuItemButton(
                closeOnActivate: false,
                leadingIcon: const Icon(MdiIcons.calendarRange),
                trailingIcon: historyFilter.dateRange.mapNotNull(
                  (_) => IconButton(
                    onPressed: () {
                      ref
                          .read(historyFilterProvider.notifier)
                          .setDateRange(null);
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ),
                child:
                    historyFilter.dateRange.mapNotNull(
                      (range) => Text(
                        '${DateFormat.yMd().format(range.start)} - ${DateFormat.yMd().format(range.end)}',
                      ),
                    ) ??
                    const Text('Filter Date'),
                onPressed: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    initialDateRange: historyFilter.dateRange,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now(),
                  );

                  ref
                      .read(historyFilterProvider.notifier)
                      .setDateRange(
                        range.mapNotNull(
                          (range) => DateTimeRange(
                            start: range.start,
                            //Make sure to include last day fully
                            end: range.end.add(
                              const Duration(days: 1) -
                                  const Duration(milliseconds: 1),
                            ),
                          ),
                        ),
                      );
                },
              ),
              const Divider(),
              ...{VisitType.link, VisitType.reload, VisitType.download}.map(
                (type) => CheckboxMenuButton(
                  closeOnActivate: false,
                  value: historyFilter.visitTypes.contains(type),
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(historyFilterProvider.notifier)
                          .updateVisitType(type, value);
                    }
                  },
                  child: switch (type) {
                    VisitType.link => const Text('Followed Links'),
                    VisitType.typed => const Text('Typed Addresses'),
                    VisitType.embed => const Text('Embedded Page Elements'),
                    VisitType.redirectPermanent => const Text(
                      'Temporary Redirects',
                    ),
                    VisitType.redirectTemporary => const Text(
                      'Permanent Redirects',
                    ),
                    VisitType.download => const Text('Downloads'),
                    VisitType.framedLink => const Text('Frames'),
                    VisitType.reload => const Text('Page Reloads'),
                    VisitType.bookmark => throw UnimplementedError(),
                  },
                ),
              ),
              const Divider(),
              MenuItemButton(
                leadingIcon: const Icon(MdiIcons.restore),
                child: const Text('Reset Filter'),
                onPressed: () {
                  textFilterController.clear();
                  textFilterEnabled.value = false;

                  ref.read(historyFilterProvider.notifier).reset();
                },
              ),
            ],
            child: IconButton(
              onPressed: () {
                if (menuController.isOpen) {
                  menuController.close();
                } else {
                  menuController.open();
                }
              },
              icon: Badge(
                isLabelVisible:
                    historyFilter != HistoryFilterOptions.withDefaults(),
                child: const Icon(MdiIcons.filter),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: historyEntries.when(
          skipLoadingOnReload: true,
          data: (data) {
            return RefreshIndicator(
              onRefresh: () async {
                // ignore: unused_result
                await ref.refresh(browsingHistoryProvider.future);
              },
              child: HookBuilder(
                builder: (context) {
                  final textFilter = useListenableSelector(
                    textFilterController,
                    () => textFilterController.text.toLowerCase(),
                  );

                  final groups = useMemoized(
                    () => data
                        .where(
                          (visit) =>
                              textFilter.isEmpty ||
                              visit.title?.toLowerCase().contains(textFilter) ==
                                  true ||
                              visit.url.toLowerCase().contains(textFilter),
                        )
                        .groupListsBy(
                          (element) => timeago.format(
                            DateTime.fromMillisecondsSinceEpoch(
                              element.visitTime,
                            ),
                          ),
                        ),
                    [EquatableValue(data), textFilter],
                  );

                  void toggleSelected(VisitInfo item) {
                    if (selectedItems.value.contains(item)) {
                      selectedItems.value = {...selectedItems.value}
                        ..remove(item);
                    } else {
                      selectedItems.value = {...selectedItems.value, item};
                    }
                  }

                  return FadingScroll(
                    startFadingSize: 0.0,
                    builder: (context, controller) {
                      return CustomScrollView(
                        controller: controller,
                        slivers: [
                          for (final MapEntry(:key, :value) in groups.entries)
                            Section(
                              context: context,
                              title: key,
                              items: value,
                              selectedItems: selectedItems.value,
                              onLongPress: toggleSelected,
                              onTap: (item) async {
                                if (selectedItems.value.isNotEmpty) {
                                  toggleSelected(item);
                                } else {
                                  await ref
                                      .read(tabRepositoryProvider.notifier)
                                      .addTab(
                                        url: Uri.parse(item.url),
                                        private: false,
                                      );

                                  if (context.mounted) {
                                    context.pop();
                                  }
                                }
                              },
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            );
          },
          error: (error, stackTrace) => Center(
            child: FailureWidget(
              title: 'Failed to load History',
              exception: error,
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
