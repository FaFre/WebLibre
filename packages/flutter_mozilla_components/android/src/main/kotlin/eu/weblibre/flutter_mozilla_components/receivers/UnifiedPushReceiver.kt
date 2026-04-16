/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.receivers

import android.content.Context
import android.content.Intent
import android.util.Log
import eu.weblibre.flutter_mozilla_components.ActiveProfile
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import org.ironfoxoss.unifiedpush.PushError
import org.ironfoxoss.unifiedpush.UnifiedPushProcessor
import org.unifiedpush.android.connector.FailedReason
import org.unifiedpush.android.connector.MessagingReceiver
import org.unifiedpush.android.connector.data.PushEndpoint
import org.unifiedpush.android.connector.data.PushMessage

class UnifiedPushReceiver : MessagingReceiver() {
    companion object {
        private const val TAG = "UnifiedPushReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        ActiveProfile.resolveFromDisk(context.applicationContext)

        if (GlobalComponents.components == null &&
            !GlobalComponents.ensureExternalComponents(context.applicationContext)
        ) {
            Log.e(TAG, "Unable to initialize components for UnifiedPush delivery")
            return
        }

        GlobalComponents.components?.push?.initialize()

        if (GlobalComponents.components == null) {
            Log.e(TAG, "UnifiedPush delivery aborted because components are unavailable")
            return
        }

        super.onReceive(context, intent)
    }

    override fun onMessage(context: Context, message: PushMessage, instance: String) {
        UnifiedPushProcessor.requireInstance.onMessage(
            scope = instance,
            message = message,
        )
    }

    override fun onNewEndpoint(context: Context, endpoint: PushEndpoint, instance: String) {
        UnifiedPushProcessor.requireInstance.onNewEndpoint(
            scope = instance,
            newEndpoint = endpoint,
        )
    }

    override fun onRegistrationFailed(context: Context, reason: FailedReason, instance: String) {
        UnifiedPushProcessor.requireInstance.onError(reason.toPushError())
    }

    override fun onUnregistered(context: Context, instance: String) {
        UnifiedPushProcessor.requireInstance.onUnregistered(scope = instance)
    }

    private fun FailedReason.toPushError(): PushError {
        return when (this) {
            FailedReason.NETWORK -> PushError.Network("Push service needs network to register")
            FailedReason.INTERNAL_ERROR -> PushError.ServiceUnavailable("Unknown error")
            FailedReason.ACTION_REQUIRED ->
                PushError.ServiceUnavailable("Push service waits for a user action")
            FailedReason.VAPID_REQUIRED -> PushError.Registration("Push service requires VAPID")
        }
    }
}
