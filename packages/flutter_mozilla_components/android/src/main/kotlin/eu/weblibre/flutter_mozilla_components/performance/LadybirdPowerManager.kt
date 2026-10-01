/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.performance

import android.app.Activity
import android.app.Application
import android.content.ComponentCallbacks2
import android.content.res.Configuration
import android.os.Bundle
import eu.weblibre.flutter_mozilla_components.EngineProvider
import eu.weblibre.flutter_mozilla_components.GeckoRuntimeState
import mozilla.components.support.base.log.logger.Logger

/**
 * Reacts to Android's own lifecycle and memory signals by moving Gecko between
 * four operating profiles.
 *
 * Ladybird's power story is structural — a background tab simply has no thread
 * scheduled for it, so it cannot burn CPU. GeckoView keeps its own scheduler
 * and cannot be told to stand down from Kotlin, but it does expose a live pref
 * surface. This manager uses that surface to approximate the same outcome:
 * the moment the app is not visible, timers, media and process priority are
 * clamped, and they are restored the moment it is visible again.
 *
 * Prefs applied here are all live-settable — none of them require the runtime
 * to be recreated. Profiles are monotonic within a background stretch: memory
 * pressure can only escalate the profile, and returning to the foreground is
 * the only thing that resets it.
 *
 * Reference: qwerzxcva/ladybird (per-process isolation), lightpanda-io/browser
 * (system-level resource control).
 */
