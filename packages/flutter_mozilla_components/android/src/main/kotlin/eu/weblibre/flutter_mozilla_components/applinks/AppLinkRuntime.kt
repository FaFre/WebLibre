/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import android.content.Context

/**
 * Process-level holder for the shared [ExternalAppResolver] and [AppLinkLauncher]
 * (APP_LINKS_OWN_IMPLEMENTATION_PLAN.md §2.7). Neither is profile-scoped — they wrap the
 * `PackageManager` and `startActivity`, both application-global.
 *
 * A single shared launcher is important: its 2 s same-package auto-launch cooldown
 * (§2.4 loop breaker) must be observed across *every* launch path — the synchronous
 * interceptor tail ([WebLibreAppLinksInterceptor]), the manual "Open in <App>" entry points
 * (`GeckoAppLinksApiImpl.launchAppLink`), and prompt resolution. If each site built its own
 * launcher the cooldown would be per-instance and the ping-pong defence would break.
 */
object AppLinkRuntime {
    @Volatile
    private var holder: Holder? = null

    fun get(context: Context): Holder {
        return holder ?: synchronized(this) {
            holder ?: Holder(context.applicationContext).also { holder = it }
        }
    }

    class Holder(appContext: Context) {
        val resolver: ExternalAppResolver = ExternalAppResolver(AndroidPackageResolver(appContext))
        val launcher: AppLinkLauncher = AppLinkLauncher(
            resolver = resolver,
            startActivity = { intent -> appContext.startActivity(intent) },
        )
    }
}
