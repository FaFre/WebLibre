/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.notifications

import android.os.Parcelable
import eu.weblibre.flutter_mozilla_components.pigeons.NotificationClickOutcome
import eu.weblibre.flutter_mozilla_components.notifications.PendingNotificationClicks.Click
import eu.weblibre.flutter_mozilla_components.notifications.PendingNotificationClicks.WindowContext

/**
 * Hands a tap Dart holds to Gecko (E12), after the checks only native can make
 * for certain: the tap still exists, it belongs to the profile this process
 * serves, its notification still shows, its storage is not restricted by a
 * freeze, and the routing this process installed is still the snapshot Dart
 * checked the storage's route against and carries its traffic.
 *
 * Gecko is the last place a restricted storage is refused (E2 keeps its
 * service worker down), but a click that reached it would be dropped without a
 * word and the notification gone, so it is refused here, where the tap can be
 * kept and the user told.
 *
 * A site can post another notification under the same tag while a tap waits,
 * and Gecko knows a notification by its tag: it would take the click for the
 * replacement, whose content the user never saw, and cancelling by tag would
 * take the replacement away. A tap is delivered only while the posting it was
 * tapped on ([Click.instance]) is the one Gecko was given last, as far as this
 * process heard ([GeckoPostings]), and still shows: Gecko holds a replacement
 * before Android shows it.
 *
 * The seams are what needs the engine or Android, so the rules are testable
 * without either.
 */
class NotificationClickDelivery(
    /** The profile the process's components serve; null while there are none. */
    private val servedProfileId: () -> String?,
    private val isRestricted: (String?) -> Boolean,
    /** The generation of the routing snapshot the extension acknowledged, null while it holds none. */
    private val installedRoutingGeneration: () -> Long?,
    /**
     * Whether the routing this process installed carries traffic of the
     * storage: directly, or through a proxy that is live or starting. The same
     * verdict a pane goes by before it wakes a tab.
     */
    private val routingCovers: (WindowContext) -> Boolean,
    /** What Android shows under a tag, null for nothing. */
    private val shown: (tag: String) -> Shown?,
    /** Whether Gecko holds a posting under a tag ([GeckoPostings.holds]); null when not known. */
    private val geckoHolds: (tag: String, instance: String) -> Boolean?,
    private val handToEngine: (engineNotification: Parcelable, action: String?) -> Unit,
    private val cancelNotification: (tag: String) -> Unit,
) {
    /** A notification Android shows. [instance] is its posting's ([Click.instance]), null for one posted without it. */
    class Shown(val instance: String?)

    /**
     * The oldest waiting tap, handed to Dart ([PendingNotificationClicks.take]).
     * One whose notification no longer shows ([isShowing]) is ended instead:
     * nothing would be delivered for it, so the user is not asked anything
     * about it either.
     */
    fun take(): Click? {
        while (true) {
            val click = PendingNotificationClicks.take() ?: return null
            if (isShowing(click)) return click
            PendingNotificationClicks.finish(click.id)
        }
    }

    /**
     * Hands the tap [clickId] to Gecko. [routingGeneration] is the routing
     * snapshot Dart found the storage's route in: its route, the container
     * that owns the storage and the routing can change while the tap waits
     * and while this call crosses over, and a snapshot installed since (a
     * container deleted, the user switched to a proxy) is one Dart never
     * checked, so the click waits for Dart to check again.
     */
    fun deliver(clickId: String, routingGeneration: Long): NotificationClickOutcome {
        val click = PendingNotificationClicks.handedOut(clickId) ?: return NotificationClickOutcome.NOT_FOUND
        val served = servedProfileId() ?: return NotificationClickOutcome.ENGINE_UNAVAILABLE
        if (served != click.profileId) {
            // Another profile's notification can never be answered here.
            PendingNotificationClicks.finish(clickId)
            return NotificationClickOutcome.NOT_FOUND
        }
        if (!isShowing(click)) {
            // Replaced or closed while the tap waited: the one showing now, if
            // any, is left alone.
            PendingNotificationClicks.finish(clickId)
            return NotificationClickOutcome.SUPERSEDED
        }
        if (isRestricted(click.contextId)) return NotificationClickOutcome.CONTEXT_RESTRICTED
        if (installedRoutingGeneration() != routingGeneration) return NotificationClickOutcome.ROUTING_CHANGED
        if (!routingCovers(click.window)) return NotificationClickOutcome.ROUTE_UNAVAILABLE

        // Before the click, so that an openWindow() the worker makes at once
        // already finds the click that explains it.
        PendingNotificationClicks.markDelivered(click)
        try {
            handToEngine(click.engineNotification, click.action)
        } catch (error: Throwable) {
            // Gecko never got it: no window may open in its name, and the tap
            // is Dart's again, which releases it on the error and leaves the
            // notification.
            PendingNotificationClicks.unmarkDelivered(click)
            throw error
        }
        // As Android's auto cancel did for AC's notification: a tap on the
        // notification takes it away, one of its buttons (Reply, Mark as read)
        // leaves it.
        if (click.action == null) cancelIfShowing(click)
        return NotificationClickOutcome.DELIVERED
    }

    /**
     * Ends the tap Dart holds under [clickId] without delivering it: the user
     * declined to resume its storage, or the storage is being deleted. The
     * notification stays showing, so it can be tapped again, unless
     * [dismissNotification] says there is nothing left for it to open.
     *
     * Another profile's tap is only dropped: its notification is not ours to
     * touch, and neither is a notification that replaced the tapped one.
     */
    fun release(clickId: String, dismissNotification: Boolean) {
        val click = PendingNotificationClicks.handedOut(clickId) ?: return
        PendingNotificationClicks.finish(clickId)
        if (dismissNotification && servedProfileId() == click.profileId) {
            cancelIfShowing(click)
        }
    }

    /**
     * Whether the posting [click] was tapped on is still the one Gecko holds
     * and Android shows. Not so, it was replaced under its tag (Gecko holds the
     * replacement first), closed by its site, or taken away by an earlier tap.
     * A tap on a notification posted without an instance cannot be told apart
     * from a replacement and counts as showing.
     */
    private fun isShowing(click: Click): Boolean {
        val instance = click.instance ?: return true
        if (geckoHolds(click.tag, instance) == false) return false
        return shown(click.tag)?.instance == instance
    }

    /** Cancels [click]'s notification, unless another posting replaced it under its tag. */
    private fun cancelIfShowing(click: Click) {
        val showing = shown(click.tag) ?: return
        if (click.instance == null || showing.instance == click.instance) cancelNotification(click.tag)
    }
}
