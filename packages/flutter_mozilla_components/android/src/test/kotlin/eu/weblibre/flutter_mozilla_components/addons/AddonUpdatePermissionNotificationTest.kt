/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.addons

import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import androidx.core.app.NotificationManagerCompat
import eu.weblibre.flutter_mozilla_components.ProfileContext
import eu.weblibre.flutter_mozilla_components.startup.StartupPaths
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotEquals
import kotlin.test.assertTrue
import mozilla.components.concept.engine.webextension.WebExtension
import mozilla.components.support.base.android.NotificationsDelegate
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.mock
import org.mockito.Mockito.`when`
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config

private const val PROFILE = "0199a0b1-1111-7111-8111-111111111111"
private const val ADDON = "addon@example.org"

@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class AddonUpdatePermissionNotificationTest {
    private val application: Context = RuntimeEnvironment.getApplication()
    private val profile = ProfileContext(application, StartupPaths.relativeProfilePath(PROFILE))
    private val notifications = application.getSystemService(NotificationManager::class.java)

    private val extension: WebExtension =
        mock(WebExtension::class.java).also { `when`(it.id).thenReturn(ADDON) }

    private fun post(permissions: List<String>) {
        AddonUpdatePermissionNotification.post(
            profile,
            NotificationsDelegate(NotificationManagerCompat.from(application)),
            extension,
            permissions,
            emptyList(),
        )
    }

    /** The Update button of the notification showing now. */
    private fun updateButton(): PendingIntent =
        shadowOf(notifications).allNotifications.single().actions
            .map { it.actionIntent }
            .single { shadowOf(it).savedIntent.action == AddonUpdatePermissionNotification.ACTION_ALLOW }

    private fun requestOf(button: PendingIntent): String? =
        shadowOf(button).savedIntent.getStringExtra(AddonUpdatePermissionNotification.EXTRA_REQUEST_ID)

    @Test
    fun `a later request leaves the buttons already showing alone`() {
        post(listOf("tabs"))
        val earlier = updateButton()
        val shown = AddonUpdatePermissionRequests.Request(listOf("tabs"), emptyList()).id

        // A later check asks for more before the notification shows it.
        post(listOf("tabs", "history"))
        val later = updateButton()

        assertEquals(shown, requestOf(earlier))
        assertEquals(
            AddonUpdatePermissionRequests.Request(listOf("tabs", "history"), emptyList()).id,
            requestOf(later),
        )
        assertNotEquals(earlier, later)
    }

    @Test
    fun `declining a replaced request changes nothing`() {
        AddonUpdatePermissionRequests.record(profile, ADDON, listOf("tabs"), emptyList(), "1.0")
        val shown = AddonUpdatePermissionRequests.get(profile, ADDON, installedVersion = null)!!.id
        AddonUpdatePermissionRequests.record(profile, ADDON, listOf("tabs", "history"), emptyList(), "1.0")

        assertFalse(AddonUpdatePermissionRequests.decline(profile, ADDON, shown))
        assertEquals(
            listOf("history", "tabs"),
            AddonUpdatePermissionRequests.get(profile, ADDON, installedVersion = null)?.permissions,
        )

        val current = AddonUpdatePermissionRequests.get(profile, ADDON, installedVersion = null)!!.id
        assertTrue(AddonUpdatePermissionRequests.decline(profile, ADDON, current))
        assertEquals(emptySet(), AddonUpdatePermissionRequests.pendingAddonIds(profile))
    }
}
