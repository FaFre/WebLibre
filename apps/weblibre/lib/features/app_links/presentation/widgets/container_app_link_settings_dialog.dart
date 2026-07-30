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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart'
    show AppLinksMode;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/app_links/domain/entities/app_link_rule.dart';
import 'package:weblibre/features/app_links/domain/entities/context_app_link_policy.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

/// Per-container app-link settings (§ container isolation), bound to
/// `GeneralSettings.appLinkContextOverrides[contextId]`. Mirrors the global
/// app-links section but writes into the container's own override bucket, which
/// fully replaces the global mode + rules for that container (replace semantics).
///
/// Present via `showDialog`; edits save live (no separate confirm step), matching
/// the global settings screen. Only meaningful for an isolated, cookie-isolated
/// container — the caller gates on that.
class ContainerAppLinkSettingsDialog extends ConsumerWidget {
  /// The container's Gecko contextId (`contextualIdentity`); the override key.
  final String contextId;

  /// Optional container name for the title.
  final String? containerName;

  const ContainerAppLinkSettingsDialog({
    super.key,
    required this.contextId,
    this.containerName,
  });

  Future<void> _updateOverride(
    WidgetRef ref,
    ContextAppLinkPolicy Function(ContextAppLinkPolicy current) update,
  ) async {
    await ref.read(saveGeneralSettingsControllerProvider.notifier).save((
      current,
    ) {
      final existing =
          current.appLinkContextOverrides[contextId] ??
          ContextAppLinkPolicy.blank();
      return current.copyWith.appLinkContextOverrides({
        ...current.appLinkContextOverrides,
        contextId: update(existing),
      });
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final override = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.appLinkContextOverrides[contextId],
      ),
    );
    final policy = override ?? ContextAppLinkPolicy.blank();

    final rules = policy.rules.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            containerName != null
                ? 'App Links — $containerName'
                : 'Container App Links',
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                'These settings apply only to this container and fully replace '
                'the global app-link settings for its tabs.',
              ),
            ),
            RadioGroup(
              groupValue: policy.mode,
              onChanged: (value) async {
                if (value != null) {
                  await _updateOverride(ref, (c) => c.copyWith.mode(value));
                }
              },
              child: const Column(
                children: [
                  RadioListTile.adaptive(
                    value: AppLinksMode.always,
                    title: Text('Always'),
                    subtitle: Text(
                      'Always open links in their native apps without asking',
                    ),
                  ),
                  RadioListTile.adaptive(
                    value: AppLinksMode.ask,
                    title: Text('Ask before opening'),
                    subtitle: Text(
                      'Show a prompt before opening links in apps',
                    ),
                  ),
                  RadioListTile.adaptive(
                    value: AppLinksMode.never,
                    title: Text('Never'),
                    subtitle: Text(
                      'Always open links in the browser instead of apps',
                    ),
                  ),
                ],
              ),
            ),
            if (rules.isNotEmpty) ...[
              const Divider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text('Remembered site rules'),
              ),
              for (final MapEntry(:key, :value) in rules)
                ListTile(
                  dense: true,
                  leading: Icon(
                    value.decision == AppLinkRuleDecision.alwaysOpen
                        ? MdiIcons.openInApp
                        : Icons.public,
                  ),
                  title: Text(_displayScope(key)),
                  subtitle: Text(
                    value.decision == AppLinkRuleDecision.alwaysOpen
                        ? 'Always open in the app'
                        : 'Always keep in the browser',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Remove rule',
                    onPressed: () async {
                      await _updateOverride(
                        ref,
                        (c) => c.copyWith.rules({...c.rules}..remove(key)),
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

String _displayScope(String scope) {
  if (scope.startsWith('host:')) return scope.substring('host:'.length);
  if (scope.startsWith('pkg:')) return scope.substring('pkg:'.length);
  return scope;
}
