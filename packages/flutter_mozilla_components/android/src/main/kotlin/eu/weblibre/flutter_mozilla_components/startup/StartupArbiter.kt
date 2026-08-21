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

import java.security.SecureRandom
import mozilla.components.support.base.log.logger.Logger

/** What `beginStartup` tells a Dart owner to do next. */
enum class StartupDirectiveKind(val id: String) {
    /** A profile is already committed; adopt it and boot. */
    COMMITTED("committed"),

    /** The caller holds a selection lease and must commit or release it. */
    SELECT("select"),

    /** The caller holds a maintenance lease and must run recovery or queued work. */
    MAINTENANCE("maintenance"),

    /** Another owner holds the decision, or the process is terminating. */
    UNAVAILABLE("unavailable"),
}

data class StartupDirective(
    val kind: StartupDirectiveKind,
    val profileId: String? = null,
    val candidateProfileId: String? = null,
    val leaseId: String? = null,
    val showPicker: Boolean = false,
    val maintenanceTaskId: String? = null,
    val recoveryRequired: Boolean = false,
    val reason: String? = null,
)

/** Outcome of a native-only entry point trying to bind the process. */
sealed interface ExternalCommitResult {
    data class CommittedRequested(val profileId: String) : ExternalCommitResult
    data class AlreadyCommittedSame(val profileId: String) : ExternalCommitResult
    data class AlreadyCommittedDifferent(val profileId: String) : ExternalCommitResult

    /**
     * A trusted launch answered an open selection.
     *
     * The lease named here is dead: nothing pushes that fact to the owner, because
     * this channel is host-only by design — it has to work before a Flutter engine
     * exists. So the picker stays on screen until the user answers it, and their
     * commit is refused; `commitChosenProfile` recovers by re-arbitrating, which
     * returns the profile committed here.
     */
    data class AnsweredSelection(val profileId: String, val leaseId: String) :
        ExternalCommitResult

    /** Maintenance owns the process; the caller must retry or fail safely. */
    data object MaintenanceRefused : ExternalCommitResult

    /** Another owner is selecting; the caller must retry, never invent a profile. */
    data object SelectionInProgress : ExternalCommitResult

    /** The process is going away; the caller must not create profile state. */
    data object Terminating : ExternalCommitResult

    /** First run, or the requested profile does not validate. */
    data object NoValidProfile : ExternalCommitResult
}

/** Writes the committed profile so a *future* process resolves the same one. */
fun interface CommittedProfileWriter {
    fun persist(profileId: String)
}

/** Injectable clock; tests drive deadlines instead of sleeping. */
fun interface StartupClock {
    fun nowMillis(): Long
}

/**
 * The process-global profile arbiter.
 *
 * Everything that can bind a profile — Dart startup, headless workers, exported
 * services, trusted PWA launches, maintenance — passes through here, so the
 * process has exactly one answer to "which profile am I?".
 *
 * ## Why this is native and not a Dart singleton
 *
 * Dart `main()` is not the definition of a process cold start. `MainActivity`
 * destroys its cached engine after a non-finishing destroy and can create a new
 * one in the same process, and workers/receivers/services can run with no Flutter
 * engine at all. Arbitration therefore has to live in process-global native state.
 *
 * ## Lock order
 *
 * `startup arbitration -> ActiveProfile profile lock -> UnifiedPush exclusivity`.
 *
 * Callbacks registered through [onCommitted] run *outside* this monitor, and each
 * is isolated so one failure cannot block the others.
 *
 * ## Watchdogs
 *
 * Deadlines are evaluated lazily on entry to every state-observing method rather
 * than by a background timer. A timer would add a second thread to the one piece
 * of state that must never be raced, and it would make the transition tests
 * depend on wall-clock timing.
 */
object StartupArbiter {

    /** Selection idles out after this long without a heartbeat. */
    const val SELECTION_TIMEOUT_MS = 5 * 60 * 1000L

    /** A maintenance lease must heartbeat at least this often. */
    const val MAINTENANCE_HEARTBEAT_TIMEOUT_MS = 60 * 1000L

    /**
     * [StartupDirective.reason] when maintenance can only continue in a new
     * process. The restart driver keys on this rather than on prose.
     */
    const val RESTART_REQUIRED_REASON = "maintenanceRestartRequired"

    private val logger = Logger("StartupArbiter")
    private val random = SecureRandom()

    private var clock: StartupClock = StartupClock { System.currentTimeMillis() }
    private var paths: StartupPaths? = null
    private var writer: CommittedProfileWriter? = null

