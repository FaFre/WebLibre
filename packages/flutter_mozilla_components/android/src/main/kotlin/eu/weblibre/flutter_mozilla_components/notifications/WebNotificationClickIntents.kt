/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.notifications

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.core.content.IntentCompat
import eu.weblibre.flutter_mozilla_components.activities.NotificationActivity
import java.security.MessageDigest
import org.mozilla.geckoview.WebNotification

/**
 * The intent behind a web notification's tap and its action buttons, which
 * [ProfileWebNotifications] builds and [NotificationActivity] reads.
 *
 * AC builds the same intent with a request code from `SharedIdsHelper`, a
 * counter kept in a preferences file. A [eu.weblibre.flutter_mozilla_components.ProfileContext]
 * has a file of its own per profile, so two profiles hand out the same code,
 * and Android then keeps the first profile's extras for the second one's
 * notification: a tap would carry the wrong profile. Pending intents are told
 * apart by action, data and class, never by extras, so the identity is in the
 * data instead: the profile, the notification, its posting, the action button.
 *
 * The posting, because a site's replacement under the same tag is built while
 * the notification it replaces shows, and a posting can be built after its
 * replacement ([GeckoPostings]): with one pending intent for the tag, the
 * build of a posting that is never published would still refresh the extras
 * of the one that shows, and its tap would carry the wrong posting.
 */
internal object WebNotificationClickIntents {
    const val ACTION_CLICK = "eu.weblibre.webnotification.CLICK"
    const val EXTRA_PROFILE_ID = "eu.weblibre.webnotification.extra.PROFILE_ID"
    const val EXTRA_NOTIFICATION = "eu.weblibre.webnotification.extra.NOTIFICATION"
    const val EXTRA_ACTION_NAME = "eu.weblibre.webnotification.extra.ACTION_NAME"

    /**
     * The posting a tap was on, in the tap's intent and in the notification's
     * own extras, where [NotificationClickDelivery] reads what shows under a
     * tag ([ProfileWebNotifications.shown]).
     */
    const val EXTRA_INSTANCE = "eu.weblibre.webnotification.extra.INSTANCE"

    /**
     * A tap as [build] wrote it. [actionName] is null for the notification
     * itself; [instance] is null for a notification posted without one.
     */
    class Tap(
        val profileId: String,
        val notification: WebNotification,
        val actionName: String?,
        val instance: String?,
    )

    /**
     * The data that makes the pending intent of this posting ([instance]) and
     * button its own: no other build, also of the same tag, changes what its
     * tap carries.
     */
    fun dataFor(profileId: String, tag: String, origin: String, instance: String, actionName: String?): Uri {
        val digest = MessageDigest.getInstance("SHA-256")
            .digest("$tag\u0000$origin".toByteArray(Charsets.UTF_8))
            .toHexString()
        return Uri.Builder()
            .scheme("weblibre")
            .authority("web-notification")
            .appendPath(profileId)
            .appendPath(digest)
            .appendPath(instance)
            .apply { if (actionName != null) appendPath(actionName) }
            .build()
    }

    fun build(
        context: Context,
        profileId: String,
        notification: WebNotification,
        actionName: String?,
        instance: String,
    ): Intent = Intent(context, NotificationActivity::class.java).apply {
        action = ACTION_CLICK
        data = dataFor(profileId, notification.tag, notification.origin, instance, actionName)
        putExtra(EXTRA_PROFILE_ID, profileId)
        putExtra(EXTRA_NOTIFICATION, notification)
        putExtra(EXTRA_INSTANCE, instance)
        actionName?.let { putExtra(EXTRA_ACTION_NAME, it) }
    }

    /** The tap [intent] describes, or null for one that is not ours (a notification an older build posted). */
    fun parse(intent: Intent): Tap? {
        if (intent.action != ACTION_CLICK) return null
        val profileId = intent.getStringExtra(EXTRA_PROFILE_ID) ?: return null
        val notification = IntentCompat.getParcelableExtra(
            intent,
            EXTRA_NOTIFICATION,
            WebNotification::class.java,
        ) ?: return null
        return Tap(
            profileId,
            notification,
            intent.getStringExtra(EXTRA_ACTION_NAME),
            intent.getStringExtra(EXTRA_INSTANCE),
        )
    }
}
