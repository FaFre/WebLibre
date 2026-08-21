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
package eu.weblibre.gecko

import android.app.ActivityManager
import android.app.Application
import android.content.Context
import android.content.SharedPreferences
import android.os.Build
import android.os.Process
import eu.weblibre.flutter_mozilla_components.ActiveProfile
import eu.weblibre.flutter_mozilla_components.MegazordSetup
import eu.weblibre.flutter_mozilla_components.feature.SandboxCaptureFeature
import eu.weblibre.flutter_mozilla_components.push.PushMessageScheduler
import eu.weblibre.flutter_mozilla_components.services.StalePrivateNotification
import eu.weblibre.flutter_mozilla_components.startup.StartupArbiter
import eu.weblibre.flutter_mozilla_components.startup.StartupPaths

class MyApplication : Application() {

    /**
     * Installs the profile arbiter before anything can ask which profile we are on.
     *
     * This has to be `attachBaseContext`, not `onCreate`. The merged manifest
     * contains `androidx.startup.InitializationProvider`, and ContentProviders are
     * created after `attachBaseContext()` but before `onCreate()`. An initializer
     * that touched a profile-sensitive preference name would otherwise reach
     * [getSharedPreferences] before the arbiter existed.
     */
    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)

        // Gecko's child services run in their own processes from the merged
        // manifest. Startup orchestration belongs to the default app process only.
        if (!isDefaultProcess(base)) return

        StartupArbiter.initialize(
            paths = StartupPaths(base.filesDir),
            writer = ActiveProfile.committedProfileWriter(base),
        )
    }

    override fun onCreate() {
        super.onCreate()

        // Unconditional and early: the megazord has to be set up whether or not a
        // profile is ever committed in this process.
        MegazordSetup.setupEarlyMainProcess()

        if (!isDefaultProcess(this)) return

        // Before anything can commit, because it must not need a profile: private
        // tabs never survive the process, so a private-browsing notification still
        // showing in a *fresh* one describes tabs that no longer exist, and its
        // only action is one `PrivateTabsNotificationService` cannot serve without
        // components. Removing it closes the window rather than handling what
        // arrives through it.
        StalePrivateNotification.clear(this)

        // Both of these create profile-bound state, so neither may run before the
        // process has committed. Registering them here keeps the ordering explicit:
        // whichever component commits — the launcher, a worker, a trusted PWA — runs
        // them at that moment, and a process that never commits never runs them.
        StartupArbiter.onCommitted { _, _ ->
            // Rehydrate the sandbox capture registry from the on-disk JSON mirror
            // before Gecko has a chance to start restoring tabs. Each entry gets
            // redirectUrl="about:blank"; Dart replaces those once CaptureServer is
            // running with real loader/capture URLs.
            SandboxCaptureFeature.preRestoreBootstrap(this)
        }

        StartupArbiter.onCommitted { _, _ ->
            ActiveProfile.resolveContext(this)?.let(PushMessageScheduler::recoverLater)
        }
    }

    /**
     * Routes the profile-sensitive preference names mozilla-components asks for by
     * bare name.
     *
     * There is no error channel here — framework and third-party code call this —
     * so an access before commitment throws. That is deliberate: returning an
     * unprefixed store would silently share one profile's FxA state with every
     * other profile, and returning a foreign profile's store is worse still. A
     * crash is the only outcome that cannot corrupt data, which is why the boot
     * smoke tests exercise the paths most likely to get here early.
     */
    override fun getSharedPreferences(name: String, mode: Int): SharedPreferences {
        if (name !in ActiveProfile.FXA_SHARED_PREFERENCE_NAMES) {
            return super.getSharedPreferences(name, mode)
        }

        val prefix = ActiveProfile.prefix
            ?: error(
                "Profile-sensitive preference '$name' requested before the process " +
                    "committed a profile",
            )

        return super.getSharedPreferences("${prefix}_$name", mode)
    }

    private fun isDefaultProcess(context: Context): Boolean =
        currentProcessName(context) == context.packageName

    private fun currentProcessName(context: Context): String? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            return Application.getProcessName()
        }

        val pid = Process.myPid()
        val activityManager =
            context.getSystemService(Context.ACTIVITY_SERVICE) as? ActivityManager
        return activityManager?.runningAppProcesses
            ?.firstOrNull { it.pid == pid }
            ?.processName
    }
}
