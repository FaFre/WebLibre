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

/// One category of profile-owned state that lives outside the profile directory.
///
/// The single registry. Preferences, external files, shortcuts, scheduled jobs,
/// push registrations and credentials all belong to a profile without being
/// inside it, so a directory-scoped operation cannot see them — each becomes a
/// participant, and each has to be described to the user in three different
/// voices: what a backup carried, what it left behind, and what a delete could
/// not enumerate.
///
/// Those descriptions used to be four hand-written prose arrays plus a policy
/// map keyed by string literals, none derived from the others. Adding a
/// participant meant five edits, and only the Kotlin one failed to compile.
/// Here it is one row, and the analyzer asks for every field.
///
/// [ParticipantCategory.name] is the participant id itself — the same string
/// native reports from `listMaintenanceParticipants` and names its staging
/// directory with — so there is no parallel id field to keep in step with it.
library;

/// What a restore into a *new* profile does with the staged state of a category.
enum ClonePolicy {
  /// Drop the staged state; the clone starts without it.
  discard,

  /// Reserved: re-key the staged records onto the clone's own profile id and
  /// install them. Nothing selects this yet.
  // ignore: unused_field
  rekey,
}

enum ParticipantCategory {
  /// Account session, sync key, proxy credentials. The Dart-side participant.
  secureStorage(
    clonePolicy: ClonePolicy.discard,
    // The reason the archive's included list is recorded at all: an archive that
    // restores a signed-in profile necessarily contains the credentials that
    // make it signed in, so the file is only as protective as its password.
    inArchive:
        'Secure-storage records: account session, sync key, proxy credentials',
    unrecordedByDelete: 'Credentials in shared secure storage',
  ),

  /// FxA and sync preference files, plus the profile's keys in the shared
  /// default preference file.
  sharedPreferences(
    clonePolicy: ClonePolicy.discard,
    inArchive:
        'Profile-scoped native preferences, including account and sync stores',
    unrecordedByDelete: 'Native preferences scoped to the profile',
  ),

  /// Downloads and media redirected outside the profile directory.
  externalStorage(
    clonePolicy: ClonePolicy.discard,
    inArchive: 'Profile-scoped external files',
    // The files travel; the cache does not, for the same reason the internal
    // cache is excluded.
    absentFromArchive: 'Profile-scoped external cache',
  ),

  /// Home-screen PWA launch tokens.
  pwaShortcuts(
    clonePolicy: ClonePolicy.discard,
    inArchive: 'PWA and shortcut launch tokens',
    // Android will not re-pin a shortcut without the user, so the launch tokens
    // travel but the icons do not.
    absentFromArchive: 'Pinned home-screen shortcuts themselves',
    unrecordedByDelete: 'Pinned shortcuts and their launch tokens',
  ),

  /// Scheduled WorkManager jobs; nothing is archived for these anyway.
  scheduledJobs(
    clonePolicy: ClonePolicy.discard,
    // Re-created from the restored queues rather than archived.
    absentFromArchive: 'Scheduled background jobs',
    unrecordedByDelete: 'Scheduled jobs and notifications',
  ),

  /// Entries in the global push ownership map.
  pushOwnership(
    clonePolicy: ClonePolicy.discard,
    // Which tokens a distributor still honours cannot be known from here, so
    // they are re-learned on the next message.
    absentFromArchive: 'Push ownership entries',
  );

  const ParticipantCategory({
    required this.clonePolicy,
    this.inArchive,
    this.absentFromArchive,
    this.unrecordedByDelete,
  });

  /// What a clone does with this category's staged state.
  final ClonePolicy clonePolicy;

  /// How the manifest describes what of this category the archive carries, or
  /// null when it carries none of it.
  final String? inArchive;

  /// How the manifest describes what of this category the archive leaves
  /// behind, or null when it carries all of it.
  final String? absentFromArchive;

  /// How a delete's ownership snapshot describes this category, or null when
  /// the snapshot enumerates it entry by entry.
  final String? unrecordedByDelete;

  /// The category a participant id names, or null if this build has none.
  static ParticipantCategory? tryById(String id) {
    for (final category in values) {
      if (category.name == id) return category;
    }
    return null;
  }

  /// Every category's [inArchive] wording, in declaration order.
  static List<String> get archiveContents =>
      values.map((c) => c.inArchive).nonNulls.toList(growable: false);

  /// Every category's [absentFromArchive] wording, in declaration order.
  static List<String> get archiveOmissions =>
      values.map((c) => c.absentFromArchive).nonNulls.toList(growable: false);

  /// Every category's [unrecordedByDelete] wording, in declaration order.
  static List<String> get deleteOmissions =>
      values.map((c) => c.unrecordedByDelete).nonNulls.toList(growable: false);
}
