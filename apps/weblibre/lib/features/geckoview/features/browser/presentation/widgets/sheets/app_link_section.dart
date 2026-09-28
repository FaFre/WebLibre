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
    show AppLinkTarget, AppLinksMode, GeckoAppLinksService;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/features/app_links/domain/entities/app_link_rule.dart';
import 'package:weblibre/features/app_links/domain/entities/context_app_link_policy.dart';
import 'package:weblibre/features/app_links/domain/services/effective_app_link_policy.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

final _appLinkTargetProvider = FutureProvider.autoDispose
    .family<AppLinkTarget?, Uri>((ref, url) {
      return GeckoAppLinksService().resolveAppLink(url);
    });

enum _SiteRuleChoice { followDefault, alwaysOpen, neverOpen }

/// Section widget showing the app-link rule for the current tab's site. Edits
/// the effective bucket — the owning container's override when it has isolated
/// app-link settings, otherwise the global rules — but does not expose the
/// global/container default from this site-specific sheet.
class AppLinkSection extends HookConsumerWidget {
  final Uri url;

  /// The tab's live contextId (`TabState.contextId`): the container base
  /// contextId for a regular tab, the isolation contextId for an isolated tab.
  final String? contextId;

  const AppLinkSection({required this.url, required this.contextId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final policy = ref.watch(effectiveAppLinkPolicyProvider(contextId));
    final target = ref.watch(_appLinkTargetProvider(url));
    final isLoadingTarget = target.isLoading && !target.hasValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            l10n.browser_appLinksSectionTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        if (policy == null || isLoadingTarget)
          Skeletonizer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.link),
                  title: Text(l10n.browser_openLinksForThisSite),
                  subtitle: Text(l10n.browser_followsTheDefault),
                ),
              ],
            ),
          )
        else
          _SiteRuleTile(
            policy: policy,
            target: target.hasValue ? target.value : null,
          ),
      ],
    );
  }
}

class _SiteRuleTile extends ConsumerWidget {
  final EffectiveAppLinkPolicy policy;
  final AppLinkTarget? target;

  const _SiteRuleTile({required this.policy, required this.target});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scope = target?.scopeKey;
    final rule = (scope != null && scope.isNotEmpty)
        ? policy.rules[scope]
        : null;
    final choice = switch (rule?.decision) {
      AppLinkRuleDecision.alwaysOpen => _SiteRuleChoice.alwaysOpen,
      AppLinkRuleDecision.neverOpen => _SiteRuleChoice.neverOpen,
      null => _SiteRuleChoice.followDefault,
    };
    final canAlwaysOpen = _alwaysOpenRuleFor(target) != null;

    final colorScheme = Theme.of(context).colorScheme;

    final (IconData icon, Color color) = switch (choice) {
      _SiteRuleChoice.alwaysOpen => (MdiIcons.openInApp, colorScheme.primary),
      _SiteRuleChoice.neverOpen => (Icons.public, colorScheme.primary),
      _SiteRuleChoice.followDefault => (
        Icons.link,
        colorScheme.onSurfaceVariant,
      ),
    };

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(l10n.browser_openLinksForThisSite),
      subtitle: Text(_subtitle(l10n, scope, rule, choice, canAlwaysOpen)),
      trailing: DropdownButton<_SiteRuleChoice>(
        value: choice,
        underline: const SizedBox(),
        items: [
          DropdownMenuItem(
            value: _SiteRuleChoice.followDefault,
            child: Text(l10n.browser_followDefault),
          ),
          DropdownMenuItem(
            value: _SiteRuleChoice.alwaysOpen,
            enabled: canAlwaysOpen || choice == _SiteRuleChoice.alwaysOpen,
            child: Text(l10n.browser_openInAppOption),
          ),
          DropdownMenuItem(
            value: _SiteRuleChoice.neverOpen,
            child: Text(l10n.browser_keepInBrowser),
          ),
        ],
        onChanged: scope == null || scope.isEmpty
            ? null
            : (value) async {
                if (value != null && value != choice) {
                  await _setSiteRule(ref, scope, target, value);
                }
              },
      ),
    );
  }

  String _subtitle(
    AppLocalizations l10n,
    String? scope,
    PersistedAppLinkRule? rule,
    _SiteRuleChoice choice,
    bool canAlwaysOpen,
  ) {
    if (scope == null || scope.isEmpty) {
      return l10n.browser_noAppFoundForSite;
    }
    return switch (choice) {
      _SiteRuleChoice.alwaysOpen => l10n.browser_alwaysOpensInApp(
        rule!.packageName ?? l10n.browser_theAppFallback,
      ),
      _SiteRuleChoice.neverOpen => l10n.browser_alwaysStaysInBrowser,
      _SiteRuleChoice.followDefault => switch (policy.mode) {
        AppLinksMode.always =>
          canAlwaysOpen
              ? l10n.browser_followsDefaultOpensInApps
              : l10n.browser_followsDefaultNoAppFound,
        AppLinksMode.ask => l10n.browser_followsDefaultAsksFirst,
        AppLinksMode.never => l10n.browser_followsDefaultStaysInBrowser,
      },
    };
  }

  Future<void> _setSiteRule(
    WidgetRef ref,
    String scope,
    AppLinkTarget? target,
    _SiteRuleChoice choice,
  ) async {
    Map<String, PersistedAppLinkRule> updateRules(
      Map<String, PersistedAppLinkRule> rules,
    ) {
      final next = {...rules};
      switch (choice) {
        case _SiteRuleChoice.followDefault:
          next.remove(scope);
        case _SiteRuleChoice.neverOpen:
          next[scope] = PersistedAppLinkRule(
            decision: AppLinkRuleDecision.neverOpen,
            scope: scope,
          );
        case _SiteRuleChoice.alwaysOpen:
          final rule = _alwaysOpenRuleFor(target);
          if (rule != null) next[scope] = rule;
      }
      return next;
    }

    final overrideKey = policy.overrideKey;
    await ref.read(saveGeneralSettingsControllerProvider.notifier).save((
      current,
    ) {
      if (overrideKey == null) {
        return current.copyWith.appLinkRules(updateRules(current.appLinkRules));
      }
      final existing =
          current.appLinkContextOverrides[overrideKey] ??
          ContextAppLinkPolicy.blank();
      return current.copyWith.appLinkContextOverrides({
        ...current.appLinkContextOverrides,
        overrideKey: existing.copyWith.rules(updateRules(existing.rules)),
      });
    });
  }
}

PersistedAppLinkRule? _alwaysOpenRuleFor(AppLinkTarget? target) {
  final packageName = target?.packageName;
  final scope = target?.scopeKey;
  if (target == null ||
      target.isAmbiguous ||
      packageName == null ||
      packageName.isEmpty ||
      scope == null ||
      scope.isEmpty) {
    return null;
  }
  return PersistedAppLinkRule(
    decision: AppLinkRuleDecision.alwaysOpen,
    scope: scope,
    packageName: packageName,
  );
}
