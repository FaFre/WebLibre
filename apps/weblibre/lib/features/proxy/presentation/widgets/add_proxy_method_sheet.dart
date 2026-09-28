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
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/branding/proxy_brands.dart';
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/features/proxy/data/models/proxy_profile_seed.dart';
import 'package:weblibre/features/proxy/domain/services/proxy_input_consumer.dart';
import 'package:weblibre/features/qr_scanner/presentation/dialogs/qr_scanner_dialog.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// Outcome of the add-proxy bottom sheet. The sheet itself does not navigate
/// or surface success messages: it pops with one of these so the caller can
/// drive navigation from a stable, non-deactivated context.
sealed class AddProxyAction {
  const AddProxyAction();
}

class AddProxyManual extends AddProxyAction {
  const AddProxyManual();
}

class AddProxySubscription extends AddProxyAction {
  const AddProxySubscription();
}

class AddProxyWithSeed extends AddProxyAction {
  final ProxyProfileSeed seed;
  const AddProxyWithSeed(this.seed);
}

class AddProxyImported extends AddProxyAction {
  final String message;
  const AddProxyImported(this.message);
}

/// Guided bottom sheet shown when the user adds a new proxy profile. Each
/// method either pops with an [AddProxyAction] for the caller to apply or
/// stays open so the user can try another method on error.
class AddProxyMethodSheet extends ConsumerWidget {
  const AddProxyMethodSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    void popWith(AddProxyAction action) {
      if (!context.mounted) return;
      Navigator.of(context).pop(action);
    }

    Future<void> scanQr() async {
      final result = await showQrScannerDialog(context);
      final code = result?.code?.trim();
      if (code == null || code.isEmpty) return;
      if (!context.mounted) return;
      final action = await _consumeRawText(context, ref, code);
      if (action == null) return;
      popWith(action);
    }

    Future<void> pasteClipboard() async {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim();
      if (text == null || text.isEmpty) {
        if (context.mounted) {
          showInfoMessage(context, l10n.proxy_clipboardEmpty);
        }
        return;
      }
      if (!context.mounted) return;
      final action = await _consumeRawText(context, ref, text);
      if (action == null) return;
      popWith(action);
    }

    Future<void> importFromFile() async {
      final kind = await showModalBottomSheet<ProxyFileImportKind>(
        context: context,
        anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
        showDragHandle: true,
        builder: (_) => const _FileKindPicker(),
      );
      if (kind == null) return;
      if (!context.mounted) return;
      final action = await _consumeFile(context, ref, kind);
      if (action == null) return;
      popWith(action);
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.proxy_addConnectionTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.proxy_addConnectionSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: [
                _MethodCard(
                  icon: Icons.content_paste,
                  title: l10n.proxy_methodClipboardTitle,
                  subtitle: l10n.proxy_methodClipboardSubtitle,
                  onTap: pasteClipboard,
                  isPrimary: true,
                ),
                _MethodCard(
                  icon: Icons.qr_code_scanner,
                  title: l10n.proxy_methodScanQrTitle,
                  subtitle: l10n.proxy_methodScanQrSubtitle,
                  onTap: scanQr,
                ),
                _MethodCard(
                  icon: Icons.cloud_download_outlined,
                  title: l10n.proxy_methodSubscriptionTitle,
                  subtitle: l10n.proxy_methodSubscriptionSubtitle,
                  onTap: () => popWith(const AddProxySubscription()),
                ),
                _MethodCard(
                  icon: Icons.upload_file_outlined,
                  title: l10n.proxy_methodImportFileTitle,
                  subtitle: l10n.proxy_methodImportFileSubtitle,
                  onTap: importFromFile,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: () => popWith(const AddProxyManual()),
                icon: const Icon(Icons.edit_note),
                label: Text(l10n.proxy_enterManually),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isPrimary;

  const _MethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = isPrimary
        ? scheme.primaryContainer
        : scheme.surfaceContainerHigh;
    final iconColor = isPrimary ? scheme.onPrimaryContainer : scheme.primary;
    final titleColor = isPrimary ? scheme.onPrimaryContainer : scheme.onSurface;
    final subtitleColor = isPrimary
        ? scheme.onPrimaryContainer.withValues(alpha: 0.75)
        : scheme.onSurfaceVariant;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: iconColor),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: subtitleColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FileKindPicker extends StatelessWidget {
  const _FileKindPicker();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.proxy_importFromFileTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.vpn_lock),
              title: Text(l10n.proxy_wireGuardConfigLabel(wireGuardBrand)),
              subtitle: Text(l10n.proxy_importFileWireGuardSubtitle),
              onTap: () =>
                  Navigator.of(context).pop(ProxyFileImportKind.wireguardConf),
            ),
            ListTile(
              leading: const Icon(Icons.data_object),
              title: Text(l10n.proxy_importFileSingboxJsonTitle),
              subtitle: Text(l10n.proxy_importFileSingboxJsonSubtitle),
              onTap: () => Navigator.of(
                context,
              ).pop(ProxyFileImportKind.singboxOutboundJson),
            ),
          ],
        ),
      ),
    );
  }
}

Future<AddProxyAction?> _consumeFile(
  BuildContext context,
  WidgetRef ref,
  ProxyFileImportKind kind,
) async {
  final picked = await FilePicker.pickFile();
  if (picked == null) return null;

  final outcome = await ref
      .read(proxyInputConsumerProvider.notifier)
      .consumeFile(kind, picked);
  if (!context.mounted) return null;
  return _actionFromOutcome(context, outcome);
}

Future<AddProxyAction?> _consumeRawText(
  BuildContext context,
  WidgetRef ref,
  String rawText,
) async {
  final outcome = await ref
      .read(proxyInputConsumerProvider.notifier)
      .consumeRawText(rawText);
  if (!context.mounted) return null;
  return _actionFromOutcome(context, outcome);
}

AddProxyAction? _actionFromOutcome(
  BuildContext context,
  ProxyInputOutcome outcome,
) {
  final l10n = AppLocalizations.of(context);
  switch (outcome) {
    case ProxyInputImported(:final created):
      return AddProxyImported(l10n.proxy_importedProfileNamed(created.name));
    case ProxyInputSeed(:final seed):
      return AddProxyWithSeed(seed);
    case ProxyInputError(:final message):
      showErrorMessage(context, message);
      return null;
  }
}
