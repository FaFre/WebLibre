/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.api

import android.content.Context
import androidx.core.app.NotificationManagerCompat
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.feature.ContainerProxyFeature
import eu.weblibre.flutter_mozilla_components.lifecycle.TabLifecycleRegistry
import eu.weblibre.flutter_mozilla_components.notifications.GeckoPostings
import eu.weblibre.flutter_mozilla_components.notifications.NotificationClickDelivery
import eu.weblibre.flutter_mozilla_components.notifications.ProfileWebNotifications
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoPushApi
import eu.weblibre.flutter_mozilla_components.pigeons.NotificationClickHandoff
import eu.weblibre.flutter_mozilla_components.pigeons.NotificationClickOutcome
import eu.weblibre.flutter_mozilla_components.pigeons.PushStatus
import eu.weblibre.flutter_mozilla_components.pigeons.PushSubscription
import eu.weblibre.flutter_mozilla_components.push.toPigeon
import eu.weblibre.flutter_mozilla_components.split.installedRoutingCovers
import eu.weblibre.flutter_mozilla_components.startup.LaunchRouting
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.async
import kotlinx.coroutines.cancel
import kotlinx.coroutines.withContext

/**
 * UnifiedPush distributor management for the settings UI, and the taps on web
 * notifications. [context] is the app's: its notifications are the app's, not
 * a profile's.
 */
class GeckoPushApiImpl(context: Context) : GeckoPushApi {
    private val notificationManager = NotificationManagerCompat.from(context)

    private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    private val push
        get() = requireNotNull(GlobalComponents.components) { "Components not initialized" }.push

    override suspend fun getPushStatus(): PushStatus = inScope {
        withContext(Dispatchers.IO) { push.status() }.toPigeon()
    }

    override suspend fun setDistributor(packageName: String) {
        inScope { withContext(Dispatchers.IO) { push.setDistributor(packageName) } }
    }

    override suspend fun removeDistributor() {
        inScope { withContext(Dispatchers.IO) { push.removeDistributor() } }
    }

    override suspend fun renewRegistration() {
        inScope { withContext(Dispatchers.IO) { push.renewRegistration() } }
    }

    override suspend fun suspendPushForRestart() {
        inScope { withContext(Dispatchers.IO) { push.suspendForRestart() } }
    }

    override suspend fun getSubscriptions(): List<PushSubscription> = inScope {
        withContext(Dispatchers.IO) {
            push.subscriptions().map {
                PushSubscription(scope = it.scope, hasEndpoint = it.hasEndpoint)
            }
        }
    }

    override fun takeNotificationClick(): NotificationClickHandoff? =
        notificationClickDelivery().take()?.let {
            NotificationClickHandoff(clickId = it.id, contextId = it.contextId, private = it.private)
        }

    override suspend fun deliverNotificationClick(
        clickId: String,
        routingGeneration: Long,
    ): NotificationClickOutcome = inScope {
        notificationClickDelivery().deliver(clickId, routingGeneration)
    }

    override fun releaseNotificationClick(clickId: String, dismissNotification: Boolean) {
        notificationClickDelivery().release(clickId, dismissNotification)
    }

    private fun notificationClickDelivery(): NotificationClickDelivery {
        val components = GlobalComponents.components
        return NotificationClickDelivery(
            servedProfileId = { components?.profileApplicationContext?.profileId },
            isRestricted = TabLifecycleRegistry::isRestricted,
            installedRoutingGeneration = ContainerProxyFeature::acknowledgedSnapshotGeneration,
            routingCovers = { window ->
                installedRoutingCovers(LaunchRouting.contextIdFor(window.contextId, window.private))
            },
            shown = { tag -> ProfileWebNotifications.shown(notificationManager, tag) },
            geckoHolds = GeckoPostings::holds,
            handToEngine = { notification, action ->
                requireNotNull(components).core.engine.handleWebNotificationClick(notification, action)
            },
            cancelNotification = { tag ->
                notificationManager.cancel(tag, ProfileWebNotifications.NOTIFICATION_ID)
            },
        )
    }

    /** Runs [block] in [coroutineScope] rather than the caller's coroutine, so [dispose] cancels it. */
    private suspend fun <T> inScope(block: suspend () -> T): T =
        coroutineScope.async { block() }.await()

    fun dispose() {
        coroutineScope.cancel()
    }
}
