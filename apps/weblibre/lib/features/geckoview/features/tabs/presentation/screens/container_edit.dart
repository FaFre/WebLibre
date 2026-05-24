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
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/controllers/container_topic.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/dialogs/delete_container_dialog.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/dialogs/discard_changes_dialog.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/screens/container_sites.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/color_picker_dialog.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_icon_picker_sheet.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_icons.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/providers/proxy_connection_options.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';

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
    final selectedIcon = useState(initialContainer.metadata.iconData);
    final contextualIdentity = useState(
      initialContainer.metadata.contextualIdentity,
    );
    final proxyConnectionId = useState<ProxyConnectionId?>(
      initialContainer.metadata.proxyConnectionId,
    );
    final clearDataOnExit = useState(initialContainer.metadata.clearDataOnExit);
    final assignedSites = useState(initialContainer.metadata.assignedSites);

    final textController = useTextEditingController(
      text: initialContainer.name,
    );
    useListenable(textController);

    ContainerData buildContainer() {
      final name = textController.text.trim();
      return initialContainer.copyWith(
        name: name.isNotEmpty ? name : null,
        color: selectedColor.value,
        metadata: initialContainer.metadata.copyWith(
          contextualIdentity: contextualIdentity.value,
          iconData: selectedIcon.value,
          proxyConnectionId: contextualIdentity.value != null
              ? proxyConnectionId.value
              : null,
          clearDataOnExit:
              clearDataOnExit.value && contextualIdentity.value != null,
          assignedSites: assignedSites.value,
        ),
      );
    }

    Future<ContainerData> saveContainer() async {
      final container = buildContainer();
      switch (_mode) {
        case _DialogMode.create:
          await ref
              .read(containerRepositoryProvider.notifier)
              .addContainer(container);
        case _DialogMode.edit:
          await ref
              .read(containerRepositoryProvider.notifier)
              .replaceContainer(container);
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
      final color = await showDialog<Color?>(
        context: context,
        builder: (context) => ColorPickerDialog(selectedColor.value),
      );

      if (color != null) {
        selectedColor.value = color;
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
      final result = await showDeleteContainerDialog(context);

      if (result == true) {
        await ref
            .read(containerRepositoryProvider.notifier)
            .deleteContainer(initialContainer.id);

        if (context.mounted) {
          context.pop();
        }
      }
    }

    final container = buildContainer();
    //Empty copy to create comparable container with same type
    final comparison = initialContainer.copyWith();
    final previewIcon = resolveContainerIcon(selectedIcon.value);
    final previewPalette = ContainerColors.palette(
      context,
      selectedColor.value,
    );
    final assignedSiteCount = assignedSites.value?.length ?? 0;
    final canPickProxy =
        _mode == _DialogMode.create || contextualIdentity.value != null;

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
                                labelText: 'Container Name',
                                filled: true,
                                fillColor: colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.6),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
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

                                  final optionsLoaded = ref
                                      .read(
                                        singboxProxyProfilesRepositoryProvider,
                                      )
                                      .hasValue;

                                  final outcome =
                                      await showModalBottomSheet<
                                        _ProxyPickerOutcome
                                      >(
                                        context: context,
                                        showDragHandle: true,
                                        builder: (context) {
                                          return _ProxyConnectionPickerSheet(
                                            options: proxyOptions,
                                            optionsLoaded: optionsLoaded,
                                            selectedProxyConnectionId:
                                                proxyConnectionId.value,
                                          );
                                        },
                                      );

                                  switch (outcome) {
                                    case null:
                                      // Dismissed without selecting — leave
                                      // existing value untouched, but undo any
                                      // temporary identity we created.
                                      if (createdTemporaryIdentity) {
                                        contextualIdentity.value = null;
                                      }
                                    case _ProxyPickerCleared():
                                      proxyConnectionId.value = null;
                                      if (createdTemporaryIdentity) {
                                        contextualIdentity.value = null;
                                      }
                                    case _ProxyPickerSelected(:final id):
                                      proxyConnectionId.value = id;
                                  }
                                }
                              : null,
                        ),
                        const Divider(height: 1, indent: 56),
                        SwitchListTile.adaptive(
                          value: clearDataOnExit.value,
                          title: const Text('Clear Data on Exit'),
                          subtitle: const Text(
                            'Clear cookies and site data when app closes',
                          ),
                          secondary: const Icon(MdiIcons.databaseRemove),
                          onChanged: (contextualIdentity.value != null)
                              ? (value) {
                                  clearDataOnExit.value = value;
                                }
                              : null,
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
                    child: ListTile(
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
                            initialSites: assignedSites.value?.toSet() ?? {},
                          ),
                        );

                        if (result == null || result.isEmpty) {
                          assignedSites.value = null;
                        } else {
                          assignedSites.value = result.toList();
                        }
                      },
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

/// Result of the proxy picker sheet. `null` (sheet dismissed) is distinct
/// from `_ProxyPickerCleared` (user explicitly picked None) so the caller can
/// avoid clobbering the previously-selected proxy on a stray swipe-down.
sealed class _ProxyPickerOutcome {
  const _ProxyPickerOutcome();
}

class _ProxyPickerCleared extends _ProxyPickerOutcome {
  const _ProxyPickerCleared();
}

class _ProxyPickerSelected extends _ProxyPickerOutcome {
  final ProxyConnectionId id;

  const _ProxyPickerSelected(this.id);
}

class _ProxyConnectionPickerSheet extends StatelessWidget {
  final List<ProxyConnectionOption> options;
  final bool optionsLoaded;
  final ProxyConnectionId? selectedProxyConnectionId;

  const _ProxyConnectionPickerSheet({
    required this.options,
    required this.optionsLoaded,
    required this.selectedProxyConnectionId,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnknownSelectedProxy =
        selectedProxyConnectionId != null &&
        optionsLoaded &&
        !proxyConnectionOptionExists(options, selectedProxyConnectionId!);

    return SafeArea(
      child: RadioGroup<ProxyConnectionId?>(
        onChanged: (value) {
          Navigator.pop(
            context,
            value == null
                ? const _ProxyPickerCleared()
                : _ProxyPickerSelected(value),
          );
        },
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
              child: Text(
                'Proxy Connection',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const RadioListTile<ProxyConnectionId?>(
              value: null,
              title: Text('None'),
              subtitle: Text('Use the normal browser connection'),
              secondary: Icon(Icons.public),
            ),
            if (hasUnknownSelectedProxy)
              ListTile(
                leading: Icon(
                  Icons.warning_amber_outlined,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: const Text('Unknown proxy'),
                subtitle: const Text('This proxy profile no longer exists'),
                trailing: TextButton(
                  onPressed: () =>
                      Navigator.pop(context, const _ProxyPickerCleared()),
                  child: const Text('Clear'),
                ),
              ),
            for (final option in options)
              RadioListTile<ProxyConnectionId?>(
                value: option.id,
                title: Text(option.title),
                subtitle: Text(option.subtitle),
                secondary: const Icon(Icons.route_outlined),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
