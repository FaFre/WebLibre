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
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/utils/localized_spans.dart';

typedef DeleteDecision = ({bool delete, bool remember});

Future<DeleteDecision?> showDeleteFileDialog(
  BuildContext context,
  String filePath, {
  bool multiFileMode = false,
}) {
  return showDialog<DeleteDecision>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (context) {
      final fileName = p.basename(filePath);

      return HookBuilder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          final remember = useState(false);

          return AlertDialog(
            icon: const Icon(Icons.warning),
            title: Text(l10n.history_deleteFileTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: localizedSpans(
                      l10n.history_deleteFileConfirm(spanPlaceholder(0)),
                      spans: [
                        TextSpan(
                          text: fileName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.history_deleteFileWarning,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (multiFileMode) ...[
                  const SizedBox(height: 16),
                  CheckboxListTile.adaptive(
                    value: remember.value,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      remember.value = value!;
                    },
                    title: Text(l10n.history_deleteFileRememberChoice),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  context.pop<DeleteDecision>((
                    delete: false,
                    remember: remember.value,
                  ));
                },
                child: Text(l10n.history_deleteFileActionKeep),
              ),
              FilledButton(
                onPressed: () {
                  context.pop<DeleteDecision>((
                    delete: true,
                    remember: remember.value,
                  ));
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: Text(l10n.common_delete),
              ),
            ],
          );
        },
      );
    },
  );
}
