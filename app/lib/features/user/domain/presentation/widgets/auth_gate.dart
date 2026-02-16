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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/user/domain/providers/profile_auth.dart';
import 'package:weblibre/presentation/hooks/on_initialization.dart';

class LockScreen extends HookConsumerWidget {
  const LockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticating = useState(false);
    final didAutoAuthenticate = useRef(false);

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

    return Scaffold(
      body: Center(
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
              onPressed: isAuthenticating.value ? null : authenticate,
            ),
          ],
        ),
      ),
    );
  }
}
