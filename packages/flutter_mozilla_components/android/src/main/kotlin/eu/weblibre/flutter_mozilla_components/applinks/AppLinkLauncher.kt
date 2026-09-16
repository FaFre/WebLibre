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
 * - [AUTHENTICATION]: same-caller Custom Tab / ActionView callback — `NEW_TASK | CLEAR_TOP` so the
 *   originating app can resume its existing task. Not a user gesture, so it takes the same 2 s
 *   cooldown as [AUTOMATIC] (AC applies its loop-breaker to authentication flows too).
 * - [MARKETPLACE]: install-app fallback — `NEW_TASK | CLEAR_TASK`.
 */
enum class AppLinkLaunchMode {
    MANUAL,
    AUTOMATIC,
    AUTHENTICATION,
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
 * expected package before `startActivity` (§2.7). Automatic and authentication launches honour a 2 s
 * same-package cooldown to break app→browser→app ping-pong loops (§2.4); manual and prompt-resolved
 * opens are user gestures that bypass the check but still record it.
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
                if (expectedPackage != null &&
                    (resolved.isAmbiguous || resolved.packageName != expectedPackage)
                ) {
                    // Ambiguity counts as a mismatch even when the expected package is still the
                    // first candidate. A remembered `alwaysOpen` names one app; if a second handler
                    // has since appeared, honouring the rule would raise a chooser offering the
                    // other one — which is not what the user agreed to. §2.5 sends that back to a
                    // prompt instead.
                    return AppLinkLaunchResult.PACKAGE_MISMATCH
                }
                resolved.appIntent
            }
        }

        val targetPackage = when (mode) {
            AppLinkLaunchMode.MARKETPLACE -> intent.`package`
            else -> resolved.packageName
        }

        if (mode == AppLinkLaunchMode.AUTOMATIC || mode == AppLinkLaunchMode.AUTHENTICATION) {
            val (lastPackage, lastTs) = lastLaunch
            if (lastPackage != null && lastPackage == targetPackage &&
                clock.elapsedRealtime() < lastTs + cooldownMs
            ) {
                return AppLinkLaunchResult.COOLDOWN
            }
        }

        // The mode's flags belong to the intent that reaches the app, so they are applied before
        // any chooser is wrapped around it. Putting them on the chooser instead would give the
        // chooser activity the separate-document/task treatment a manual open is asking for and
        // leave the app itself without it.
        applyLaunchFlags(intent, mode)
        val launchIntent = chooserIfUnbound(intent, resolved, mode)

        return try {
            startActivity(launchIntent)
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

    /**
     * Send an unbound intent through an explicit chooser that cannot offer WebLibre or any other
     * browser, instead of letting `startActivity` resolve it implicitly.
     *
     * An ambiguous resolution deliberately leaves the component unbound so the user picks the app.
     * Handing that to `startActivity` does not ask anyone: for an http(s) target it resolves like
     * any ordinary web link and lands on the default browser — which, for this app's users, is
     * usually WebLibre. The link would then reopen the browser it was trying to leave, and under
     * `always` the original navigation is denied as well, because relaunching ourselves counts as a
     * successful launch. Filtering browsers out of the candidate list during discovery does not
     * prevent this; it never constrained the intent that is actually started.
     *
     * A bound intent already names its target, and a marketplace intent names its package, so both
     * are started as they are.
     */
    private fun chooserIfUnbound(
        intent: Intent,
        resolved: ResolvedAppLink,
        mode: AppLinkLaunchMode,
    ): Intent {
        if (mode == AppLinkLaunchMode.MARKETPLACE) return intent
        // `isAmbiguous` is the resolver saying it deliberately left the component unbound; every
        // other resolution names its target and resolves to nothing else.
        if (!resolved.isAmbiguous) return intent

        return Intent.createChooser(intent, null).apply {
            val excluded = resolved.excludedComponents
            if (excluded.isNotEmpty()) {
                putExtra(Intent.EXTRA_EXCLUDE_COMPONENTS, excluded.toTypedArray())
            }
            // The chooser's own requirement, and the only flag it needs: every launch here goes
            // through the process-level application context. The target keeps the mode's flags,
            // which were applied to it before this wrapping.
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
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
            AppLinkLaunchMode.AUTHENTICATION ->
                Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            AppLinkLaunchMode.MARKETPLACE ->
                Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
    }

    companion object {
        const val APP_LINKS_DO_NOT_INTERCEPT_INTERVAL = 2000L
    }
}
