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
import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:nullability/nullability.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/delete_data.dart';
import 'package:weblibre/features/geckoview/features/history/domain/entities/history_entry.dart';
import 'package:weblibre/features/geckoview/features/history/domain/entities/history_filter_options.dart';
import 'package:weblibre/features/geckoview/features/history/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/container_history.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/recently_closed_tabs.dart';
import 'package:weblibre/features/geckoview/features/history/presentation/dialogs/delete_file.dart';
import 'package:weblibre/features/geckoview/features/history/presentation/dialogs/delete_time_range.dart';
import 'package:weblibre/features/geckoview/features/history/presentation/utils/history_day_l10n.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/hooks/menu_controller.dart';
import 'package:weblibre/presentation/utils/units_l10n.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class Section extends MultiSliver {
  Section({
    super.key,
    required BuildContext context,
    required String title,
    required List<HistoryEntry> items,
    required Set<HistoryEntryId> selectedIds,
    required Map<String, ContainerData> containersById,
    required void Function(HistoryEntry) onTap,
    required void Function(HistoryEntry) onLongPress,
    required Future<void> Function(HistoryEntry) onDelete,
    Future<void> Function(HistoryEntry, DownloadControl)? onDownloadControl,
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
                 // Which entry the row is, not its state: the hash takes in a
                 // running download's progress, so keyed by it the row (and
                 // an open ⋮ menu) was rebuilt on every update.
                 key: ValueKey(item.id),
                 mainAxisSize: MainAxisSize.min,
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   ListTile(
                     // M3 list items keep 16 on both sides. ListTile ends 24
                     // from the edge, and the ⋮ button centers its icon in a
                     // 48 target, so the icon sat 36 from the edge against
                     // the favicon's 16 (#651). 4 + 12 brings it to 16.
                     contentPadding: const EdgeInsetsDirectional.only(
                       start: 16,
                       end: 4,
                     ),
                     leading: selectedIds.contains(item.id)
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
                     trailing: _HistoryEntryMenu(
                       item: item,
                       onDelete: onDelete,
                       onDownloadControl: onDownloadControl,
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
                       runSpacing: 4.0,
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
                             VisitType.link => Text(
                               AppLocalizations.of(
                                 context,
                               ).history_visitTypeFollowedLink,
                             ),
                             VisitType.typed => Text(
                               AppLocalizations.of(
                                 context,
                               ).history_visitTypeTypedAddress,
                             ),
                             VisitType.embed => Text(
                               AppLocalizations.of(
                                 context,
                               ).history_visitTypeEmbeddedPageElement,
                             ),
                             VisitType.redirectPermanent => Text(
                               AppLocalizations.of(
                                 context,
                               ).history_visitTypePermanentRedirect,
                             ),
                             VisitType.redirectTemporary => Text(
                               AppLocalizations.of(
                                 context,
                               ).history_visitTypeTemporaryRedirect,
                             ),
                             VisitType.download => Text(
                               AppLocalizations.of(
                                 context,
                               ).history_visitTypeDownload,
                             ),
                             VisitType.framedLink => Text(
                               AppLocalizations.of(
                                 context,
                               ).history_visitTypeFrame,
                             ),
                             VisitType.reload => Text(
                               AppLocalizations.of(
                                 context,
                               ).history_visitTypePageReload,
                             ),
                             VisitType.bookmark => Text(
                               AppLocalizations.of(
                                 context,
                               ).history_visitTypeBookmark,
                             ),
                           },
                         ),
                         // The day is the section heading's.
                         Chip(
                           label: Text(
                             MaterialLocalizations.of(context).formatTimeOfDay(
                               TimeOfDay.fromDateTime(
                                 DateTime.fromMillisecondsSinceEpoch(
                                   item.visitTime,
                                 ),
                               ),
                               alwaysUse24HourFormat:
                                   MediaQuery.alwaysUse24HourFormatOf(context),
                             ),
                           ),
                         ),
                         if (item.olderVisits.isNotEmpty)
                           Chip(
                             avatar: const Icon(MdiIcons.history),
                             label: Text(
                               AppLocalizations.of(context).history_visitCount(
                                 item.olderVisits.length + 1,
                               ),
                             ),
                           ),
                         for (final containerId in item.containerIds)
                           if (containersById[containerId]
                               case final container?)
                             Chip(
                               avatar: CircleAvatar(
                                 backgroundColor: container.color,
                                 radius: 8,
                               ),
                               label: Text(
                                 container.name ??
                                     AppLocalizations.of(
                                       context,
                                     ).history_unnamedContainer,
                               ),
                             ),
                       ],
                     ),
                   ),
                   if (item.isUnfinishedDownload)
                     Padding(
                       padding: const EdgeInsets.only(
                         left: 54,
                         right: 16,
                         top: 8,
                       ),
                       child: _DownloadProgress(item: item),
                     ),
                 ],
               );
             },
           ),
         ],
       );
}

