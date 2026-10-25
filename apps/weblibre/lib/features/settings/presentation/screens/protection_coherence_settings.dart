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
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Pref keys shared with the Kotlin side. The monitor publishes the
/// declarations; the two switches are owned here.
const _monitorPref = 'weblibre.protection.monitor_extension_conflicts';
const _followPref = 'weblibre.protection.follow_extension_conflicts';
const _declarationsPref = 'weblibre.protection.extension_declarations';

List<SettingsSectionDefinition> protectionCoherenceSections(
  BuildContext context,
) {
  final l10n = AppLocalizations.of(context);

  return [
    SettingsSectionDefinition(
      title: l10n.settings_protectionCoherenceSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_monitorExtensionConflictsTitle,
          subtitle: l10n.settings_monitorExtensionConflictsSubtitle,
          child: const _MonitorExtensionConflictsTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_followExtensionChangesTitle,
          subtitle: l10n.settings_followExtensionChangesSubtitle,
          child: const _FollowExtensionChangesTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_extensionProtectionClaimsTitle,
          child: const _ExtensionProtectionClaimsTile(),
        ),
      ],
    ),
  ];
}

/// Reads and writes one boolean pref, so the tiles stay free of the async
/// plumbing. Kept as a plain stateful tile rather than behind a generated
/// provider because the value is a Gecko pref the Kotlin side also publishes
/// to, and `GeckoPrefService` is already the app's accessor for that space.
class _PrefBackedTile extends StatefulWidget {
  const _PrefBackedTile({
    required this.prefKey,
    required this.defaultValue,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String prefKey;
  final bool defaultValue;
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  State<_PrefBackedTile> createState() => _PrefBackedTileState();
}

class _PrefBackedTileState extends State<_PrefBackedTile> {
  bool? _value;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await GeckoPrefService().getPrefs([widget.prefKey]);
      final raw = prefs[widget.prefKey]?.value;
      if (!mounted) return;
      setState(() => _value = raw is bool ? raw : widget.defaultValue);
    } catch (_) {
      if (!mounted) return;
      setState(() => _value = widget.defaultValue);
    }
  }

  Future<void> _set(bool value) async {
    setState(() => _value = value);
    await GeckoPrefService().applyPrefs({widget.prefKey: value});
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      title: Text(widget.title),
      subtitle: Text(widget.subtitle),
      secondary: Icon(widget.icon),
      value: _value ?? widget.defaultValue,
      onChanged: _value == null ? null : _set,
    );
  }
}

class _MonitorExtensionConflictsTile extends StatelessWidget {
  const _MonitorExtensionConflictsTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _PrefBackedTile(
      prefKey: _monitorPref,
      defaultValue: true,
      title: l10n.settings_monitorExtensionConflictsTitle,
      subtitle: l10n.settings_monitorExtensionConflictsSubtitle,
      icon: MdiIcons.shieldSearch,
    );
  }
}

class _FollowExtensionChangesTile extends StatelessWidget {
  const _FollowExtensionChangesTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _PrefBackedTile(
      prefKey: _followPref,
      defaultValue: false,
      title: l10n.settings_followExtensionChangesTitle,
      subtitle: l10n.settings_followExtensionChangesSubtitle,
      icon: MdiIcons.linkVariant,
    );
  }
}

/// Shows what the built-in protection extensions declared, and which clusters
/// each one left half-moved.
///
/// This is the read side of the monitor: the Kotlin side publishes the
/// declarations to a Gecko pref and this tile turns them into something a
/// person can act on. An extension that changes the User-Agent but not the
/// screen metrics shows up here as a partial device identity, which is the
/// case the whole feature exists for.
class _ExtensionProtectionClaimsTile extends StatefulWidget {
  const _ExtensionProtectionClaimsTile();

  @override
  State<_ExtensionProtectionClaimsTile> createState() =>
      _ExtensionProtectionClaimsTileState();
}

class _ExtensionProtectionClaimsTileState
    extends State<_ExtensionProtectionClaimsTile> {
  List<Map<String, dynamic>>? _declarations;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await GeckoPrefService().getPrefs([_declarationsPref]);
      final raw = prefs[_declarationsPref]?.value;
      final decoded = raw is String ? jsonDecode(raw) : null;
      if (!mounted) return;
      setState(() {
        _declarations = decoded is List
            ? decoded.whereType<Map<String, dynamic>>().toList()
            : const <Map<String, dynamic>>[];
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _declarations = const <Map<String, dynamic>>[]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final declarations = _declarations;

    if (declarations == null) {
      return ListTile(
        leading: const Icon(MdiIcons.shieldSearch),
        title: Text(l10n.settings_extensionProtectionClaimsTitle),
        subtitle: Text(l10n.settings_extensionProtectionClaimsLoading),
      );
    }

    if (declarations.isEmpty) {
      return ListTile(
        leading: const Icon(MdiIcons.shieldCheckOutline),
        title: Text(l10n.settings_extensionProtectionClaimsTitle),
        subtitle: Text(l10n.settings_extensionProtectionClaimsNone),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final declaration in declarations)
          _declarationTile(l10n, declaration),
      ],
    );
  }

  Widget _declarationTile(
    AppLocalizations l10n,
    Map<String, dynamic> declaration,
  ) {
    final extensionId = declaration['extensionId'] as String? ?? '';
    final parameters =
        (declaration['parameters'] as List?)?.whereType<String>().toList() ??
            const <String>[];
    final clusters =
        (declaration['incompleteClusters'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        const <Map<String, dynamic>>[];

    final subtitle = StringBuffer(
      '${l10n.settings_extensionProtectionClaimsControls}: '
      '${parameters.join(', ')}',
    );
    for (final cluster in clusters) {
      final missing =
          (cluster['missing'] as List?)?.whereType<String>().join(', ') ?? '';
      if (missing.isEmpty) continue;
      subtitle.write('\n');
      subtitle.write(
        '${l10n.settings_extensionProtectionClaimsIncomplete}: '
        '${cluster['cluster']} -> $missing',
      );
    }

    return ListTile(
      leading: Icon(
        clusters.isEmpty ? MdiIcons.shieldCheckOutline : MdiIcons.shieldAlert,
      ),
      title: Text(extensionId),
      subtitle: Text(subtitle.toString()),
      isThreeLine: clusters.isNotEmpty,
    );
  }
}
