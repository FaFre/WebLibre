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

import android.app.ActivityOptions
import android.app.AlarmManager
import android.app.PendingIntent
import android.os.Build
import android.os.Process
import android.content.Context
import android.content.Intent
import eu.weblibre.flutter_mozilla_components.activities.RestartActivity
import mozilla.components.support.base.log.logger.Logger
import java.security.SecureRandom
import kotlin.system.exitProcess

/** How long a written restart request stays actionable. */
const val RESTART_REQUEST_TTL_MS = 5 * 60 * 1000L

/**
 * The pid of the process the trampoline has to outlive.
 *
 * Carried on the intent because the trampoline cannot work it out for itself: it
 * only ever sees "the default process", and after a successful relaunch that name
 * belongs to the *new* browser. Without the pid a late backstop would wait on the
 * process it was supposed to bring into existence, then kill it.
 */
const val EXTRA_RESTART_TARGET_PID = "eu.weblibre.extra.RESTART_TARGET_PID"

/**
 * The flags the relaunch alarm's `PendingIntent` is registered with.
 *
 * Shared between arming and cancelling because they are part of its *identity*.
 * The system strips only `FLAG_NO_CREATE`/`FLAG_CANCEL_CURRENT`/
 * `FLAG_UPDATE_CURRENT` before keying the record; `FLAG_ONE_SHOT` survives and is
 * compared, so a `FLAG_NO_CREATE` lookup that omits it misses, returns null, and
 * turns the cancel into a silent no-op — leaving the backstop free to fire after
 * the relaunch already happened.
 */
private const val RESTART_ALARM_FLAGS =
    PendingIntent.FLAG_ONE_SHOT or PendingIntent.FLAG_IMMUTABLE

/** How long after arming the alarm should fire. */
private const val RESTART_ALARM_DELAY_MS = 300L

/**
 * Arms a durable restart, then terminates the process.
 *
 * The process profile is immutable, so "switch to profile B" can only ever mean
 * "die and come back as B". Everything here exists to make that survivable at any
 * interruption point: the request is on disk before the alarm is armed, the alarm
 * is armed before anything is torn down, and only after both are durable does the
 * process become terminal.
 *
 * The old process never writes `current_profile`. The new one applies the target
 * from the request, so disk never says B while a live process still serves A.
 */
object RestartCoordinator {
    /** Request code for the one-shot relaunch alarm. */
    const val RESTART_PENDING_INTENT_REQUEST_CODE = 0x5245

    private val logger = Logger("RestartCoordinator")
    private val random = SecureRandom()

    /**
     * Everything before the point of no return.
     *
     * Returns false having changed nothing observable: the request is deleted and
     * the arbiter is back in the state it was in. Callers can report the failure
     * and carry on running.
     */
    fun arm(
        context: Context,
        targetProfileId: String?,
        reason: String,
        brokerEntryId: String? = null,
        now: Long = System.currentTimeMillis(),
        /**
         * Starts the relaunch. Injected so the failure path is testable without
         * an Activity; production passes [launchTrampoline].
         */
        startTrampoline: (Context) -> Boolean = ::launchTrampoline,
    ): RestartRequest? {
        if (!StartupArbiter.prepareRestart(targetProfileId, reason)) {
            logger.warn("Refusing to prepare a restart in ${StartupArbiter.currentState()}")
            return null
        }

        val paths = StartupPaths(context.applicationContext)
        val store = RestartRequestStore(paths)

        val request = RestartRequest(
            requestId = newToken(),
            reason = reason,
            processInstanceId = StartupArbiter.processInstanceId,
            stateId = RestartRequestState.PENDING.id,
            createdAtMillis = now,
            expiresAtMillis = now + RESTART_REQUEST_TTL_MS,
            targetProfileId = targetProfileId,
            brokerEntryId = brokerEntryId,
        )

        val armed = runCatching {
            store.write(request)
            armAlarm(context, now)
        }

        if (armed.isFailure || armed.getOrDefault(false) != true) {
            // Nothing has been torn down yet, so this is fully recoverable. Leaving
            // the request behind would be worse than not restarting at all: the next
            // process would honour a restart nobody is waiting for.
            logger.error("Could not arm the restart; aborting", armed.exceptionOrNull())
            runCatching { store.clear() }
            StartupArbiter.abortRestart()
            return null
        }

        // Before `confirmRestarting`, and that ordering is the fix rather than a
        // tidy-up. The trampoline is the *only* reliable relaunch on modern
        // Android — see [launchTrampoline]; the alarm is refused once this
        // process dies. Starting it after the arbiter went terminal meant a
        // refused start left a caller that had been told the restart was armed,
        // exited, and never came back: the app simply closed, and the user had
        // to find it and open it again.
        //
        // Here the arbiter is still `RestartPreparing`, so a failure aborts back
        // to the state it came from and nothing observable has changed.
        if (!startTrampoline(context)) {
            logger.error("Could not start the restart trampoline; aborting")
            runCatching { cancelArmedAlarm(context) }
            runCatching { store.clear() }
            StartupArbiter.abortRestart()
            return null
        }

        if (!StartupArbiter.confirmRestarting()) {
            logger.error("Restart was armed but the arbiter would not confirm it")
            return null
        }

        return request
    }