    private var state: StartupState = StartupState.Uninitialized

    /**
     * Identifies this process instance. A restart request written by *this*
     * process must never be honoured by it; only a genuinely new process may.
     */
    var processInstanceId: String = newToken()
        private set

    /**
     * True once maintenance decided the process cannot continue and must restart
     * into recovery. Read by the restart driver.
     */
    var restartRequiredForRecovery: Boolean = false
        private set

    private val committedCallbacks = mutableListOf<(String, String) -> Unit>()

    // --- lifecycle -------------------------------------------------------------

    /**
     * Installs the arbiter. Idempotent, and safe to call from
     * `Application.attachBaseContext()`.
     *
     * It *must* run there rather than in `onCreate()`: the merged manifest contains
     * `androidx.startup.InitializationProvider`, and ContentProviders are created
     * after `attachBaseContext()` but before `onCreate()`. An initializer that
     * touched a profile-sensitive preference name would otherwise run before the
     * arbiter exists and hit the binding error in `MyApplication`.
     */
    @Synchronized
    fun initialize(
        paths: StartupPaths,
        writer: CommittedProfileWriter,
        clock: StartupClock = StartupClock { System.currentTimeMillis() },
    ) {
        if (state != StartupState.Uninitialized) return

        this.paths = paths
        this.writer = writer
        this.clock = clock

        val reservation = MaintenanceReservation.resolve(paths)
        state = if (reservation.required) {
            logger.warn("Reserving maintenance: ${reservation.reason}")
            StartupState.MaintenanceReserved(
                taskId = reservation.taskId,
                recoveryRequired = reservation.recoveryRequired,
            )
        } else {
            // Enter Unresolved even when prompting is off. Application.onCreate
            // cannot know whether the dispatched component will be a trusted
            // non-current PWA, a launcher Activity, or a headless worker, so it
            // must not commit.
            StartupState.Unresolved(resolveCandidate())
        }

        // A restart target overrides the candidate, and has to be applied here —
        // before anything can ask what the candidate is. `current_profile` still
        // says what the *old* process was serving, because the old process
        // deliberately never rewrote it.
        RestartCoordinator.consumePendingRestart(paths)?.let { request ->
            logger.info(
                "Applied restart request ${request.requestId} " +
                    "(target=${request.targetProfileId}, reason=${request.reason})",
            )
        }
    }

    /** Test seam. Never call from production code. */
    @Synchronized
    internal fun resetForTest() {
        state = StartupState.Uninitialized
        paths = null
        writer = null
        clock = StartupClock { System.currentTimeMillis() }
        committedCallbacks.clear()
        pendingCallbacks = emptyList()
        pendingProfileId = null
        pendingRelativePath = null
        restartRequiredForRecovery = false
        processInstanceId = newToken()
    }

    // --- observation -----------------------------------------------------------

    fun currentState(): StartupState = arbitrate {
        tick()
        state
    }

    fun committedProfileId(): String? = arbitrate {
        tick()
        state.committedProfileId
    }

    /** Relative profile path of the committed profile, for `ProfileContext`. */
    fun boundProfileFolder(): String? = arbitrate {
        tick()
        (state as? StartupState.Committed)?.relativePath
    }

    /**
     * The folder this process serves, or would serve if asked to commit now.
     *
     * Answers the profile question **without** settling it, which is the whole
     * point: a background worker holding a job for some profile has to know
     * whether the job is even for this process before it does anything
     * irreversible. Committing to find that out means a stale job for a profile
     * nobody asked for can silently answer the picker the user was going to be
     * shown.
     *
     * Null means the answer is not knowable yet rather than "no": maintenance,
     * a selection in flight and a restart all withhold it, and so does having no
     * valid profile at all. A caller that gets null retries; it must not fall
     * back to committing.
     *
     * A candidate is a *prediction*, not a promise — a picker or a trusted
     * launch can still land somewhere else — so it may only be used to rule work
     * out, never to rule it in.
     */
    fun peekProfileFolder(): String? = arbitrate {
        tick()
        val paths = this.paths ?: return@arbitrate null

        when (val current = state) {
            is StartupState.Committed -> current.relativePath
            is StartupState.Unresolved ->
                resolveCandidate()?.let { paths.relativeProfilePath(it) }
            else -> null
        }
    }

