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
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/user/domain/presentation/dialogs/delete_profile_dialog.dart';
import 'package:weblibre/features/user/domain/presentation/utils/profile_switch_handler.dart';
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
                validator: validateProfileName,
              ),
              const SizedBox(height: 16),
              if (profile != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    label: const Text('Backup'),
                    icon: const Icon(MdiIcons.safe),
                    onPressed: () async {
                      await BackupProfileRoute(
                        profile: jsonEncode(profile!.toJson()),
                      ).push(context);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                if (filesystem.selectedProfile != profile!.uuidValue)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      label: const Text('Switch to this Profile'),
                      icon: const Icon(MdiIcons.accountSwitch),
                      onPressed: () async {
                        await handleSwitchProfile(context, ref, profile!);
                      },
                    ),
                  ),
                const SizedBox(height: 16),
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
                      final result = await showDeleteProfileDialog(context);

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
            ],
          ),
        ),
      ),
    );
  }
}
