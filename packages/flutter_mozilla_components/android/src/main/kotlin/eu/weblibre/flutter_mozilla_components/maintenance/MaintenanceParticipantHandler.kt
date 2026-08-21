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
package eu.weblibre.flutter_mozilla_components.maintenance

import java.io.File

/**
 * The native half of one maintenance participant.
 *
 * Dart owns the ordering, the journal, and the rollback discipline; this is only
 * the part that touches Android state. Every method returns `false` rather than
 * throwing when it cannot do its step safely — the coordinator turns that into a
 * rollback, which is a decision that belongs on the Dart side where the whole
 * sequence is visible.
 *
 * `kind` is `backup`, `restore`, or `delete`. Participants branch on it because
 * the same category of state is captured, replaced, or removed depending on the
 * operation, and confusing the three is how a backup ends up archiving nothing.
 *
 * ## Which directory `workDir` is
 *
 * Not one directory across the protocol. Dart hands each step whichever of two
 * workspaces that step's data belongs in, so a participant may reuse a file name
 * for both roles without them ever colliding:
 *
 * - **Archive content** — `backup.prepare`, and `restore`'s `discover`, `apply`
 *   and `verify`. Lives inside the profile tree, so it is packed into the archive
 *   and travels with it. It moves when the tree is renamed into place.
 * - **Undo content** — `restore`'s `prepare` and `rollback`, `finalizeWork`, and
 *   every step of a `delete`. Lives outside every directory the operation renames
 *   or deletes, because a rollback needs it *after* the profile tree has been put
 *   back.
 *
 * The consequence worth remembering: a restore's `prepare` and its `apply` are
 * handed different directories on purpose. `prepare` captures the live state as
 * undo data; `apply` reads what the backup archived. Writing the first where the
 * second reads would make a restore quietly reinstall the state it was replacing.
 */
internal interface MaintenanceParticipantHandler {
    fun prepare(workDir: File, profileId: String, kind: String): Boolean

    fun apply(workDir: File, profileId: String, kind: String): Boolean

    fun verify(workDir: File, profileId: String, kind: String): Boolean

    fun finalizeWork(workDir: File): Boolean

    fun rollback(workDir: File, profileId: String): Boolean
}
