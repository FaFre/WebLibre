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

Future<({String title, Uri url})?> showEditTopSiteDialog(
  BuildContext context, {
  required String initialTitle,
  required Uri initialUrl,
}) {
  return showDialog<({String title, Uri url})>(
    context: context,
    builder: (context) => _EditTopSiteDialog(
      initialTitle: initialTitle,
      initialUrl: initialUrl,
    ),
  );
}

class _EditTopSiteDialog extends StatefulWidget {
  final String initialTitle;
  final Uri initialUrl;

  const _EditTopSiteDialog({
    required this.initialTitle,
    required this.initialUrl,
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
    _urlController = TextEditingController(text: widget.initialUrl.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Top Site'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              autofocus: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: 'URL'),
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'URL cannot be empty';
                }
                final uri = Uri.tryParse(value.trim());
                if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
                  return 'Enter a valid URL';
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
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              final url = Uri.parse(_urlController.text.trim());
              Navigator.pop(
                context,
                (title: _titleController.text.trim(), url: url),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
