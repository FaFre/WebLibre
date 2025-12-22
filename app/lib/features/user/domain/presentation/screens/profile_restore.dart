import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/user/domain/services/user_backup.dart';
import 'package:weblibre/utils/form_validators.dart';
import 'package:weblibre/utils/ui_helper.dart';

enum RestoreTarget { createOrOverride, createNew }

class ProfileRestoreScreen extends HookConsumerWidget {
  final File backupFile;

  const ProfileRestoreScreen({super.key, required this.backupFile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final passwordTextController = useTextEditingController();
    final nameTextController = useTextEditingController();

    final restoreFuture = useState<Future<bool>?>(null);
    final restoreState = useFuture(restoreFuture.value);

    final restoreTarget = useState(RestoreTarget.createNew);

    useEffect(() {
      if (restoreState.hasError) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showErrorMessage(context, restoreState.error!.toString());
        });
      } else if (restoreState.hasData) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showInfoMessage(context, 'Backup restored successfully');
          ProfileListRoute().go(context);
        });
      }

      return null;
    }, [restoreState.hasError, restoreState.hasData, restoreState.error]);

    final disableInteraction =
        restoreState.connectionState == ConnectionState.waiting;

    return Scaffold(
      appBar: AppBar(title: const Text('Restore Backup')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: passwordTextController,
                enabled: !disableInteraction,
                enableSuggestions: false,
                autocorrect: false,
                enableIMEPersonalizedLearning: false,
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                validator: (value) {
                  return validateRequired(value, message: 'Password required');
                },
              ),
              const SizedBox(height: 16),
              RadioGroup(
                groupValue: restoreTarget.value,
                onChanged: (value) {
                  if (value != null) {
                    restoreTarget.value = value;
                  }
                },
                child: Column(
                  children: [
                    RadioListTile(
                      enabled: !disableInteraction,
                      value: RestoreTarget.createNew,
                      title: const Text('Create New User'),
                      subtitle: const Text('Restore backup as a new user'),
                    ),
                    RadioListTile(
                      enabled: !disableInteraction,
                      value: RestoreTarget.createOrOverride,
                      title: const Text('Restore & Replace'),
                      subtitle: const Text(
                        'Restore backup and overwrite existing user if present',
                      ),
                    ),
                  ],
                ),
              ),
              if (restoreTarget.value == RestoreTarget.createNew)
                TextFormField(
                  controller: nameTextController,
                  enabled: !disableInteraction,
                  decoration: const InputDecoration(
                    label: Text('Name'),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  validator: validateProfileName,
                ),
              const SizedBox(height: 16),
              if (disableInteraction)
                const Column(
                  children: [
                    LinearProgressIndicator(),
                    Text('Restoring Backup'),
                  ],
                )
              else
                FilledButton.icon(
                  icon: const Icon(MdiIcons.backupRestore),
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      restoreFuture.value = switch (restoreTarget.value) {
                        RestoreTarget.createOrOverride =>
                          ref
                              .read(userBackupServiceProvider.notifier)
                              .restoreAndCreateOrOverride(
                                backupFile,
                                password: passwordTextController.text,
                                confirmOverrideCallback: () {
                                  if (context.mounted) {
                                    return showDialog<bool?>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          icon: const Icon(Icons.warning),
                                          title: const Text('Override User'),
                                          content: const Text(
                                            'Are you sure you want to override the exisiting User?',
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, false);
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, true);
                                              },
                                              child: const Text('Override'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    throw Exception('Override failed');
                                  }
                                },
                              ),
                        RestoreTarget.createNew =>
                          ref
                              .read(userBackupServiceProvider.notifier)
                              .restoreAndCreateNew(
                                backupFile,
                                profileName: nameTextController.text,
                                password: passwordTextController.text,
                              ),
                      };
                    }
                  },
                  label: const Text('Restore'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
