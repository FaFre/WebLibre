import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:universal_io/io.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/utils/form_validators.dart';

const _defaultServerUrl = 'https://services.addons.mozilla.org';

class AddonCollectionScreen extends HookConsumerWidget {
  const AddonCollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final addonCollectionSetting = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (value) => value.addonCollection,
      ),
    );

    final serverURLController = useTextEditingController(
      text: addonCollectionSetting?.serverURL ?? _defaultServerUrl,
      keys: [addonCollectionSetting],
    );

    final collectionUserController = useTextEditingController(
      text: addonCollectionSetting?.collectionUser,
      keys: [addonCollectionSetting],
    );

    final collectionNameController = useTextEditingController(
      text: addonCollectionSetting?.collectionName,
      keys: [addonCollectionSetting],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Extension Collection'),
        actions: [
          if (addonCollectionSetting != null)
            IconButton(
              onPressed: () async {
                await ref
                    .read(engineSettingsRepositoryProvider.notifier)
                    .updateSettings(
                      (currentSettings) =>
                          currentSettings.copyWith.addonCollection(null),
                    );

                unawaited(
                  Future.delayed(const Duration(seconds: 1)).whenComplete(() {
                    exit(0);
                  }),
                );
              },
              icon: const Icon(Icons.delete),
            ),
        ],
      ),
      body: Form(
        key: formKey,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView(
              children: [
                TextFormField(
                  controller: serverURLController,
                  decoration: const InputDecoration(
                    label: Text('Server URL'),
                    hintText: _defaultServerUrl,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    return validateUrl(
                      value,
                      onlyHttpProtocol: true,
                      eagerParsing: false,
                    );
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: collectionUserController,
                  decoration: const InputDecoration(
                    label: Text('Collection User'),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  validator: validateRequired,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: collectionNameController,
                  decoration: const InputDecoration(
                    label: Text('Collection Name'),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  validator: validateRequired,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() == true) {
                      await ref
                          .read(engineSettingsRepositoryProvider.notifier)
                          .updateSettings(
                            (
                              currentSettings,
                            ) => currentSettings.copyWith.addonCollection(
                              AddonCollection(
                                serverURL: serverURLController.text,
                                collectionUser: collectionUserController.text,
                                collectionName: collectionNameController.text,
                              ),
                            ),
                          );

                      unawaited(
                        Future.delayed(const Duration(seconds: 1)).whenComplete(
                          () {
                            exit(0);
                          },
                        ),
                      );
                    }
                  },
                  child: const Text('Save & Restart Browser'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