class LadybirdPowerManager :
    Application.ActivityLifecycleCallbacks, ComponentCallbacks2 {

    enum class Profile { Foreground, Background, Pressure, Critical }

    private val logger = Logger("LadybirdPowerManager")

    private var startedActivities = 0
    private var profile = Profile.Foreground

    /** Number of activities currently started; 0 means the app is not visible. */
    private val isVisible: Boolean get() = startedActivities > 0

    override fun onActivityStarted(activity: Activity) {
        startedActivities++
        if (startedActivities == 1) {
            // Back to the foreground: the pressure we saw while hidden no longer
            // applies, so drop straight back to the interactive profile.
            transitionTo(Profile.Foreground)
        }
    }

    override fun onActivityStopped(activity: Activity) {
        startedActivities = (startedActivities - 1).coerceAtLeast(0)
        if (startedActivities == 0) {
            transitionTo(Profile.Background)
        }
    }

    override fun onTrimMemory(level: Int) {
        // The TRIM_MEMORY_* constants are not ordered by severity: the
        // RUNNING_* values (5/10/15) are more severe than BACKGROUND (40) and
        // MODERATE (60), so they are matched by value, not by comparison.
        val target = when (level) {
            ComponentCallbacks2.TRIM_MEMORY_COMPLETE,
            ComponentCallbacks2.TRIM_MEMORY_RUNNING_CRITICAL -> Profile.Critical
            ComponentCallbacks2.TRIM_MEMORY_MODERATE,
            ComponentCallbacks2.TRIM_MEMORY_RUNNING_LOW,
            ComponentCallbacks2.TRIM_MEMORY_RUNNING_MODERATE,
            ComponentCallbacks2.TRIM_MEMORY_BACKGROUND -> Profile.Pressure
            ComponentCallbacks2.TRIM_MEMORY_UI_HIDDEN -> Profile.Background
            else -> return
        }

        if (isVisible && target == Profile.Background) {
            // TRIM_MEMORY_UI_HIDDEN can arrive while an activity is technically
            // still started; trust the lifecycle count over the trim level.
            return
        }

        transitionTo(target)
    }

    override fun onLowMemory() {
        transitionTo(Profile.Critical)
    }

    override fun onConfigurationChanged(newConfig: Configuration) = Unit

    // Unused lifecycle callbacks — the manager only needs started/stopped.
    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) = Unit
    override fun onActivityResumed(activity: Activity) = Unit
    override fun onActivityPaused(activity: Activity) = Unit
    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) = Unit
    override fun onActivityDestroyed(activity: Activity) = Unit

    private fun transitionTo(target: Profile) {
        // Escalation only while hidden; the foreground is always authoritative.
        if (target != Profile.Foreground && target.ordinal < profile.ordinal) return
        if (target == profile) return

        profile = target
        val runtime = (EngineProvider.runtimeState() as? GeckoRuntimeState.Live)?.runtime
        if (runtime == null) {
            logger.debug("Profile ${target.name} recorded; no live runtime to apply it to")
            return
        }

        val prefs = runtime.settings
        when (target) {
            Profile.Foreground -> applyForeground(prefs)
            Profile.Background -> applyBackground(prefs)
            Profile.Pressure -> applyPressure(prefs)
            Profile.Critical -> applyCritical(prefs)
        }
        logger.info("Gecko power profile -> ${target.name}")
    }

    /**
     * Interactive: the browser is on screen, so timers, media and caches run at
     * full speed. This is the profile every other one returns to.
     */
    private fun applyForeground(prefs: org.mozilla.geckoview.GeckoRuntimeSettings) {
        prefs.setInt("dom.min_background_timeout_value", 1000)
        prefs.setInt("dom.timeout.background_throttling_max_budget", -1)
        prefs.setBoolean("media.suspend-bkgnd-video.enabled", true)
        prefs.setInt("media.suspend-bkgnd-video.delay-ms", 3000)
        prefs.setInt("javascript.options.mem.high_water_mark", 128)
        prefs.setInt("browser.cache.memory.capacity", 65536)
    }

    /**
     * Hidden: no tab is on screen, so clamp background timers hard and stop
     * background media immediately. A page left open in the background keeps
     * its state but stops consuming CPU and radio.
     */
    private fun applyBackground(prefs: org.mozilla.geckoview.GeckoRuntimeSettings) {
        prefs.setInt("dom.min_background_timeout_value", 10000)
        prefs.setInt("dom.timeout.background_throttling_max_budget", 50)
        prefs.setBoolean("media.suspend-bkgnd-video.enabled", true)
        prefs.setInt("media.suspend-bkgnd-video.delay-ms", 0)
        prefs.setBoolean("dom.animations.offscreen-throttling", true)
        prefs.setInt("dom.ipc.processPriorityManager.backgroundGracePeriodMS", 0)
    }

    /**
     * Pressure: the system is asking for memory back while we are still running.
     * Shrink caches and JS headroom so Gecko collects earlier instead of being
     * killed later.
     */
    private fun applyPressure(prefs: org.mozilla.geckoview.GeckoRuntimeSettings) {
        applyBackground(prefs)
        prefs.setInt("javascript.options.mem.high_water_mark", 64)
        prefs.setInt("browser.cache.memory.capacity", 32768)
        prefs.setInt("image.mem.surfacecache.max_size_kb", 32768)
        prefs.setInt("browser.sessionhistory.max_total_viewers", 0)
        prefs.setBoolean("memory.free_dirty_pages", true)
    }

    /**
     * Critical: the process is a candidate for the LMK. Release everything that
     * can be rebuilt and let Gecko unload background tabs.
     */
    private fun applyCritical(prefs: org.mozilla.geckoview.GeckoRuntimeSettings) {
        applyPressure(prefs)
        prefs.setInt("javascript.options.mem.high_water_mark", 32)
        prefs.setInt("javascript.options.mem.max", 256)
        prefs.setInt("browser.cache.memory.capacity", 16384)
        prefs.setInt("image.mem.surfacecache.max_size_kb", 16384)
        prefs.setBoolean("browser.tabs.unloadOnLowMemory", true)
    }

    companion object {
        /**
         * Wires the manager to the application. Idempotent — later calls are
         * no-ops, so it is safe to call from both `attachBaseContext` and
         * `onCreate` paths if that ever becomes convenient.
         */
        @Volatile
        private var instance: LadybirdPowerManager? = null

        fun install(app: Application) {
            if (instance != null) return
            synchronized(LadybirdPowerManager::class.java) {
                if (instance != null) return
                val manager = LadybirdPowerManager()
                app.registerActivityLifecycleCallbacks(manager)
                app.registerComponentCallbacks(manager)
                instance = manager
            }
        }
    }
}
