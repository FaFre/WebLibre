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

import org.json.JSONObject

const val STARTUP_CONFIG_VERSION = 1

enum class ProfilePromptMode(val id: String) {
    OFF("off"),
    BROWSER_ONLY("browserOnly");

    companion object {
        /** Unknown values fall back to [OFF] rather than failing the whole config. */
        fun fromId(id: String?): ProfilePromptMode =
            ProfilePromptMode.entries.firstOrNull { it.id == id } ?: OFF
    }
}

enum class MaintenanceAction(val id: String) {
    BACKUP("backup"),
    RESTORE_OVER("restoreOver"),
    RESTORE_CLONE("restoreClone"),
    DELETE("delete");

    companion object {
        fun tryFromId(id: String?): MaintenanceAction? = MaintenanceAction.entries.firstOrNull { it.id == id }
    }
}

enum class MaintenanceTaskState(val id: String) {
    QUEUED("queued"),
    AWAITING_INPUT("awaitingInput"),
    RUNNING("running"),
    COMMITTING("committing"),
    COMPLETED("completed"),
    RECOVERY_REQUIRED("recoveryRequired"),
    FAILED("failed");

    /** A task in one of these states still needs the reservation on the next start. */
    val requiresMaintenance: Boolean
        get() = this != COMPLETED && this != FAILED

    /** The previous process died mid-operation, or already asked for recovery. */
    val requiresRecovery: Boolean
        get() = this == RUNNING || this == COMMITTING || this == RECOVERY_REQUIRED

    companion object {
        fun tryFromId(id: String?): MaintenanceTaskState? = MaintenanceTaskState.entries.firstOrNull { it.id == id }
    }
}

/**
 * The subset of a queued maintenance task Kotlin needs in order to reserve
 * maintenance before any profile consumer runs. Kotlin never writes this file;
 * mutation is serialized through the single Dart repository.
 */
data class MaintenanceTaskSummary(
    val id: String,
    val actionId: String,
    val stateId: String,
    val profileId: String,
    val profileName: String,
) {
    val action: MaintenanceAction? get() = MaintenanceAction.tryFromId(actionId)
    val state: MaintenanceTaskState? get() = MaintenanceTaskState.tryFromId(stateId)

    /** An unknown action or state is quarantined individually, not fatally. */
    val isQuarantined: Boolean get() = action == null || state == null

    val effectiveState: MaintenanceTaskState
        get() = if (isQuarantined) MaintenanceTaskState.FAILED else state!!
}

/**
 * Tolerant reader for `startup_config.json`, matching Dart's `StartupConfig`.
 *
 * Tolerance is not politeness here: this file is parsed before any profile is
 * committed, so throwing would leave the process with no way to decide anything,
 * including whether maintenance is pending.
 */
data class StartupConfig(
    val version: Int = STARTUP_CONFIG_VERSION,
    val profilePrompt: ProfilePromptMode = ProfilePromptMode.OFF,
    val honorShortcutProfile: Boolean = true,
    val pendingTasks: List<MaintenanceTaskSummary> = emptyList(),
) {
    val activeTasks: List<MaintenanceTaskSummary>
        get() = pendingTasks.filter { it.effectiveState.requiresMaintenance }

    val requiresMaintenance: Boolean get() = activeTasks.isNotEmpty()

    val requiresRecovery: Boolean
        get() = pendingTasks.any { it.effectiveState.requiresRecovery }

    companion object {
        val DEFAULTS = StartupConfig()

        fun fromJson(json: JSONObject): StartupConfig {
            val tasks = mutableListOf<MaintenanceTaskSummary>()
            val seen = mutableSetOf<String>()

            val rawTasks = json.optJSONArray("pendingTasks")
            if (rawTasks != null) {
                for (index in 0 until rawTasks.length()) {
                    val entry = rawTasks.optJSONObject(index) ?: continue

                    val id = entry.stringOrEmpty("id")
                    if (id.isEmpty()) continue

                    val profileId = entry.stringOrEmpty("profileId")
                    if (profileId.isEmpty()) continue

                    if (!seen.add(id)) continue

                    tasks += MaintenanceTaskSummary(
                        id = id,
                        actionId = entry.stringOrEmpty("action"),
                        stateId = entry.stringOrEmpty("state"),
                        profileId = profileId,
                        profileName = entry.stringOrEmpty("profileName"),
                    )
                }
            }

            return StartupConfig(
                version = json.intOr("version", STARTUP_CONFIG_VERSION),
                profilePrompt = ProfilePromptMode.fromId(
                    json.stringOrNull("profilePrompt"),
                ),
                honorShortcutProfile = json.booleanOr("honorShortcutProfile", true),
                pendingTasks = tasks,
            )
        }

        /**
         * Reads the config from disk. A corrupt file yields [DEFAULTS]; it is *not*
         * quarantined here, because Kotlin is only a reader and moving the file aside
         * from a background component would race the Dart writer.
         */
        fun read(paths: StartupPaths): StartupConfig =
            when (val result = AtomicJsonFile(paths.startupConfigFile).read()) {
                is AtomicJsonFile.Read.Absent -> DEFAULTS
                is AtomicJsonFile.Read.Corrupt -> DEFAULTS
                is AtomicJsonFile.Read.Present -> fromJson(result.json)
            }
    }
}
