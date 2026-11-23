/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.notifications

import android.content.Context
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import java.util.concurrent.Executor
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.asCoroutineDispatcher
import kotlinx.coroutines.runBlocking
import mozilla.components.browser.icons.BrowserIcons
import mozilla.components.concept.engine.permission.SitePermissionsStorage
import mozilla.components.concept.engine.webnotifications.WebNotification
import mozilla.components.concept.engine.webnotifications.WebNotificationAction
import mozilla.components.support.base.android.NotificationsDelegate
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.mock
import org.mockito.Mockito.verifyNoInteractions
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import org.mozilla.geckoview.WebNotification as GeckoWebNotification

private const val PROFILE = "0199a0b1-1111-7111-8111-111111111111"
private const val ORIGIN = "https://example.org"

@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class ProfileWebNotificationsTest {
    private val application: Context = RuntimeEnvironment.getApplication()
    private val notificationManager = NotificationManagerCompat.from(application)

    /** The background work of each show, run when the test says. */
    private val queued = ArrayDeque<Runnable>()
    private val sitePermissions = mock(SitePermissionsStorage::class.java)

    private val delegate = ProfileWebNotifications(
        context = application,
        profileId = PROFILE,
        browserIcons = mock(BrowserIcons::class.java),
        smallIcon = android.R.drawable.star_on,
        sitePermissionsStorage = sitePermissions,
        notificationsDelegate = NotificationsDelegate(notificationManager),
        coroutineContext = Executor { queued.addLast(it) }.asCoroutineDispatcher(),
    )

    @Before
    fun setUp() = GeckoPostings.resetForTest()

    @After
    fun tearDown() = GeckoPostings.resetForTest()

    private fun runQueued() {
        while (queued.isNotEmpty()) queued.removeFirst().run()
    }

    /** GeckoView builds these itself; a mock with its final fields set is enough to read them. */
    private fun geckoNotification(): GeckoWebNotification {
        val notification = mock(GeckoWebNotification::class.java)
        listOf("tag" to "chat", "origin" to ORIGIN).forEach { (name, value) ->
            GeckoWebNotification::class.java.getDeclaredField(name).apply { isAccessible = true }
                .set(notification, value)
        }
        return notification
    }

    /** A notification of a web extension, which needs no site permission. */
    private fun notification(title: String) = WebNotification(
        title = title,
        tag = "chat",
        body = null,
        sourceUrl = null,
        iconUrl = null,
        direction = null,
        lang = null,
        requireInteraction = false,
        engineNotification = geckoNotification(),
        triggeredByWebExtension = true,
        privateBrowsing = false,
        actions = arrayOf(WebNotificationAction("reply", "Reply")),
    )

    private fun shownTitles() = notificationManager.activeNotifications
        .filter { it.tag == "chat" }
        .map { it.notification.extras.getCharSequence(NotificationCompat.EXTRA_TITLE).toString() }

    /**
     * The posting the shown notification's tap and buttons carry, one each,
     * as [NotificationActivity][eu.weblibre.flutter_mozilla_components.activities.NotificationActivity]
     * reads them, and the posting the notification itself is.
     */
    private fun tapPayload(): Pair<List<String?>, String?> {
        val notification = notificationManager.activeNotifications.single { it.tag == "chat" }.notification
        val intents = listOf(notification.contentIntent) + notification.actions.map { it.actionIntent }
        val carried = intents.map { WebNotificationClickIntents.parse(shadowOf(it).savedIntent)?.instance }
        return carried to notification.extras.getString(WebNotificationClickIntents.EXTRA_INSTANCE)
    }

    private fun Deferred<Boolean>.answer(): Boolean {
        assertTrue(isCompleted)
        return runBlocking { await() }
    }

    @Test
    fun `a posting is published and reported shown`() {
        val shown = delegate.onShowNotification(notification("first"))
        runQueued()

        assertEquals(listOf("first"), shownTitles())
        assertTrue(shown.answer())
    }

    @Test
    fun `a private tab's page gets no notification, whatever its permission`() {
        val page = notification("private").copy(
            sourceUrl = ORIGIN,
            triggeredByWebExtension = false,
            privateBrowsing = true,
        )

        val shown = delegate.onShowNotification(page)
        runQueued()

        assertEquals(false, shown.answer())
        assertEquals(emptyList<String>(), shownTitles())
        // Refused before any lookup: no stored or private grant changes it.
        verifyNoInteractions(sitePermissions)
    }

    @Test
    fun `a replacement's tap carries the replacement`() {
        delegate.onShowNotification(notification("first"))
        runQueued()
        delegate.onShowNotification(notification("second"))
        runQueued()

        val (carried, shown) = tapPayload()
        assertEquals(listOf("second"), shownTitles())
        assertEquals(listOf(shown, shown), carried)
        assertEquals(true, GeckoPostings.holds("chat", shown!!))
    }

    @Test
    fun `a posting built after its replacement is not published over it`() {
        // Gecko gives both before either is built, and the earlier one's
        // build (a slow icon, say) finishes last.
        val first = delegate.onShowNotification(notification("first"))
        val second = delegate.onShowNotification(notification("second"))
        queued.removeLast().run()
        assertEquals(listOf("second"), shownTitles())
        val (carried, shown) = tapPayload()
        runQueued()

        assertEquals(listOf("second"), shownTitles())
        // The earlier build, discarded, did not change what the replacement's
        // tap and button carry: the posting that shows, which the delivery
        // takes as current.
        assertEquals(carried, tapPayload().first)
        assertEquals(listOf(shown, shown), carried)
        assertEquals(true, GeckoPostings.holds("chat", shown!!))
        // Reported shown, not dismissed: a dismissal by tag would close the replacement.
        assertTrue(first.answer())
        assertTrue(second.answer())
    }

    @Test
    fun `a closed posting is not brought back by its late build`() {
        val shown = delegate.onShowNotification(notification("first"))
        delegate.onCloseNotification(notification("first"))
        runQueued()

        assertEquals(emptyList<String>(), shownTitles())
        assertTrue(shown.answer())
    }

    @Test
    fun `the posting shown is the one the delivery takes as current`() {
        delegate.onShowNotification(notification("first"))
        runQueued()

        val instance = ProfileWebNotifications.shown(notificationManager, "chat")?.instance
        assertEquals(true, GeckoPostings.holds("chat", instance!!))
    }

    @Test
    fun `a replacement that cannot be built takes the posting it replaced with it`() {
        delegate.onShowNotification(notification("first"))
        runQueued()

        // Its icon cannot be loaded (the mocked icon loader has no answer):
        // building it throws.
        val broken = notification("second").copy(sourceUrl = ORIGIN, iconUrl = "$ORIGIN/icon.png")
        val shown = delegate.onShowNotification(broken)
        runQueued()

        // Gecko holds the replacement only, which shows nowhere: the earlier
        // posting would be a tap target for nothing.
        assertEquals(false, shown.answer())
        assertEquals(emptyList<String>(), shownTitles())
        assertNull(GeckoPostings.holds("chat", "anything"))
    }
}
