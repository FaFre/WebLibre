/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.services

import android.content.Intent
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.base.crash.CrashReporting
import mozilla.components.feature.media.service.AbstractMediaSessionService
import mozilla.components.support.base.android.NotificationsDelegate
import mozilla.components.support.base.log.logger.Logger

/**
 * See [AbstractMediaSessionService].
 */
class MediaSessionService : AbstractMediaSessionService() {
    /**
     * Stops instead of crashing when the system restarts this service into a
     * process that has no committed profile.
     *
     * Android restarts foreground services after a process death, and the
     * replacement process has decided nothing yet. The service cannot bind a
     * profile on its own — the work it was doing belonged to whichever profile
     * was running before, and nothing in the restart intent says which — so the
     * only honest outcome is to stop and let the user retry.
     */
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (GlobalComponents.components == null) {
            Logger.warn("Stopping ${javaClass.simpleName}: no profile is committed")
            stopSelf(startId)
            return START_NOT_STICKY
        }

        return super.onStartCommand(intent, flags, startId)
    }

    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    override val crashReporter: CrashReporting? by lazy { null }
    override val store: BrowserStore by lazy { components.core.store }
    override val notificationsDelegate: NotificationsDelegate by lazy { components.notificationsDelegate }
}