/// How far an unfinished download got, under its row.
class _DownloadProgress extends StatelessWidget {
  final HistoryEntry item;

  const _DownloadProgress({required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final status = item.downloadStatus;
    final downloaded = item.downloadedBytes ?? 0;
    final size = item.downloadSize;
    final hasSize = size != null && size > 0;

    final label = switch (status) {
      DownloadStatus.initiated => l10n.history_downloadStatusStarting,
      DownloadStatus.downloading => l10n.history_downloadStatusDownloading,
      DownloadStatus.paused => l10n.history_downloadStatusPaused,
      DownloadStatus.failed => l10n.history_downloadStatusFailed,
      DownloadStatus.completed || DownloadStatus.cancelled || null => null,
    };
    final style = theme.textTheme.bodySmall?.copyWith(
      color: status == DownloadStatus.failed
          ? theme.colorScheme.error
          : theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status != DownloadStatus.failed)
          LinearProgressIndicator(
            // Indeterminate only while it runs with no size to measure by.
            value: hasSize
                ? (downloaded / size).clamp(0.0, 1.0)
                : (status == DownloadStatus.paused ? 0 : null),
          ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 12,
          children: [
            if (label != null) Text(label, style: style),
            if (status != DownloadStatus.failed)
              Text(
                hasSize
                    ? l10n.history_downloadProgress(
                        formatByteSize(l10n, downloaded),
                        formatByteSize(l10n, size),
                      )
                    : formatByteSize(l10n, downloaded),
                style: style,
              ),
          ],
        ),
      ],
    );
  }
}

/// Per-row actions, behind a ⋮ like the bookmark list rather than an inline
/// delete button on every row (#651). Long press still starts multi-select.
class _HistoryEntryMenu extends HookConsumerWidget {
  final HistoryEntry item;
  final Future<void> Function(HistoryEntry) onDelete;
  final Future<void> Function(HistoryEntry, DownloadControl)? onDownloadControl;