    /**
     * Registers work that must not run before commitment, such as push recovery
     * and the sandbox capture bootstrap. Fires immediately when already committed.
     */
    fun onCommitted(callback: (profileId: String, relativePath: String) -> Unit) {
        val committed = synchronized(this) {
            val current = state
            if (current is StartupState.Committed) {
                current
            } else {
                committedCallbacks += callback
                null
            }
        }

        if (committed != null) {
            runCallback(callback, committed.profileId, committed.relativePath)
        }
    }

    // --- Dart-facing startup ---------------------------------------------------

    /**
     * Entry point for a Dart owner. Returns the directive that owner must act on.
     *
     * The caller may not fall back to reading `current_profile` itself if this
     * throws or is unavailable; it must schedule a restart instead. Continuing
     * unarbitrated is exactly the split-brain this exists to prevent.
     */
    fun beginStartup(
        owner: StartupOwner,
        promptMode: ProfilePromptMode,
    ): StartupDirective = arbitrate {
        tick()

        when (val current = state) {
            is StartupState.Uninitialized -> StartupDirective(
                StartupDirectiveKind.UNAVAILABLE,
                reason = "arbiter not initialized",
            )

            is StartupState.Committed -> StartupDirective(
                StartupDirectiveKind.COMMITTED,
                profileId = current.profileId,
            )

            is StartupState.Committing -> StartupDirective(
                StartupDirectiveKind.UNAVAILABLE,
                reason = "commit in flight",
            )

            is StartupState.Unresolved -> {
                val leaseId = newToken()
                state = StartupState.Selecting(
                    owner = owner,
                    leaseId = leaseId,
                    candidateProfileId = current.candidateProfileId,
                    deadlineMillis = clock.nowMillis() + SELECTION_TIMEOUT_MS,
                    candidateIsRestartTarget = current.candidateIsRestartTarget,
                )
                StartupDirective(
                    kind = StartupDirectiveKind.SELECT,
                    candidateProfileId = current.candidateProfileId,
                    leaseId = leaseId,
                    showPicker = shouldShowPicker(
                        owner,
                        promptMode,
                        current.candidateIsRestartTarget,
                    ),
                )
            }

            is StartupState.Selecting ->
                if (current.owner.engineId == owner.engineId) {
                    // A healthy Activity recreation reattaches the same engine; it
                    // must resume its own lease, not be told to prompt again.
                    StartupDirective(
                        kind = StartupDirectiveKind.SELECT,
                        candidateProfileId = current.candidateProfileId,
                        leaseId = current.leaseId,
                        showPicker = shouldShowPicker(
                            owner,
                            promptMode,
                            current.candidateIsRestartTarget,
                        ),
                    )
                } else {
                    StartupDirective(
                        StartupDirectiveKind.UNAVAILABLE,
                        reason = "selection owned by ${current.owner.engineId}",
                    )
                }

            is StartupState.MaintenanceReserved ->
                if (restartRequiredForRecovery) {
                    // A lease already expired mid-operation in this process. Handing
                    // out another one would let destructive work resume in exactly
                    // the process that just proved it can stall, and against state
                    // whose consistency is now unknown. The reservation is kept and
                    // recovery waits for a new process.
                    StartupDirective(
                        StartupDirectiveKind.UNAVAILABLE,
                        maintenanceTaskId = current.taskId,
                        recoveryRequired = true,
                        reason = RESTART_REQUIRED_REASON,
                    )
                } else {
                    val leaseId = newToken()
                    state = StartupState.Maintenance(
                        owner = owner,
                        leaseId = leaseId,
                        taskId = current.taskId,
                        recoveryRequired = current.recoveryRequired,
                        heartbeatDeadlineMillis =
                            clock.nowMillis() + MAINTENANCE_HEARTBEAT_TIMEOUT_MS,
                    )
                    StartupDirective(
                        kind = StartupDirectiveKind.MAINTENANCE,
                        leaseId = leaseId,
                        maintenanceTaskId = current.taskId,
                        recoveryRequired = current.recoveryRequired,
                    )
                }

            is StartupState.Maintenance ->
                if (current.owner.engineId == owner.engineId) {
                    StartupDirective(
                        kind = StartupDirectiveKind.MAINTENANCE,
                        leaseId = current.leaseId,
                        maintenanceTaskId = current.taskId,
                        recoveryRequired = current.recoveryRequired,
                    )
                } else {
                    StartupDirective(
                        StartupDirectiveKind.UNAVAILABLE,
                        reason = "maintenance owned by ${current.owner.engineId}",
                    )
                }

            is StartupState.RestartPreparing, is StartupState.Restarting ->
                StartupDirective(
                    StartupDirectiveKind.UNAVAILABLE,
                    reason = "process is restarting",
                )
        }
    }

