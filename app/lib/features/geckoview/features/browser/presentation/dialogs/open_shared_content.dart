import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
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
              height: 48,
              width: double.maxFinite,
              child: ContainerChips(
                displayMenu: false,
                selectedContainer: selectedContainer.value,
                onSelected: (container) {
                  selectedContainer.value = container;
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
                return validateUrl(
                  value,
                  onlyHttpProtocol: true,
                  eagerParsing: false,
                );
              },
            ),
          ),
          ListTile(
            title: const Text('Open Regular Tab'),
            leading: const Icon(MdiIcons.tab),
            onTap: () async {
              await openTab(false);
              if (context.mounted) {
                context.pop();
              }
            },
          ),
          ListTile(
            title: const Text('Open Private Tab'),
            leading: const Icon(MdiIcons.tabUnselected),
            onTap: () async {
              await openTab(true);
              if (context.mounted) {
                context.pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
