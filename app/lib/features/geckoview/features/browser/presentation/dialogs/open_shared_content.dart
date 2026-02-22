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
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart'
    show GeckoBrowserService;
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_chips.dart';
import 'package:weblibre/utils/form_validators.dart';

class OpenSharedContent extends HookConsumerWidget {
  final Uri sharedUrl;

  const OpenSharedContent({super.key, required this.sharedUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final textController = useTextEditingController(text: sharedUrl.toString());
    final appColors = AppColors.of(context);

    final selectedContainer = useState<ContainerData?>(null);

    Future<void> openTab(bool isPrivate) async {
      if (formKey.currentState?.validate() == true) {
        await ref
            .read(tabRepositoryProvider.notifier)
            .addTab(
              url: Uri.parse(textController.text),
              private: isPrivate,
              container: Value(selectedContainer.value),
              launchedFromIntent: true,
              selectTab: true,
            );

        if (context.mounted) {
          context.pop(true);
        }
      }
    }

    Future<void> openCustomTab(bool isPrivate) async {
      if (formKey.currentState?.validate() == true) {
        await GeckoBrowserService().openInCustomTab(
          url: Uri.parse(textController.text),
          private: isPrivate,
          contextId: selectedContainer.value?.id,
        );

        if (context.mounted) {
          context.pop(true);
        }
      }
    }

    return SafeArea(
      child: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Open link', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ContainerChips(
                displayMenu: false,
                selectedContainer: selectedContainer.value,
                onSelected: (container) {
                  selectedContainer.value = container;
                },
                onDeleted: (container) {
                  selectedContainer.value = null;
                },
              ),
              TextFormField(
                controller: textController,
                keyboardType: TextInputType.url,
                minLines: 1,
                maxLines: 10,
                validator: (value) {
                  return validateUrl(value, eagerParsing: false);
                },
              ),
              const SizedBox(height: 8),
              _OpenActionTile(
                title: 'Open in new tab',
                subtitle: 'Add to your browser tabs',
                icon: MdiIcons.tab,
                privateColor: appColors.privateTabPurple,
                onTap: () => openTab(false),
                onPrivateTap: () => openTab(true),
              ),
              _OpenActionTile(
                title: 'Open in custom tab',
                subtitle: 'Open in a separate window',
                icon: MdiIcons.applicationOutline,
                privateColor: appColors.privateTabPurple,
                onTap: () => openCustomTab(false),
                onPrivateTap: () => openCustomTab(true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpenActionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color privateColor;
  final VoidCallback onTap;
  final VoidCallback onPrivateTap;

  const _OpenActionTile({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.privateColor,
    required this.onTap,
    required this.onPrivateTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      leading: Icon(icon),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24, child: VerticalDivider(width: 16)),
          IconButton(
            icon: Icon(MdiIcons.dominoMask, color: privateColor, size: 24),
            tooltip: 'Private',
            onPressed: onPrivateTap,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
