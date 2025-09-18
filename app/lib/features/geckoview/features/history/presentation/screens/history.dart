import 'package:collection/collection.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:nullability/nullability.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:weblibre/features/geckoview/features/history/domain/providers.dart';
import 'package:weblibre/presentation/hooks/menu_controller.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

class Section extends MultiSliver {
  static final _datePattern = DateFormat('yMMMMd').addPattern('Hm');

  Section({
    Key? key,
    required BuildContext context,
    required String title,
    required List<VisitInfo> items,
  }) : super(
         key: key,
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
                     leading: UrlIcon([Uri.parse(item.url)], iconSize: 24),
                     title: item.title.mapNotNull((title) => Text(title)),
                     subtitle: Text(
                       item.url,
                       maxLines: 2,
                       overflow: TextOverflow.ellipsis,
                     ),
                   ),
                   Padding(
                     padding: const EdgeInsets.only(left: 54),
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

    return Scaffold(
      appBar: AppBar(
        actions: [
          MenuAnchor(
            controller: menuController,
            menuChildren: [
              ...VisitType.values
                  .whereNot(
                    (element) => const {VisitType.bookmark}.contains(element),
                  )
                  .map(
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
              icon: const Icon(Icons.more_vert),
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

                return CustomScrollView(
                  slivers: [
                    for (final MapEntry(:key, :value) in groups.entries)
                      Section(context: context, title: key, items: value),
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