    /**
     * Commits the selection held under [leaseId].
     *
     * A stale lease — from a Flutter engine or dialog that lost the race — cannot
     * commit, which is the whole reason lease ids are unguessable.
     */
    fun commitSelection(leaseId: String, profileId: String): Boolean = arbitrate {
        tick()

        val current = state as? StartupState.Selecting
        when {
            current == null -> {
                logger.warn("commitSelection with no live selection (state=$state)")
                false
            }
            current.leaseId != leaseId -> {
                logger.warn("Rejecting commitSelection from stale lease")
                false
            }
            else -> commitLocked(profileId, "selection")
        }
    }

    /** Renews the idle deadline. Driven by visible user interaction, not a timer. */
    fun heartbeatSelection(leaseId: String): Boolean = arbitrate {
        tick()

        val current = state as? StartupState.Selecting
        if (current == null || current.leaseId != leaseId) {
            false
        } else {
            state = current.copy(deadlineMillis = clock.nowMillis() + SELECTION_TIMEOUT_MS)
            true
        }
    }

    /** Gives the decision back without committing. */
    fun releaseSelection(leaseId: String, reason: String): Boolean = arbitrate {
        tick()

        val current = state as? StartupState.Selecting
        if (current == null || current.leaseId != leaseId) {
            false
        } else {
            logger.debug("Selection released: $reason")
            // The provenance survives a handed-back lease. Releasing means this
            // owner stopped resolving, not that the user withdrew the switch that
            // named the candidate in the first place.
            state = StartupState.Unresolved(
                current.candidateProfileId,
                current.candidateIsRestartTarget,
            )
            true
        }
    }

    /**
     * Hands back whatever [engineId] was holding, because that engine is gone.
     *
     * Proven loss, not suspected loss, and the difference is the whole reason this
     * exists. The heartbeat deadline answers "might this owner still be running and
     * mutating?" — it has to assume yes, so expiry sets `restartRequiredForRecovery`
     * and refuses to hand out another lease in this process. A destroyed engine
     * needs no such assumption: the isolate is gone, it cannot mutate anything, and
     * a replacement engine is as safe a recoverer as a new process would be.
     *
     * Without it, `MainActivity.onDestroy` destroying the cached engine on an
     * ordinary system-initiated destroy stranded the lease. The replacement engine
     * has a different id, so `beginStartup` answered "maintenance owned by
     * <dead engine>" for the life of the process — and with the deadline held, it
     * would have answered that forever. That is an app that will not reopen until
     * it is force-stopped.
     *
     * [recoveryRequired] is still raised on the reservation: the engine may well
     * have died mid-operation, and reconciling from the journals is cheap and
     * idempotent. What is *not* raised is `restartRequiredForRecovery`, which is
     * the flag that would make the reservation unreachable.
     */
    fun abandonEngine(engineId: String): Boolean = arbitrate {
        when (val current = state) {
            is StartupState.Selecting -> {
                if (current.owner.engineId != engineId) {
                    false
                } else {
                    logger.info("Selection lease abandoned by a destroyed engine")
                    // Same transition a voluntary release makes: the provenance of
                    // the candidate outlives the owner that was resolving it.
                    state = StartupState.Unresolved(
                        current.candidateProfileId,
                        current.candidateIsRestartTarget,
                    )
                    true
                }
            }

            is StartupState.Maintenance -> {
                if (current.owner.engineId != engineId) {
                    false
                } else {
                    logger.info("Maintenance lease abandoned by a destroyed engine")
                    state = StartupState.MaintenanceReserved(
                        taskId = current.taskId,
                        recoveryRequired = true,
                    )
                    true
                }
            }

            else -> false
        }
    }

    // --- native-only entry points ----------------------------------------------