  const _HistoryEntryMenu({
    required this.item,
    required this.onDelete,
    this.onDownloadControl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = useMenuController();
    final isDownload = item.visitType == VisitType.download;

    return MenuAnchor(
      controller: controller,
      builder: (context, controller, child) => IconButton(
        tooltip: l10n.history_tooltipEntryActions,
        onPressed: () {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        },
        icon: const Icon(MdiIcons.dotsVertical),
      ),
      menuChildren: [
        if (onDownloadControl case final control?)
          for (final (action, icon, label) in switch (item.downloadStatus) {
            DownloadStatus.initiated || DownloadStatus.downloading => [
              (
                DownloadControl.pause,
                Icons.pause,
                l10n.history_downloadActionPause,
              ),
              (
                DownloadControl.cancel,
                Icons.close,
                l10n.history_downloadActionCancel,
              ),
            ],
            DownloadStatus.paused => [
              (
                DownloadControl.resume,
                Icons.play_arrow,
                l10n.history_downloadActionResume,
              ),
              (
                DownloadControl.cancel,
                Icons.close,
                l10n.history_downloadActionCancel,
              ),
            ],
            DownloadStatus.failed => [
              (DownloadControl.retry, Icons.refresh, l10n.common_retry),
            ],
            DownloadStatus.completed ||
            DownloadStatus.cancelled ||
            null => const <(DownloadControl, IconData, String)>[],
          })
            MenuItemButton(
              leadingIcon: Icon(icon),
              onPressed: () => control(item, action),
              child: Text(label),
            ),
        if (!isDownload)
          MenuItemButton(
            leadingIcon: const Icon(MdiIcons.tab),
            child: Text(l10n.history_actionOpenInBackground),
            onPressed: () async {
              final repo = ref.read(tabRepositoryProvider.notifier);
              final router = GoRouter.of(context);
              final tabId = await repo.addTab(
                url: Uri.parse(item.url),
                tabMode: TabMode.regular,
                selectTab: false,
              );

              if (context.mounted) {
                ui_helper.showTabSwitchMessage(
                  context,
                  onSwitch: () async {
                    await repo.selectTab(tabId);
                    // Selecting alone leaves this screen over the browser.
                    // The router, not this row's context: the row may have
                    // scrolled away while the snackbar was up.
                    router.go(const BrowserRoute().location);
                  },
                );
              }
            },
          ),
        MenuItemButton(
          leadingIcon: const Icon(MdiIcons.contentCopy),
          child: Text(l10n.history_actionCopyLink),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: item.url));
          },
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.share),
          child: Text(l10n.history_actionShareLink),
          onPressed: () async {
            await SharePlus.instance.share(ShareParams(text: item.url));
          },
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.delete),
          child: Text(l10n.common_delete),
          onPressed: () async {
            await onDelete(item);
          },
        ),
      ],
    );
  }
}

enum HistoryScreenMode { history, downloads }

class HistoryScreen extends HookConsumerWidget {
  const HistoryScreen({super.key, this.mode = HistoryScreenMode.history});

  final HistoryScreenMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDownloadsMode = mode == HistoryScreenMode.downloads;

    final textFilterEnabled = useState(false);
    final textFilterController = useTextEditingController();

    final menuController = useMenuController();
    final deleteMenuController = useMenuController();

    final historyFilter = isDownloadsMode
        ? ref.watch(historyDownloadsFilterProvider)
        : ref.watch(historyVisitsFilterProvider);
    final historyEntries = isDownloadsMode
        ? ref.watch(browsingDownloadsProvider)
        : ref.watch(browsingHistoryProvider);

    final containers = ref.watch(
      watchContainersWithCountProvider.select((value) => value.value),
    );
    final containersById = <String, ContainerData>{
      for (final container in containers ?? const <ContainerData>[])
        container.id: container,
    };
    final filterContainer = historyFilter.containerId.mapNotNull(
      (id) => containersById[id],
    );

    // By id: a running download's entry is replaced on every update.
    final selectedIds = useState(<HistoryEntryId>{});
    // The entries as listed now. Also leaves out rows gone since.
    final selectedRows = selectedIds.value.isEmpty
        ? const <HistoryEntry>[]
        : [
            for (final entry in historyEntries.value ?? const <HistoryEntry>[])
              if (selectedIds.value.contains(entry.id)) entry,
          ];
    // The mode never changes for a screen, so neither does this watch.
    final recentlyClosedCount = isDownloadsMode
        ? 0
        : ref.watch(
            recentlyClosedTabsRepositoryProvider.select(
              (value) => value.value?.length ?? 0,
            ),
          );
    final defaultDownloadsFilter = HistoryFilterOptions(
      dateRange: null,
      visitTypes: const {VisitType.download},
    );
    final hasActiveFilter = isDownloadsMode
        ? historyFilter != defaultDownloadsFilter
        : historyFilter != HistoryFilterOptions.withDefaults();

