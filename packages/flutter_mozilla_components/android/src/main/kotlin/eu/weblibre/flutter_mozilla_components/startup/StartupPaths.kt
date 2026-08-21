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
package eu.weblibre.flutter_mozilla_components.startup

import android.content.Context
import eu.weblibre.flutter_mozilla_components.PwaConstants
import java.io.File

/**
 * Global, profile-independent locations, mirroring Dart's `StartupPaths`.
 *
 * Everything here is readable before a profile is committed, and none of it lives
 * inside the `profile-` namespace — prefix-based profile enumeration must never be
 * able to mistake a maintenance artifact for a profile.
 */
class StartupPaths(val filesDir: File) {

    constructor(context: Context) : this(context.filesDir)

    val profilesDir: File
        get() = File(filesDir, PwaConstants.PROFILES_DIR_NAME)

    val startupConfigFile: File
        get() = File(profilesDir, STARTUP_CONFIG_FILE_NAME)

    val currentProfileFile: File
        get() = File(profilesDir, CURRENT_PROFILE_FILE_NAME)

    val maintenanceDir: File
        get() = File(filesDir, MAINTENANCE_DIR_NAME)

    val maintenanceIncomingDir: File
        get() = File(maintenanceDir, MAINTENANCE_INCOMING_DIR_NAME)

    val maintenanceOutgoingDir: File
        get() = File(maintenanceDir, MAINTENANCE_OUTGOING_DIR_NAME)

    val maintenanceRestoreDir: File
        get() = File(maintenanceDir, MAINTENANCE_RESTORE_DIR_NAME)

    val maintenanceJournalsDir: File
        get() = File(maintenanceDir, MAINTENANCE_JOURNALS_DIR_NAME)

    fun restoreWorkspaceDir(taskId: String): File = File(maintenanceRestoreDir, taskId)

    fun restoreStagingDir(taskId: String): File = File(restoreWorkspaceDir(taskId), "staging")

    fun restoreOldDir(taskId: String): File = File(restoreWorkspaceDir(taskId), "old")

    fun journalFile(taskId: String): File = File(maintenanceJournalsDir, "$taskId.json")

    val restartDir: File
        get() = File(filesDir, RESTART_DIR_NAME)

    val restartRequestFile: File
        get() = File(restartDir, RESTART_REQUEST_FILE_NAME)

    /**
     * Proof that a restart-into-profile request came from this app.
     *
     * Beside the restart request because it belongs to the same protocol, but a
     * separate file: it is written by whichever activity raised the mismatch
     * dialog, minutes before any restart is armed, and consumed by Dart.
     */
    val restartAuthorizationFile: File
        get() = File(restartDir, RESTART_AUTHORIZATION_FILE_NAME)

    /**
     * The launch to re-deliver after a restart, if any.
     *
     * Beside the restart request rather than inside it: only the native restart
     * path reads this, and it holds a serialized Intent that no other consumer
     * has any business parsing.
     */
    fun pendingLaunchFile(): File = File(restartDir, PENDING_LAUNCH_FILE_NAME)

    /**
     * The global UnifiedPush ownership map.
     *
     * Outside every profile on purpose: it answers "which profile owns this
     * connector token", and a process that has not committed to a profile — which
     * is exactly when a push broadcast arrives — cannot read anything that lives
     * inside one.
     */
    val pushOwnershipFile: File
        get() = File(File(filesDir, PUSH_DIR_NAME), PUSH_OWNERSHIP_FILE_NAME)

    val startupIntentsDir: File
        get() = File(filesDir, STARTUP_INTENTS_DIR_NAME)

    val startupIntentQueueFile: File
        get() = File(startupIntentsDir, STARTUP_INTENT_QUEUE_FILE_NAME)

    val startupIntentPayloadsDir: File
        get() = File(startupIntentsDir, STARTUP_INTENT_PAYLOADS_DIR_NAME)

    fun startupIntentPayloadDir(entryId: String): File =
        File(startupIntentPayloadsDir, entryId)

    /** Profile directory for a canonical UUID string, without validating existence. */
    fun profileDir(profileId: String): File =
        File(profilesDir, "${PwaConstants.PROFILE_DIR_PREFIX}$profileId")

    /** Path of a profile directory relative to [filesDir], as `ProfileContext` expects. */
    fun relativeProfilePath(profileId: String): String =
        Companion.relativeProfilePath(profileId)

    companion object {
        /**
         * Path of a profile directory relative to the app's `files` root.
         *
         * On the companion because it derives from the id alone: callers that
         * hold a profile id but no [StartupPaths] — the maintenance participants
         * reaching into external storage, in particular — need the same spelling,
         * and a second copy of it is a second thing to keep in step.
         */
        fun relativeProfilePath(profileId: String): String =
            "${PwaConstants.PROFILES_DIR_NAME}/${PwaConstants.PROFILE_DIR_PREFIX}$profileId"

        const val STARTUP_CONFIG_FILE_NAME = "startup_config.json"
        const val CURRENT_PROFILE_FILE_NAME = "current_profile"

        const val MAINTENANCE_DIR_NAME = "weblibre_maintenance"
        const val MAINTENANCE_INCOMING_DIR_NAME = "incoming"
        const val MAINTENANCE_OUTGOING_DIR_NAME = "outgoing"
        const val MAINTENANCE_RESTORE_DIR_NAME = "restore"
        const val MAINTENANCE_JOURNALS_DIR_NAME = "journals"

        const val RESTART_DIR_NAME = "weblibre_restart"
        const val RESTART_REQUEST_FILE_NAME = "request.json"
        const val RESTART_AUTHORIZATION_FILE_NAME = "authorization.json"
        const val PENDING_LAUNCH_FILE_NAME = "pending_launch.json"

        const val PUSH_DIR_NAME = "weblibre_push"
        const val PUSH_OWNERSHIP_FILE_NAME = "ownership.json"

        const val STARTUP_INTENTS_DIR_NAME = "weblibre_startup_intents"
        const val STARTUP_INTENT_QUEUE_FILE_NAME = "queue.json"
        const val STARTUP_INTENT_PAYLOADS_DIR_NAME = "payloads"

        const val PROFILE_METADATA_FILE_NAME = "metadata.json"
    }
}