    /**
     * Atomically binds the process from a native entry point: a headless worker, an
     * exported service, or a trusted PWA/shortcut launch.
     *
     * [requestedProfileId] may only be non-null for a launch native has already
     * authenticated. Dart-visible intent extras never reach this parameter — a
     * spoofed `pwa_profile_uuid` must not be able to select a profile.
     */
    fun tryCommitExternal(
        requestedProfileId: String?,
        trusted: Boolean,
        honorShortcutProfile: Boolean = true,
    ): ExternalCommitResult = arbitrate {
        tick()

        val target = when {
            requestedProfileId == null -> null
            !trusted -> {
                logger.warn("Ignoring untrusted profile hint")
                null
            }
            !honorShortcutProfile -> null
            else -> requestedProfileId
        }

        when (val current = state) {
            is StartupState.Uninitialized -> ExternalCommitResult.NoValidProfile

            is StartupState.Committed ->
                if (target == null || target == current.profileId) {
                    ExternalCommitResult.AlreadyCommittedSame(current.profileId)
                } else {
                    // Never a silent rebind: the caller has to run the mismatch and
                    // restart flow instead.
                    ExternalCommitResult.AlreadyCommittedDifferent(current.profileId)
                }

            is StartupState.Committing -> ExternalCommitResult.SelectionInProgress

            is StartupState.Unresolved -> {
                val profileId = target ?: current.candidateProfileId
                when {
                    profileId == null -> ExternalCommitResult.NoValidProfile
                    !commitLocked(profileId, "external") ->
                        ExternalCommitResult.NoValidProfile
                    else -> ExternalCommitResult.CommittedRequested(profileId)
                }
            }

            is StartupState.Selecting -> {
                // A trusted launch may *answer* an open selection; anything else
                // retries rather than racing the picker.
                val answeredLease = current.leaseId
                when {
                    target == null || !trusted -> ExternalCommitResult.SelectionInProgress
                    !commitLocked(target, "trusted launch answered selection") ->
                        ExternalCommitResult.NoValidProfile
                    else -> ExternalCommitResult.AnsweredSelection(target, answeredLease)
                }
            }

            is StartupState.MaintenanceReserved, is StartupState.Maintenance ->
                ExternalCommitResult.MaintenanceRefused

            is StartupState.RestartPreparing, is StartupState.Restarting ->
                ExternalCommitResult.Terminating
        }
    }

    // --- maintenance -----------------------------------------------------------

    fun heartbeatMaintenance(leaseId: String): Boolean = arbitrate {
        renewMaintenance(leaseId)
    }

    /**
     * Holds or releases the deadline on the lease [leaseId] names.
     *
     * Held means "the owner is not running": the maintenance UI is not resumed, so
     * Android may freeze the process at any moment, and a frozen isolate fires no
     * timers. Without this, the deadline measured how long the platform declined
     * to run the owner — and an ordinary trip to a password manager could expire a
     * lease, set `restartRequiredForRecovery`, and refuse every later maintenance
     * boundary in the process.
     *
     * **Only this call moves the flag.** Heartbeats and boundary assertions renew
     * the deadline and leave it alone, because they answer a different question:
     * they say the owner is *running*, which is not the same as the owner being on
     * screen. `MaintenanceLease.keepAlive` pumps heartbeats for as long as a task
     * runs, so tying the two together meant a backup running behind a backgrounded
     * app cleared its own hold every fifteen seconds and put the deadline straight
     * back — leaving the frozen process to be caught out exactly as before.
     *
     * A hold is not a licence to keep the lease forever, because it is not what a
     * *dead* owner leaves behind: this state lives in memory, a process that dies
     * takes the lease with it, and an engine that is destroyed hands it back
     * through [abandonEngine]. What the deadline actually catches is an owner that
     * stalls while its engine and process both keep running.
     */
    fun holdMaintenanceHeartbeat(leaseId: String, held: Boolean): Boolean = arbitrate {
        renewMaintenance(leaseId, held = held)
    }

    /**
     * Renews the lease [leaseId] names, if it is still live and still its owner's.
     *
     * **Deliberately matches before it ticks.** Expiry is evaluated lazily, at the
     * top of every observation, so a heartbeat that arrives after the deadline used
     * to expire the very lease it was renewing — which is precisely the wrong
     * answer, because a late heartbeat is the owner proving it is alive. The
     * fencing that the deadline exists for is unaffected: if anything else has
     * observed the expiry in the meantime, the state is no longer this owner's
     * `Maintenance` and this returns false, so a stale holder still cannot renew
     * past a takeover.
     */
    private fun renewMaintenance(leaseId: String, held: Boolean? = null): Boolean {
        val current = state as? StartupState.Maintenance
        if (current == null || current.leaseId != leaseId) {
            // Not ours to renew. Fall back to the ordinary rules, so an expiry
            // nobody has looked at yet is still applied.
            tick()
            return false
        }

        state = current.copy(
            // Null leaves it where it was: liveness and lifecycle are separate
            // facts, and a renewal only ever answers the first one.
            heartbeatHeld = held ?: current.heartbeatHeld,
            heartbeatDeadlineMillis = clock.nowMillis() + MAINTENANCE_HEARTBEAT_TIMEOUT_MS,
        )
        return true
    }

