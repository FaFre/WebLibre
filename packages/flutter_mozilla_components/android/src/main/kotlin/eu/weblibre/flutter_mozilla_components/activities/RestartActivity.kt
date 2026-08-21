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
package eu.weblibre.flutter_mozilla_components.activities

import android.app.Activity
import android.app.ActivityManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.content.Intent
import eu.weblibre.flutter_mozilla_components.startup.EXTRA_RESTART_TARGET_PID
import eu.weblibre.flutter_mozilla_components.startup.PendingLaunch
import eu.weblibre.flutter_mozilla_components.startup.PendingLaunchStore
import eu.weblibre.flutter_mozilla_components.startup.RestartCoordinator
import eu.weblibre.flutter_mozilla_components.startup.StartupPaths

/**
 * Relaunches the browser after the default process has died.
 *
 * It runs in its own process (`:restart`, declared in the manifest), and that is
 * the whole point of it. From a separate process it cannot deliver `onNewIntent`
 * to the still-live `singleTask` `MainActivity` or reattach its cached Flutter
 * engine — which is exactly what a same-process "restart" would do, producing a
 * second Dart entrypoint against a Gecko runtime that is already bound.
 *
 * It also gives the relaunch a foreground context of its own, so the start of
 * `MainActivity` is not subject to the background-activity-launch rules that make
 * the alarm path unreliable on Android 10+.
 *
 * It waits for the old process rather than assuming it is gone: launching while
 * it still lives would hand the intent straight back to the activity that is in
 * the middle of dying.
 */
class RestartActivity : Activity() {
    companion object {
        private const val TAG = "RestartActivity"

        /**
         * Generous, because the trampoline now starts *before* teardown rather
         * than after it: closing databases, clearing on-exit container data and
         * shutting down Gecko all happen while this is already waiting. Relaunching
         * early would deliver the intent to the dying `singleTask` Activity.
         */
        private const val WAIT_TIMEOUT_MS = 30_000L
        private const val WAIT_INTERVAL_MS = 100L

        /** Time for a kill to be reflected in the process list. */
        private const val KILL_SETTLE_MS = 250L
    }

    private val handler = Handler(Looper.getMainLooper())
    private var waitedMs = 0L

    /** The process this trampoline was armed for, or -1 when it was not told. */
    private var targetPid = -1

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Whichever path got here first wins; the other must not fire later and
        // relaunch a browser the user has since closed.
        RestartCoordinator.cancelArmedAlarm(applicationContext)

        targetPid = intent?.getIntExtra(EXTRA_RESTART_TARGET_PID, -1) ?: -1

        val livePid = defaultProcessPid()
        if (targetPid != -1 && livePid != null && livePid != targetPid) {
            // The process this was armed for is already gone and a different one
            // holds the default process: another trampoline completed the relaunch
            // and $livePid is the browser the user is now looking at. Waiting on it
            // would end in killing it, so there is nothing to do here but leave —
            // and leaving promptly matters, because this is a translucent Activity
            // sitting on top of that browser and swallowing its input.
            Log.i(TAG, "Restart already completed by pid $livePid; standing down")
            finish()
            return
        }

        awaitDefaultProcessDeath()
    }

    private fun awaitDefaultProcessDeath() {
        val pid = defaultProcessPid()
        if (pid == null) {
            launchBrowser()
            return
        }

        if (targetPid != -1 && pid != targetPid) {
            // Same reasoning as in onCreate, reached the other way: the target died
            // mid-wait and the relaunch has already happened without us.
            Log.i(TAG, "Restart completed by pid $pid while waiting; standing down")
            finish()
            return
        }

        if (waitedMs >= WAIT_TIMEOUT_MS) {
            if (targetPid == -1) {
                // An alarm armed by a build that did not name its target. Killing a
                // process this cannot identify is the very hazard the pid check
                // exists to prevent, so the relaunch is attempted without it.
                Log.w(TAG, "Timed out waiting on unidentified process $pid; relaunching anyway")
                launchBrowser()
                return
            }

            // Relaunching into a process that said it was exiting and then did not
            // is the worst outcome available: its Flutter engine is half torn down,
            // so MainActivity would attach to a detached JNI and come up broken.
            // Same UID, so this process may end it — and must, to guarantee the
            // relaunch lands somewhere clean. Safe to do bluntly because the checks
            // above have established that $pid is still the armed target and not a
            // browser that came up in the meantime.
            Log.w(TAG, "Default process $pid did not exit within ${WAIT_TIMEOUT_MS}ms; terminating it")
            android.os.Process.killProcess(pid)
            handler.postDelayed(::launchBrowser, KILL_SETTLE_MS)
            return
        }

        waitedMs += WAIT_INTERVAL_MS
        handler.postDelayed(::awaitDefaultProcessDeath, WAIT_INTERVAL_MS)
    }

    /**
     * The default process's pid, or null once it is gone.
     *
     * Since Android 5 this only reports the caller's own processes, which is
     * exactly what is being asked about.
     */
    private fun defaultProcessPid(): Int? {
        val activityManager =
            getSystemService(ACTIVITY_SERVICE) as? ActivityManager ?: return null

        return activityManager.runningAppProcesses
            .orEmpty()
            .firstOrNull { it.processName == packageName }
            ?.pid
    }

    private fun launchBrowser() {
        // A restart the user asked for by tapping a shortcut should end on that
        // shortcut, not on a bare browser window.
        val intent = pendingLaunchIntent() ?: packageManager.getLaunchIntentForPackage(packageName)
        if (intent == null) {
            Log.e(TAG, "No launch intent for $packageName; cannot relaunch")
        } else {
            startActivity(intent)
        }

        finish()
    }

    /**
     * The handed-over launch, rebuilt as an intent this app is willing to fire.
     *
     * Never fired as parsed. `Intent.parseUri` can carry a component, a selector
     * and URI-permission grants, so honouring the stored string as-is would turn
     * this private file into an intent-redirection primitive the moment anything
     * could write to it. Only the parts a launch legitimately needs are copied
     * onto a fresh intent aimed at our own receiver.
     */
    private fun pendingLaunchIntent(): Intent? {
        val launch = runCatching {
            PendingLaunchStore(StartupPaths(applicationContext)).consume()
        }.getOrNull() ?: return null

        return runCatching { rebuild(launch) }
            .onFailure { Log.w(TAG, "Ignoring an unusable pending launch", it) }
            .getOrNull()
    }

    private fun rebuild(launch: PendingLaunch): Intent {
        val parsed = Intent.parseUri(launch.intentUri, Intent.URI_INTENT_SCHEME)

        return Intent(parsed.action ?: Intent.ACTION_VIEW).apply {
            setClassName(packageName, IntentReceiverActivity::class.java.name)
            setDataAndType(parsed.data, parsed.type)
            parsed.categories?.forEach { addCategory(it) }
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

            parsed.extras?.let { extras ->
                for (key in extras.keySet()) {
                    // A nested Intent is the classic redirection payload: something
                    // downstream forwards it, and it runs with our privileges.
                    // Nothing in a shortcut launch needs one.
                    @Suppress("DEPRECATION")
                    if (extras.get(key) is Intent) continue
                    putExtra(key, extras.get(key) as? java.io.Serializable ?: continue)
                }
            }
        }
    }

    override fun onDestroy() {
        handler.removeCallbacksAndMessages(null)
        super.onDestroy()
    }
}
