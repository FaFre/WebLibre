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

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart'
    show GeckoAppLinksService, GeckoBrowserService;
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/entities/url_cleaner_result.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/services/url_cleaner_catalog_service.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/services/url_cleaner_service.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/services/url_unshortener_service.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/presentation/controllers/open_shared_content_unshorten_controller.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/presentation/dialogs/tracking_details_dialog.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/presentation/widgets/attribution_link.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_chips.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/cached_future.dart';
import 'package:weblibre/presentation/hooks/debouncer.dart';
import 'package:weblibre/presentation/icons/weblibre_icons.dart';
import 'package:weblibre/utils/form_validators.dart';
import 'package:weblibre/utils/ui_helper.dart';

class OpenSharedContent extends HookConsumerWidget {
  final Uri sharedUrl;

  static final _appLinksService = GeckoAppLinksService();

  const OpenSharedContent({super.key, required this.sharedUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final textController = useTextEditingController(text: sharedUrl.toString());
    final appColors = AppColors.of(context);

    final selectedContainer = useState<ContainerData?>(null);

    final settings = ref.watch(generalSettingsWithDefaultsProvider);
    final catalogAsync = ref.watch(urlCleanerCatalogServiceProvider);
    final supportedShortenerHosts = ref.watch(urlUnshortenerServiceProvider);

    final currentUrl = useValueListenable(textController).text;

    // Debounce the URL to avoid running expensive operations on every keystroke.
    final debouncedUrl = useState(currentUrl);
    final debouncer = useDebouncer(const Duration(milliseconds: 300));
    useEffect(() {
      debouncer.eventOccured(() => debouncedUrl.value = currentUrl);
      return null;
    }, [currentUrl]);

    final parsedDebouncedUrl = parseValidatedUrl(
      debouncedUrl.value,
      eagerParsing: false,
    );
    final hasExternalApp = useCachedFuture(
      // ignore: discarded_futures useFuture
      () => parsedDebouncedUrl != null
          ? _appLinksService.hasExternalApp(parsedDebouncedUrl)
          : Future.value(false),
      [parsedDebouncedUrl],
    );

    final shouldShowUnshortenerTile =
        settings.unshortenerEnabled &&
        ref
            .read(urlUnshortenerServiceProvider.notifier)
            .isSupportedShortenerUrl(
              debouncedUrl.value,
              supportedShortenerHosts.value ?? const <String>{},
            );

    // URL cleaner state
    final cleanerResult = useState<UrlCleanerResult?>(null);
    final cleanerApplied = useState(false);

    final unshortenState = ref.watch(
      openSharedContentUnshortenControllerProvider,
    );

    void runCleaner({bool allowAutoApply = false}) {
      final settings = ref.read(generalSettingsWithDefaultsProvider);

      if (!settings.urlCleanerEnabled) return;

      final rules = catalogAsync.value;
      if (rules == null) return;

      final result = cleanUrl(
        currentUrl,
        rules,
        allowReferral: settings.urlCleanerAllowReferralMarketing,
      );
      cleanerResult.value = result;

      // Only reset applied state when new tracking params are found,
      // preserving the "cleaned" indicator when the URL is already clean.
      if (result.removedParams.isNotEmpty) {
        cleanerApplied.value = false;
      }

      if (allowAutoApply && result.changed) {
        textController.text = result.cleanedUrl;
        cleanerApplied.value = true;
      }
    }

    // Run URL cleaner on build when enabled and catalog is loaded.
    // Uses debouncedUrl to avoid running regex matching on every keystroke.
    useEffect(
      () {
        runCleaner(allowAutoApply: settings.urlCleanerAutoApply);
        return null;
      },
      [
        debouncedUrl.value,
        catalogAsync.value,
        settings.urlCleanerEnabled,
        settings.urlCleanerAllowReferralMarketing,
        settings.urlCleanerAutoApply,
      ],
    );

    void applyCleanUrl() {
      final result = cleanerResult.value;
      if (result != null && result.changed) {
        textController.text = result.cleanedUrl;
        cleanerApplied.value = true;
        showInfoMessage(context, 'URL cleaned');
      }
    }

    void applySelectedTrackingRemovals(String previewUrl) {
      if (previewUrl == textController.text) return;

      textController.text = previewUrl;
      cleanerApplied.value = true;

      showInfoMessage(context, 'URL preview applied');
    }

    Future<void> openTab(TabMode tabMode) async {
      if (formKey.currentState?.validate() == true) {
        final parsedUrl = parseValidatedUrl(
          textController.text,
          eagerParsing: false,
        );
        if (parsedUrl == null) {
          return;
        }

        await ref
            .read(tabRepositoryProvider.notifier)
            .addTab(
              url: parsedUrl,
              tabMode: tabMode,
              containerSelection: selectedContainer.value == null
                  ? const TabContainerSelection.unassigned()
                  : TabContainerSelection.specific(selectedContainer.value!),
              launchedFromIntent: true,
              selectTab: true,
            );

        if (context.mounted) {
          context.pop(true);
        }
      }
    }

    Future<void> openCustomTab(bool isPrivate) async {
      if (formKey.currentState?.validate() == true) {
        final parsedUrl = parseValidatedUrl(
          textController.text,
          eagerParsing: false,
        );
        if (parsedUrl == null) {
          return;
        }

        await GeckoBrowserService().openInCustomTab(
          url: parsedUrl,
          private: isPrivate,
          contextId: selectedContainer.value?.id,
        );

        if (context.mounted) {
          context.pop(true);
        }
      }
    }

    Future<void> openInApp() async {
      if (formKey.currentState?.validate() == true) {
        final uri = parseValidatedUrl(textController.text, eagerParsing: false);
        if (uri == null) return;

        final success = await _appLinksService.openAppLink(uri);

        if (success && context.mounted) {
          context.pop(true);
        } else if (!success && context.mounted) {
          showErrorMessage(context, 'Could not open in app');
        }
      }
    }

    return SafeArea(
      child: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Open link', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              if (settings.showContainerUi)
                ContainerChips(
                  displayMenu: false,
                  selectedContainer: selectedContainer.value,
                  onSelected: (container) {
                    selectedContainer.value = container;
                  },
                  onDeleted: (container) {
                    selectedContainer.value = null;
                  },
                ),
              TextFormField(
                controller: textController,
                keyboardType: TextInputType.url,
                minLines: 1,
                maxLines: 10,
                validator: (value) {
                  return validateUrl(value, eagerParsing: false);
                },
              ),
              const SizedBox(height: 8),
              // URL Cleaner tile
              if (settings.urlCleanerEnabled &&
                  cleanerResult.value != null) ...[
                if (cleanerResult.value!.blocked)
                  ListTile(
                    leading: Icon(
                      MdiIcons.alertCircle,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: const Text('URL blocked by ClearURLs'),
                    dense: true,
                  )
                else if (cleanerResult.value!.removedParams.isNotEmpty)
                  _UrlCleanerTile(
                    result: cleanerResult.value!,
                    currentUrl: currentUrl,
                    allowReferralMarketing:
                        settings.urlCleanerAllowReferralMarketing,
                    onClean: cleanerResult.value!.changed
                        ? applyCleanUrl
                        : null,
                    onApplySelectedRemovals: applySelectedTrackingRemovals,
                  )
                else if (cleanerApplied.value)
                  _UrlCleanerTile(
                    result: cleanerResult.value!,
                    currentUrl: currentUrl,
                    allowReferralMarketing:
                        settings.urlCleanerAllowReferralMarketing,
                    applied: true,
                  ),
              ],
              // Unshortener UI
              if (shouldShowUnshortenerTile) ...[
                if (unshortenState != null)
                  unshortenState.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: LinearProgressIndicator(),
                    ),
                    error: (error, _) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'Unshorten failed: $error',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    data: (result) {
                      if (!result.success) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Unshorten failed: ${result.error}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }
                      final remaining = result.remainingCalls;
                      final limit = result.usageCount;
                      if (remaining != null &&
                          limit != null &&
                          limit > 0 &&
                          remaining < limit ~/ 2) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Remaining calls: $remaining/$limit',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                _OpenActionTile(
                  title: 'Unshorten',
                  subtitle: 'Resolve shortened URL',
                  icon: MdiIcons.linkVariant,
                  showTrailingDivider: false,
                  trailing: IconButton(
                    icon: const Icon(Icons.info_outline),
                    tooltip: 'Unshortener info',
                    onPressed: () {
                      unawaited(_showUnshortenerInfoDialog(context));
                    },
                  ),
                  onTap: () async {
                    final result = await ref
                        .read(
                          openSharedContentUnshortenControllerProvider.notifier,
                        )
                        .unshorten(
                          url: textController.text,
                          token: settings.unshortenerToken,
                        );
                    if (!context.mounted) return;
                    if (result?.success == true && result?.finalUrl != null) {
                      textController.text = result!.finalUrl!;
                    }
                  },
                ),
              ],
              if (hasExternalApp.data == true)
                _OpenActionTile(
                  title: 'Open in App',
                  subtitle: 'Open in an installed app',
                  icon: Icons.open_in_new,
                  onTap: openInApp,
                ),
              _OpenActionTile(
                title: 'Open in new tab',
                subtitle: 'Add to your browser tabs',
                icon: MdiIcons.tab,
                trailing: PopupMenuButton<TabMode>(
                  icon: const Icon(WebLibreIcons.tabType, size: 24),
                  tooltip: settings.showIsolatedTabUi
                      ? 'Private / Isolated'
                      : 'Private',
                  onSelected: openTab,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: TabMode.private,
                      child: Row(
                        children: [
                          Icon(
                            MdiIcons.dominoMask,
                            color: appColors.privateTabPurple,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Text('Private'),
                        ],
                      ),
                    ),
                    if (settings.showIsolatedTabUi)
                      PopupMenuItem(
                        value: TabMode.newIsolated(),
                        child: Row(
                          children: [
                            Icon(
                              MdiIcons.snowflake,
                              color: appColors.isolatedTabTeal,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Text('Isolated'),
                          ],
                        ),
                      ),
                  ],
                ),
                onTap: () => openTab(TabMode.regular),
              ),
              _OpenActionTile(
                title: 'Open in custom tab',
                subtitle: 'Open in a separate window',
                icon: MdiIcons.applicationOutline,
                trailing: IconButton(
                  icon: Icon(
                    MdiIcons.dominoMask,
                    color: appColors.privateTabPurple,
                    size: 24,
                  ),
                  tooltip: 'Private',
                  onPressed: () => openCustomTab(true),
                ),
                onTap: () => openCustomTab(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showUnshortenerInfoDialog(BuildContext context) {
  final textColor = Theme.of(context).textTheme.bodyMedium?.color;
  final linkStyle = TextStyle(
    color: Theme.of(context).colorScheme.primary,
    decoration: TextDecoration.underline,
    decorationColor: Theme.of(context).colorScheme.primary,
  );

  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Unshortener Attribution'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: textColor),
                children: [
                  const TextSpan(
                    text: 'This module will unshort links by sending them to ',
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: AttributionLink(
                      label: 'https://unshorten.me/',
                      url: 'https://unshorten.me/',
                      style: linkStyle,
                    ),
                  ),
                  const TextSpan(
                    text:
                        ', which evaluates them on their servers and saves the redirection for future requests. '
                        'Avoid unshortening links with private or sensitive data.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'The free API is rate limited to 10 requests per hour for new checks.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: textColor),
                children: [
                  const TextSpan(text: 'Privacy policy: '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: AttributionLink(
                      label: 'https://unshorten.me/privacy-policy',
                      url: 'https://unshorten.me/privacy-policy',
                      style: linkStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

class _UrlCleanerTile extends StatelessWidget {
  final UrlCleanerResult result;
  final String currentUrl;
  final bool allowReferralMarketing;
  final VoidCallback? onClean;
  final ValueChanged<String>? onApplySelectedRemovals;
  final bool applied;

  const _UrlCleanerTile({
    required this.result,
    required this.currentUrl,
    required this.allowReferralMarketing,
    this.onClean,
    this.onApplySelectedRemovals,
    this.applied = false,
  });

  @override
  Widget build(BuildContext context) {
    final paramCount = result.removedParams.length;
    final hasParams = paramCount > 0;

    final String subtitle;
    if (!hasParams) {
      subtitle = 'Tracking parameters removed';
    } else if (paramCount == 1) {
      subtitle = '1 tracking parameter found';
    } else {
      subtitle = '$paramCount tracking parameters found';
    }

    return ListTile(
      leading: Icon(
        applied ? MdiIcons.checkCircle : MdiIcons.broom,
        color: applied
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.error,
      ),
      title: Text(applied ? 'URL cleaned' : 'Tracking detected'),
      subtitle: Text(subtitle),
      trailing: applied || !hasParams
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24, child: VerticalDivider(width: 16)),

                IconButton(
                  icon: const Icon(MdiIcons.linkVariantRemove),
                  tooltip: 'Clean URL',
                  onPressed: onClean,
                ),
              ],
            ),
      dense: true,
      onTap: hasParams
          ? () {
              unawaited(
                showDialog(
                  context: context,
                  builder: (context) => TrackingDetailsDialog(
                    currentUrl: currentUrl,
                    result: result,
                    allowReferralMarketing: allowReferralMarketing,
                    onApplySelectedRemovals: onApplySelectedRemovals,
                  ),
                ),
              );
            }
          : null,
    );
  }
}

class _OpenActionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final bool showTrailingDivider;
  final VoidCallback onTap;

  const _OpenActionTile({
    required this.title,
    this.subtitle,
    required this.icon,
    this.trailing,
    this.showTrailingDivider = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      leading: Icon(icon),
      trailing: trailing == null
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showTrailingDivider)
                  const SizedBox(height: 24, child: VerticalDivider(width: 16)),
                trailing!,
              ],
            ),
      onTap: onTap,
    );
  }
}
