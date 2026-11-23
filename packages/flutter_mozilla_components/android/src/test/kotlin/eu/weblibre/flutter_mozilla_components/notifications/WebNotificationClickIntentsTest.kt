/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.notifications

import android.content.Context
import android.content.Intent
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals
import kotlin.test.assertNull
import kotlin.test.assertSame
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.mock
import org.mozilla.geckoview.WebNotification
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

private const val PROFILE = "0199a0b1-1111-7111-8111-111111111111"
private const val OTHER = "0199a0b1-2222-7222-8222-222222222222"
private const val ORIGIN = "https://example.org"

@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class WebNotificationClickIntentsTest {
    private val application: Context = RuntimeEnvironment.getApplication()

    private fun data(
        profile: String = PROFILE,
        tag: String = "chat",
        origin: String = ORIGIN,
        instance: String = "posting-1",
        action: String? = null,
    ) = WebNotificationClickIntents.dataFor(profile, tag, origin, instance, action)

    /** GeckoView builds these itself; a mock with its final fields set is enough to read them. */
    private fun geckoNotification(tag: String, origin: String): WebNotification {
        val notification = mock(WebNotification::class.java)
        listOf("tag" to tag, "origin" to origin).forEach { (name, value) ->
            WebNotification::class.java.getDeclaredField(name).apply { isAccessible = true }
                .set(notification, value)
        }
        return notification
    }

    @Test
    fun `the same notification has the same data`() {
        assertEquals(data(), data())
    }

    @Test
    fun `two profiles never share a pending intent`() {
        assertNotEquals(data(profile = PROFILE), data(profile = OTHER))
    }

    @Test
    fun `two notifications and two buttons never share one`() {
        assertNotEquals(data(tag = "chat"), data(tag = "mail"))
        assertNotEquals(data(origin = ORIGIN), data(origin = "https://example.com"))
        assertNotEquals(data(action = null), data(action = "reply"))
        assertNotEquals(data(action = "reply"), data(action = "archive"))
    }

    @Test
    fun `two postings of a notification never share one`() {
        // A replacement under the same tag, built while the one it replaces shows.
        assertNotEquals(data(instance = "posting-1"), data(instance = "posting-2"))
        assertNotEquals(data(instance = "posting-1", action = "reply"), data(instance = "posting-2", action = "reply"))
    }

    @Test
    fun `the tag and origin cannot run together into another notification`() {
        assertNotEquals(data(tag = "ab", origin = "c"), data(tag = "a", origin = "bc"))
    }

    @Test
    fun `a button's name cannot break out of its path`() {
        val uri = data(action = "a/b?c#d")

        assertEquals("weblibre", uri.scheme)
        assertEquals("web-notification", uri.authority)
        // Profile, notification, posting, button: the button's own slashes stay inside it.
        assertEquals(4, uri.pathSegments.size)
        assertEquals("a/b?c#d", uri.pathSegments.last())
    }

    @Test
    fun `an intent we built is read back with its profile, notification and button`() {
        val notification = geckoNotification("chat", ORIGIN)

        val intent = WebNotificationClickIntents.build(application, PROFILE, notification, "reply", "posting-1")
        val tap = WebNotificationClickIntents.parse(intent)

        assertEquals(PROFILE, tap?.profileId)
        assertSame(notification, tap?.notification)
        assertEquals("reply", tap?.actionName)
        assertEquals("posting-1", tap?.instance)
        assertEquals(data(action = "reply"), intent.data)
    }

    @Test
    fun `a notification posted before instances reads back without one`() {
        val intent = WebNotificationClickIntents.build(
            application,
            PROFILE,
            geckoNotification("chat", ORIGIN),
            actionName = null,
            instance = "posting-1",
        ).apply { removeExtra(WebNotificationClickIntents.EXTRA_INSTANCE) }

        val tap = WebNotificationClickIntents.parse(intent)

        assertEquals(PROFILE, tap?.profileId)
        assertNull(tap?.instance)
    }

    @Test
    fun `a tap on the notification itself names no button`() {
        val intent = WebNotificationClickIntents.build(
            application,
            PROFILE,
            geckoNotification("chat", ORIGIN),
            actionName = null,
            instance = "posting-1",
        )

        assertNull(WebNotificationClickIntents.parse(intent)?.actionName)
    }

    @Test
    fun `an intent of another action is not a tap`() {
        assertNull(WebNotificationClickIntents.parse(Intent(Intent.ACTION_VIEW)))
    }

    @Test
    fun `an intent without its profile or notification is not a tap`() {
        val notification = geckoNotification("chat", ORIGIN)
        val full = WebNotificationClickIntents.build(application, PROFILE, notification, null, "posting-1")

        val noProfile = Intent(full).apply { removeExtra(WebNotificationClickIntents.EXTRA_PROFILE_ID) }
        val noNotification = Intent(full).apply { removeExtra(WebNotificationClickIntents.EXTRA_NOTIFICATION) }

        assertNull(WebNotificationClickIntents.parse(noProfile))
        assertNull(WebNotificationClickIntents.parse(noNotification))
    }
}