    /**
     * The fencing check every destructive boundary must pass.
     *
     * The lease is not merely an end-of-task receipt: a stale holder that kept
     * running after its lease expired would be mutating a profile the process no
     * longer believes is under maintenance. Callers must stop immediately when this
     * returns false.
     */
    fun assertMaintenanceLease(
        leaseId: String,
        taskId: String?,
        boundary: String,
    ): Boolean = arbitrate {
        // Before `tick()`, for the same reason [renewMaintenance] is: reaching a
        // boundary is proof of liveness, and a process that was frozen between two
        // boundaries has done nothing wrong. A takeover still fences this out —
        // the state would no longer be this owner's `Maintenance`.
        val live = (state as? StartupState.Maintenance)?.takeIf { it.leaseId == leaseId }
        if (live == null) tick()

        val current = state as? StartupState.Maintenance
        when {
            current == null -> {
                logger.error("Maintenance boundary '$boundary' outside a maintenance lease")
                false
            }
            current.leaseId != leaseId -> {
                logger.error("Stale maintenance lease at boundary '$boundary'")
                false
            }
            taskId != null && current.taskId != null && current.taskId != taskId -> {
                logger.error("Maintenance lease is for ${current.taskId}, not $taskId")
                false
            }
            else -> {
                // Touching a boundary is itself proof of liveness. It says nothing
                // about whether the owner is on screen, so it does not disturb a
                // hold: work runs behind a backgrounded app all the time.
                state = current.copy(
                    heartbeatDeadlineMillis =
                        clock.nowMillis() + MAINTENANCE_HEARTBEAT_TIMEOUT_MS,
                )
                true
            }
        }
    }

    /** Returns to the reservation at a task or input boundary. */
    fun suspendMaintenance(leaseId: String, taskId: String?): Boolean = arbitrate {
        tick()

        val current = state as? StartupState.Maintenance
        if (current == null || current.leaseId != leaseId) {
            false
        } else {
            state = StartupState.MaintenanceReserved(
                taskId = taskId ?: current.taskId,
                recoveryRequired = current.recoveryRequired,
            )
            true
        }
    }

    /**
     * All maintenance work is reconciled. The process becomes selectable again
     * rather than committing straight away: the profile that was under maintenance
     * may have been deleted or replaced.
     *
     * The resulting candidate carries `candidateIsRestartTarget` when it is still
     * the profile `current_profile` names, and that is not a shortcut — it is the
     * same rule an explicit switch uses. Backups, restores and deletions all
     * restart the process implicitly; the user asked for the operation, never to
     * change profile. Rebuilding `Unresolved` without the flag meant that anyone
     * with "Ask which profile to open" turned on was handed the picker after every
     * one of them, and had to re-answer a question they had not asked.
     *
     * It is deliberately not set when the candidate had to fall back to the oldest
     * profile: `current_profile` no longer validates, so there *is* no profile to
     * return to and the choice is real.
     */
    fun finishMaintenance(leaseId: String): Boolean = arbitrate {
        tick()

        val current = state as? StartupState.Maintenance
        if (current == null || current.leaseId != leaseId) {
            false
        } else {
            val reservation = paths?.let { MaintenanceReservation.resolve(it) }
            if (reservation != null && reservation.required) {
                logger.warn("Maintenance still required after finish: ${reservation.reason}")
                state = StartupState.MaintenanceReserved(
                    taskId = reservation.taskId,
                    recoveryRequired = reservation.recoveryRequired,
                )
                false
            } else {
                val candidate = resolveCandidateWithSource()
                state = StartupState.Unresolved(
                    candidate.profileId,
                    candidateIsRestartTarget =
                        candidate.source == ProfileCandidateSource.CURRENT_PROFILE,
                )
                true
            }
        }
    }

    // --- restart ---------------------------------------------------------------

    /**
     * Enters `RestartPreparing`. Profile access is refused from here, but nothing
     * is torn down yet: if arming the alarm fails, [abortRestart] returns the
     * process to exactly the state it was in.
     */
    fun prepareRestart(targetProfileId: String?, reason: String): Boolean = arbitrate {
        tick()

        when (val current = state) {
            is StartupState.Restarting -> false
            is StartupState.RestartPreparing -> true
            else -> {
                state = StartupState.RestartPreparing(targetProfileId, reason, current)
                true
            }
        }
    }

