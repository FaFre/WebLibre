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
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/uuid.dart';
import 'package:weblibre/features/app_links/presentation/widgets/container_app_link_settings_dialog.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/controllers/container_topic.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/dialogs/discard_changes_dialog.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/screens/container_sites.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/utils/container_actions.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/color_picker_dialog.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_icon_picker_sheet.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_icons.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/providers/proxy_connection_options.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/presentation/widgets/proxy_connection_picker_sheet.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/wallpaper/domain/entities/wallpaper_override.dart';
import 'package:weblibre/features/wallpaper/presentation/widgets/wallpaper_editor.dart';

enum _DialogMode { create, edit }

class ContainerEditScreen extends HookConsumerWidget {
  final _DialogMode _mode;

  final ContainerData initialContainer;
  final Set<String>? tabIds;

  const ContainerEditScreen._({
    required _DialogMode mode,
    required this.initialContainer,
    this.tabIds,
  }) : _mode = mode;

  factory ContainerEditScreen.create({
    required ContainerData initialContainer,
    Set<String>? tabIds,
  }) {
    return ContainerEditScreen._(
      mode: _DialogMode.create,
      initialContainer: initialContainer,
      tabIds: tabIds,
    );
  }

  factory ContainerEditScreen.edit({
    required ContainerDataWithCount initialContainer,
  }) {
    return ContainerEditScreen._(
      mode: _DialogMode.edit,
      initialContainer: initialContainer,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final proxyOptions = ref.watch(proxyConnectionOptionsProvider);
    final proxyOptionsLoading = ref.watch(
      singboxProxyProfilesRepositoryProvider.select(
        (value) => value.isLoading && !value.hasValue,
      ),
    );

    final selectedColor = useState(initialContainer.color);
    final useCustomColor = useState(initialContainer.metadata.useCustomColor);
    final selectedIcon = useState(initialContainer.metadata.iconData);
    final contextualIdentity = useState(
      initialContainer.metadata.contextualIdentity,
    );
    final proxyConnectionId = useState<ProxyConnectionId?>(
      initialContainer.metadata.proxyConnectionId,
    );
    final clearDataOnExit = useState(initialContainer.metadata.clearDataOnExit);
    final excludeFromIndex = useState(
      initialContainer.metadata.excludeFromIndex,
    );
    final excludeFromHistory = useState(
      initialContainer.metadata.excludeFromHistory,
    );
    final bypassGlobalProxy = useState(
      initialContainer.metadata.bypassGlobalProxy,
    );
    final assignedSites = useState(initialContainer.metadata.assignedSites);
    final strictMode = useState(initialContainer.metadata.strictMode);
    final isolatedAppLinkSettings = useState(
      initialContainer.metadata.isolatedAppLinkSettings,
    );
    final isPinned = useState(initialContainer.isPinned);
    final wallpaper = useState(initialContainer.metadata.wallpaper);

    final textController = useTextEditingController(
      text: initialContainer.name,
    );
    useListenable(textController);

    ContainerData buildContainer() {
      final name = textController.text.trim();
      return initialContainer.copyWith(
        name: name.isNotEmpty ? name : null,
        color: selectedColor.value,
        isPinned: isPinned.value,
        metadata: initialContainer.metadata
            .copyWith(
              contextualIdentity: contextualIdentity.value,
              iconData: selectedIcon.value,
              proxyConnectionId: contextualIdentity.value != null
                  ? proxyConnectionId.value
                  : null,
              clearDataOnExit:
                  clearDataOnExit.value && contextualIdentity.value != null,
              excludeFromIndex: excludeFromIndex.value,
              excludeFromHistory: excludeFromHistory.value,
              bypassGlobalProxy:
                  contextualIdentity.value != null &&
                  proxyConnectionId.value == null &&
                  bypassGlobalProxy.value,
              useCustomColor: useCustomColor.value,
              assignedSites: assignedSites.value,
              // Strict mode requires a Gecko contextId (the extension keys
              // strictness on the tab's cookieStoreId). sanitized() enforces the
              // same invariant defensively on write.
              strictMode: strictMode.value && contextualIdentity.value != null,
              // Isolated app-link settings require a Gecko contextId (the
              // interceptor keys the override on the tab's contextId).
              // sanitized() enforces the same invariant defensively on write.
              isolatedAppLinkSettings:
                  isolatedAppLinkSettings.value &&
                  contextualIdentity.value != null,
              wallpaper: wallpaper.value,
            )
            .sanitized(),
      );
    }

    Future<ContainerData> saveContainer() async {
      final container = buildContainer();
      final repository = ref.read(containerRepositoryProvider.notifier);
      switch (_mode) {
        case _DialogMode.create:
          await repository.addContainer(container);
        case _DialogMode.edit:
          await repository.replaceContainer(container);
      }
      if (isPinned.value != initialContainer.isPinned) {
        await repository.setContainerPinned(
          container.id,
          isPinned: isPinned.value,
        );
      }
      // Keep the per-container app-link override in step with the isolation
      // toggle: drop it when the container is no longer isolated (or lost its
      // contextId) so it can't linger orphaned in GeneralSettings.
      if (!container.metadata.isolatedAppLinkSettings) {
        await removeContainerAppLinkOverrides(ref, {
          initialContainer.metadata.contextualIdentity,
          container.metadata.contextualIdentity,
        });
      }
      return container;
    }

    Future<void> saveAndClose() async {
      final container = await saveContainer();
      if (context.mounted) {
        context.pop(container);
      }
    }

    Future<void> openColorPicker() async {
      final result = await showDialog<ColorPickerResult?>(
        context: context,
        builder: (context) => ColorPickerDialog(
          selectedColor.value,
          initialUseCustomColor: useCustomColor.value,
        ),
      );

      if (result != null) {
        selectedColor.value = result.color;
        useCustomColor.value = result.useCustomColor;
      }
    }

    Future<void> openIconPicker() async {
      final icon = await showModalBottomSheet<IconData>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) => FractionallySizedBox(
          heightFactor: 0.92,
          child: ContainerIconPickerSheet(
            selectedColor: selectedColor.value,
            useCustomColor: useCustomColor.value,
            selectedIcon: resolveContainerIcon(selectedIcon.value),
            onSelected: (iconData) => Navigator.of(context).pop(iconData),
          ),
        ),
      );

      if (icon != null) {
        selectedIcon.value = icon;
      }
    }

