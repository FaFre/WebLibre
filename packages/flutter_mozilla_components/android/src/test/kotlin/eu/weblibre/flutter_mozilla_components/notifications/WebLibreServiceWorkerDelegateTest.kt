/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.notifications

import android.os.Parcelable
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertSame
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.mock
import org.mozilla.geckoview.GeckoSession
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class WebLibreServiceWorkerDelegateTest {
    private val session = mock(GeckoSession::class.java)
    private val opened = mutableListOf<PendingNotificationClicks.WindowContext>()

    private val delegate = WebLibreServiceWorkerDelegate { window ->
        opened += window
        session
    }

    @Before
    fun setUp() = PendingNotificationClicks.resetForTest()

    @After
    fun tearDown() = PendingNotificationClicks.resetForTest()

    private fun deliveredClick(contextId: String?, private: Boolean = false) = PendingNotificationClicks.markDelivered(
        PendingNotificationClicks.Click(
            id = PendingNotificationClicks.newId(),
            profileId = "0199a0b1-1111-7111-8111-111111111111",
            tag = "chat",
            instance = "posting-1",
            contextId = contextId,
            private = private,
            action = null,
            engineNotification = mock(Parcelable::class.java),
        ),
    )

    private fun open(contextId: String?, private: Boolean = false) =
        delegate.onOpenWindow("https://example.org/inbox", contextId, private).poll(1000)

    @Test
    fun `a window nobody's click asked for is refused`() {
        assertNull(open("gvctx.work"))
        assertEquals(emptyList<PendingNotificationClicks.WindowContext>(), opened)
    }

    @Test
    fun `the window opens in the storage Gecko says the worker runs in`() {
        deliveredClick("gvctx.work")

        assertSame(session, open("gvctx.work"))
        assertEquals(listOf(PendingNotificationClicks.WindowContext("gvctx.work", private = false)), opened)
    }

    @Test
    fun `a window without its storage is refused, also with a click delivered`() {
        deliveredClick("gvctx.work")

        assertNull(delegate.onOpenWindow("https://example.org/inbox").poll(1000))
        assertEquals(emptyList<PendingNotificationClicks.WindowContext>(), opened)
    }

    @Test
    fun `a click of another storage does not explain a window`() {
        deliveredClick("gvctx.work")

        assertNull(open(null))
        assertNull(open("gvctx.work", private = true))
        assertEquals(emptyList<PendingNotificationClicks.WindowContext>(), opened)
    }

    @Test
    fun `a click whose handler opened no window does not hold another storage back`() {
        // "Mark as read" in work, then a tap in the default storage.
        deliveredClick("gvctx.work")
        deliveredClick(null)

        assertSame(session, open(null))
        assertEquals(listOf(PendingNotificationClicks.WindowContext(null, private = false)), opened)
    }

    @Test
    fun `the window of a worker in private browsing is private`() {
        deliveredClick("gvctx.work", private = true)

        assertSame(session, open("gvctx.work", private = true))
        assertEquals(listOf(PendingNotificationClicks.WindowContext("gvctx.work", private = true)), opened)
    }
}
