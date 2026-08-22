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
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/app_links/domain/services/app_links_coordinator.dart';
import 'package:weblibre/features/app_links/presentation/widgets/app_link_prompt_dialog.dart';

/// Non-modal banner for an http(s) app link (§2.2). The page is allowed to load
/// while the banner is up; nothing blocks on it. Declining leaves the page
/// loaded; choosing the app leaves the tab on the committed page.
class AppLinkOpenBanner extends HookConsumerWidget {
  final AppLinkPromptRequest request;

  const AppLinkOpenBanner({super.key, required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = request.target;
    final appName = target.appName;
    final remember = useState(false);
    final coordinator = ref.read(appLinksCoordinatorProvider.notifier);
    final theme = Theme.of(context);

    Future<void> resolve(AppLinkDecision decision) async {
      logger.i(
        'app-link banner tap request=${request.requestId} decision=$decision '
        'remember=${remember.value} canRemember=${request.canRemember} '
        'target=${target.url}',
      );
      if (remember.value && request.canRemember) {
        final rule = decision == AppLinkDecision.open
            ? alwaysOpenRuleFor(target)
            : neverOpenRuleFor(target);
        if (rule != null) {
          await coordinator.resolveWithRule(
            request.requestId,
            decision,
            rule,
            contextId: request.contextId,
          );
          return;
        }
      }
      await coordinator.resolve(request.requestId, decision);
    }

    return Material(
      elevation: 3,
      color: theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.open_in_new, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    appName != null
                        ? 'Open this link in $appName?'
                        : 'Open this link in an app?',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Dismiss',
                  // A back/swipe/cancel resolves as dismiss (§2.6).
                  onPressed: () => resolve(AppLinkDecision.dismiss),
                ),
              ],
            ),
            if (request.canRemember)
              Row(
                children: [
                  Checkbox(
                    value: remember.value,
                    onChanged: (value) => remember.value = value ?? false,
                  ),
                  const Flexible(child: Text('Remember for this site')),
                ],
              ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => resolve(AppLinkDecision.cancel),
                    child: const Text('Stay in browser'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => resolve(AppLinkDecision.open),
                    child: const Text('Open app'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
