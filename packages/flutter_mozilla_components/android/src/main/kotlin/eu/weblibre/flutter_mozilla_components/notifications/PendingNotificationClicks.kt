/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.notifications

import android.os.Parcelable
import androidx.annotation.VisibleForTesting
import java.util.UUID

/**
 * The web-notification taps that [NotificationActivity] accepted and Dart has
 * not delivered yet, and the window a delivered tap leaves open for the
 * service worker it woke ([takeWindow]).
 *
 * Kept in this process rather than on the intent that opens WebLibre: the
 * browser activity is exported, so an extra any app can send must never be
 * what chooses the notification Gecko is told was clicked. Dart takes a tap
 * once it runs and whenever WebLibre comes to the front, and answers with the
 * id native gave it, which no other app can guess.
 *
 * A tap goes through three states: *waiting* (parked by the activity),
 * *handed out* (Dart has it and decides) and gone (delivered or released).
 */
object PendingNotificationClicks {
    /**
     * A tapped notification. [instance] names the posting it was tapped on
     * ([ProfileWebNotifications] makes one per notification it shows, also
     * for a site's replacement under the same tag); null for one posted
     * without it. [contextId] is null for the default storage; [private] is
     * whether it came from a private tab.
     */
    class Click(
        val id: String,
        val profileId: String,
        val tag: String,
        val instance: String?,
        val contextId: String?,
        val private: Boolean,
        val action: String?,
        val engineNotification: Parcelable,
    ) {
        val window get() = WindowContext(contextId, private)

        /** Whether [other] is this tap again: the same button of the same posting. */
        fun isRepeatOf(other: Click) =
            profileId == other.profileId && tag == other.tag && instance == other.instance && action == other.action
    }

    /**
     * A storage a service worker's `openWindow()` opens its page in: a session
     * context and private mode. [contextId] is null for the default storage,
     * which is a context like any other, not "unknown".
     */
    data class WindowContext(val contextId: String?, val private: Boolean)

    private class Delivered(val clickId: String, val window: WindowContext, val atMillis: Long)

    /** How long after its delivery a click lets its service worker open a window. */
    const val WINDOW_MILLIS = 60_000L

    /** How many taps are kept at once, waiting and handed out together: a tap past it drops the oldest. */
    private const val MAX_PARKED = 8

    @Volatile
    @VisibleForTesting
    internal var now: () -> Long = { System.nanoTime() / 1_000_000 }

    private val waiting = ArrayDeque<Click>()
    private val handedOut = LinkedHashMap<String, Click>()
    private val delivered = ArrayList<Delivered>()

    fun newId(): String = UUID.randomUUID().toString()

    /**
     * Parks [click] for Dart, unless the same tap waits or is handed out
     * already ([Click.isRepeatOf]); returns whether it was parked. Its
     * notification stays showing until the first one is delivered, which can
     * take a while (a routing wait, the startup cleanup, a Resume dialog), and
     * a second tap meanwhile would run the site's handler twice and open a
     * second window.
     *
     * Only the newest few are kept, and never at the cost of [click]: the
     * oldest goes, except the tap Dart took last. Dart delivers one at a time,
     * so that one may be the tap it is working on (waiting for the user to
     * answer "Resume and open?", say), and only the ones it took before it
     * can be lost. A handed-out tap is older than any waiting one (Dart takes
     * them oldest first), and one Dart has held that long is most likely one
     * it lost. Dart's later answer for it finds nothing
     * ([eu.weblibre.flutter_mozilla_components.pigeons.NotificationClickOutcome.NOT_FOUND]), and its notification
     * stays showing.
     */
    @Synchronized
    fun park(click: Click): Boolean {
        if (waiting.any { it.isRepeatOf(click) } || handedOut.values.any { it.isRepeatOf(click) }) return false
        waiting.addLast(click)
        while (waiting.size + handedOut.size > MAX_PARKED) {
            // With one handed out at most, the waiting ones are more than
            // MAX_PARKED, so the first of them is never [click].
            if (handedOut.size > 1) handedOut.remove(handedOut.keys.first()) else waiting.removeFirst()
        }
        return true
    }

    /** The oldest waiting tap, handed to Dart: it stays claimable by its id until [finish]. */
    @Synchronized
    fun take(): Click? = waiting.removeFirstOrNull()?.also { handedOut[it.id] = it }

    /** The tap Dart holds under [id], still held. Null once it was finished, or for an id native never gave out. */
    @Synchronized
    fun handedOut(id: String): Click? = handedOut[id]

    /** Ends the tap [id]. */
    @Synchronized
    fun finish(id: String) {
        handedOut.remove(id)
    }

    /** Remembers that [click] was handed to Gecko, so its service worker may open a window. */
    @Synchronized
    fun markDelivered(click: Click) {
        delivered.removeAll { expired(it) }
        delivered.add(Delivered(click.id, click.window, now()))
        handedOut.remove(click.id)
    }

    /**
     * Takes back [markDelivered] for [click], which never reached Gecko: no
     * window may open for it, and Dart holds the tap again, to release it.
     */
    @Synchronized
    fun unmarkDelivered(click: Click) {
        delivered.removeAll { it.clickId == click.id }
        handedOut[click.id] = click
    }

    /**
     * Whether a delivered click explains a service worker's `openWindow()` in
     * [window], the storage Gecko says the worker runs in: one of that same
     * storage and private mode, which it uses up. Each delivered click
     * authorises one window, and only in its own storage, so a click whose
     * handler opens no window (it only marks a message read) holds no other
     * storage's window back.
     *
     * Gecko only lets a service worker open a window while it handles a
     * notification click, and the only clicks it is given are the ones
     * delivered here; this keeps it that way.
     */
    @Synchronized
    fun takeWindow(window: WindowContext): Boolean {
        delivered.removeAll { expired(it) }
        val index = delivered.indexOfFirst { it.window == window }
        if (index < 0) return false
        delivered.removeAt(index)
        return true
    }

    private fun expired(entry: Delivered) = now() - entry.atMillis > WINDOW_MILLIS

    @Synchronized
    @VisibleForTesting
    internal fun resetForTest() {
        waiting.clear()
        handedOut.clear()
        delivered.clear()
        now = { System.nanoTime() / 1_000_000 }
    }
}
