/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import android.content.ActivityNotFoundException
import android.content.Intent
import mozilla.components.support.base.log.logger.Logger

/**
 * Distinct launch modes, each with an exact flag set (§6):
 * - [MANUAL]: user-driven "Open in <App>" — preserves the `NEW_DOCUMENT | MULTIPLE_TASK` task
 *   behaviour so the app opens in its own recents entry.
 * - [AUTOMATIC]: global-`always` or a remembered `alwaysOpen` rule — `NEW_TASK`, subject to the
 *   2 s same-package cooldown loop-breaker (§2.4).
 * - [MARKETPLACE]: install-app fallback — `NEW_TASK | CLEAR_TASK`.
 */
enum class AppLinkLaunchMode {
    MANUAL,
    AUTOMATIC,
    MARKETPLACE,
}

enum class AppLinkLaunchResult {
    LAUNCHED,
    NO_APP,
    COOLDOWN,
    PACKAGE_MISMATCH,
    FAILED,
}

/**
 * Launches external apps. Every launch re-resolves immediately first (no cache) and verifies the
 * expected package before `startActivity` (§2.7). Automatic launches honour a 2 s same-package
 * cooldown to break app→browser→app ping-pong loops (§2.4); manual and prompt-resolved opens are
 * user gestures that bypass the check but still record it.
 */
class AppLinkLauncher(
    private val resolver: ExternalAppResolver,
    private val startActivity: (Intent) -> Unit,
    private val clock: MonotonicClock = MonotonicClock.SYSTEM,
    private val cooldownMs: Long = APP_LINKS_DO_NOT_INTERCEPT_INTERVAL,
) {
    private val logger = Logger("AppLinkLauncher")

    @Volatile
    private var lastLaunch: Pair<String?, Long> = Pair(null, 0L)

    /**
     * Re-resolve [url] and launch it in the appropriate external app.
     *
     * @param expectedPackage when non-null (remembered/manual rebind paths), the freshly resolved
     * package must equal it or the launch is refused with [AppLinkLaunchResult.PACKAGE_MISMATCH].
     */
    @Synchronized
    fun launch(
        url: String,
        mode: AppLinkLaunchMode,
        expectedPackage: String? = null,
    ): AppLinkLaunchResult {
        val resolved = resolver.resolve(url, includeHttpAppLinks = true, useCache = false)

        val intent: Intent = when (mode) {
            AppLinkLaunchMode.MARKETPLACE -> resolved.marketplaceIntent ?: return AppLinkLaunchResult.NO_APP
            else -> {
                if (!resolved.hasExternalApp || resolved.appIntent == null) {
                    return AppLinkLaunchResult.NO_APP
                }
                if (expectedPackage != null && resolved.packageName != expectedPackage) {
                    return AppLinkLaunchResult.PACKAGE_MISMATCH
                }
                resolved.appIntent
            }
        }

        val targetPackage = when (mode) {
            AppLinkLaunchMode.MARKETPLACE -> intent.`package`
            else -> resolved.packageName
        }

        if (mode == AppLinkLaunchMode.AUTOMATIC) {
            val (lastPackage, lastTs) = lastLaunch
            if (lastPackage != null && lastPackage == targetPackage &&
                clock.elapsedRealtime() < lastTs + cooldownMs
            ) {
                return AppLinkLaunchResult.COOLDOWN
            }
        }

        applyLaunchFlags(intent, mode)

        return try {
            startActivity(intent)
            lastLaunch = Pair(targetPackage, clock.elapsedRealtime())
            AppLinkLaunchResult.LAUNCHED
        } catch (e: ActivityNotFoundException) {
            logger.error("failed to start external app activity", e)
            AppLinkLaunchResult.FAILED
        } catch (e: SecurityException) {
            logger.error("not permitted to start external app activity", e)
            AppLinkLaunchResult.FAILED
        }
    }

    private fun applyLaunchFlags(intent: Intent, mode: AppLinkLaunchMode) {
        intent.flags = when (mode) {
            // NEW_DOCUMENT | MULTIPLE_TASK gives the app its own recents entry; NEW_TASK is
            // mandatory because every launch path now dispatches through the process-level
            // application context (AppLinkRuntime), and startActivity() from a non-Activity
            // context requires it.
            AppLinkLaunchMode.MANUAL ->
                Intent.FLAG_ACTIVITY_NEW_DOCUMENT or
                    Intent.FLAG_ACTIVITY_MULTIPLE_TASK or
                    Intent.FLAG_ACTIVITY_NEW_TASK
            AppLinkLaunchMode.AUTOMATIC ->
                Intent.FLAG_ACTIVITY_NEW_TASK
            AppLinkLaunchMode.MARKETPLACE ->
                Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
    }

    companion object {
        const val APP_LINKS_DO_NOT_INTERCEPT_INTERVAL = 2000L
    }
}
