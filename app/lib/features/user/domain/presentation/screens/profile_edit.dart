import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/user/domain/repositories/profile.dart';
import 'package:weblibre/utils/form_validators.dart';

class ProfileEditScreen extends HookConsumerWidget {
  final Profile? profile;

  const ProfileEditScreen({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameTextController = useTextEditingController(text: profile?.name);

    return Scaffold(
      appBar: AppBar(
        title: (profile != null)
            ? const Text('Edit User')
            : const Text('Create User'),
        actions: [
          IconButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                if (profile != null) {
                  await ref
                      .read(profileRepositoryProvider.notifier)
                      .updateProfileMetadata(
                        profile!.copyWith.name(nameTextController.text),
                      );

                  if (context.mounted) {
                    context.pop();
                  }
                } else {
                  await ref
                      .read(profileRepositoryProvider.notifier)
                      .createProfile(name: nameTextController.text);

                  if (context.mounted) {
                    context.pop();
                  }
                }
              }
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: ListView(
            children: [
              TextFormField(
                controller: nameTextController,
                decoration: const InputDecoration(
                  label: Text('Name'),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                validator: validateRequired,
              ),
              const SizedBox(height: 16),
              if (profile != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      foregroundColor: Theme.of(context).colorScheme.error,
                      iconColor: Theme.of(context).colorScheme.error,
                    ),
                    label: const Text('Delete'),
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final result = await showDialog<bool?>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            icon: const Icon(Icons.warning),
                            title: const Text('Delete User'),
                            content: const Text(
                              'Are you sure you want to delete this User including all data?',
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
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );

                      if (result == true) {
                        await ref
                            .read(profileRepositoryProvider.notifier)
                            .deleteProfile(profile!.uuidValue.uuid);

                        if (context.mounted) {
                          context.pop();
                        }
                      }
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
