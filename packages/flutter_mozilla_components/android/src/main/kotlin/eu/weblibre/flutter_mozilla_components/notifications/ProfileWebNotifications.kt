/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.notifications

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.graphics.Bitmap
import android.os.Bundle
import androidx.annotation.DrawableRes
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import java.util.UUID
import kotlin.coroutines.CoroutineContext
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import mozilla.components.browser.icons.BrowserIcons
import mozilla.components.browser.icons.Icon.Source
import mozilla.components.browser.icons.IconRequest
import mozilla.components.browser.icons.IconRequest.Size
import mozilla.components.concept.engine.permission.SitePermissionsStorage
import mozilla.components.concept.engine.webnotifications.WebNotification
import mozilla.components.concept.engine.webnotifications.WebNotificationDelegate
import mozilla.components.support.base.android.NotificationsDelegate
import mozilla.components.support.base.log.logger.Logger
import mozilla.components.support.ktx.kotlin.getOrigin
import mozilla.components.support.ktx.kotlin.tryGetHostFromUrl
import mozilla.components.feature.webnotifications.R as WebNotificationsR
import org.mozilla.geckoview.WebNotification as GeckoWebNotification

/**
 * Shows a site's notification, as AC's `WebNotificationFeature` does, with a
 * tap that can reach Gecko again.
 *
 * AC's feature points the tap at an activity with extras it builds itself
 * (`NativeNotificationBridge`, internal, no hook): they name no profile, and
 * their request codes collide between profiles (see
 * [WebNotificationClickIntents]). A tap in a process that serves another
 * profile, or none, then cannot tell whether the notification is its own.
 * This delegate keeps AC's behaviour (site permission check, channel, title,
 * body, sub text, icon, silent flag, action buttons, replacing a notification
 * of the same tag) and changes only what a tap carries, and that it is not
 * cancelled by Android: it is cancelled once the click reached Gecko, so a tap
 * the process could not answer leaves it showing. Each notification it shows
 * gets an instance of its own, also a site's replacement under the same tag,
 * so a tap that waited is not delivered for a replacement ([shown]).
 */
