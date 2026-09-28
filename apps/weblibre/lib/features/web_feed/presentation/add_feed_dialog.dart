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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/web_feed/domain/providers/add_dialog_blocking.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/form_validators.dart';

class AddFeedDialog extends HookConsumerWidget {
  final Uri? initialUri;

  const AddFeedDialog({super.key, required this.initialUri});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final textController = useTextEditingController(
      text: initialUri?.toString(),
    );

    return AlertDialog(
      title: Text(l10n.webFeed_addFeedTitle),
      // contentPadding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 16.0),
      content: Form(
        key: formKey,
        child: TextFormField(
          decoration: InputDecoration(
            label: Text(l10n.webFeed_fieldUrlLabel),
            hintText: 'https://example.com/feed',
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
          controller: textController,
          keyboardType: TextInputType.url,
          minLines: 1,
          maxLines: 10,
          validator: (value) {
            return validateUrl(
              value,
              onlyHttpProtocol: true,
              eagerParsing: false,
              l10n: l10n,
            );
          },
        ),
      ),
      actions: [
        if (initialUri != null)
          TextButton(
            onPressed: () {
              ref
                  .read(addFeedDialogBlockingProvider.notifier)
                  .ignore(initialUri!);
              context.pop();
            },
            child: Text(l10n.webFeed_actionIgnore),
          ),
        TextButton(
          onPressed: () {
            context.pop();
          },
          child: Text(l10n.common_cancel),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState?.validate() == true) {
              final feedId = parseValidatedUrl(
                textController.text,
                eagerParsing: false,
                onlyHttpProtocol: true,
              );
              if (feedId == null) {
                return;
              }

              FeedCreateRoute(feedId: feedId).pushReplacement(context);
            }
          },
          child: Text(l10n.common_add),
        ),
      ],
    );
  }
}
