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
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/user/data/models/auth_settings.dart';
import 'package:weblibre/features/user/domain/services/profile_password.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/obscurable_text_field.dart';

/// The sentence that says how long the next attempt has to wait.
String describePasswordRetryAfter(AppLocalizations l10n, Duration wait) {
  // Rounded up: "try again in 0 seconds" for a wait that is still running
  // reads as a bug.
  final seconds = (wait.inMilliseconds / 1000).ceil();
  if (seconds < 120) {
    return l10n.user_passwordRetryInSeconds(seconds);
  }
  return l10n.user_passwordRetryInMinutes((seconds / 60).ceil());
}

/// The error under a password field for an attempt that did not unlock.
String? describeProfilePasswordCheck(
  AppLocalizations l10n,
  ProfilePasswordCheck check,
) {
  return switch (check) {
    ProfilePasswordAccepted() => null,
    ProfilePasswordRejected(retryAfter: null) => l10n.user_wrongProfilePassword,
    ProfilePasswordRejected(:final retryAfter?) =>
      l10n.user_wrongProfilePasswordWithRetry(
        describePasswordRetryAfter(l10n, retryAfter),
      ),
    ProfilePasswordInterrupted() => l10n.user_profilePasswordInterrupted,
    ProfilePasswordThrottled(:final retryAfter) =>
      l10n.user_tooManyPasswordAttempts(
        describePasswordRetryAfter(l10n, retryAfter),
      ),
  };
}

/// Asks for the password of the profile in [profileDir].
///
/// Returns true once the password is accepted, false when the dialog is
/// dismissed. Wrong attempts are answered inside the dialog, so the person can
/// try again without reopening it.
///
/// [departureCount] is read before and after each check; see
/// `LocalAuthenticationService.departureCount`. A check during which the app
/// left the foreground does not authorize.
Future<bool> showProfilePasswordDialog(
  BuildContext context, {
  required Directory profileDir,
  required AuthSettings settings,
  required String title,
  required int Function() departureCount,
}) async {
  final result = await showDialog<bool>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (context) => _ProfilePasswordDialog(
      profileDir: profileDir,
      settings: settings,
      title: title,
      departureCount: departureCount,
    ),
  );

  return result ?? false;
}

class _ProfilePasswordDialog extends HookWidget {
  final Directory profileDir;
  final AuthSettings settings;
  final String title;
  final int Function() departureCount;

  const _ProfilePasswordDialog({
    required this.profileDir,
    required this.settings,
    required this.title,
    required this.departureCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = useTextEditingController();
    final passwordText = useValueListenable(controller).text;
    final checking = useState(false);
    final error = useState<String?>(null);

    Future<void> submit() async {
      if (checking.value || passwordText.isEmpty) return;
      checking.value = true;

      try {
        final departuresBefore = departureCount();
        var result = await ProfilePasswordGate(
          profileDir,
        ).check(settings, controller.text);

        if (!context.mounted) return;

        // An authorization that lands while the app is away would let the
        // action run — and a backup restart into a screen that asks whoever
        // opens the app next for the archive password.
        if (result is ProfilePasswordAccepted &&
            departureCount() != departuresBefore) {
          result = const ProfilePasswordInterrupted();
        }

        if (result is ProfilePasswordAccepted) {
          Navigator.of(context).pop(true);
          return;
        }

        controller.clear();
        error.value = describeProfilePasswordCheck(l10n, result);
      } catch (e, s) {
        // Most likely the attempt record could not be written. Denied, not
        // waved through: a check that cannot count its failures must not
        // count as passed.
        logger.e('Profile password check failed', error: e, stackTrace: s);
        if (context.mounted) {
          error.value = l10n.user_profilePasswordCheckFailed;
        }
      } finally {
        if (context.mounted) {
          checking.value = false;
        }
      }
    }

    // Not dismissible mid-check: the answer would arrive with nobody to give it
    // to, and a reopened dialog would start a second check.
    return PopScope(
      canPop: !checking.value,
      child: AlertDialog(
        title: Text(title),
        content: ObscurableTextField(
          controller: controller,
          enabled: !checking.value,
          autofocus: true,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
          onChanged: (_) => error.value = null,
          onSubmitted: (_) => submit(),
          decoration: InputDecoration(
            labelText: l10n.user_profilePasswordFieldLabel,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            errorText: error.value,
            errorMaxLines: 3,
          ),
        ),
        actions: [
          TextButton(
            onPressed: checking.value
                ? null
                : () => Navigator.of(context).pop(false),
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: checking.value || passwordText.isEmpty ? null : submit,
            child: checking.value
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.user_actionConfirm),
          ),
        ],
      ),
    );
  }
}

/// Asks for a new profile password, twice, and returns its verifier.
///
/// Returns null when the dialog is dismissed. The only rule is the one backup
/// passwords already have: it must not be empty.
Future<String?> showSetProfilePasswordDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (context) => const _SetProfilePasswordDialog(),
  );
}

class _SetProfilePasswordDialog extends HookWidget {
  const _SetProfilePasswordDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final password = useTextEditingController();
    final repeat = useTextEditingController();
    final passwordText = useValueListenable(password).text;
    final repeatText = useValueListenable(repeat).text;
    final saving = useState(false);
    final saveFailed = useState(false);

    final mismatch = repeatText.isNotEmpty && repeatText != passwordText;
    final canSave =
        !saving.value && passwordText.isNotEmpty && repeatText == passwordText;

    Future<void> save() async {
      if (!canSave) return;
      saving.value = true;
      saveFailed.value = false;

      try {
        final verifier = await createProfilePasswordVerifier(passwordText);
        if (context.mounted) {
          Navigator.of(context).pop(verifier);
        }
      } catch (e, s) {
        logger.e(
          'Could not create a profile password',
          error: e,
          stackTrace: s,
        );
        if (context.mounted) {
          saveFailed.value = true;
        }
      } finally {
        if (context.mounted) {
          saving.value = false;
        }
      }
    }

    return AlertDialog(
      title: Text(l10n.user_setProfilePasswordTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.user_setProfilePasswordExplanation),
            const SizedBox(height: 16),
            ObscurableTextField(
              controller: password,
              enabled: !saving.value,
              autofocus: true,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.user_newProfilePasswordFieldLabel,
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),
            const SizedBox(height: 12),
            ObscurableTextField(
              controller: repeat,
              enabled: !saving.value,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => save(),
              decoration: InputDecoration(
                labelText: l10n.user_repeatProfilePasswordFieldLabel,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                errorText: mismatch
                    ? l10n.user_profilePasswordsDoNotMatch
                    : saveFailed.value
                    ? l10n.user_profilePasswordSaveFailed
                    : null,
                errorMaxLines: 3,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving.value ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.common_cancel),
        ),
        TextButton(
          onPressed: canSave ? save : null,
          child: saving.value
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.common_save),
        ),
      ],
    );
  }
}