    Future<void> openAppearanceMenu() async {
      await showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Change Color'),
                  onTap: () {
                    Navigator.of(context).pop();
                    unawaited(openColorPicker());
                  },
                ),
                ListTile(
                  leading: Icon(resolveContainerIcon(selectedIcon.value)),
                  title: const Text('Change Icon'),
                  onTap: () {
                    Navigator.of(context).pop();
                    unawaited(openIconPicker());
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );
    }

    Future<void> deleteContainer() async {
      final deleted = await confirmAndDeleteContainer(
        context,
        ref,
        initialContainer,
      );

      if (deleted && context.mounted) {
        context.pop();
      }
    }

    final container = buildContainer();
    //Empty copy to create comparable container with same type
    final comparison = initialContainer.copyWith();
    final previewIcon = resolveContainerIcon(selectedIcon.value);
    final previewPalette = ContainerColors.palette(
      context,
      selectedColor.value,
      useCustomColor: useCustomColor.value,
    );
    final assignedSiteCount = assignedSites.value?.length ?? 0;
    final canPickProxy =
        _mode == _DialogMode.create || contextualIdentity.value != null;
    final canBypassGlobalProxy =
        contextualIdentity.value != null && proxyConnectionId.value == null;

    return PopScope(
      canPop: container == comparison,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final choice = await showDiscardChangesDialog(context);
        if (choice == null) return;

        switch (choice) {
          case DiscardChangesChoice.discard:
            if (context.mounted) {
              context.pop();
            }
          case DiscardChangesChoice.save:
            await saveAndClose();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(switch (_mode) {
            _DialogMode.create => 'New Container',
            _DialogMode.edit => 'Edit Container',
          }),
          actions: [
            IconButton(onPressed: saveAndClose, icon: const Icon(Icons.check)),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Card.filled(
                    margin: EdgeInsets.zero,
                    color: colorScheme.surfaceContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: openAppearanceMenu,
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                AnimatedContainer(
                                  duration: disableAnimations
                                      ? Duration.zero
                                      : const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: previewPalette.avatarBackgroundColor,
                                    border: Border.all(
                                      color: previewPalette.outlineColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    previewIcon,
                                    color: previewPalette.avatarForegroundColor,
                                    size: 34,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: theme.scaffoldBackgroundColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    size: 14,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: TextField(
                              controller: textController,
                              style: theme.textTheme.titleLarge,
                              decoration: InputDecoration(
                                hintText: 'Container Name',
                                border: InputBorder.none,
                                suffixIcon: _buildMagicWandButton(
                                  context,
                                  ref,
                                  textController,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Display',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card.filled(
                    margin: EdgeInsets.zero,
                    color: colorScheme.surfaceContainer,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        SwitchListTile.adaptive(
                          value: isPinned.value,
                          title: const Text('Pin Container'),
                          subtitle: const Text(
                            'Keep this container at the top of the list',
                          ),
                          secondary: const Icon(MdiIcons.pin),
                          onChanged: (value) {
                            isPinned.value = value;
                          },
                        ),
                        const Divider(height: 1, indent: 56),
                        // Collapsed by default: most containers use the
                        // profile's wallpaper, and an always-open picker with a
                        // preview would push the rest of this form off screen.
                        ExpansionTile(
                          shape: const Border(),
                          collapsedShape: const Border(),
                          leading: const Icon(MdiIcons.imageOutline),
                          title: const Text('Wallpaper'),
                          subtitle: Text(
                            wallpaper.value != null
                                ? 'Shown on home while this container is '
                                      'selected'
                                : 'Uses the wallpaper from settings',
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              // The inherited treatment is read here rather
                              // than in the screen's build: a collapsed
                              // ExpansionTile never builds its body, so a form
                              // whose wallpaper section is untouched does not
                              // open the settings database at all.
                              child: Consumer(
                                builder: (context, ref, child) {
                                  final settings = ref.watch(
                                    generalSettingsWithDefaultsProvider,
                                  );

                                  final override = wallpaper.value;

                                  return WallpaperEditor(
                                    fileName: override?.file,
                                    blur:
                                        override?.blur ??
                                        settings.homeWallpaperBlur,
                                    dim:
                                        override?.dim ??
                                        settings.homeWallpaperDim,
                                    emptyDescription:
                                        'This container falls back to the '
                                        'wallpaper set in settings.',
                                    // Replacing the picture keeps the
                                    // treatment; removing it drops the whole
                                    // override, so a later pick starts from
                                    // whatever the profile does now rather
                                    // than from a setting made months ago.
                                    onFileChanged: (fileName) =>
                                        wallpaper.value = fileName == null
                                        ? null
                                        : WallpaperOverride(
                                            file: fileName,
                                            blur: override?.blur,
                                            dim: override?.dim,
                                          ),
                                    // The sliders are disabled without a
                                    // wallpaper, so there is always an
                                    // override to amend here.
                                    onBlurChanged: (value) => wallpaper.value =
                                        override?.copyWith(blur: value),
                                    onDimChanged: (value) => wallpaper.value =
                                        override?.copyWith(dim: value),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Privacy & Security',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card.filled(
                    margin: EdgeInsets.zero,
                    color: colorScheme.surfaceContainer,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        SwitchListTile.adaptive(
                          value: contextualIdentity.value != null,
                          title: const Text('Cookie Isolation'),
                          secondary: const Icon(MdiIcons.cookieLock),
                          onChanged: (_mode == _DialogMode.create)
                              ? (value) {
                                  contextualIdentity.value = value
                                      ? initialContainer
                                                .metadata
                                                .contextualIdentity ??
                                            uuid.v4()
                                      : null;

                                  if (!value) {
                                    proxyConnectionId.value = null;
                                    bypassGlobalProxy.value = false;
                                  }

                                  if (!value && clearDataOnExit.value) {
                                    clearDataOnExit.value = false;
                                  }
                                }
                              : null,
                        ),
                        const Divider(height: 1, indent: 56),
                        ListTile(
                          leading: const Icon(Icons.route_outlined),
                          title: const Text('Proxy Connection'),
                          subtitle: Text(switch (proxyConnectionId.value) {
                            final id? => proxyConnectionTitle(
                              proxyOptions,
                              id,
                              isLoading: proxyOptionsLoading,
                            ),
                            null => 'None',
                          }),
                          trailing: const Icon(Icons.chevron_right),
                          enabled: canPickProxy,
                          onTap: canPickProxy
                              ? () async {
                                  final createdTemporaryIdentity =
                                      contextualIdentity.value == null;

                                  if (createdTemporaryIdentity) {
                                    contextualIdentity.value =
                                        initialContainer
                                            .metadata
                                            .contextualIdentity ??
                                        uuid.v4();
                                  }

                                  final outcome =
                                      await showProxyConnectionPicker(
                                        context,
                                        selectedProxyConnectionId:
                                            proxyConnectionId.value,
                                      );

                                  switch (outcome) {
                                    case null:
                                      // Dismissed without selecting — leave
                                      // existing value untouched, but undo any
                                      // temporary identity we created.
                                      if (createdTemporaryIdentity) {
                                        contextualIdentity.value = null;
                                      }
                                    case ProxyPickerCleared():
                                      proxyConnectionId.value = null;
                                      if (createdTemporaryIdentity) {
                                        contextualIdentity.value = null;
                                        bypassGlobalProxy.value = false;
                                      }
                                    case ProxyPickerSelected(:final id):
                                      proxyConnectionId.value = id;
                                      bypassGlobalProxy.value = false;
                                    case ProxyPickerDirect():
                                      // Not offered here — this screen has its
                                      // own bypass switch below — but the
                                      // mapping is the same one it performs.
                                      proxyConnectionId.value = null;
                                      bypassGlobalProxy.value = true;
                                  }
                                }
                              : null,
                        ),
                        const Divider(height: 1, indent: 56),
                        SwitchListTile.adaptive(
                          value:
                              canBypassGlobalProxy && bypassGlobalProxy.value,
                          title: const Text('Bypass Global Proxy'),
                          subtitle: const Text(
                            'Use the normal connection for this container when global routing is enabled',
                          ),
                          secondary: const Icon(Icons.public),
                          onChanged: canBypassGlobalProxy
                              ? (value) {
                                  bypassGlobalProxy.value = value;
                                }
                              : null,
                        ),
                        const Divider(height: 1, indent: 56),
                        SwitchListTile.adaptive(
                          value: clearDataOnExit.value,
                          title: const Text('Clear Data on Exit'),
                          subtitle: const Text(
                            "Clear cookies and site data for this container's "
                            'regular tabs when the app closes. Isolated tabs '
                            'keep separate data.',
                          ),
                          secondary: const Icon(MdiIcons.databaseRemove),
                          onChanged: (contextualIdentity.value != null)
                              ? (value) {
                                  clearDataOnExit.value = value;
                                }
                              : null,
                        ),
                        const Divider(height: 1, indent: 56),
                        SwitchListTile.adaptive(
                          value: excludeFromIndex.value,
                          title: const Text('Exclude from Search Index'),
                          subtitle: const Text(
                            'Skip pages in this container from the local search index',
                          ),
                          secondary: const Icon(MdiIcons.magnifyRemoveOutline),
                          onChanged: (value) {
                            excludeFromIndex.value = value;
                          },
                        ),
                        const Divider(height: 1, indent: 56),
                        SwitchListTile.adaptive(
                          value: excludeFromHistory.value,
                          title: const Text('Exclude from History'),
                          subtitle: const Text(
                            "Don't record new visits from this container's "
                            'tabs, and drop its pages from local search. '
                            'Existing browsing history is kept.',
                          ),
                          secondary: const Icon(MdiIcons.incognito),
                          onChanged: (value) {
                            excludeFromHistory.value = value;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Assignments',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card.filled(
                    margin: EdgeInsets.zero,
                    color: colorScheme.surfaceContainer,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.web),
                          title: const Text('Assigned Sites'),
                          subtitle: assignedSiteCount > 0
                              ? Text(
                                  '$assignedSiteCount ${assignedSiteCount == 1 ? 'rule' : 'rules'} configured',
                                )
                              : const Text(
                                  'Route matching origins into this container',
                                ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final result = await showDialog<Set<Uri>>(
                              context: context,
                              builder: (context) => ContainerSitesScreen(
                                initialSites:
                                    assignedSites.value?.toSet() ?? {},
                              ),
                            );

                            if (result == null || result.isEmpty) {
                              assignedSites.value = null;
                            } else {
                              assignedSites.value = result.toList();
                            }
                          },
                        ),
                        const Divider(height: 1, indent: 56),
                        SwitchListTile.adaptive(
                          value:
                              contextualIdentity.value != null &&
                              strictMode.value,
                          title: const Text('Strict Mode'),
                          subtitle: Text(
                            contextualIdentity.value != null
                                ? 'Only allow assigned sites to load; block everything else'
                                : 'Requires cookie isolation to be enabled',
                          ),
                          secondary: const Icon(MdiIcons.shieldLockOutline),
                          onChanged: (contextualIdentity.value != null)
                              ? (value) {
                                  strictMode.value = value;
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'App Links',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card.filled(
                    margin: EdgeInsets.zero,
                    color: colorScheme.surfaceContainer,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        SwitchListTile.adaptive(
                          value:
                              contextualIdentity.value != null &&
                              isolatedAppLinkSettings.value,
                          title: const Text('Isolated App Link Settings'),
                          subtitle: Text(
                            contextualIdentity.value != null
                                ? 'Use a separate open-in-app mode and remembered '
                                      'site rules for this container instead of the '
                                      'global settings'
                                : 'Requires cookie isolation to be enabled',
                          ),
                          secondary: const Icon(MdiIcons.openInApp),
                          onChanged: (contextualIdentity.value != null)
                              ? (value) {
                                  isolatedAppLinkSettings.value = value;
                                }
                              : null,
                        ),
                        // The per-container mode + rules live in GeneralSettings
                        // (keyed by the persisted contextId) and are edited live,
                        // like the global app-link settings. Only offered in edit
                        // mode against the saved, immutable contextId — a create
                        // draft's contextId can still churn (cookie-isolation
                        // toggling regenerates it), which would orphan overrides.
                        if (_mode == _DialogMode.edit &&
                            initialContainer.metadata.contextualIdentity !=
                                null &&
                            isolatedAppLinkSettings.value) ...[
                          const Divider(height: 1, indent: 56),
                          ListTile(
                            leading: const Icon(Icons.tune),
                            title: const Text('App Link Behavior'),
                            subtitle: const Text(
                              "Configure this container's open-in-app mode and "
                              'remembered sites',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              await showDialog<void>(
                                context: context,
                                builder: (context) =>
                                    ContainerAppLinkSettingsDialog(
                                      contextId: initialContainer
                                          .metadata
                                          .contextualIdentity!,
                                      containerName:
                                          textController.text.trim().isNotEmpty
                                          ? textController.text.trim()
                                          : initialContainer.name,
                                    ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_mode == _DialogMode.edit)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.tonalIcon(
                      onPressed: deleteContainer,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete Container'),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.errorContainer,
                        foregroundColor: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget? _buildMagicWandButton(
    BuildContext context,
    WidgetRef ref,
    TextEditingController textController,
  ) {
    final predict = switch (_mode) {
      _DialogMode.edit => switch (initialContainer) {
        ContainerDataWithCount(:final tabCount?) when tabCount > 0 =>
          (WidgetRef ref) => ref
              .read(containerTopicControllerProvider.notifier)
              .predictDocumentTopic(initialContainer.id),
        _ => null,
      },
      _DialogMode.create => switch (tabIds) {
        final ids? when ids.isNotEmpty =>
          (WidgetRef ref) => ref
              .read(containerTopicControllerProvider.notifier)
              .predictTopicFromTabIds(ids),
        _ => null,
      },
    };

    if (predict == null) return null;

    return Consumer(
      builder: (context, ref, child) {
        final isLoading = ref.watch(
          containerTopicControllerProvider.select((value) => value.isLoading),
        );

        return IconButton(
          onPressed: isLoading
              ? null
              : () async {
                  final topic = await predict(ref);
                  if (topic != null) {
                    textController.text = topic;
                  }
                },
          icon: const Icon(MdiIcons.creation),
        );
      },
    );
  }
}
