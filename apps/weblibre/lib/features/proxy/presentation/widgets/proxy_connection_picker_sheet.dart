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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/providers/proxy_connection_options.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';

/// Radio sentinels. Neither can collide with an encoded [ProxyConnectionId],
/// whose forms are `tor` and `singbox:<id>`.
const _noneKey = '__none__';
const _directKey = '__direct__';

/// Result of the proxy picker sheet. `null` (sheet dismissed) is distinct
/// from [ProxyPickerCleared] (user explicitly picked None) so the caller can
/// avoid clobbering the previously-selected proxy on a stray swipe-down.
sealed class ProxyPickerOutcome {
  const ProxyPickerOutcome();
}

class ProxyPickerCleared extends ProxyPickerOutcome {
  const ProxyPickerCleared();
}

class ProxyPickerSelected extends ProxyPickerOutcome {
  final ProxyConnectionId id;

  const ProxyPickerSelected(this.id);
}

/// The user picked an explicit direct connection, which is distinct from
/// [ProxyPickerCleared]: "no proxy assigned" inherits whatever routes the
/// context, "direct" deliberately refuses to.
class ProxyPickerDirect extends ProxyPickerOutcome {
  const ProxyPickerDirect();
}

/// Shows the shared "which connection carries this?" picker and returns the
/// user's choice, preserving the dismissed/cleared distinction.
Future<ProxyPickerOutcome?> showProxyConnectionPicker(
  BuildContext context, {
  required ProxyConnectionId? selectedProxyConnectionId,
  bool isDirectSelected = false,
  String title = 'Proxy Connection',
  String noneTitle = 'None',
  String noneSubtitle = 'Use the normal browser connection',
  String? directTitle,
  String? directSubtitle,
}) {
  return showModalBottomSheet<ProxyPickerOutcome>(
    context: context,
    showDragHandle: true,
    builder: (context) => ProxyConnectionPickerSheet(
      selectedProxyConnectionId: selectedProxyConnectionId,
      isDirectSelected: isDirectSelected,
      title: title,
      noneTitle: noneTitle,
      noneSubtitle: noneSubtitle,
      directTitle: directTitle,
      directSubtitle: directSubtitle,
    ),
  );
}

/// Radio list of every connection a route can name (Tor plus the sing-box
/// profiles), shared by the container editor, the browser menu and the site
/// sheet so a route is picked the same way wherever it is picked.
class ProxyConnectionPickerSheet extends ConsumerWidget {
  final ProxyConnectionId? selectedProxyConnectionId;

  /// Whether the current selection is the explicit-direct option rather than
  /// the "none" option. Only meaningful when [directTitle] is set.
  final bool isDirectSelected;

  final String title;

  /// Wording for the "no proxy" option, which means different things per
  /// caller: no connection assigned, or an explicit direct connection.
  final String noneTitle;
  final String noneSubtitle;

  /// When set, an explicit direct-connection choice is offered alongside the
  /// proxies, returning [ProxyPickerDirect].
  final String? directTitle;
  final String? directSubtitle;

  const ProxyConnectionPickerSheet({
    required this.selectedProxyConnectionId,
    this.isDirectSelected = false,
    this.title = 'Proxy Connection',
    this.noneTitle = 'None',
    this.noneSubtitle = 'Use the normal browser connection',
    this.directTitle,
    this.directSubtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = ref.watch(proxyConnectionOptionsProvider);
    // Only a loaded profile list can prove a selection is stale; until then an
    // unknown id is simply one that has not arrived yet.
    final optionsLoaded = ref
        .watch(singboxProxyProfilesRepositoryProvider)
        .hasValue;

    final hasUnknownSelectedProxy =
        selectedProxyConnectionId != null &&
        optionsLoaded &&
        !proxyConnectionOptionExists(options, selectedProxyConnectionId!);

    // Radio values are the encoded connection ids plus two sentinels: the
    // choices are not all [ProxyConnectionId]s, and a `null` group value cannot
    // distinguish "none" from "direct".
    return SafeArea(
      child: RadioGroup<String>(
        groupValue: switch (selectedProxyConnectionId) {
          final id? => id.encode(),
          null when isDirectSelected && directTitle != null => _directKey,
          null => _noneKey,
        },
        onChanged: (value) {
          Navigator.pop(context, switch (value) {
            null || _noneKey => const ProxyPickerCleared(),
            _directKey => const ProxyPickerDirect(),
            final key => ProxyConnectionId.decode(
              key,
            ).mapNotNull(ProxyPickerSelected.new),
          });
        },
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            RadioListTile<String>(
              value: _noneKey,
              title: Text(noneTitle),
              subtitle: Text(noneSubtitle),
              secondary: const Icon(Icons.public),
            ),
            if (directTitle != null)
              RadioListTile<String>(
                value: _directKey,
                title: Text(directTitle!),
                subtitle: directSubtitle.mapNotNull(Text.new),
                secondary: const Icon(Icons.public_off),
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
                      Navigator.pop(context, const ProxyPickerCleared()),
                  child: const Text('Clear'),
                ),
              ),
            for (final option in options)
              RadioListTile<String>(
                value: option.id.encode(),
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