    Future<void> refreshHistoryEntries() async {
      if (isDownloadsMode) {
        // ignore: unused_result
        await ref.refresh(browsingDownloadsProvider.future);
      } else {
        // ignore: unused_result
        await ref.refresh(browsingHistoryProvider.future);
      }
    }

    void setDateRange(DateTimeRange<DateTime>? range) {
      if (isDownloadsMode) {
        ref.read(historyDownloadsFilterProvider.notifier).setDateRange(range);
      } else {
        ref.read(historyVisitsFilterProvider.notifier).setDateRange(range);
      }
    }

    // Running downloads change only on the engine's side; follow them.
    final hasRunningDownload =
        isDownloadsMode &&
        (historyEntries.value?.any(
              (entry) => switch (entry.downloadStatus) {
                DownloadStatus.initiated || DownloadStatus.downloading => true,
                _ => false,
              },
            ) ??
            false);
    useEffect(() {
      if (!hasRunningDownload) return null;
      final timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => ref.invalidate(browsingDownloadsProvider),
      );
      return timer.cancel;
    }, [hasRunningDownload]);

    Future<void> controlDownload(
      HistoryEntry item,
      DownloadControl control,
    ) async {
      final downloadId = item.contentId;
      if (downloadId == null) return;

      await GeckoDownloadsService().controlDownload(downloadId, control);
      // The service updates the list a moment after it gets the request.
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (context.mounted) await refreshHistoryEntries();
    }

    // Delete [rows] with every visit each stands for (a Distinct URLs row
    // covers all visits of its URL, or it would resurface as the next older
    // one), asking about each downloaded file still on the device.
    Future<void> deleteRows(Iterable<HistoryEntry> rows) async {
      final visits = [for (final row in rows) ...row.allVisits];
      final downloadCount = visits
          .where((visit) => visit.visitType == VisitType.download)
          .length;
      final repository = ref.read(containerHistoryRepositoryProvider.notifier);

      DeleteDecision? decision;
      for (final visit in visits) {
        // Stopped first, or the service would go on writing the file.
        if (visit.isUnfinishedDownload &&
            visit.downloadStatus != DownloadStatus.failed &&
            visit.contentId != null) {
          await GeckoDownloadsService().controlDownload(
            visit.contentId!,
            DownloadControl.cancel,
          );
        }
        await repository.deleteVisit(visit);

        // A download's title is its file path.
        if (visit.visitType != VisitType.download) continue;
        final file = visit.title.mapNotNull(File.new);
        if (file == null || !await file.exists()) continue;

        if (decision?.remember != true) {
          if (!context.mounted) continue;
          decision = await showDeleteFileDialog(
            context,
            file.path,
            multiFileMode: downloadCount > 1,
          );
        }
        if (decision?.delete == true) {
          await file.delete();
        }
      }

      await refreshHistoryEntries();
    }

    Future<void> clearContainerHistory(ContainerData container) async {
      final confirmed = await showDialog<bool>(
        context: context,
        anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.warning),
          title: Text(l10n.history_clearContainerHistoryTitle),
          content: Text(
            l10n.history_clearContainerHistoryContent(
              container.name ?? l10n.history_unnamedContainer,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.common_cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.common_clear),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await ref
            .read(containerHistoryRepositoryProvider.notifier)
            .deleteContainerHistory(container.id);
        await refreshHistoryEntries();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: textFilterEnabled.value
            ? TextField(
                controller: textFilterController,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  // Collapsed so the box is exactly the text: any asymmetric
                  // content padding would offset the text from the centre the
                  // app bar aligns the action icons to.
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: isDownloadsMode
                      ? l10n.history_filterHintDownloads
                      : l10n.history_filterHintHistory,
                ),
              )
            : selectedRows.isEmpty
            ? Text(
                isDownloadsMode
                    ? l10n.history_titleDownloads
                    : l10n.history_titleHistory,
              )
            : Text(l10n.history_selectionCount(selectedRows.length)),
        actions: [
          if (selectedRows.isEmpty)
            IconButton(
              tooltip: textFilterEnabled.value
                  ? l10n.history_tooltipClearSearch
                  : isDownloadsMode
                  ? l10n.history_tooltipSearchDownloads
                  : l10n.history_tooltipSearchHistory,
              onPressed: () {
                if (!textFilterEnabled.value) {
                  textFilterEnabled.value = true;
                } else if (textFilterController.text.isNotEmpty) {
                  textFilterController.clear();
                } else {
                  textFilterEnabled.value = false;
                }
              },
              icon: Icon(textFilterEnabled.value ? Icons.clear : Icons.search),
            ),
          if (selectedRows.isNotEmpty)
            IconButton(
              onPressed: () async {
                final rows = selectedRows;
                selectedIds.value = {};
                await deleteRows(rows);
              },
              icon: const Icon(Icons.delete),
            )
          else if (filterContainer != null || isDownloadsMode)
            IconButton(
              // Mirror what the list currently shows: with a container filter
              // active, clear only that container's history; on the downloads
              // screen, open the delete-browsing-data sheet for downloads. The
              // unfiltered history screen gets the menu below instead.
              tooltip: filterContainer != null
                  ? l10n.history_tooltipClearContainerHistory(
                      filterContainer.name ?? l10n.history_unnamedContainer,
                    )
                  : null,
              onPressed: () async {
                if (filterContainer != null) {
                  await clearContainerHistory(filterContainer);
                  return;
                }

                await showDeleteDataDialog(
                  context,
                  initialSettings: {DeleteBrowsingDataType.downloads},
                );

                await refreshHistoryEntries();
              },
              icon: const Icon(Icons.delete),
            )
          else
            MenuAnchor(
              controller: deleteMenuController,
              menuChildren: [
                MenuItemButton(
                  leadingIcon: const Icon(MdiIcons.clockRemoveOutline),
                  child: Text(l10n.history_deleteMenuTimeRange),
                  onPressed: () async {
                    final range = await showDeleteTimeRangeDialog(
                      context,
                      initialRange: historyFilter.dateRange,
                    );
                    if (range == null) return;

                    await ref
                        .read(containerHistoryRepositoryProvider.notifier)
                        .deleteVisitsBetween(range.start, range.end);

                    await refreshHistoryEntries();
                  },
                ),
                MenuItemButton(
                  leadingIcon: const Icon(MdiIcons.deleteSweepOutline),
                  child: Text(l10n.history_deleteMenuBrowsingData),
                  onPressed: () async {
                    await showDeleteDataDialog(
                      context,
                      initialSettings: {DeleteBrowsingDataType.history},
                    );

                    await refreshHistoryEntries();
                  },
                ),
              ],
              child: IconButton(
                tooltip: l10n.history_tooltipDeleteHistory,
                onPressed: () {
                  if (deleteMenuController.isOpen) {
                    deleteMenuController.close();
                  } else {
                    deleteMenuController.open();
                  }
                },
                icon: const Icon(Icons.delete),
              ),
            ),
          if (selectedRows.isEmpty)
            MenuAnchor(
              controller: menuController,
              consumeOutsideTap: true,
              menuChildren: [
                MenuItemButton(
                  closeOnActivate: false,
                  leadingIcon: const Icon(MdiIcons.calendarRange),
                  trailingIcon: historyFilter.dateRange.mapNotNull(
                    (_) => IconButton(
                      onPressed: () {
                        setDateRange(null);
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
                      Text(l10n.history_filterDate),
                  onPressed: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      initialDateRange: historyFilter.dateRange,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now(),
                    );

                    setDateRange(
                      range.mapNotNull(
                        (range) => DateTimeRange(
                          start: range.start,
                          // Make sure to include last day fully.
                          end: range.end.add(
                            const Duration(days: 1) -
                                const Duration(milliseconds: 1),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (!isDownloadsMode) const Divider(),
                if (!isDownloadsMode)
                  ...{VisitType.link, VisitType.reload, VisitType.download}.map(
                    (type) => CheckboxMenuButton(
                      closeOnActivate: false,
                      value: historyFilter.visitTypes.contains(type),
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(historyVisitsFilterProvider.notifier)
                              .updateVisitType(type, value);
                        }
                      },
                      child: switch (type) {
                        VisitType.link => Text(
                          l10n.history_filterTypeFollowedLinks,
                        ),
                        VisitType.typed => Text(
                          l10n.history_filterTypeTypedAddresses,
                        ),
                        VisitType.embed => Text(
                          l10n.history_filterTypeEmbeddedPageElements,
                        ),
                        VisitType.redirectPermanent => Text(
                          l10n.history_filterTypePermanentRedirects,
                        ),
                        VisitType.redirectTemporary => Text(
                          l10n.history_filterTypeTemporaryRedirects,
                        ),
                        VisitType.download => Text(
                          l10n.history_filterTypeDownloads,
                        ),
                        VisitType.framedLink => Text(
                          l10n.history_filterTypeFrames,
                        ),
                        VisitType.reload => Text(
                          l10n.history_filterTypePageReloads,
                        ),
                        VisitType.bookmark => Text(
                          l10n.history_filterTypeBookmarks,
                        ),
                      },
                    ),
                  ),
                // A view option, not a visit type: its own group so it doesn't
                // read as a fourth type.
                if (!isDownloadsMode) const Divider(),
                if (!isDownloadsMode)
                  CheckboxMenuButton(
                    closeOnActivate: false,
                    value: historyFilter.distinctUrls,
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(historyVisitsFilterProvider.notifier)
                            .setDistinctUrls(value);
                      }
                    },
                    child: Text(l10n.history_filterDistinctUrls),
                  ),
                if (!isDownloadsMode && (containers?.isNotEmpty ?? false)) ...[
                  const Divider(),
                  SubmenuButton(
                    leadingIcon: const Icon(MdiIcons.folderMultipleOutline),
                    menuChildren: [
                      MenuItemButton(
                        leadingIcon: Icon(
                          historyFilter.containerId == null
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                        ),
                        onPressed: () {
                          ref
                              .read(historyVisitsFilterProvider.notifier)
                              .setContainer(null);
                        },
                        child: Text(l10n.history_allContainers),
                      ),
                      for (final container in containers!)
                        MenuItemButton(
                          leadingIcon: Icon(
                            historyFilter.containerId == container.id
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: container.color,
                          ),
                          onPressed: () {
                            ref
                                .read(historyVisitsFilterProvider.notifier)
                                .setContainer(container.id);
                          },
                          child: Text(
                            container.name ?? l10n.history_unnamedContainer,
                          ),
                        ),
                    ],
                    child: Text(
                      filterContainer != null
                          ? l10n.history_containerFilterLabel(
                              filterContainer.name ??
                                  l10n.history_unnamedContainer,
                            )
                          : l10n.history_filterContainer,
                    ),
                  ),
                ],
                const Divider(),
                MenuItemButton(
                  leadingIcon: const Icon(MdiIcons.restore),
                  child: Text(l10n.history_resetFilter),
                  onPressed: () {
                    textFilterController.clear();
                    textFilterEnabled.value = false;
                    if (isDownloadsMode) {
                      ref.read(historyDownloadsFilterProvider.notifier).reset();
                    } else {
                      ref.read(historyVisitsFilterProvider.notifier).reset();
                    }
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
                  isLabelVisible: hasActiveFilter,
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
                await refreshHistoryEntries();
              },
              child: HookBuilder(
                builder: (context) {
                  final textFilter = useListenableSelector(
                    textFilterController,
                    () => textFilterController.text.toLowerCase(),
                  );
                  final query =
                      useDebounced(
                        textFilter,
                        const Duration(milliseconds: 150),
                      ) ??
                      '';

                  // Grouped once per load rather than on every keystroke.
                  // Keyed on the list itself, as comparing it by value walked
                  // every entry on each rebuild.
                  final allGroups = useMemoized(
                    () => data.groupListsBy(
                      (entry) => historyDayOf(entry.visitTime),
                    ),
                    [data],
                  );

                  final groups = useMemoized(() {
                    if (query.isEmpty) {
                      return allGroups;
                    }

                    return {
                      for (final MapEntry(:key, :value) in allGroups.entries)
                        if (value
                                .where((entry) => entry.matchesText(query))
                                .toList()
                            case final matches when matches.isNotEmpty)
                          key: matches,
                    };
                  }, [allGroups, query]);

                  void toggleSelected(HistoryEntry item) {
                    if (selectedIds.value.contains(item.id)) {
                      selectedIds.value = {...selectedIds.value}
                        ..remove(item.id);
                    } else {
                      selectedIds.value = {...selectedIds.value, item.id};
                    }
                  }

                  final now = DateTime.now();

                  return FadingScroll(
                    startFadingSize: 0.0,
                    builder: (context, controller) {
                      return CustomScrollView(
                        controller: controller,
                        slivers: [
                          // Where Fenix has it, above the visits.
                          if (recentlyClosedCount > 0 &&
                              query.isEmpty &&
                              selectedRows.isEmpty)
                            SliverToBoxAdapter(
                              child: ListTile(
                                leading: const Icon(Icons.restore_page),
                                title: Text(l10n.history_recentlyClosedTitle),
                                subtitle: Text(
                                  l10n.history_recentlyClosedCount(
                                    recentlyClosedCount,
                                  ),
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => const HistoryRecentlyClosedRoute()
                                    .push<void>(context),
                              ),
                            ),
                          for (final MapEntry(:key, :value) in groups.entries)
                            Section(
                              context: context,
                              title: historyDayLabel(l10n, key, now: now),
                              items: value,
                              selectedIds: selectedIds.value,
                              containersById: containersById,
                              onLongPress: toggleSelected,
                              onDelete: (item) => deleteRows([item]),
                              onDownloadControl: isDownloadsMode
                                  ? controlDownload
                                  : null,
                              onTap: (item) async {
                                if (selectedRows.isNotEmpty) {
                                  toggleSelected(item);
                                } else if (isDownloadsMode) {
                                  // Its menu has what can be done with it.
                                  if (item.isUnfinishedDownload) return;

                                  final filePath = item.title;
                                  final file = filePath.mapNotNull(File.new);

                                  if (file == null ||
                                      await file.exists() != true) {
                                    if (context.mounted) {
                                      ui_helper.showErrorMessage(
                                        context,
                                        l10n.history_downloadedFileNotFound,
                                      );
                                    }
                                    return;
                                  }

                                  final opened = await GeckoDownloadsService()
                                      .openDownloadedFile(
                                        fileName: p.basename(file.path),
                                        directoryPath: file.parent.path,
                                        contentType: item.previewImageUrl,
                                      );

                                  if (!opened && context.mounted) {
                                    ui_helper.showErrorMessage(
                                      context,
                                      l10n.history_couldNotOpenDownloadedFile,
                                    );
                                  }
                                } else {
                                  await ref
                                      .read(tabRepositoryProvider.notifier)
                                      .addTab(
                                        url: Uri.parse(item.url),
                                        tabMode: TabMode.regular,
                                        selectTab: true,
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
              title: isDownloadsMode
                  ? l10n.history_loadDownloadsFailedTitle
                  : l10n.history_loadHistoryFailedTitle,
              exception: error,
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
