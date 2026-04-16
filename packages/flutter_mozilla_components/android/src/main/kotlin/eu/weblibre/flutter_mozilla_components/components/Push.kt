/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.components

import android.app.Activity
import eu.weblibre.flutter_mozilla_components.Components
import eu.weblibre.flutter_mozilla_components.push.WebPushEngineIntegration
import java.util.concurrent.atomic.AtomicBoolean
import org.ironfoxoss.unifiedpush.UnifiedPushFeature
import org.unifiedpush.android.connector.UnifiedPush

/**
 * Component group for web push services backed by UnifiedPush.
 */
class Push(
    private val components: Components,
) {
    private val initialized = AtomicBoolean(false)

    private val feature by lazy {
        UnifiedPushFeature(
            context = components.profileApplicationContext,
            disableRateLimit = true,
        )
    }

    private val webPushEngineIntegration by lazy {
        WebPushEngineIntegration(components.core.engine, feature)
    }

    fun initialize() {
        if (!initialized.compareAndSet(false, true)) {
            return
        }

        // Ensure the store-side WebNotificationFeature is installed before push events arrive.
        components.core.store
        webPushEngineIntegration.start()
        feature.initialize()
    }

    fun pickDistributor(activity: Activity, callback: (Boolean) -> Unit) {
        initialize()
        UnifiedPush.tryPickDistributor(activity) { success ->
            if (success) {
                feature.renewRegistration()
            }
            callback(success)
        }
    }
}
