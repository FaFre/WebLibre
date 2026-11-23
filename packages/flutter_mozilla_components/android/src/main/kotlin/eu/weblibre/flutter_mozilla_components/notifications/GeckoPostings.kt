/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.notifications

import androidx.annotation.VisibleForTesting

/**
 * The posting Gecko holds under each tag, as far as this process heard of it.
 *
 * Gecko replaces its own notification of a tag at once and tells the delegate
 * on the UI thread ([ProfileWebNotifications.onShowNotification]); Android
 * shows the replacement only after the site permission check and the icon,
 * which can take seconds. A tap on the earlier posting in between still finds
 * it on screen, while Gecko, which knows a notification by its tag, would take
 * the click for the replacement. This is what Gecko was given last.
 *
 * It also decides what Android shows: a posting is published only while it is
 * the one Gecko holds ([publishIfCurrent]). The delegate builds each one on a
 * background thread, the icon included, so an earlier posting can be ready
 * after its replacement; published last, it would cover the replacement with
 * a notification Gecko no longer holds, whose tap the delivery refuses.
 *
 * In memory: a process that started after a posting heard nothing of it, and
 * Android's notification is all there is to go by then; a tap on the posting
 * that shows is delivered. What Gecko stored for it can be an earlier posting:
 * Gecko stores a replacement once it was published here and reported shown,
 * and a process that ended in between has the posting it replaced stored
 * still. The notification posting patch stores the posting with it and
 * matches the click to it, so the earlier posting's click is not dispatched
 * (Gecko opens the site, as for a notification it has nothing stored for). A
 * closed posting is forgotten: Android's is cancelled with it.
 */
internal object GeckoPostings {
    private val instances = HashMap<String, String>()

    /** Gecko holds the posting [instance] under [tag] now. */
    @Synchronized
    fun shown(tag: String, instance: String) {
        instances[tag] = instance
    }

    /** Gecko closed what it held under [tag]. */
    @Synchronized
    fun closed(tag: String) {
        instances.remove(tag)
    }

    /**
     * Runs [publish] (posting the notification to Android) if [instance] is
     * still the posting Gecko holds under [tag], and returns whether it ran.
     * Under the same lock as [shown], so a replacement Gecko is given meanwhile
     * is published after it, over it, and never under it.
     */
    @Synchronized
    fun publishIfCurrent(tag: String, instance: String, publish: () -> Unit): Boolean {
        if (instances[tag] != instance) return false
        publish()
        return true
    }

    /**
     * Forgets [instance], which could not be shown (no permission, or building
     * it failed), if it is still the posting Gecko holds under [tag], runs
     * [cancel] (what Android still shows there is the posting it replaced,
     * which Gecko holds no more) and returns true; false when Gecko holds a
     * replacement by now, which is left alone.
     */
    @Synchronized
    fun withdraw(tag: String, instance: String, cancel: () -> Unit): Boolean {
        if (instances[tag] != instance) return false
        instances.remove(tag)
        cancel()
        return true
    }

    /**
     * Whether [instance] is the posting Gecko holds under [tag]; null when this
     * process heard of none there.
     */
    @Synchronized
    fun holds(tag: String, instance: String): Boolean? = instances[tag]?.let { it == instance }

    @Synchronized
    @VisibleForTesting
    internal fun resetForTest() {
        instances.clear()
    }
}
