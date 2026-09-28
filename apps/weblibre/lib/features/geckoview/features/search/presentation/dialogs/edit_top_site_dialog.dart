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
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/uri_parser.dart' as uri_parser;

/// Edits an existing shortcut, or — with both initial values omitted — creates
/// one from scratch.
///
/// [dialogTitle] and [confirmLabel] default to the "edit" copy when omitted;
/// pass them explicitly for the "add" flow.
Future<({String title, Uri url})?> showEditTopSiteDialog(
  BuildContext context, {
  String initialTitle = '',
  Uri? initialUrl,
  String? dialogTitle,
  String? confirmLabel,
}) {
  return showDialog<({String title, Uri url})>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (context) => _EditTopSiteDialog(
      initialTitle: initialTitle,
      initialUrl: initialUrl,
      dialogTitle: dialogTitle,
      confirmLabel: confirmLabel,
    ),
  );
}

class _EditTopSiteDialog extends StatefulWidget {
  final String initialTitle;
  final Uri? initialUrl;
  final String? dialogTitle;
  final String? confirmLabel;

  const _EditTopSiteDialog({
    required this.initialTitle,
    required this.initialUrl,
    required this.dialogTitle,
    required this.confirmLabel,
  });

  @override
  State<_EditTopSiteDialog> createState() => _EditTopSiteDialogState();
}

class _EditTopSiteDialogState extends State<_EditTopSiteDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _urlController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _urlController = TextEditingController(
      text: widget.initialUrl?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(widget.dialogTitle ?? l10n.search_editShortcutDialogTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.search_titleFieldLabel,
              ),
              autofocus: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.search_titleCannotBeEmpty;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _urlController,
              decoration: InputDecoration(labelText: l10n.search_urlFieldLabel),
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.search_urlCannotBeEmpty;
                }
                final parsed = uri_parser.tryParseUrl(
                  value.trim(),
                  eagerParsing: true,
                );
                if (parsed == null) {
                  return l10n.search_enterValidUrl;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.common_cancel),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              final url = uri_parser.tryParseUrl(
                _urlController.text.trim(),
                eagerParsing: true,
              );
              if (url == null) return;
              Navigator.pop(context, (
                title: _titleController.text.trim(),
                url: url,
              ));
            }
          },
          child: Text(widget.confirmLabel ?? l10n.common_save),
        ),
      ],
    );
  }
}
