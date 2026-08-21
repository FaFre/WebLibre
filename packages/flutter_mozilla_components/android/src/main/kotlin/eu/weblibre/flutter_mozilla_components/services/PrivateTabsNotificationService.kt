/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.services

import android.annotation.SuppressLint
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.R
import eu.weblibre.flutter_mozilla_components.activities.AuthCustomTabActivity
import eu.weblibre.flutter_mozilla_components.activities.AuthIntentReceiverActivity
import eu.weblibre.flutter_mozilla_components.activities.ExternalAppBrowserActivity
import eu.weblibre.flutter_mozilla_components.activities.IntentReceiverActivity
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.feature.privatemode.notification.AbstractPrivateNotificationService
import mozilla.components.support.base.android.NotificationsDelegate

class PrivateTabsNotificationService : AbstractPrivateNotificationService() {
    /**
     * How this service survives a cold dispatch.
     *
     * [DownloadService] and [MediaSessionService] stop themselves when the system
     * starts them into a process with no committed profile. This one cannot use
     * that shape: `AbstractPrivateNotificationService` declares both `onCreate`
     * and `onStartCommand` `final`, and `onCreate` touches [store] and
     * [notificationsDelegate] synchronously — so anything resolved through
     * `components` is reached before any hook this class owns can run.
     *
     * Reachable one way: the erase action on the notification, which outlives the
     * process that posted it. Tapping it after a process death starts this service
     * into a process that has committed nothing. (Not reachable the way the
     * sibling services are — `onStartCommand` returns `START_NOT_STICKY`, so
     * Android does not restart it after a process death.)
     *
     * So the answer is not to guard, but to be **truthful with no profile open**.
     * Private tabs do not survive the process: in a process that has committed
     * nothing there are provably none. An empty [BrowserStore] states exactly
     * that, and it is not a stand-in for a real one — it is the correct answer to
     * the only question the base class asks of it. The base class then does the
     * rest by itself: its `privateTabs.isEmpty()` collector fires immediately and
     * calls `stopService()`, which is precisely the self-stop the sibling services
     * implement by hand.
     *
     * [StalePrivateNotification] still clears the notification at startup, so in
     * the ordinary case there is nothing left to tap at all. This covers the tap
     * that races it.
     */
    private val components get() = GlobalComponents.components

    /**
     * The real store, or an empty one when no profile is committed.
     *
     * `by lazy` on purpose: once this service is running with components, the
     * store must not be re-resolved into a different one mid-life.
     */
    override val store: BrowserStore by lazy {
        components?.core?.store ?: BrowserStore()
    }

    override val notificationsDelegate: NotificationsDelegate by lazy {
        components?.notificationsDelegate
            ?: NotificationsDelegate(NotificationManagerCompat.from(applicationContext))
    }

    override fun NotificationCompat.Builder.buildNotification() {
        setSmallIcon(R.drawable.mdi_icon_domino_mask)

        val contentTitle = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            applicationContext.getString(R.string.private_tabs_notification_title_android_14)
        } else {
            applicationContext.getString(R.string.private_tabs_notification_text)
        }

        val contentText = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            applicationContext.getString(R.string.private_tabs_notification_text_android_14)
        } else {
            applicationContext.getString(R.string.private_tabs_notification_text)
        }

        setContentTitle(contentTitle)
        setContentText(contentText)

        color = ContextCompat.getColor(
            this@PrivateTabsNotificationService,
            R.color.private_tab_mask_accent,
        )
    }

    override fun notifyLocaleChanged() {
        refreshNotification()
    }

    /**
     * No-op with no profile committed, which is the correct outcome rather than a
     * degraded one: the private tabs this action refers to died with the process
     * that posted the notification.
     */
    @SuppressLint("MissingSuperCall")
    override fun erasePrivateTabs() {
        components?.useCases?.tabsUseCases?.removePrivateTabs()
    }

    override fun ignoreTaskComponentClasses(): List<String> = listOf(
        ExternalAppBrowserActivity::class.qualifiedName!!,
        IntentReceiverActivity::class.qualifiedName!!,
        AuthIntentReceiverActivity::class.qualifiedName!!,
        AuthCustomTabActivity::class.qualifiedName!!,
    )

    override fun ignoreTaskActions(): List<String> = emptyList()
}
