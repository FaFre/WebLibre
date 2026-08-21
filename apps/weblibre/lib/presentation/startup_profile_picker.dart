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
 */
import 'package:flutter/material.dart';
import 'package:uuid/uuid_value.dart';
import 'package:weblibre/core/copy/profile_copy.dart';
import 'package:weblibre/core/startup/profile_discovery.dart';
import 'package:weblibre/features/user/domain/presentation/utils/profile_labels.dart';

/// Asks which profile to start, while the selection lease is held.
///
/// Selection only, by design: creating, renaming, and deleting profiles all need
/// a running app, and none of that exists yet at this point in startup. Icons and
/// labels are generic because the profile model has no avatar field and the
/// per-profile theme lives in settings this screen may not read.
///
/// There is no "cancel". The lease is out and the process has to end up on some
/// profile; an escape hatch here could only lead to a started browser on an
/// unchosen profile, which is the thing being avoided.
class StartupProfilePicker extends StatelessWidget {
  const StartupProfilePicker({
    required this.profiles,
    required this.onSelected,
    this.candidateProfileId,
    this.busy = false,
    super.key,
  });

  final List<DiscoveredProfile> profiles;
  final ValueChanged<UuidValue> onSelected;

  /// Highlighted as the one that would have started without asking.
  final String? candidateProfileId;

  /// A choice is being committed; further taps are ignored.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // The same disambiguation every in-app picker uses. It matters more here
    // than anywhere: two users called "a" are two identical rows at the one
    // point in the app where you cannot open either to check which is which.
    final labels = profileLabels(profiles.map((profile) => profile.metadata));

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
              child: Text(
                'Choose a profile',
                style: theme.textTheme.headlineSmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Each profile keeps its own $profilePickerContents.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            // Always occupies its slot, so committing a choice does not shift
            // the list up under the finger that just tapped it.
            SizedBox(
              height: 4,
              child: busy ? const LinearProgressIndicator() : null,
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  final isCandidate = profile.uuid.uuid == candidateProfileId;
                  final isLocked =
                      profile.metadata.authSettings.authenticationRequired;

                  return ListTile(
                    enabled: !busy,
                    leading: CircleAvatar(
                      backgroundColor: isCandidate
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      foregroundColor: isCandidate
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                      // Generic by design: the profile model has no avatar, and
                      // the per-profile theme lives in settings this screen may
                      // not read. An initial is at least the user's own word for
                      // the profile.
                      child: Text(_initial(profile.name)),
                    ),
                    title: Text(labelOfProfile(profile.metadata, labels)),
                    subtitle: switch ((isCandidate, isLocked)) {
                      (true, true) => const Text('Opens by default · Locked'),
                      (true, false) => const Text('Opens by default'),
                      (false, true) => const Text('Locked'),
                      (false, false) => null,
                    },
                    // Said before the choice rather than discovered after it:
                    // picking a locked profile lands on the unlock screen, and a
                    // user who cannot pass it has to close and reopen the app to
                    // choose again.
                    trailing: Icon(
                      isLocked ? Icons.lock_outline : Icons.chevron_right,
                    ),
                    onTap: busy ? null : () => onSelected(profile.uuid),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// First character of the name, or a placeholder for one that has none the
  /// renderer can show (an emoji-only or whitespace name).
  static String _initial(String name) {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();
  }
}
