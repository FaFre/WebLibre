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
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/ui_helper.dart';

class ShareProfileDialog extends StatelessWidget {
  final String profileName;
  final String shareUri;

  const ShareProfileDialog({
    super.key,
    required this.profileName,
    required this.shareUri,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.proxy_shareDialogTitle(profileName)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.proxy_shareDialogWarning,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(maxHeight: 160),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                shareUri,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.copy),
          label: Text(l10n.common_copy),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: shareUri));
            if (context.mounted) {
              showInfoMessage(context, l10n.proxy_copiedToClipboard);
            }
          },
        ),
        TextButton.icon(
          icon: const Icon(Icons.share),
          label: Text(l10n.proxy_actionShare),
          onPressed: () async {
            await SharePlus.instance.share(
              ShareParams(text: shareUri, subject: profileName),
            );
          },
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.common_close),
        ),
      ],
    );
  }
}
