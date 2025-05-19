package eu.weblibre.flutter_mozilla_components.services

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.base.crash.CrashReporting
import mozilla.components.feature.media.service.AbstractMediaSessionService
import mozilla.components.support.base.android.NotificationsDelegate

/**
 * See [AbstractMediaSessionService].
 */
class MediaSessionService : AbstractMediaSessionService() {
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    override val crashReporter: CrashReporting? by lazy { null }
    override val store: BrowserStore by lazy { components.core.store }
    override val notificationsDelegate: NotificationsDelegate by lazy { components.notificationsDelegate }
}