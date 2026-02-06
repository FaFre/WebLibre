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
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_addon.dart';

Future<bool?> showInstallLocalAddonDialog(BuildContext context) {
  return showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _InstallLocalAddonSheet(),
  );
}

class _InstallLocalAddonSheet extends HookConsumerWidget {
  const _InstallLocalAddonSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFile = useState<String?>(null);
    final allowUnsigned = useState(false);
    final isInstalling = useState(false);
    final errorMessage = useState<String?>(null);

    Future<void> pickFile() async {
      try {
        final result = await FilePicker.platform.pickFiles();

        if (result != null && result.files.isNotEmpty) {
          final path = result.files.single.path;
          if (path != null) {
            final extension = p.extension(path).toLowerCase();
            if (extension == '.xpi') {
              selectedFile.value = path;
              errorMessage.value = null;
            } else {
              errorMessage.value = 'Please select an .xpi file';
            }
          }
        }
      } catch (e) {
        errorMessage.value = 'Failed to pick file: $e';
      }
    }

    Future<void> install() async {
      if (selectedFile.value == null) return;

      isInstalling.value = true;
      errorMessage.value = null;

      try {
        await ref
            .read(browserAddonServiceProvider.notifier)
            .installFromFile(
              selectedFile.value!,
              allowUnsigned: allowUnsigned.value,
            );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Extension installed successfully')),
          );
          context.pop(true);
        }
      } catch (e) {
        final errorString = e.toString();
        if (errorString.contains('NotSigned') ||
            errorString.contains('SIGNEDSTATE')) {
          errorMessage.value =
              'This extension is not signed by Mozilla. Enable "Allow unsigned extensions" to install it.';
        } else {
          errorMessage.value = 'Installation failed: $errorString';
        }
      } finally {
        isInstalling.value = false;
      }
    }

    final fileName = selectedFile.value != null
        ? p.basename(selectedFile.value!)
        : 'No file selected';

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Install Extension from File',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: isInstalling.value ? null : pickFile,
              icon: const Icon(Icons.folder_open),
              label: const Text('Select XPI File'),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    selectedFile.value != null
                        ? Icons.extension
                        : Icons.file_present_outlined,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fileName,
                      style: TextStyle(
                        color: selectedFile.value != null
                            ? null
                            : Theme.of(context).colorScheme.outline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Allow unsigned extensions'),
              subtitle: const Text(
                'Unsigned extensions have not been verified by Mozilla',
              ),
              value: allowUnsigned.value,
              onChanged: isInstalling.value
                  ? null
                  : (value) => allowUnsigned.value = value,
            ),
            if (allowUnsigned.value) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.errorContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Only install unsigned extensions from sources you trust. '
                        'They may contain malicious code.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (errorMessage.value != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  errorMessage.value!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  maxLines: 10,
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: selectedFile.value == null || isInstalling.value
                  ? null
                  : install,
              child: isInstalling.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Install'),
            ),
          ],
        ),
      ),
    );
  }
}
