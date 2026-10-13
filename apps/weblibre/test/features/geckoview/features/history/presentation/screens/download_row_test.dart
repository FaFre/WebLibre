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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/history/domain/entities/history_entry.dart';
import 'package:weblibre/features/geckoview/features/history/presentation/screens/history.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/utils/units_l10n.dart';

HistoryEntry _download(
  DownloadStatus status, {
  int? size = 4 * 1024 * 1024,
  int downloadedBytes = 1024 * 1024,
}) => HistoryEntry(
  visit: VisitInfo(
    url: 'https://example.com/file.zip',
    title: '/storage/emulated/0/Download/file.zip',
    visitTime: 0,
    visitType: VisitType.download,
    isRemote: false,
    contentId: 'download-1',
    downloadStatus: status,
    downloadedBytes: downloadedBytes,
    downloadSize: size,
  ),
  containerIds: const [],
);

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  Future<List<DownloadControl>> pumpRow(
    WidgetTester tester,
    HistoryEntry entry, {
    HistoryEntryId? selected,
  }) async {
    final controls = <DownloadControl>[];

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => CustomScrollView(
                slivers: [
                  Section(
                    context: context,
                    title: 'Today',
                    items: [entry],
                    // Selected, so the row leads with a check mark rather
                    // than the favicon, which wants the icon service.
                    selectedIds: {selected ?? entry.id},
                    containersById: const {},
                    onTap: (_) {},
                    onLongPress: (_) {},
                    onDelete: (_) async {},
                    onDownloadControl: (_, control) async =>
                        controls.add(control),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return controls;
  }

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byIcon(MdiIcons.dotsVertical));
    await tester.pumpAndSettle();
  }

  testWidgets('a running download shows how far it got and can be paused', (
    tester,
  ) async {
    final controls = await pumpRow(
      tester,
      _download(DownloadStatus.downloading),
    );

    expect(find.text(l10n.history_downloadStatusDownloading), findsOne);
    expect(
      find.text(
        l10n.history_downloadProgress(
          formatByteSize(l10n, 1024 * 1024),
          formatByteSize(l10n, 4 * 1024 * 1024),
        ),
      ),
      findsOne,
    );
    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progress.value, 0.25);

    await openMenu(tester);
    expect(find.text(l10n.history_downloadActionCancel), findsOne);
    await tester.tap(find.text(l10n.history_downloadActionPause));
    await tester.pumpAndSettle();

    expect(controls, [DownloadControl.pause]);
  });

  testWidgets('a paused download resumes', (tester) async {
    final controls = await pumpRow(tester, _download(DownloadStatus.paused));

    expect(find.text(l10n.history_downloadStatusPaused), findsOne);

    await openMenu(tester);
    await tester.tap(find.text(l10n.history_downloadActionResume));
    await tester.pumpAndSettle();

    expect(controls, [DownloadControl.resume]);
  });

  testWidgets('a failed download offers a retry and no progress', (
    tester,
  ) async {
    final controls = await pumpRow(tester, _download(DownloadStatus.failed));

    expect(find.text(l10n.history_downloadStatusFailed), findsOne);
    expect(find.byType(LinearProgressIndicator), findsNothing);

    await openMenu(tester);
    await tester.tap(find.text(l10n.common_retry));
    await tester.pumpAndSettle();

    expect(controls, [DownloadControl.retry]);
  });

  testWidgets('a finished download shows no status', (tester) async {
    await pumpRow(tester, _download(DownloadStatus.completed));

    expect(find.byType(LinearProgressIndicator), findsNothing);
    await openMenu(tester);
    expect(find.text(l10n.history_downloadActionPause), findsNothing);
    expect(find.text(l10n.common_retry), findsNothing);
  });

  testWidgets('the menu stays open while the download progresses', (
    tester,
  ) async {
    await pumpRow(tester, _download(DownloadStatus.downloading));
    await openMenu(tester);

    // The screen reads the list again every second while it runs.
    await pumpRow(
      tester,
      _download(DownloadStatus.downloading, downloadedBytes: 2 * 1024 * 1024),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.history_downloadActionPause), findsOne);
  });

  testWidgets('a selected download stays selected while it progresses', (
    tester,
  ) async {
    final before = _download(DownloadStatus.downloading);
    final after = _download(
      DownloadStatus.downloading,
      downloadedBytes: 2 * 1024 * 1024,
    );
    expect(after, isNot(before));
    expect(after.id, before.id);

    // Selected before the update, listed after it.
    await pumpRow(tester, after, selected: before.id);

    expect(find.byIcon(Icons.check), findsOne);
  });
}
