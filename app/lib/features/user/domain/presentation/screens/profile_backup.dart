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
import 'package:fancy_password_field/fancy_password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/user/domain/presentation/dialogs/password_confirmation_dialog.dart';
import 'package:weblibre/features/user/domain/services/user_backup.dart';
import 'package:weblibre/utils/ui_helper.dart';

class ProfileBackupScreen extends HookConsumerWidget {
  final Profile profile;

  const ProfileBackupScreen({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final passwordTextController = useTextEditingController();
    final passwordController = useMemoized(() => FancyPasswordController());

    final integrityVerification = useState(true);
    final skipPasswordConfirmation = useState(false);

    final backupFuture = useState<Future<bool>?>(null);
    final backupState = useFuture(backupFuture.value);

    useEffect(() {
      if (backupState.hasError) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showErrorMessage(context, backupState.error!.toString());
        });
      } else if (backupState.hasData) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showInfoMessage(context, 'Backup created successfully');
          ProfileListRoute().go(context);
        });
      }

      return null;
    }, [backupState.hasError, backupState.hasData, backupState.error]);

    final disableInteraction =
        backupState.connectionState == ConnectionState.waiting;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Backup')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              FancyPasswordField(
                controller: passwordTextController,
                enabled: !disableInteraction,
                passwordController: passwordController,
                enableSuggestions: false,
                autocorrect: false,
                enableIMEPersonalizedLearning: false,
                keyboardType: TextInputType.visiblePassword,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                validationRules: {MinCharactersValidationRule(5)},
                validator: (value) {
                  //Make sure since onChange is sometimes unreliable
                  passwordController.onChange(value ?? '');

                  return passwordController.areAllRulesValidated
                      ? null
                      : 'Not Validated';
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: integrityVerification.value,
                onChanged: disableInteraction
                    ? null
                    : (value) {
                        integrityVerification.value = value;
                      },
                title: const Text('Verify Backup Integrity'),
                subtitle: const Text(
                  'Automatically check that backups are complete and restorable',
                ),
              ),
              ExpansionTile(
                enabled: !disableInteraction,
                childrenPadding: EdgeInsets.zero,
                tilePadding: EdgeInsets.zero,
                title: const Text('Advanced'),
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: skipPasswordConfirmation.value,
                    onChanged: disableInteraction
                        ? null
                        : (value) {
                            skipPasswordConfirmation.value = value;
                          },
                    title: const Text('Skip Password Confirmation Prompt'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (disableInteraction)
                const Column(
                  children: [
                    LinearProgressIndicator(),
                    Text('Creating Backup'),
                  ],
                )
              else
                FilledButton.icon(
                  icon: const Icon(MdiIcons.safe),
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      if (!skipPasswordConfirmation.value) {
                        final confirmation =
                            await showPasswordConfirmationDialog(context);

                        if (confirmation != passwordTextController.text) {
                          if (context.mounted) {
                            showErrorMessage(context, 'Passwords do not match');
                          }

                          return;
                        }
                      }

                      backupFuture.value = ref
                          .read(userBackupServiceProvider.notifier)
                          .createUserBackup(
                            profile,
                            password: passwordTextController.text,
                            integrityCheck: integrityVerification.value,
                          );
                    }
                  },
                  label: const Text('Backup'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
