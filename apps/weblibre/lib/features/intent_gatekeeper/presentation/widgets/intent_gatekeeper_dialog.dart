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
import 'package:weblibre/features/intent_gatekeeper/domain/entities/intent_source_policy.dart';
import 'package:weblibre/features/intent_gatekeeper/domain/entities/pending_intent_decision.dart';
import 'package:weblibre/features/intent_gatekeeper/domain/services/package_label_resolver.dart';
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';

class DialogOutcome {
  final IntentSourcePolicy decision;
  final bool persist;

  const DialogOutcome({required this.decision, this.persist = false});
}

class IntentGatekeeperDialog extends HookConsumerWidget {
  final PendingIntentDecision request;

  const IntentGatekeeperDialog({super.key, required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bold = TextStyle(
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
    );

    final label = ref.watch(
      packageLabelProvider(request.packageName).select((value) => value.value),
    );

    final displayName = (label != null && label.isNotEmpty)
        ? label
        : request.packageName;

    final uri = request.url != null ? Uri.tryParse(request.url!) : null;

    return AlertDialog(
      icon: const Icon(Icons.shield_outlined, size: 32),
      title: const Text('Open link in WebLibre?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                children: [
                  TextSpan(text: displayName, style: bold),
                  const TextSpan(text: ' is trying to open a link in '),
                  TextSpan(text: 'WebLibre', style: bold),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            if (uri != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: UriBreadcrumb(
                  uri: uri,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      actionsPadding: const EdgeInsets.all(24),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(
                const DialogOutcome(
                  decision: IntentSourcePolicy.allow,
                  persist: true,
                ),
              ),
              child: const Text('Always allow'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => Navigator.of(context).pop(
                const DialogOutcome(decision: IntentSourcePolicy.allow),
              ),
              child: const Text('Allow once'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(
                const DialogOutcome(decision: IntentSourcePolicy.block),
              ),
              child: const Text('Block once'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(
                const DialogOutcome(
                  decision: IntentSourcePolicy.block,
                  persist: true,
                ),
              ),
              child: const Text('Always block'),
            ),
          ],
        ),
      ],
    );
  }
}
