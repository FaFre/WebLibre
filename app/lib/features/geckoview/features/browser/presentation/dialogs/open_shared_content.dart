/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_chips.dart';
import 'package:weblibre/utils/form_validators.dart';

class OpenSharedContent extends HookConsumerWidget {
  final Uri sharedUrl;

  const OpenSharedContent({required this.sharedUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final textController = useTextEditingController(text: sharedUrl.toString());

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
            );

        if (context.mounted) {
          context.pop(true);
        }
      }
    }

    return Form(
      key: formKey,
      child: SimpleDialog(
        title: const Text('Open URL'),
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.maxFinite,
              child: ContainerChips(
                displayMenu: false,
                selectedContainer: selectedContainer.value,
                onSelected: (container) async {
                  if (container != null) {
                    if (await ref
                        .read(selectedContainerProvider.notifier)
                        .authenticateContainer(container)) {
                      selectedContainer.value = container;
                    }
                  } else {
                    selectedContainer.value = container;
                  }
                },
                onDeleted: (container) {
                  selectedContainer.value = null;
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16.0),
            child: TextFormField(
              controller: textController,
              keyboardType: TextInputType.url,
              minLines: 1,
              maxLines: 10,
              validator: (value) {
                return validateUrl(value, eagerParsing: false);
              },
            ),
          ),
          ListTile(
            title: const Text('Open Regular Tab'),
            leading: const Icon(MdiIcons.tab),
            onTap: () async {
              await openTab(false);
            },
          ),
          ListTile(
            title: const Text('Open Private Tab'),
            leading: const Icon(MdiIcons.tabUnselected),
            onTap: () async {
              await openTab(true);
            },
          ),
        ],
      ),
    );
  }
}
