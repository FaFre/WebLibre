/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.services

import android.annotation.SuppressLint
import android.os.Build
import androidx.core.app.NotificationCompat
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
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    override val store: BrowserStore by lazy { components.core.store }

    override val notificationsDelegate: NotificationsDelegate by lazy {
        components.notificationsDelegate
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

    @SuppressLint("MissingSuperCall")
    override fun erasePrivateTabs() {
        components.useCases.tabsUseCases.removePrivateTabs()
    }

    override fun ignoreTaskComponentClasses(): List<String> = listOf(
        ExternalAppBrowserActivity::class.qualifiedName!!,
        IntentReceiverActivity::class.qualifiedName!!,
        AuthIntentReceiverActivity::class.qualifiedName!!,
        AuthCustomTabActivity::class.qualifiedName!!,
    )

    override fun ignoreTaskActions(): List<String> = emptyList()
}
