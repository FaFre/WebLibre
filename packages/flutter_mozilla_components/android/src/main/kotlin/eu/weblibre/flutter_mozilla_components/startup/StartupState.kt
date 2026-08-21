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

/** Who owns an unresolved profile decision or a maintenance operation. */
enum class StartupOwnerType(val id: String) {
    UI("ui"),
    HEADLESS("headless");

    companion object {
        fun fromId(id: String?): StartupOwnerType =
            entries.firstOrNull { it.id == id } ?: HEADLESS
    }
}

data class StartupOwner(val type: StartupOwnerType, val engineId: String)

/**
 * The profile state of the *default app process*.
 *
 * There is deliberately no `Committed(A) -> Committed(B)` transition. GeckoView
 * permits one runtime per process and `GeckoRuntime.shutdown()` does not clear
 * GeckoView's static runtime, so the only legal way to change profile is process
 * death. Every other design here follows from that one constraint.
 */
sealed interface StartupState {

    /** Before `Application.attachBaseContext` installed the arbiter. */
    data object Uninitialized : StartupState

    /**
     * A candidate is known (or not), but nothing is committed.
     *
     * [candidateIsRestartTarget] records where the candidate came from. Two things
     * set it, and both mean "this launch is a continuation, not a fresh choice":
     * a restart request naming a profile the user picked explicitly (the switch
     * screen, or the profile-mismatch dialog), and finishing maintenance on the
     * profile this process was already serving — a backup, restore or deletion
     * restarts the process, but the user asked for the operation, not for a
     * different profile. Without it the candidate is indistinguishable from the
     * ordinary "whatever was running last" one, and prompting is correct for that.
     */
    data class Unresolved(
        val candidateProfileId: String?,
        val candidateIsRestartTarget: Boolean = false,
    ) : StartupState

    /**
     * An owner holds an exclusive selection lease with an idle deadline.
     *
     * [candidateIsRestartTarget] is carried through from [Unresolved] because an
     * owner that asks twice — the Activity recreation path — has to be given the
     * same answer about prompting. Losing it here would let a rotation during
     * startup resurrect a picker the switch had already answered.
     */
    data class Selecting(
        val owner: StartupOwner,
        val leaseId: String,
        val candidateProfileId: String?,
        val deadlineMillis: Long,
        val candidateIsRestartTarget: Boolean = false,
    ) : StartupState

    /** A commitment is in flight; briefly visible while `current_profile` is written. */
    data class Committing(val profileId: String) : StartupState

    /** Immutable for the rest of this process's life. */
    data class Committed(val profileId: String, val relativePath: String) : StartupState

    /** Maintenance evidence exists; every profile consumer is refused. */
    data class MaintenanceReserved(
        val taskId: String?,
        val recoveryRequired: Boolean,
    ) : StartupState

    /** A maintenance lease is live and heartbeating. */
    data class Maintenance(
        val owner: StartupOwner,
        val leaseId: String,
        val taskId: String?,
        val recoveryRequired: Boolean,
        val heartbeatDeadlineMillis: Long,
        /**
         * The owner has said it is not running, so its silence proves nothing.
         *
         * Set while the maintenance UI is not resumed. Android freezes cached
         * processes, and a frozen isolate fires no timers — the deadline would then
         * measure how long the *platform* declined to run the owner, and expire a
         * lease over a user who stepped out to a password manager. Any renewal
         * clears it, because a heartbeat or a boundary assertion is the owner
         * proving the opposite.
         */
        val heartbeatHeld: Boolean = false,
    ) : StartupState

    /**
     * Restart requested but not yet durable. Profile access is refused
     * provisionally; if arming the alarm fails we return to [returnState] without
     * having torn anything down.
     */
    data class RestartPreparing(
        val targetProfileId: String?,
        val reason: String,
        val returnState: StartupState,
    ) : StartupState

    /** Request and alarm are durable. From here, failure means process exit. */
    data class Restarting(val targetProfileId: String?, val reason: String) : StartupState
}

/** Committed profile id, or `null` while the process is still undecided. */
val StartupState.committedProfileId: String?
    get() = (this as? StartupState.Committed)?.profileId

/**
 * Whether a profile consumer may create profile-bound state right now.
 *
 * Note that `Committing` is *not* permissive: the write to `current_profile` has
 * not finished, so a consumer that raced in here could observe a profile the
 * process may still fail to commit.
 */
val StartupState.allowsProfileAccess: Boolean
    get() = this is StartupState.Committed

/** Whether the process is on its way out and must refuse all new profile work. */
val StartupState.isTerminating: Boolean
    get() = this is StartupState.RestartPreparing || this is StartupState.Restarting

/** Whether maintenance owns the process. */
val StartupState.isMaintenance: Boolean
    get() = this is StartupState.MaintenanceReserved || this is StartupState.Maintenance
