/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.activities

import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import eu.weblibre.flutter_mozilla_components.notifications.NotificationClickPlan
import eu.weblibre.flutter_mozilla_components.notifications.PendingNotificationClicks
import eu.weblibre.flutter_mozilla_components.notifications.WebNotificationClickIntents
import eu.weblibre.flutter_mozilla_components.startup.StartupArbiter
import eu.weblibre.flutter_mozilla_components.startup.StartupConfig

/**
 * What a tap on a web notification (or one of its buttons) opens.
 *
 * It decides whether the tap may reach Gecko, parks it for Dart
 * ([PendingNotificationClicks]) and brings WebLibre to the front, where the
 * Flutter side delivers it once the engine is up, the routing is ready and
 * nothing the click would wake is frozen. It never talks to Gecko itself: a
 * tap can start the process, and the engine of a process that has not
 * committed a profile does not exist yet.
 *
 * The notification outlives the process that posted it, so the profile it
 * belongs to travels with it ([WebNotificationClickIntents]). Where nothing is
 * committed, the tap binds that profile like a trusted pinned shortcut does
 * (the activity is not exported and the pending intent immutable, so the
 * extras are authentic). Where another profile runs, nothing is delivered and
 * the notification stays, answerable once its profile runs: a click reaches
 * whatever profile the runtime serves, so it would otherwise fire a worker of
 * the wrong one. A notification an older build posted names no profile and
 * only opens the app.
 */
class NotificationActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handle(intent, isNewTap = savedInstanceState == null)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handle(intent, isNewTap = true)
    }

    /**
     * Parks the tap [intent] carries, when [isNewTap] and it is not a replay.
     * A tap is delivered once: an activity Android re-creates, or the tap's
     * intent relaunched from recents, would otherwise run the site's
     * `notificationclick` handler again and open another window. The manifest
     * keeps this activity out of recents and in a task of its own, so the
     * app's task never starts from the tap's intent; this is the second line.
     */
    private fun handle(intent: Intent, isNewTap: Boolean) {
        val replayed = (intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY) != 0
        try {
            if (isNewTap && !replayed) {
                WebNotificationClickIntents.parse(intent)?.let(::park)
            } else {
                Log.i(TAG, "A web notification tap was replayed; opening the app only")
            }
        } catch (error: Throwable) {
            // A tap that cannot be read is no reason to leave the user on a
            // blank translucent window.
            Log.e(TAG, "Could not read the tap on a web notification", error)
        }
        openApp()
        finish()
    }

    /** Parks the tap for Dart when this process serves its profile, binding it first when none is committed. */
    private fun park(tap: WebNotificationClickIntents.Tap) {
        val profileId = tap.profileId
        val serves = when (NotificationClickPlan.decide(profileId, StartupArbiter.committedProfileId())) {
            NotificationClickPlan.Step.OPEN_ONLY -> false
            NotificationClickPlan.Step.PARK -> true
            NotificationClickPlan.Step.BIND_THEN_PARK -> {
                NotificationClickPlan.servesProfile(
                    StartupArbiter.tryCommitExternal(
                        requestedProfileId = profileId,
                        trusted = true,
                        honorShortcutProfile = StartupConfig.honorShortcutProfile(applicationContext),
                    ),
                    profileId,
                )
            }
        }

        if (!serves) {
            Log.i(TAG, "A notification of profile $profileId was tapped in a process that does not serve it; left showing")
            return
        }

        val parked = PendingNotificationClicks.park(
            PendingNotificationClicks.Click(
                id = PendingNotificationClicks.newId(),
                profileId = profileId,
                tag = tap.notification.tag,
                instance = tap.instance,
                contextId = tap.notification.sessionContextId,
                private = tap.notification.privateBrowsing,
                action = tap.actionName,
                engineNotification = tap.notification,
            ),
        )
        if (!parked) Log.i(TAG, "A web notification was tapped again before its first tap was delivered")
    }

    private fun openApp() {
        val launch = packageManager.getLaunchIntentForPackage(packageName) ?: return
        startActivity(launch.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
    }

    private companion object {
        const val TAG = "NotificationActivity"
    }
}
