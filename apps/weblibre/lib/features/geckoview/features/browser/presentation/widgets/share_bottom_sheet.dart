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
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/extensions/uri.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/qr_code.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/entities/url_cleaner_result.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/services/url_cleaner_catalog_service.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/presentation/dialogs/tracking_details_dialog.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/presentation/hooks/url_cleaner_controller.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/sync/domain/repositories/sync.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/cached_future.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

Future<void> showShareBottomSheet(
  BuildContext context, {
  required String selectedTabId,
}) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => ShareBottomSheet(selectedTabId: selectedTabId),
  );
}

class ShareBottomSheet extends HookConsumerWidget {
  final String selectedTabId;

  const ShareBottomSheet({super.key, required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(generalSettingsWithDefaultsProvider);
    final catalogAsync = ref.watch(urlCleanerCatalogServiceProvider);

    final tabUrl = ref.watch(
      tabStateProvider(selectedTabId).select((v) => v?.url),
    );

    final cleanedUrl = useState<Uri?>(null);
    final cleaner = useUrlCleanerController(
      sourceUrl: (cleanedUrl.value ?? tabUrl)?.toString(),
      rules: catalogAsync.value,
      cleanerEnabled: settings.urlCleanerEnabled,
      allowReferralMarketing: settings.urlCleanerAllowReferralMarketing,
      autoApply: settings.urlCleanerAutoApply,
      getCurrentUrl: () => (cleanedUrl.value ?? tabUrl)?.toString(),
      onApplyCleanedUrl: (cleanedUrlValue) {
        cleanedUrl.value = Uri.parse(cleanedUrlValue);
      },
    );

    void applyCleanUrl() {
      if (cleaner.applyCleanUrl()) {
        ui_helper.showInfoMessage(context, 'URL cleaned');
      }
    }

    void applySelectedTrackingRemovals(String previewUrl) {
      if (cleaner.applyPreviewUrl(previewUrl)) {
        ui_helper.showInfoMessage(context, 'URL preview applied');
      }
    }

    final effectiveUrl = cleanedUrl.value ?? tabUrl;
    final cleaningHappened = cleanedUrl.value != null;
    final hasActiveTracking = cleaner.result?.removedParams.isNotEmpty ?? false;
    final urlWasCleaned = cleaningHappened && !hasActiveTracking;
    final trackingStatusTrailing = cleaningHappened
        ? Icon(
            hasActiveTracking
                ? MdiIcons.shieldLinkVariantOutline
                : MdiIcons.shieldLinkVariant,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          )
        : null;
    final showCleanerTile = tabUrl != null && cleaner.showTile;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with URL and tracking status
            _ShareHeader(
              url: effectiveUrl?.toString() ?? '',
              urlWasCleaned: urlWasCleaned,
              hasTracking: showCleanerTile && !cleaner.applied,
              cleanerResult: showCleanerTile ? cleaner.result : null,
              allowReferralMarketing: settings.urlCleanerAllowReferralMarketing,
              onClean: showCleanerTile && !cleaner.applied
                  ? applyCleanUrl
                  : null,
              onApplySelectedRemovals: applySelectedTrackingRemovals,
            ),

            // Copy Address
            ListTile(
              leading: const Icon(MdiIcons.contentCopy),
              title: const Text('Copy Address'),
              trailing: trackingStatusTrailing,
              onTap: () async {
                await Clipboard.setData(
                  ClipboardData(text: effectiveUrl.toString()),
                );
                if (context.mounted) Navigator.pop(context);
              },
            ),

            // Open in App (conditional)
            _OpenInAppTile(selectedTabId: selectedTabId),

            // Share Screenshot
            ListTile(
              leading: const Icon(Icons.mobile_screen_share),
              title: const Text('Share Screenshot'),
              onTap: () async {
                final screenshot = await ref
                    .read(selectedTabSessionProvider)
                    .requestScreenshot();

                final ts = ref.read(tabStateProvider(selectedTabId))!;

                if (screenshot != null) {
                  ui.decodeImageFromList(screenshot, (result) async {
                    try {
                      final png = await result.toByteData(
                        format: ui.ImageByteFormat.png,
                      );

                      if (png != null) {
                        final file = XFile.fromData(
                          png.buffer.asUint8List(),
                          mimeType: 'image/png',
                        );

                        await SharePlus.instance.share(
                          ShareParams(
                            files: [file],
                            subject: ts.titleOrAuthority,
                          ),
                        );
                      }
                    } finally {
                      result.dispose();
                    }
                  });
                }

                if (context.mounted) Navigator.pop(context);
              },
            ),

            // Share Link
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Link'),
              trailing: trackingStatusTrailing,
              onTap: () async {
                await SharePlus.instance.share(ShareParams(uri: effectiveUrl));
                if (context.mounted) Navigator.pop(context);
              },
            ),

            // Send To Device (conditional)
            _SendToDeviceTile(selectedTabId: selectedTabId),

            // Show QR Code
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Show QR Code'),
              trailing: trackingStatusTrailing,
              onTap: () async {
                if (context.mounted) {
                  Navigator.pop(context);
                  await showQrCode(context, effectiveUrl.toString());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareHeader extends StatelessWidget {
  final String url;
  final bool urlWasCleaned;
  final bool hasTracking;
  final UrlCleanerResult? cleanerResult;
  final bool allowReferralMarketing;
  final VoidCallback? onClean;
  final ValueChanged<String>? onApplySelectedRemovals;

  const _ShareHeader({
    required this.url,
    required this.urlWasCleaned,
    required this.hasTracking,
    required this.allowReferralMarketing,
    this.cleanerResult,
    this.onClean,
    this.onApplySelectedRemovals,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final paramCount = cleanerResult?.removedParams.length ?? 0;
    final hasTappableDetails = paramCount > 0;

    return InkWell(
      onTap: hasTappableDetails
          ? () {
              unawaited(
                showDialog(
                  context: context,
                  builder: (context) => TrackingDetailsDialog(
                    currentUrl: url,
                    result: cleanerResult!,
                    allowReferralMarketing: allowReferralMarketing,
                    onApplySelectedRemovals: onApplySelectedRemovals,
                  ),
                ),
              );
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    url.uriDisplayString,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: urlWasCleaned
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (hasTracking)
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: colorScheme.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          paramCount == 1
                              ? '1 tracking parameter detected'
                              : '$paramCount tracking parameters detected',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.error,
                          ),
                        ),
                      ],
                    )
                  else if (urlWasCleaned)
                    Row(
                      children: [
                        Icon(
                          MdiIcons.checkCircle,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Link is clean',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (hasTracking && onClean != null)
              IconButton.filledTonal(
                onPressed: onClean,
                icon: const Icon(MdiIcons.linkVariantRemove),
                tooltip: 'Remove tracking',
              ),
          ],
        ),
      ),
    );
  }
}

class _OpenInAppTile extends HookConsumerWidget {
  final String selectedTabId;

  static final _service = GeckoAppLinksService();

  const _OpenInAppTile({required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(tabStateProvider(selectedTabId));
    final url = tabState?.url;
    final hasExternalApp = useCachedFuture(
      () => url != null ? _service.hasExternalApp(url) : Future.value(false),
      [url],
    );

    if (hasExternalApp.data != true) return const SizedBox.shrink();

    return ListTile(
      leading: const Icon(Icons.open_in_new),
      title: const Text('Open in App'),
      onTap: () async {
        if (url == null) return;
        final success = await _service.openAppLink(url);
        if (success && context.mounted) Navigator.pop(context);
      },
    );
  }
}

class _SendToDeviceTile extends ConsumerWidget {
  final String selectedTabId;

  const _SendToDeviceTile({required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(syncIsAuthenticatedProvider);
    final devices = ref.watch(syncDevicesProvider);

    if (!isAuthenticated) return const SizedBox.shrink();

    return Skeletonizer(
      enabled: devices.isLoading && devices.value == null,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: const Icon(Icons.send_outlined),
          title: const Text('Send To Device'),
          children: devices.when(
            data: (deviceList) {
              final targets = deviceList
                  .where(
                    (device) => !device.isCurrentDevice && device.canSendTab,
                  )
                  .toList(growable: false);

              if (targets.isEmpty) {
                return const [
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 72, right: 16),
                    title: Text('No target devices'),
                  ),
                ];
              }

              return targets
                  .map(
                    (device) => ListTile(
                      contentPadding: const EdgeInsets.only(
                        left: 72,
                        right: 16,
                      ),
                      leading: const Icon(Icons.devices_other, size: 18),
                      title: Text(device.displayName),
                      dense: true,
                      onTap: () async {
                        final tabState = ref.read(
                          tabStateProvider(selectedTabId),
                        );
                        if (tabState == null) return;

                        final title = tabState.title.isNotEmpty
                            ? tabState.title
                            : tabState.url.toString();

                        final success = await ref
                            .read(syncRepositoryProvider.notifier)
                            .sendTabToDevice(
                              deviceId: device.deviceId,
                              title: title,
                              url: tabState.url.toString(),
                              private: tabState.tabMode == TabMode.private,
                            );

                        if (context.mounted) {
                          Navigator.pop(context);
                          if (success) {
                            ui_helper.showInfoMessage(
                              context,
                              'Sent tab to ${device.displayName}',
                            );
                          } else {
                            ui_helper.showErrorMessage(
                              context,
                              'Failed to send tab',
                            );
                          }
                        }
                      },
                    ),
                  )
                  .toList(growable: false);
            },
            loading: () => const [
              ListTile(
                contentPadding: EdgeInsets.only(left: 72, right: 16),
                leading: Icon(Icons.devices_other, size: 18),
                title: Text('Loading devices...'),
              ),
            ],
            error: (_, _) => const [
              ListTile(
                contentPadding: EdgeInsets.only(left: 72, right: 16),
                title: Text('Failed to load devices'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
