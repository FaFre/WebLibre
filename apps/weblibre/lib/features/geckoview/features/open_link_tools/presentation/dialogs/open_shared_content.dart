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
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/services/url_cleaner_catalog_service.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/services/url_unshortener_service.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/presentation/controllers/open_shared_content_unshorten_controller.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/presentation/hooks/url_cleaner_controller.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/presentation/widgets/attribution_link.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/presentation/widgets/url_cleaner_tile.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/animated_tab_type_switcher.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/isolation_context.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/container_selection_result.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/compact_container_selector.dart';
import 'package:weblibre/features/share_intent/domain/entities/intent_container_mode.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/cached_future.dart';
import 'package:weblibre/presentation/hooks/debouncer.dart';
import 'package:weblibre/utils/form_validators.dart';
import 'package:weblibre/utils/ui_helper.dart';

class OpenSharedContent extends HookConsumerWidget {
  final Uri sharedUrl;
  final String? contextId;
  final IntentContainerMode containerMode;

  static final _appLinksService = GeckoAppLinksService();

  const OpenSharedContent({
    super.key,
    required this.sharedUrl,
    this.contextId,
    this.containerMode = IntentContainerMode.useSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final textController = useTextEditingController(text: sharedUrl.toString());
    final appColors = AppColors.of(context);

    final globalSelectedContainer = ref.watch(
      selectedContainerDataProvider.select((value) => value.value),
    );
    final selectedContainer = useState<ContainerData?>(
      containerMode == IntentContainerMode.useSelected
          ? globalSelectedContainer
          : null,
    );
    final containerSelectionTouched = useRef(false);
    final defaultTabType = ref.read(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.effectiveDefaultCreateTabType,
      ),
    );

    // If the intent carried an isolated context, preselect the isolated tab
    // type and preserve the existing context id so opening doesn't mint a
    // fresh one.
    final carriedIsolatedContextId = useMemoized(
      () => isIsolatedContextId(contextId) ? contextId : null,
      [contextId],
    );

    final selectedTabType = useState(
      carriedIsolatedContextId != null ? TabType.isolated : defaultTabType,
    );

    useEffect(() {
      if (!containerSelectionTouched.value &&
          containerMode == IntentContainerMode.useSelected) {
        selectedContainer.value = globalSelectedContainer;
      }
      return null;
    }, [globalSelectedContainer, containerMode]);

    useEffect(() {
      if (containerMode != IntentContainerMode.specific ||
          contextId == null ||
          isIsolatedContextId(contextId)) {
        if (!containerSelectionTouched.value &&
            containerMode == IntentContainerMode.unassigned) {
          selectedContainer.value = null;
        }
        return null;
      }

      var cancelled = false;

      unawaited(
        Future(() async {
          final container = await ref
              .read(containerRepositoryProvider.notifier)
              .getContainerByContextualIdentity(contextId!);
          if (cancelled ||
              !context.mounted ||
              containerSelectionTouched.value) {
            return;
          }

          selectedContainer.value = container;
        }),
      );

      return () {
        cancelled = true;
      };
    }, [containerMode, contextId]);

    TabMode resolveTabMode() {
      if (selectedTabType.value == TabType.isolated &&
          carriedIsolatedContextId != null) {
        return TabMode.isolated(carriedIsolatedContextId);
      }
      return TabMode.fromTabType(selectedTabType.value);
    }

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

    final unshortenState = ref.watch(
      openSharedContentUnshortenControllerProvider,
    );
    final cleaner = useUrlCleanerController(
      // Avoid expensive matching work on every keystroke.
      sourceUrl: debouncedUrl.value,
      rules: catalogAsync.value,
      cleanerEnabled: settings.urlCleanerEnabled,
      allowReferralMarketing: settings.urlCleanerAllowReferralMarketing,
      autoApply: settings.urlCleanerAutoApply,
      getCurrentUrl: () => textController.text,
      onApplyCleanedUrl: (cleanedUrl) {
        textController.text = cleanedUrl;
      },
    );

    void applyCleanUrl() {
      if (cleaner.applyCleanUrl()) {
        showInfoMessage(context, 'URL cleaned');
      }
    }

    void applySelectedTrackingRemovals(String previewUrl) {
      if (cleaner.applyPreviewUrl(previewUrl)) {
        showInfoMessage(context, 'URL preview applied');
      }
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

    Future<void> openCustomTab(TabMode tabMode) async {
      if (formKey.currentState?.validate() == true) {
        final parsedUrl = parseValidatedUrl(
          textController.text,
          eagerParsing: false,
        );
        if (parsedUrl == null) {
          return;
        }

        final contextId = tabMode is IsolatedTabMode
            ? tabMode.isolationContextId
            : selectedContainer.value?.metadata.contextualIdentity;

        await GeckoBrowserService().openInCustomTab(
          url: parsedUrl,
          private: tabMode is PrivateTabMode,
          contextId: contextId,
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
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Open link', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
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
              if (settings.urlCleanerEnabled && cleaner.result != null) ...[
                if (cleaner.result!.blocked)
                  ListTile(
                    leading: Icon(
                      MdiIcons.alertCircle,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: const Text('URL blocked by ClearURLs'),
                    dense: true,
                  )
                else if (cleaner.result!.removedParams.isNotEmpty)
                  UrlCleanerTile(
                    result: cleaner.result!,
                    currentUrl: currentUrl,
                    allowReferralMarketing:
                        settings.urlCleanerAllowReferralMarketing,
                    onClean: cleaner.result!.changed ? applyCleanUrl : null,
                    onApplySelectedRemovals: applySelectedTrackingRemovals,
                  )
                else if (cleaner.applied)
                  UrlCleanerTile(
                    result: cleaner.result!,
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Builder(
                  builder: (context) {
                    final tabTypeSwitcher = AnimatedTabTypeSwitcher(
                      selected: selectedTabType.value,
                      onChanged: (value) => selectedTabType.value = value,
                      showIsolatedOption:
                          settings.showIsolatedTabUi ||
                          carriedIsolatedContextId != null,
                      selectedBackgroundColor: switch (selectedTabType.value) {
                        TabType.regular => null,
                        TabType.private => appColors.privateSelectionOverlay,
                        TabType.isolated => appColors.isolatedSelectionOverlay,
                        TabType.child => null,
                      },
                    );

                    if (!settings.showContainerUi) {
                      return Center(child: tabTypeSwitcher);
                    }

                    return Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: tabTypeSwitcher,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: CompactContainerSelector(
                              selectedContainer: selectedContainer.value,
                              onSelectionChanged: (selection) async {
                                containerSelectionTouched.value = true;
                                switch (selection) {
                                  case ContainerSelectionSelected(
                                    :final containerId,
                                  ):
                                    selectedContainer.value = await ref
                                        .read(
                                          containerRepositoryProvider.notifier,
                                        )
                                        .getContainerData(containerId);
                                  case ContainerSelectionUnassigned():
                                    selectedContainer.value = null;
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              _OpenActionTile(
                title: 'Open in new tab',
                subtitle: 'Add to your browser tabs',
                icon: MdiIcons.tab,
                onTap: () => openTab(resolveTabMode()),
              ),
              _OpenActionTile(
                title: 'Open in custom tab',
                subtitle: 'Open in a separate window',
                icon: MdiIcons.applicationOutline,
                onTap: () => openCustomTab(resolveTabMode()),
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

class _OpenActionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final bool showTrailingDivider;
  final VoidCallback? onTap;

  const _OpenActionTile({
    required this.title,
    this.subtitle,
    required this.icon,
    this.trailing,
    this.showTrailingDivider = true,
    this.onTap,
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
