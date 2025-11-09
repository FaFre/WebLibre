import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';
import 'package:weblibre/utils/form_validators.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;
import 'package:weblibre/utils/uri_parser.dart' as uri_parser;

class ContainerSitesScreen extends HookConsumerWidget {
  final Set<Uri> initialSites;

  const ContainerSitesScreen({super.key, required this.initialSites});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final textController = useTextEditingController();

    final sites = useState(initialSites);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.pop(result ?? sites.value);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: BackButton(
            onPressed: () {
              context.pop(sites.value);
            },
          ),
          title: const Text('Site Assignments'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    decoration: InputDecoration(
                      label: const Text('Add Site'),
                      hintText: 'example.com',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      suffix: TextButton(
                        onPressed: () {
                          if (formKey.currentState?.validate() == true) {
                            formKey.currentState?.save();
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ),
                    controller: textController,
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      final uriValid = validateUrl(
                        value,
                        onlyHttpProtocol: true,
                        eagerParsing: true,
                      );

                      if (uriValid != null) {
                        return uriValid;
                      }

                      final origin = Uri.parse(
                        uri_parser
                            .tryParseUrl(value, eagerParsing: true)!
                            .origin,
                      );

                      if (sites.value.contains(origin)) {
                        return 'This site has been already assigned';
                      }

                      return null;
                    },
                    onSaved: (newValue) async {
                      final origin = Uri.parse(
                        uri_parser
                            .tryParseUrl(newValue, eagerParsing: true)!
                            .origin,
                      );

                      final isAssigned = await ref
                          .read(containerRepositoryProvider.notifier)
                          .isSiteAssignedToContainer(origin);

                      if (!isAssigned) {
                        sites.value = {...sites.value, origin};
                      } else {
                        final assignedContainerId = await ref
                            .read(containerRepositoryProvider.notifier)
                            .siteAssignedContainerId(origin);
                        final assignedContainer = await assignedContainerId
                            .mapNotNull(
                              (id) => ref
                                  .read(containerRepositoryProvider.notifier)
                                  .getContainerData(id),
                            );

                        if (context.mounted) {
                          ui_helper.showErrorMessage(
                            context,
                            (assignedContainer?.name.isNotEmpty ?? false)
                                ? '$origin has already been assigned to container "${assignedContainer?.name}"'
                                : '$origin has already been assigned to another container',
                          );
                        }
                      }

                      textController.clear();
                    },
                    onFieldSubmitted: (_) {
                      if (formKey.currentState?.validate() == true) {
                        formKey.currentState?.save();
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: sites.value.length,
                  itemBuilder: (context, index) {
                    final site = sites.value.elementAt(index);

                    return ListTile(
                      leading: UrlIcon([site], iconSize: 20),
                      title: Text(site.host),
                      subtitle: Text(site.toString()),
                      trailing: IconButton(
                        onPressed: () {
                          sites.value = {...sites.value}..remove(site);
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
