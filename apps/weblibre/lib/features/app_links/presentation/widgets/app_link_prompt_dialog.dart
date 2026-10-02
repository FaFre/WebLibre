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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/app_links/domain/entities/app_link_rule.dart';
import 'package:weblibre/features/app_links/domain/services/app_links_coordinator.dart';
import 'package:weblibre/features/app_links/presentation/widgets/app_link_prompt_details.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Build the `alwaysOpen` rule for a target, or null when it cannot be remembered
/// (ambiguous resolution / no bound package).
PersistedAppLinkRule? alwaysOpenRuleFor(AppLinkTarget target) {
  final packageName = target.packageName;
  if (target.isAmbiguous || packageName == null || packageName.isEmpty) {
    return null;
  }
  return PersistedAppLinkRule(
    decision: AppLinkRuleDecision.alwaysOpen,
    scope: target.scopeKey,
    packageName: packageName,
  );
}

PersistedAppLinkRule neverOpenRuleFor(AppLinkTarget target) {
  return PersistedAppLinkRule(
    decision: AppLinkRuleDecision.neverOpen,
    scope: target.scopeKey,
  );
}

PersistedAppLinkRule? rememberedRuleFor(
  AppLinkDecision decision,
  AppLinkTarget target,
) => switch (decision) {
  AppLinkDecision.open => alwaysOpenRuleFor(target),
  AppLinkDecision.cancel => neverOpenRuleFor(target),
  AppLinkDecision.dismiss => null,
};

/// Modal prompt for an unsupported-scheme app link (§2.2). The navigation is
/// genuinely stalled and there is no page to show behind it.
///
/// The content of a modal bottom sheet; `AppLinkPromptHost` presents it.
class AppLinkPromptDialog extends HookConsumerWidget {
  final AppLinkPromptRequest request;

  const AppLinkPromptDialog({super.key, required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final target = request.target;
    final appName = target.appName;
    final remember = useState(false);
    final coordinator = ref.read(appLinksCoordinatorProvider.notifier);
    // Guards against a double-tap running two resolves + two Navigator.pop()s
    // (the second pop would tear down the route beneath the dialog).
    final resolving = useRef(false);

    Future<void> resolve(AppLinkDecision decision) async {
      if (resolving.value) return;
      resolving.value = true;
      final navigator = Navigator.of(context);
      if (remember.value && request.canRemember) {
        final rule = rememberedRuleFor(decision, target);
        if (rule != null) {
          await coordinator.resolveWithRule(
            request.requestId,
            decision,
            rule,
            contextId: request.contextId,
          );
          navigator.pop();
          return;
        }
      }
      await coordinator.resolve(request.requestId, decision);
      navigator.pop();
    }

    final textTheme = Theme.of(context).textTheme;

    // Shown as a modal bottom sheet (#651): it sits on the bottom edge, over the
    // toolbar, next to where the banner form of this prompt appears.
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.open_in_new),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    appName != null
                        ? l10n.appLinks_dialogTitleNamed(appName)
                        : l10n.appLinks_dialogTitleGeneric,
                    style: textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.appLinks_dialogBody),
            const SizedBox(height: 8),
            AppLinkPromptDetails(request: request),
            if (request.canRemember)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: remember.value,
                onChanged: (value) => remember.value = value ?? false,
                title: Text(
                  l10n.appLinks_dialogRememberFor(
                    displayAppLinkScope(target.scopeKey),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            OverflowBar(
              alignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () => resolve(AppLinkDecision.cancel),
                  child: Text(l10n.common_cancel),
                ),
                FilledButton(
                  onPressed: () => resolve(AppLinkDecision.open),
                  child: Text(l10n.common_open),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