    fun abortRestart(): Boolean = arbitrate {
        val current = state as? StartupState.RestartPreparing
        if (current == null) {
            false
        } else {
            logger.warn("Restart aborted: ${current.reason}")
            state = current.returnState
            true
        }
    }

    /** Request and alarm are durable; from here failure means process exit. */
    fun confirmRestarting(): Boolean = arbitrate {
        val current = state as? StartupState.RestartPreparing
        if (current == null) {
            false
        } else {
            state = StartupState.Restarting(current.targetProfileId, current.reason)
            true
        }
    }

    /**
     * Applies a restart target in a *new* process, before candidate resolution.
     *
     * Refused when this process wrote the request: an alarm delivered back into the
     * still-live old process must be rescheduled after termination, never honoured
     * in place.
     */
    fun applyRestartTarget(request: RestartRequest): Boolean = arbitrate {
        tick()

        val current = state as? StartupState.Unresolved
        val target = request.targetProfileId

        when {
            !request.isActionableFor(processInstanceId, clock.nowMillis()) -> {
                logger.warn("Ignoring stale or self-issued restart request ${request.requestId}")
                false
            }
            current == null -> {
                logger.warn("Restart target arrived in state $state; ignoring")
                false
            }
            target == null -> false
            !isValidProfile(target) -> {
                logger.warn("Restart target $target does not validate")
                false
            }
            else -> {
                state = current.copy(
                    candidateProfileId = target,
                    candidateIsRestartTarget = true,
                )
                true
            }
        }
    }

    // --- internals -------------------------------------------------------------

    /**
     * Applies expiry rules. Called at the top of every state-observing method so
     * deadlines do not need a background thread.
     */
    private fun tick() {
        val now = clock.nowMillis()

        when (val current = state) {
            is StartupState.Selecting -> {
                if (now < current.deadlineMillis) return
                logger.warn("Selection lease expired")
                val candidate = current.candidateProfileId
                if (candidate != null && isValidProfile(candidate)) {
                    commitLocked(candidate, "selection watchdog")
                } else {
                    // First run with no candidate stays unresolved; native code
                    // cannot invent a profile.
                    state = StartupState.Unresolved(
                        candidate,
                        current.candidateIsRestartTarget,
                    )
                }
            }

            is StartupState.Maintenance -> {
                // A held deadline is not a missed one: the owner said it is not
                // running, so the time since its last renewal measures the
                // platform, not the owner.
                if (current.heartbeatHeld) return
                if (now < current.heartbeatDeadlineMillis) return
                logger.error("Maintenance lease expired; preserving the reservation")
                // Never silently commit a profile that may be half restored.
                restartRequiredForRecovery = true
                state = StartupState.MaintenanceReserved(
                    taskId = current.taskId,
                    recoveryRequired = true,
                )
            }

            else -> Unit
        }
    }

    /** Caller must hold the monitor. Fires callbacks after releasing it. */
    private fun commitLocked(profileId: String, source: String): Boolean {
        val paths = this.paths ?: return false
        if (!isValidProfile(profileId)) {
            logger.error("Refusing to commit invalid profile $profileId")
            return false
        }

        state = StartupState.Committing(profileId)

        try {
            writer?.persist(profileId)
        } catch (error: Throwable) {
            logger.error("Could not persist committed profile", error)
            state = StartupState.Unresolved(profileId)
            return false
        }

        val relativePath = paths.relativeProfilePath(profileId)
        state = StartupState.Committed(profileId, relativePath)

        // Startup ownership is settled, so a restart request that got us here has
        // done its job. Leaving it would make the *next* process apply the same
        // target again, overriding whatever the user chose in between.
        RestartCoordinator.clearAppliedRestart(paths)

        val callbacks = committedCallbacks.toList()
        committedCallbacks.clear()

        // Queued rather than invoked: `arbitrate` runs them once the monitor is
        // released. They do profile-bound work that may re-enter the arbiter, and
        // one failing callback must not block the others.
        pendingCallbacks = callbacks
        pendingProfileId = profileId
        pendingRelativePath = relativePath

        logger.info("Committed profile $profileId ($source)")
        return true
    }

    private var pendingCallbacks: List<(String, String) -> Unit> = emptyList()
    private var pendingProfileId: String? = null
    private var pendingRelativePath: String? = null