class ProfileWebNotifications(
    private val context: Context,
    private val profileId: String?,
    private val browserIcons: BrowserIcons,
    @param:DrawableRes private val smallIcon: Int,
    private val sitePermissionsStorage: SitePermissionsStorage,
    private val notificationsDelegate: NotificationsDelegate,
    private val coroutineContext: CoroutineContext = Dispatchers.IO,
) : WebNotificationDelegate {
    private val logger = Logger("ProfileWebNotifications")

    override fun onShowNotification(webNotification: WebNotification): Deferred<Boolean> {
        val deferred = CompletableDeferred<Boolean>()
        val tag = webNotification.tag
        val notificationManager = notificationsDelegate.notificationManagerCompat
        // Here, as Gecko replaces what it holds under the tag, not once Android
        // shows it: see [GeckoPostings].
        val instance = UUID.randomUUID().toString()
        GeckoPostings.shown(tag, instance)

        // What AC tells Gecko of this posting goes by the tag, and a GeckoView
        // without the notification posting patch takes it for whatever posting
        // it holds there: a dismissal of one it replaced would close the
        // replacement. A replaced one is reported shown, which changes nothing
        // (Gecko finished it when it replaced it, and the patch drops it).
        fun superseded() {
            deferred.complete(true)
        }

        fun notShown() {
            val current = GeckoPostings.withdraw(tag, instance) { notificationManager.cancel(tag, NOTIFICATION_ID) }
            if (current) deferred.complete(false) else superseded()
        }
        CoroutineScope(coroutineContext).launch {
            try {
                if (!isAllowed(webNotification)) {
                    notShown()
                    return@launch
                }

                ensureChannelExists()
                val notification = convertToAndroidNotification(webNotification, instance)

                val published = GeckoPostings.publishIfCurrent(tag, instance) {
                    notificationManager.cancel(tag, NOTIFICATION_ID)
                    notificationsDelegate.notify(
                        tag,
                        NOTIFICATION_ID,
                        notification,
                        onPermissionGranted = { deferred.complete(true) },
                        onPermissionRejected = {
                            logger.info("Web notification not shown: Android's notification permission was declined")
                            notShown()
                        },
                    )
                }
                // Gecko replaced it while it was being built: the replacement is
                // published instead.
                if (!published) superseded()
            } catch (error: Throwable) {
                logger.error("Could not show the notification $tag", error)
                notShown()
            }
        }
        return deferred
    }

    override fun onCloseNotification(webNotification: WebNotification) {
        GeckoPostings.closed(webNotification.tag)
        notificationsDelegate.notificationManagerCompat.cancel(webNotification.tag, NOTIFICATION_ID)
    }

    /**
     * Only a page's notification needs its site's permission; a web
     * extension's is covered by the permissions its user approved on install.
     * A private tab's page gets none: Gecko already refuses it the permission
     * (`dom.webnotifications.privateBrowsing.enabled`, off in the engine
     * baseline), and it would not get past the lookup either, since AC never
     * stores a private grant.
     */
    private suspend fun isAllowed(webNotification: WebNotification): Boolean {
        if (webNotification.triggeredByWebExtension) return true
        // Every refusal says why, and none names the site or the tag: a page's
        // notification that never shows is otherwise indistinguishable from one
        // that was never posted.
        if (webNotification.privateBrowsing) {
            logger.info("Web notification not shown: private browsing shows no site notifications")
            return false
        }
        val origin = webNotification.sourceUrl?.getOrigin()
        if (origin == null) {
            logger.info("Web notification not shown: it has no source origin")
            return false
        }
        val permissions = sitePermissionsStorage.findSitePermissionsBy(origin, private = false)
        if (permissions == null) {
            logger.info("Web notification not shown: no site permission is stored for its origin")
            return false
        }
        if (!permissions.notification.isAllowed()) {
            logger.info(
                "Web notification not shown: the site's notification permission is ${permissions.notification}",
            )
            return false
        }
        return true
    }

    private fun ensureChannelExists() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            context.getString(WebNotificationsR.string.mozac_feature_notification_channel_name),
            NotificationManager.IMPORTANCE_DEFAULT,
        )
        channel.setShowBadge(true)
        channel.lockscreenVisibility = NotificationCompat.VISIBILITY_PRIVATE
        notificationsDelegate.notificationManagerCompat.createNotificationChannel(channel)
    }

    private suspend fun convertToAndroidNotification(webNotification: WebNotification, instance: String): Notification {
        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
        // With no profile or no engine notification nothing could be answered:
        // its tap only opens WebLibre (below).
        val gecko = webNotification.engineNotification as? GeckoWebNotification

        with(webNotification) {
            if (profileId != null && gecko != null) {
                builder
                    .setContentIntent(tapIntent(profileId, gecko, actionName = null, instance))
                    // Cancelled once Gecko was given the click, not by
                    // Android: see the class comment.
                    .setAutoCancel(false)
                    .addExtras(Bundle().apply { putString(WebNotificationClickIntents.EXTRA_INSTANCE, instance) })
                for (browserAction in actions) {
                    builder.addAction(
                        NotificationCompat.Action.Builder(
                            0,
                            browserAction.title,
                            tapIntent(profileId, gecko, browserAction.name, instance),
                        ).build(),
                    )
                }
            } else {
                // Nothing could be answered: a tap opens WebLibre and takes the
                // notification away, as AC's did, rather than doing nothing.
                openAppIntent()?.let(builder::setContentIntent)
                builder.setAutoCancel(true)
            }

            builder
                .setSmallIcon(smallIcon)
                .setContentTitle(title)
                .setShowWhen(true)
                .setWhen(timestamp)
                .setSilent(silent)

            sourceUrl?.let { builder.setSubText(it.tryGetHostFromUrl()) }

            body?.let {
                builder.setContentText(it).setStyle(NotificationCompat.BigTextStyle().bigText(it))
            }

            loadIcon(sourceUrl, iconUrl)?.let { builder.setLargeIcon(it) }
        }

        return builder.build()
    }

    /** The posting's own pending intent (see [WebNotificationClickIntents]), not one another build refreshes. */
    private fun tapIntent(
        profileId: String,
        gecko: GeckoWebNotification,
        actionName: String?,
        instance: String,
    ): PendingIntent =
        PendingIntent.getActivity(
            context,
            0,
            WebNotificationClickIntents.build(context, profileId, gecko, actionName, instance),
            PendingIntent.FLAG_IMMUTABLE,
        )

    private fun openAppIntent(): PendingIntent? =
        context.packageManager.getLaunchIntentForPackage(context.packageName)?.let {
            PendingIntent.getActivity(context, 0, it, PendingIntent.FLAG_IMMUTABLE)
        }

    private suspend fun loadIcon(url: String?, iconUrl: String?): Bitmap? {
        url ?: return null
        iconUrl ?: return null
        val icon = browserIcons.loadIcon(
            IconRequest(
                url = url,
                size = Size.DEFAULT,
                resources = listOf(
                    IconRequest.Resource(
                        url = iconUrl,
                        type = IconRequest.Resource.Type.MANIFEST_ICON,
                    ),
                ),
                isPrivate = true,
            ),
        ).await()
        return if (icon.source == Source.GENERATOR) null else icon.bitmap
    }

    companion object {
        /** AC's channel, so the user's settings for site notifications carry over. */
        const val CHANNEL_ID = "mozac.feature.webnotifications.generic.channel"

        /** Paired with the page's tag; AC's id, so a notification an older build posted is replaced, not doubled. */
        const val NOTIFICATION_ID = 1

        /**
         * The site notification Android shows under [tag], with the instance
         * this delegate gave it; null when none shows. Every profile's
         * notifications are the app's, so one of another profile under the
         * same tag (which replaced this one's on screen) is what shows.
         */
        fun shown(notificationManager: NotificationManagerCompat, tag: String): NotificationClickDelivery.Shown? =
            notificationManager.activeNotifications
                .firstOrNull { it.id == NOTIFICATION_ID && it.tag == tag }
                ?.let {
                    NotificationClickDelivery.Shown(
                        it.notification.extras.getString(WebNotificationClickIntents.EXTRA_INSTANCE),
                    )
                }
    }
}
