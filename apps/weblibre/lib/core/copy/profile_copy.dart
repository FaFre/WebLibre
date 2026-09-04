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

/// Shared wording for profile maintenance screens.
library;

/// What profile selection separates.
const profilePickerContents = 'tabs, history and settings';

/// Profile data users expect to lose when deleting or replacing a profile.
const profileDataDescription =
    'tabs, history, bookmarks, settings and saved site logins';

/// WebLibre account state restored only when replacing a profile.
///
/// Kept separate from [profileDataDescription] because creating a new profile
/// from a backup leaves these behind, while replacing a profile restores them.
const profileSecretDataDescription =
    'WebLibre account sign-in, sync setup and proxy details';

/// Said the same way everywhere, so it reads as a property of the operation
/// rather than as one screen's turn of phrase.
const cannotBeUndone = 'This cannot be undone.';

/// The opposite, and just as load-bearing: the operation stopped before touching
/// anything.
///
/// It is what makes retrying safe to offer, so it belongs in the same breath as
/// the failure rather than being left for the user to assume.
const nothingChanged = 'Nothing has been changed.';

/// Why a destructive action closes the browser first.
const restartsToWork = 'WebLibre restarts to do this.';

/// The password half of [restartsThenAsksPassword], on its own.
///
/// For screens that say the restart part in their own tile, so the two are not
/// worded twice and cannot drift apart.
const asksPasswordAfterRestart =
    'It asks for the backup file password after restarting.';

/// For archive operations, the password is entered after the restart.
const restartsThenAsksPassword = '$restartsToWork $asksPasswordAfterRestart';

/// The only move a user has when startup will not continue.
const reopenToContinue = 'Close WebLibre and open it again.';

/// Replacing a profile installs the archive's WebLibre account state.
const signedInFromBackup =
    'The restored profile uses the WebLibre account from the backup.';

/// What a backup made before credentials were archived does to the target's own.
///
/// Deliberately stated up front rather than discovered afterwards. Backups taken
/// by earlier versions of WebLibre carry no credentials at all, and
/// `SecureStorageParticipant.apply` leaves the target profile's existing ones
/// alone rather than deleting an account the archive never held. That is the
/// right default — the alternative signs the user out of an account they may
/// still be using — but it means the restored profile can be signed in to
/// something the backup knows nothing about, and only the user can tell whether
/// that is what they wanted.
const olderBackupKeepsCredentials =
    'A backup made by an older version of WebLibre carries none of these, and '
    'the profile keeps the ones it has now.';

/// Shown when the restart a destructive operation needs cannot be scheduled.
///
/// Every call site unqueues its task before throwing this, so it is a clean
/// stop: nothing is pending and nothing was touched. It used to say "could not
/// arm a restart", which named the internal call rather than the situation.
const restartCouldNotBeScheduled =
    'WebLibre could not schedule the restart this needs. $nothingChanged';

/// Android does not let an app recreate pinned shortcuts.
const shortcutsNeedPinningAgain =
    'Pin home-screen shortcuts again after restore.';

/// What ending the process costs, whichever profile the operation names.
///
/// Backup, delete and replace all leave through `exitApp`, and it tears down the
/// profile this process is *serving* — not the profile the task happens to name.
/// Backing up an idle profile still ends the private session of the one in front
/// of you, and that is the half nobody pictures.
/// Worded to follow [restartsToWork] rather than to stand alone: every screen
/// that says this has already said WebLibre restarts, and repeating the subject
/// made the pair read as two unrelated warnings.
const restartClosesCurrentProfile =
    'It also closes the profile you are using now, which is not always the '
    'profile named here.';

/// The floor under the counted warnings below, so they say what survives too.
const restartKeepsOtherTabs = 'Your other tabs reopen afterwards.';

/// Private browsing does not survive the process holding it.
///
/// Not a policy that could be softened: private tabs live in a memory-only
/// session context, and `exitApp` closes them explicitly before the engine goes
/// down. Said only when there are some — a line that prints on every backup is
/// one people learn to tap past, and then it is not there when it matters.
String privateTabsClosedByRestart(int count) => count == 1
    ? '1 private tab closes and its browsing data is cleared.'
    : '$count private tabs close and their browsing data is cleared.';

/// A maintenance restart is an exit, so containers set to clear on exit clear.
String containersClearedByRestart(int count) => count == 1
    ? '1 container set to clear data on exit is cleared.'
    : '$count containers set to clear data on exit are cleared.';
