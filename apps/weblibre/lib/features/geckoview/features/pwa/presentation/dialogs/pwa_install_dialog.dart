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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/isolation_context.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

/// The type of home screen shortcut the user chose.
enum ShortcutInstallType { shortcut, app }

/// Result of the install configuration sheets.
class PwaInstallConfig {
  final String name;
  final String? contextId;

  const PwaInstallConfig({required this.name, required this.contextId});
}

/// Result of the shortcut choice sheet (basic vs app + config).
class ShortcutInstallConfig {
  final ShortcutInstallType type;
  final String name;
  final String? contextId;

  const ShortcutInstallConfig({
    required this.type,
    required this.name,
    required this.contextId,
  });
}

/// Shows a bottom sheet to confirm installing a PWA with an editable name
/// and a storage (contextId) selection.
Future<PwaInstallConfig?> showPwaInstallBottomSheet(
  BuildContext context, {
  required String defaultName,
  required Uri url,
}) {
  return showModalBottomSheet<ShortcutInstallConfig>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _InstallConfigSheet(
        defaultName: defaultName,
        url: url,
        showAppOption: true,
        showShortcutOption: false,
      ),
    ),
  ).then((result) {
    if (result == null) return null;
    return PwaInstallConfig(name: result.name, contextId: result.contextId);
  });
}

/// Shows a bottom sheet for non-manifest sites offering a choice between
/// "Add Shortcut" (opens in browser) and "Install as App" (standalone mode).
///
/// [showAppOption] controls whether the "Install as App" option is visible
/// (requires the allowNonManifestPwaInstall setting to be enabled).
Future<ShortcutInstallConfig?> showShortcutChoiceBottomSheet(
  BuildContext context, {
  required String defaultName,
  required Uri url,
  required bool showAppOption,
}) {
  return showModalBottomSheet<ShortcutInstallConfig>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _InstallConfigSheet(
        defaultName: defaultName,
        url: url,
        showAppOption: showAppOption,
        showShortcutOption: true,
      ),
    ),
  );
}

/// Internal storage options backing the radio selector.
sealed class _StorageOption {
  const _StorageOption();
  String? get contextId;
}

class _StorageDefault extends _StorageOption {
  const _StorageDefault();
  @override
  String? get contextId => null;
}

class _StorageContainer extends _StorageOption {
  final String label;
  @override
  final String contextId;
  const _StorageContainer({required this.label, required this.contextId});
}

class _StorageInheritIsolated extends _StorageOption {
  @override
  final String contextId;
  const _StorageInheritIsolated(this.contextId);
}

class _StorageNewIsolated extends _StorageOption {
  @override
  final String contextId;
  _StorageNewIsolated() : contextId = newIsolatedContextId();
}

class _InstallConfigSheet extends HookConsumerWidget {
  final String defaultName;
  final Uri url;
  final bool showAppOption;
  final bool showShortcutOption;

  const _InstallConfigSheet({
    required this.defaultName,
    required this.url,
    required this.showAppOption,
    required this.showShortcutOption,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final nameController = useTextEditingController(text: defaultName);

    final selectedTabId = ref.watch(selectedTabProvider);
    final tabContextId = selectedTabId != null
        ? ref.watch(tabStateProvider(selectedTabId))?.contextId
        : null;
    final containerAsync = ref.watch(selectedContainerDataProvider);
    final containerData = containerAsync.asData?.value;

    final options = useMemoized<List<_StorageOption>>(
      () {
        final list = <_StorageOption>[const _StorageDefault()];

        // If the current tab is in an isolated context, offer to inherit it.
        if (isIsolatedContextId(tabContextId)) {
          list.add(_StorageInheritIsolated(tabContextId!));
        }

        // If a regular (non-isolated) container is active, offer it.
        final containerContextId = containerData?.metadata.contextualIdentity;
        if (containerData != null &&
            containerContextId != null &&
            !isIsolatedContextId(containerContextId)) {
          list.add(
            _StorageContainer(
              label: containerData.name ?? 'Container',
              contextId: containerContextId,
            ),
          );
        }

        list.add(_StorageNewIsolated());
        return list;
      },
      [tabContextId, containerData?.id, containerData?.metadata.contextualIdentity],
    );

    // Pick sensible default selection based on current context.
    final defaultIndex = useMemoized(() {
      for (var i = 0; i < options.length; i++) {
        final o = options[i];
        if (o is _StorageInheritIsolated) return i;
        if (o is _StorageContainer) return i;
      }
      return 0;
    }, [options]);

    final selectedIndex = useState(defaultIndex);
    final userTouched = useRef(false);

    // When options resolve async (e.g. selected container stream arrives
    // after first build), re-sync the radio to the computed default — unless
    // the user has already made a choice.
    useEffect(() {
      if (!userTouched.value) {
        selectedIndex.value = defaultIndex;
      }
      return null;
    }, [defaultIndex]);

    void submit(ShortcutInstallType type) {
      final name = nameController.text.trim();
      Navigator.of(context).pop(
        ShortcutInstallConfig(
          type: type,
          name: name.isEmpty ? defaultName : name,
          contextId: options[selectedIndex.value].contextId,
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add to Home Screen', style: textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      RepaintBoundary(child: UrlIcon([url], iconSize: 32)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: UriBreadcrumb(
                          uri: url,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                textInputAction: TextInputAction.done,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Storage',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            RadioGroup<int>(
              groupValue: selectedIndex.value,
              onChanged: (v) {
                if (v != null) {
                  userTouched.value = true;
                  selectedIndex.value = v;
                }
              },
              child: Column(
                children: [
                  for (var i = 0; i < options.length; i++)
                    _StorageTile(option: options[i], value: i),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            if (showAppOption)
              ListTile(
                leading: const Icon(Icons.install_mobile),
                title: const Text('Install as App'),
                subtitle: const Text('Runs standalone with its own window.'),
                onTap: () => submit(ShortcutInstallType.app),
              ),
            if (showShortcutOption)
              ListTile(
                leading: const Icon(Icons.shortcut),
                title: const Text('Add Shortcut'),
                subtitle: const Text(
                  'Opens as a standard tab in the browser.',
                ),
                onTap: () => submit(ShortcutInstallType.shortcut),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _StorageTile extends StatelessWidget {
  final _StorageOption option;
  final int value;

  const _StorageTile({required this.option, required this.value});

  @override
  Widget build(BuildContext context) {
    final (title, subtitle, icon) = switch (option) {
      _StorageDefault() => (
        'Default',
        'Uses the default browser storage (no container).',
        Icons.public,
      ),
      _StorageContainer(:final label) => (
        'Container "$label"',
        'Shares cookies and data with the selected container.',
        Icons.folder_outlined,
      ),
      _StorageInheritIsolated() => (
        'Inherit current isolated context',
        'Shares storage with the currently open isolated session.',
        Icons.link,
      ),
      _StorageNewIsolated() => (
        'New isolated context',
        'Creates a fresh storage jar just for this installation.',
        Icons.shield_outlined,
      ),
    };

    return RadioListTile<int>(
      value: value,
      dense: true,
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
