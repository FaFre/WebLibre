/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.notifications

import mozilla.components.browser.engine.gecko.GeckoEngineSession
import mozilla.components.browser.state.state.SessionState
import mozilla.components.concept.engine.Settings
import mozilla.components.feature.tabs.TabsUseCases
import mozilla.components.support.base.log.logger.Logger
import org.mozilla.geckoview.GeckoResult
import org.mozilla.geckoview.GeckoRuntime
import org.mozilla.geckoview.GeckoSession
import org.mozilla.geckoview.GeckoSessionSettings

/**
 * Gives a service worker's `clients.openWindow()` a tab: what a site's
 * `notificationclick` handler usually does with a tap.
 *
 * Not AC's `registerServiceWorkerDelegate`: the tab has to be marked as a
 * service worker's window ([ServiceWorkerWindows]) for the tab added event.
 * The page opens in the storage Gecko says the worker runs in, its session
 * context and private mode (WebLibre's GeckoView patch), so a container's
 * page keeps its container's proxy route and isolation, and a private one
 * stays out of history and the restored session. Only for a notification
 * click delivered in that same storage ([PendingNotificationClicks.takeWindow]),
 * and nowhere when Gecko does not say the storage: refusing makes the site's
 * `openWindow()` fail, which is better than a page in a guessed identity.
 *
 * [openWindow] is the part that needs a Gecko runtime, so the decision can be
 * tested without one.
 */
class WebLibreServiceWorkerDelegate(
    private val openWindow: (PendingNotificationClicks.WindowContext) -> GeckoSession?,
) : GeckoRuntime.ServiceWorkerDelegate {
    private val logger = Logger("WebLibreServiceWorkerDelegate")

    constructor(
        runtime: GeckoRuntime,
        engineSettings: Settings?,
        tabs: () -> TabsUseCases,
    ) : this(
        openWindow = { window ->
            val settings = GeckoSessionSettings.Builder()
                .usePrivateMode(window.private)
                .contextId(window.contextId)
                .build()
            val geckoSession = GeckoSession(settings)
            val engineSession = GeckoEngineSession(
                runtime = runtime,
                privateMode = window.private,
                defaultSettings = engineSettings,
                contextId = window.contextId,
                geckoSessionProvider = { geckoSession },
                openGeckoSession = false,
            )
            ServiceWorkerWindows.mark(engineSession)
            // The worker loads its page through the session, so no URL here
            // and no navigation of ours.
            tabs().addTab(
                selectTab = true,
                contextId = window.contextId,
                engineSession = engineSession,
                source = SessionState.Source.Internal.None,
                private = window.private,
            )
            geckoSession
        },
    )

    /** Only called without the worker's storage, which is never guessed. */
    override fun onOpenWindow(url: String): GeckoResult<GeckoSession> {
        logger.warn("A service worker asked to open a window without saying its storage; refused")
        return GeckoResult.fromValue(null)
    }

    override fun onOpenWindow(
        url: String,
        sessionContextId: String?,
        privateBrowsing: Boolean,
    ): GeckoResult<GeckoSession> {
        val window = PendingNotificationClicks.WindowContext(sessionContextId, privateBrowsing)
        if (!PendingNotificationClicks.takeWindow(window)) {
            logger.warn("A service worker asked to open a window with no notification click of its storage; refused")
            return GeckoResult.fromValue(null)
        }
        return GeckoResult.fromValue(openWindow(window))
    }
}
