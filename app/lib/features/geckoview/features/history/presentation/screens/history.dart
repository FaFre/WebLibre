import 'package:collection/collection.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:nullability/nullability.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/delete_data.dart';
import 'package:weblibre/features/geckoview/features/history/domain/providers.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/presentation/hooks/menu_controller.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';
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
                         : UrlIcon([Uri.parse(item.url)], iconSize: 24),
                     title: item.title.mapNotNull((title) => Text(title)),
                     subtitle: Text(
                       item.url,
                       maxLines: 2,
                       overflow: TextOverflow.ellipsis,
                     ),
                     trailing: Consumer(
                       builder: (context, ref, _) {
                         return IconButton(
                           onPressed: () async {
                             final service = GeckoHistoryService();
                             await service.deleteVisit(item);
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

    final menuController = useMenuController();

    final historyEntries = ref.watch(browsingHistoryProvider);

    final selectedItems = useState(<VisitInfo>{});

    return Scaffold(
      appBar: AppBar(
        title: selectedItems.value.isEmpty
            ? const Text('History')
            : Text('${selectedItems.value.length} selected'),
        actions: [
          if (selectedItems.value.isNotEmpty)
            IconButton(
              onPressed: () async {
                for (final item in selectedItems.value) {
                  final service = GeckoHistoryService();
                  await service.deleteVisit(item);
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
            menuChildren: [
              MenuItemButton(
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
              ...{
                VisitType.link,
                VisitType.typed,
                VisitType.reload,
                VisitType.download,
              }.map(
                (type) => CheckboxMenuButton(
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
            ],
            child: IconButton(
              onPressed: () {
                if (menuController.isOpen) {
                  menuController.close();
                } else {
                  menuController.open();
                }
              },
              icon: const Icon(MdiIcons.filter),
            ),
          ),
        ],
      ),
      body: historyEntries.when(
        data: (data) {
          return RefreshIndicator(
            onRefresh: () async {
              // ignore: unused_result
              await ref.refresh(browsingHistoryProvider.future);
            },
            child: HookBuilder(
              builder: (context) {
                final groups = useMemoized(
                  () => data.groupListsBy(
                    (element) => timeago.format(
                      DateTime.fromMillisecondsSinceEpoch(element.visitTime),
                    ),
                  ),
                  [EquatableValue(data)],
                );

                void toggleSelected(VisitInfo item) {
                  if (selectedItems.value.contains(item)) {
                    selectedItems.value = {...selectedItems.value}
                      ..remove(item);
                  } else {
                    selectedItems.value = {...selectedItems.value, item};
                  }
                }

                return CustomScrollView(
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
    );
  }
}
