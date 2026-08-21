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
import 'package:weblibre/core/copy/profile_copy.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/startup/models/startup_config.dart';
import 'package:weblibre/core/startup/startup_config_store.dart';
import 'package:weblibre/features/user/domain/providers/profile_auth.dart';
import 'package:weblibre/presentation/hooks/on_initialization.dart';
import 'package:weblibre/utils/exit_app.dart';
import 'package:weblibre/utils/ui_helper.dart';

class LockScreen extends HookConsumerWidget {
  const LockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticating = useState(false);
    final isSwitching = useState(false);
    final didAutoAuthenticate = useRef(false);

    /// Whether a restart would actually land on the picker.
    ///
    /// Read straight from the global startup config rather than through a
    /// provider: it is deliberately not profile-bound — the startup path reads
    /// it before any profile is open — and this screen sits in front of a
    /// profile whose settings the user has not unlocked.
    final pickerEnabled = useState(false);
    useEffect(() {
      unawaited(() async {
        final config = await StartupConfigStore(filesystem.startupPaths).read();
        if (context.mounted) {
          pickerEnabled.value =
              config.profilePrompt == ProfilePromptMode.browserOnly;
        }
      }());
      return null;
    }, const []);

    Future<void> authenticate() async {
      if (isAuthenticating.value) return;

      isAuthenticating.value = true;

      try {
        await ref.read(profileAuthStateProvider.notifier).authenticate();
      } finally {
        if (context.mounted) {
          isAuthenticating.value = false;
        }
      }
    }

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
    /// implementation: the arbiter re-arbitrates from scratch, and because
    /// nothing names a profile, the picker is not suppressed.
    ///
    /// Only offered when the picker is actually enabled. Without it the restart
    /// would resolve the same candidate and land the user back on this screen,
    /// which is worse than not offering a way out at all.
    Future<void> chooseAnother() async {
      if (isSwitching.value) return;
      isSwitching.value = true;

      try {
        // A refusal is reported, not thrown: native declines when it could not
        // start the relaunch trampoline, and exiting on that answer would close
        // the app for good instead of returning the user to the picker.
        final armed = await GeckoProfileService().armProfileRestart(
          reason: 'the user could not unlock this profile',
        );
        if (!armed) {
          isSwitching.value = false;
          if (context.mounted) {
            showErrorMessage(context, restartCouldNotBeScheduled);
          }
          return;
        }
      } catch (error) {
        isSwitching.value = false;
        if (context.mounted) {
          showErrorMessage(context, 'Could not restart: $error');
        }
        return;
      }

      await exitApp(ref.container, restart: true);
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(MdiIcons.lock, size: 64),
              const SizedBox(height: 16),
              const Text('Profile is locked'),
              const SizedBox(height: 16),
              FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size(160, 40)),
                icon: const Icon(MdiIcons.fingerprint),
                label: Text(isAuthenticating.value ? 'Unlocking...' : 'Unlock'),
                onPressed: isAuthenticating.value || isSwitching.value
                    ? null
                    : authenticate,
              ),
              // Without this the only way out of a lock the user cannot pass is
              // to close the app and reopen it — which they have to work out for
              // themselves, from a screen that does not say so. The picker warns
              // that a locked profile leads here; this is the way back.
              if (pickerEnabled.value) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  icon: const Icon(MdiIcons.accountSwitch),
                  label: Text(
                    isSwitching.value
                        ? 'Restarting…'
                        : 'Choose another profile',
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
    );
  }
}