    /**
     * Runs every public entry point under the arbitration monitor and then drains
     * any callbacks a commit queued — outside the monitor.
     *
     * The two halves cannot be merged. `onCommitted` work (push recovery, the
     * sandbox capture bootstrap) does I/O and takes the profile lock and UnifiedPush
     * exclusivity. Holding this monitor across those inverts the documented lock
     * order — `startup arbitration -> profile lock -> UnifiedPush exclusivity` — and
     * would let a slow callback stall every other component's arbitration query for
     * as long as it runs.
     */
    private fun <T> arbitrate(block: () -> T): T {
        val result = synchronized(this) { block() }
        drainCommittedCallbacks()
        return result
    }

    private fun drainCommittedCallbacks() {
        val pending = synchronized(this) {
            val callbacks = pendingCallbacks
            val profileId = pendingProfileId
            val relativePath = pendingRelativePath

            // Cleared unconditionally, so a half-written trio can never leave
            // callbacks queued forever behind a `null` guard.
            pendingCallbacks = emptyList()
            pendingProfileId = null
            pendingRelativePath = null

            if (callbacks.isEmpty() || profileId == null || relativePath == null) {
                null
            } else {
                Triple(callbacks, profileId, relativePath)
            }
        } ?: return

        for (callback in pending.first) {
            runCallback(callback, pending.second, pending.third)
        }
    }

    private fun runCallback(
        callback: (String, String) -> Unit,
        profileId: String,
        relativePath: String,
    ) {
        try {
            callback(profileId, relativePath)
        } catch (error: Throwable) {
            logger.error("Profile commitment callback failed", error)
        }
    }

    /**
     * The picker is shown only when it can actually change anything.
     *
     * A headless owner never prompts — there is no UI to prompt in — and a single
     * valid profile has nothing to choose between, so prompting there would just be
     * a startup delay users cannot act on.
     *
     * [candidateIsRestartTarget] is the third case: the user has *already* made
     * this exact choice, and the restart is how it gets carried out. Asking again
     * would be asking them to confirm the answer they just gave. It suppresses one
     * launch only — the flag lives on the in-process state, so once this boot
     * commits, the next cold start prompts as configured.
     */
    private fun shouldShowPicker(
        owner: StartupOwner,
        promptMode: ProfilePromptMode,
        candidateIsRestartTarget: Boolean,
    ): Boolean {
        if (owner.type != StartupOwnerType.UI) return false
        if (promptMode != ProfilePromptMode.BROWSER_ONLY) return false
        if (candidateIsRestartTarget) return false

        val paths = this.paths ?: return false
        return ProfileDiscovery.scan(paths.profilesDir).profiles.size >= 2
    }

    /**
     * The one validation every commit passes, trusted launches included.
     *
     * A canonical name and an existing directory are not enough. Authenticating a
     * PWA or shortcut proves the caller is entitled to *name* a profile; it says
     * nothing about whether that profile still parses. Committing a profile whose
     * `metadata.json` has since been damaged would bind the process to something
     * Dart's `ProfileDiscovery` then skips, and since the process profile is
     * immutable, Dart would go on to select a different profile and engine setup
     * would fail on the mismatch. Refusing here instead degrades to the ordinary
     * candidate, which is recoverable.
     */
    private fun isValidProfile(profileId: String): Boolean {
        val paths = this.paths ?: return false
        return ProfileDiscovery.validate(paths.profilesDir, profileId)
    }

    /**
     * Resolves the candidate with the shared rule.
     *
     * No maintenance filtering happens here on purpose: a profile that is
     * mid-operation keeps the whole process in `MaintenanceReserved`, so this is
     * only ever reached once nothing is in flight. Filtering as well would be dead
     * code that reads like a second safety net.
     */
    private fun resolveCandidate(): String? = resolveCandidateWithSource().profileId

    /**
     * As [resolveCandidate], but keeps *why* the candidate was chosen.
     *
     * The source is what separates "this process is returning to the profile it
     * was already on" from "that profile is gone and this is the fallback", and
     * only the first of those may suppress a picker.
     */
    private fun resolveCandidateWithSource(): ProfileCandidate {
        val paths = this.paths ?: return ProfileCandidate.ABSENT

        return ProfileCandidateResolver.resolve(
            ProfileCandidateResolver.readCurrentProfile(paths),
            ProfileDiscovery.scan(paths.profilesDir).profileIds,
        )
    }

    private fun newToken(): String {
        val bytes = ByteArray(16)
        random.nextBytes(bytes)
        return bytes.joinToString("") { "%02x".format(it) }
    }
}
