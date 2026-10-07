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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/user/data/models/auth_settings.dart';
import 'package:weblibre/features/user/domain/presentation/dialogs/profile_password_dialogs.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/user/domain/providers/profile_auth.dart';
import 'package:weblibre/features/user/domain/repositories/profile.dart';
import 'package:weblibre/features/user/domain/services/profile_password.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/hooks/on_initialization.dart';
import 'package:weblibre/presentation/utils/profile_copy_l10n.dart';
import 'package:weblibre/presentation/widgets/obscurable_text_field.dart';
import 'package:weblibre/utils/exit_app.dart';
import 'package:weblibre/utils/ui_helper.dart';

class LockScreen extends HookConsumerWidget {
  const LockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isAuthenticating = useState(false);
    final isSwitching = useState(false);
    final didAutoAuthenticate = useRef(false);

    final lockMethod = ref.watch(
      selectedProfileProvider.select(
        (profile) => profile.value?.authSettings.lockMethod,
      ),
    );
    final usesPassword = lockMethod == ProfileLockMethod.password;
    final password = useTextEditingController();
    final passwordText = useValueListenable(password).text;
    final passwordError = useState<String?>(null);

    /// Whether there is another profile to choose.
    ///
    /// The picker is not consulted: "choose another profile" asks for it
    /// explicitly, so it shows even when the prompt setting is off. With one
    /// profile the picker would have nothing to offer, and the restart would
    /// land straight back here.
    final hasOtherProfiles = ref.watch(
      profileRepositoryProvider.select(
        (profiles) => (profiles.value?.length ?? 0) >= 2,
      ),
    );

    Future<void> authenticate() async {
      if (isAuthenticating.value) return;

      isAuthenticating.value = true;

      try {
        await ref
            .read(profileAuthStateProvider.notifier)
            .authenticate(
              localizedReason: AppLocalizations.of(
                context,
              ).user_authReasonUnlockProfile,
            );
      } finally {
        if (context.mounted) {
          isAuthenticating.value = false;
        }
      }
    }

    Future<void> unlockWithPassword() async {
      if (isAuthenticating.value || passwordText.isEmpty) return;

      isAuthenticating.value = true;

      try {
        final result = await ref
            .read(profileAuthStateProvider.notifier)
            .unlockWithPassword(password.text);

        if (context.mounted && result is! ProfilePasswordAccepted) {
          password.clear();
          passwordError.value = describeProfilePasswordCheck(l10n, result);
        }
      } catch (e, s) {
        // Stays locked: a check that could not record its outcome is not a
        // pass.
        logger.e('Profile password unlock failed', error: e, stackTrace: s);
        if (context.mounted) {
          passwordError.value = l10n.user_profilePasswordCheckFailed;
        }
      } finally {
        if (context.mounted) {
          isAuthenticating.value = false;
        }
      }
    }

    // Only the device prompt opens by itself. A password-locked profile is
    // refused by `authenticate` without prompting, so this is harmless there,
    // and the field below takes over.
    useOnInitialization(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!didAutoAuthenticate.value) {
          didAutoAuthenticate.value = true;
          unawaited(authenticate());
        }
      });
      return null;
    });

    /// Restarts so the startup picker can be answered again.
    ///
    /// The profile question is settled for the life of the process — that is what
    /// keeps Dart, Gecko and the native side on one profile — so there is no
    /// in-place way back to the picker. A relaunch with no target is the honest
    /// implementation: the arbiter re-arbitrates from scratch.
    ///
    /// It asks for the picker explicitly (`showPicker`) rather than relying on
    /// the prompt setting. When this screen only offered the way out with the
    /// picker enabled, someone who forgot a profile password and had the
    /// picker off was stuck here for good.
    Future<void> chooseAnother() async {
      if (isSwitching.value) return;
      isSwitching.value = true;

      try {
        // A refusal is reported, not thrown: native declines when it could not
        // start the relaunch trampoline, and exiting on that answer would close
        // the app for good instead of returning the user to the picker.
        final armed = await GeckoProfileService().armProfileRestart(
          reason: 'the user could not unlock this profile',
          showPicker: true,
        );
        if (!armed) {
          isSwitching.value = false;
          if (context.mounted) {
            showErrorMessage(context, restartCouldNotBeScheduled(l10n));
          }
          return;
        }
      } catch (error) {
        isSwitching.value = false;
        if (context.mounted) {
          showErrorMessage(
            context,
            l10n.user_restartFailedWithError(error.toString()),
          );
        }
        return;
      }

      await exitApp(ref.container, restart: true);
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          // Scrolls so the keyboard raised by the password field cannot push
          // the column out of its box.
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(MdiIcons.lock, size: 64),
                const SizedBox(height: 16),
                Text(l10n.user_profileLockedTitle),
                const SizedBox(height: 16),
                if (usesPassword) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: ObscurableTextField(
                        controller: password,
                        enabled: !isAuthenticating.value && !isSwitching.value,
                        autofocus: true,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => passwordError.value = null,
                        onSubmitted: (_) => unlockWithPassword(),
                        decoration: InputDecoration(
                          labelText: l10n.user_profilePasswordFieldLabel,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          errorText: passwordError.value,
                          errorMaxLines: 3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(160, 40),
                    ),
                    icon: const Icon(MdiIcons.lockOpenVariant),
                    label: Text(
                      isAuthenticating.value
                          ? l10n.user_unlockingLabel
                          : l10n.user_unlockButtonLabel,
                    ),
                    onPressed:
                        isAuthenticating.value ||
                            isSwitching.value ||
                            passwordText.isEmpty
                        ? null
                        : unlockWithPassword,
                  ),
                ] else
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(160, 40),
                    ),
                    icon: const Icon(MdiIcons.fingerprint),
                    label: Text(
                      isAuthenticating.value
                          ? l10n.user_unlockingLabel
                          : l10n.user_unlockButtonLabel,
                    ),
                    // Disabled until the lock method is known, so a tap during
                    // the first frame cannot raise the device prompt for a
                    // profile that turns out to need its password.
                    onPressed:
                        lockMethod == null ||
                            isAuthenticating.value ||
                            isSwitching.value
                        ? null
                        : authenticate,
                  ),
                // Without this the only way out of a lock the user cannot pass is
                // to close the app and reopen it — which they have to work out for
                // themselves, from a screen that does not say so. The picker warns
                // that a locked profile leads here; this is the way back.
                if (hasOtherProfiles) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(MdiIcons.accountSwitch),
                    label: Text(
                      isSwitching.value
                          ? l10n.user_restartingLabel
                          : l10n.user_chooseAnotherProfileLabel,
                    ),
                    onPressed: isAuthenticating.value || isSwitching.value
                        ? null
                        : chooseAnother,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