    /**
     * The point of no return: tear down and exit.
     *
     * [teardown] failing does not cancel the exit. The alarm is already armed and
     * the arbiter is already terminal, so staying alive would leave a process that
     * refuses all profile work and never comes back. The new process owns recovery.
     */
    /**
     * Starts the trampoline. Must be called while a window is still visible.
     *
     * This is the only reliable relaunch path on modern Android, and the ordering
     * is the whole trick. A direct activity start from a package that currently
     * has a visible window is permitted (`BAL_ALLOW_VISIBLE_WINDOW`); the same
     * start once the Activity has been finished is not, and neither is the
     * alarm's `PendingIntent` after the process dies. Measured on API 36: both
     * of those are refused with `BAL_BLOCK`.
     *
     * So the trampoline is launched *before* teardown, and it sits in its own
     * process waiting for this one to die.
     */
    fun launchTrampoline(context: Context): Boolean =
        runCatching { context.startActivity(trampolineIntent(context)) }
            .onFailure { logger.error("Could not start the restart trampoline", it) }
            .isSuccess

    /**
     * The point of no return: tear down and exit.
     *
     * [teardown] failing does not cancel the exit. The alarm is already armed and
     * the arbiter is already terminal, so staying alive would leave a process that
     * refuses all profile work and never comes back. The new process owns recovery.
     */
    fun terminate(teardown: () -> Unit) {
        runCatching(teardown)
            .onFailure { logger.error("Restart teardown failed; exiting anyway", it) }

        logger.info("Exiting for restart")
        exitProcess(0)
    }

    /** Cancels the backstop alarm once a relaunch is definitely under way. */
    fun cancelArmedAlarm(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
            ?: return

        val pendingIntent = PendingIntent.getActivity(
            context,
            RESTART_PENDING_INTENT_REQUEST_CODE,
            trampolineIntent(context),
            RESTART_ALARM_FLAGS or PendingIntent.FLAG_NO_CREATE,
        ) ?: return

        alarmManager.cancel(pendingIntent)
        pendingIntent.cancel()
    }

    private fun creatorBalOptIn(): android.os.Bundle? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            ActivityOptions.makeBasic()
                .setPendingIntentCreatorBackgroundActivityStartMode(
                    ActivityOptions.MODE_BACKGROUND_ACTIVITY_START_ALLOWED,
                )
                .toBundle()
        } else {
            null
        }

    /**
     * The intent both relaunch paths fire.
     *
     * The pid is an extra rather than part of the identity on purpose: matching a
     * `PendingIntent` uses `filterEquals`, which ignores extras, so the cancel
     * lookup still finds the armed alarm even though it is built from a different
     * process. `FLAG_UPDATE_CURRENT` is what keeps the stored copy's pid current.
     */
    private fun trampolineIntent(context: Context): Intent =
        Intent(context, RestartActivity::class.java).apply {
            `package` = context.packageName
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS)
            putExtra(EXTRA_RESTART_TARGET_PID, Process.myPid())
        }

    /**
     * Applies a pending restart request in a *new* process.
     *
     * Marks it applied before the target is used rather than after: a crash between
     * the two must not replay the restart, and losing one restart is recoverable
     * where a boot loop is not.
     */
    fun consumePendingRestart(paths: StartupPaths): RestartRequest? {
        val store = RestartRequestStore(paths)
        val request = store.read() ?: return null

        if (!StartupArbiter.applyRestartTarget(request)) {
            // Stale, expired, or delivered back into the process that wrote it.
            // Only the writer's own request is cleared here; a request from another
            // instance may still be for a process that has not started yet.
            if (request.processInstanceId == StartupArbiter.processInstanceId) {
                runCatching { store.clear() }
            }
            return null
        }

        runCatching { store.markApplied(request, System.currentTimeMillis()) }
        return request
    }

    /** Clears an applied request once the new process owns startup. */
    fun clearAppliedRestart(paths: StartupPaths) {
        runCatching { RestartRequestStore(paths).clear() }
            .onFailure { logger.warn("Could not clear the applied restart request", it) }
    }

    /**
     * Schedules the relaunch.
     *
     * Inexact on purpose: an exact alarm would need `SCHEDULE_EXACT_ALARM`, which is
     * a user-visible special permission for a few hundred milliseconds of accuracy
     * nobody would notice. The delay is real and must be tolerated, not designed
     * around.
     *
     * Note that the alarm targets [RestartActivity] in its own process rather than
     * `MainActivity` directly. Two reasons: after `exitProcess` the app has no
     * foreground component, so an activity start from an alarm is subject to
     * background-activity-launch restrictions, and starting `MainActivity` could
     * deliver `onNewIntent` to the still-live `singleTask` instance and its cached
     * Flutter engine instead of launching a fresh one.
     */
    private fun armAlarm(context: Context, now: Long): Boolean {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
            ?: return false

        val pendingIntent = PendingIntent.getActivity(
            context,
            RESTART_PENDING_INTENT_REQUEST_CODE,
            trampolineIntent(context),
            RESTART_ALARM_FLAGS or PendingIntent.FLAG_UPDATE_CURRENT,
            // Opt the *creator* into background activity starts. Without it the
            // system reports `balAllowedByPiCreator: BSP.NONE` and refuses, even
            // when the app had a visible window when the alarm was armed —
            // measured on API 36, where it also reported that allowing it would
            // have permitted the launch. It does not help once the process is
            // gone, which is why this is only the backstop.
            creatorBalOptIn(),
        ) ?: return false

        alarmManager.set(AlarmManager.RTC, now + RESTART_ALARM_DELAY_MS, pendingIntent)
        return true
    }

    private fun newToken(): String {
        val bytes = ByteArray(16)
        random.nextBytes(bytes)
        return bytes.joinToString("") { "%02x".format(it) }
    }
}
