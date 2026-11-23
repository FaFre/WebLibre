/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.notifications

import android.os.Parcelable
import eu.weblibre.flutter_mozilla_components.notifications.PendingNotificationClicks.Click
import eu.weblibre.flutter_mozilla_components.notifications.PendingNotificationClicks.WindowContext
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue
import org.mockito.Mockito.mock

private const val PROFILE = "0199a0b1-1111-7111-8111-111111111111"

class PendingNotificationClicksTest {
    private var clock = 0L

    @BeforeTest
    fun setUp() {
        PendingNotificationClicks.resetForTest()
        PendingNotificationClicks.now = { clock }
    }

    @AfterTest
    fun tearDown() = PendingNotificationClicks.resetForTest()

    private fun click(
        id: String,
        contextId: String? = null,
        private: Boolean = false,
        tag: String = "tag-$id",
        instance: String? = "posting-$id",
        action: String? = null,
    ) = Click(
        id = id,
        profileId = PROFILE,
        tag = tag,
        instance = instance,
        contextId = contextId,
        private = private,
        action = action,
        engineNotification = mock(Parcelable::class.java),
    )

    @Test
    fun `a parked tap is taken once, oldest first`() {
        PendingNotificationClicks.park(click("a"))
        PendingNotificationClicks.park(click("b"))

        assertEquals("a", PendingNotificationClicks.take()?.id)
        assertEquals("b", PendingNotificationClicks.take()?.id)
        assertNull(PendingNotificationClicks.take())
    }

    @Test
    fun `a taken tap stays answerable by its id until it is finished`() {
        PendingNotificationClicks.park(click("a"))
        val taken = PendingNotificationClicks.take()

        assertNotNull(PendingNotificationClicks.handedOut("a"))
        assertEquals("a", taken?.id)

        PendingNotificationClicks.finish("a")
        assertNull(PendingNotificationClicks.handedOut("a"))
    }

    @Test
    fun `an id native never gave out is not answerable`() {
        PendingNotificationClicks.park(click("a"))

        // Parked, not handed out yet: Dart cannot reach it by guessing its id.
        assertNull(PendingNotificationClicks.handedOut("a"))
        assertNull(PendingNotificationClicks.handedOut("nothing"))
    }

    @Test
    fun `only the newest taps are kept`() {
        repeat(10) { PendingNotificationClicks.park(click("tap-$it")) }

        val ids = generateSequence { PendingNotificationClicks.take()?.id }.toList()
        assertEquals((2..9).map { "tap-$it" }, ids)
    }

    @Test
    fun `a new tap is kept when every other one is held by Dart`() {
        // Dart holds them while it decides; one it lost is never finished.
        repeat(8) {
            PendingNotificationClicks.park(click("held-$it"))
            PendingNotificationClicks.take()
        }

        PendingNotificationClicks.park(click("new"))

        assertEquals("new", PendingNotificationClicks.take()?.id)
        // The oldest held one made room.
        assertNull(PendingNotificationClicks.handedOut("held-0"))
        assertNotNull(PendingNotificationClicks.handedOut("held-1"))
    }

    @Test
    fun `the tap Dart took last is kept, however many come after it`() {
        // Dart works on it: the user is being asked to resume its container.
        PendingNotificationClicks.park(click("asking"))
        PendingNotificationClicks.take()

        repeat(9) { PendingNotificationClicks.park(click("tap-$it")) }

        assertNotNull(PendingNotificationClicks.handedOut("asking"))
        val ids = generateSequence { PendingNotificationClicks.take()?.id }.toList()
        assertEquals((2..8).map { "tap-$it" }, ids)
    }

    @Test
    fun `a tap again on a notification whose first tap waits is not parked`() {
        val first = click("a", tag = "chat", instance = "posting-1")
        val again = click("b", tag = "chat", instance = "posting-1")

        assertTrue(PendingNotificationClicks.park(first))
        assertFalse(PendingNotificationClicks.park(again))

        assertEquals("a", PendingNotificationClicks.take()?.id)
        assertNull(PendingNotificationClicks.take())
    }

    @Test
    fun `a tap again while Dart holds the first one is not parked`() {
        PendingNotificationClicks.park(click("a", tag = "chat", instance = "posting-1"))
        PendingNotificationClicks.take()

        assertFalse(PendingNotificationClicks.park(click("b", tag = "chat", instance = "posting-1")))
        assertNull(PendingNotificationClicks.take())
    }

    @Test
    fun `a tap again once the first one is over is parked`() {
        PendingNotificationClicks.park(click("a", tag = "chat", instance = "posting-1"))
        PendingNotificationClicks.take()
        PendingNotificationClicks.finish("a")

        assertTrue(PendingNotificationClicks.park(click("b", tag = "chat", instance = "posting-1")))
    }

    @Test
    fun `a button or a replacement is another tap`() {
        PendingNotificationClicks.park(click("a", tag = "chat", instance = "posting-1"))

        assertTrue(
            PendingNotificationClicks.park(click("b", tag = "chat", instance = "posting-1", action = "reply")),
        )
        assertTrue(PendingNotificationClicks.park(click("c", tag = "chat", instance = "posting-2")))
    }

    @Test
    fun `ids are not reused`() {
        assertNotEquals(PendingNotificationClicks.newId(), PendingNotificationClicks.newId())
    }

    private val work = WindowContext("gvctx.work", private = false)
    private val play = WindowContext("gvctx.play", private = false)
    private val default = WindowContext(null, private = false)

    @Test
    fun `no window opens without a delivered click`() {
        assertFalse(PendingNotificationClicks.takeWindow(work))
    }

    @Test
    fun `a delivered click lets its worker open a window in its storage`() {
        PendingNotificationClicks.markDelivered(click("a", contextId = "gvctx.work"))

        assertTrue(PendingNotificationClicks.takeWindow(work))
    }

    @Test
    fun `the default storage is a context, not an unknown one`() {
        PendingNotificationClicks.markDelivered(click("a", contextId = null))

        assertFalse(PendingNotificationClicks.takeWindow(work))
        assertTrue(PendingNotificationClicks.takeWindow(default))
    }

    @Test
    fun `delivering a click ends the tap`() {
        PendingNotificationClicks.park(click("a"))
        val taken = PendingNotificationClicks.take()!!

        PendingNotificationClicks.markDelivered(taken)

        assertNull(PendingNotificationClicks.handedOut("a"))
    }

    @Test
    fun `the window closes after its time`() {
        PendingNotificationClicks.markDelivered(click("a", contextId = "gvctx.work"))

        clock = PendingNotificationClicks.WINDOW_MILLIS + 1

        assertFalse(PendingNotificationClicks.takeWindow(work))
    }

    @Test
    fun `a click is still good at the last moment of its window`() {
        PendingNotificationClicks.markDelivered(click("a", contextId = "gvctx.work"))

        clock = PendingNotificationClicks.WINDOW_MILLIS

        assertTrue(PendingNotificationClicks.takeWindow(work))
    }

    @Test
    fun `a click authorises one window, not every window after it`() {
        PendingNotificationClicks.markDelivered(click("a", contextId = "gvctx.work"))

        assertTrue(PendingNotificationClicks.takeWindow(work))
        assertFalse(PendingNotificationClicks.takeWindow(work))
    }

    @Test
    fun `two clicks of the same storage authorise two windows`() {
        PendingNotificationClicks.markDelivered(click("a", contextId = "gvctx.work"))
        PendingNotificationClicks.markDelivered(click("b", contextId = "gvctx.work"))

        assertTrue(PendingNotificationClicks.takeWindow(work))
        assertTrue(PendingNotificationClicks.takeWindow(work))
        assertFalse(PendingNotificationClicks.takeWindow(work))
    }

    @Test
    fun `a click whose handler opened no window does not hold other storages back`() {
        PendingNotificationClicks.markDelivered(click("a", contextId = "gvctx.work"))
        clock = 20_000
        PendingNotificationClicks.markDelivered(click("b", contextId = "gvctx.play"))

        assertTrue(PendingNotificationClicks.takeWindow(play))
        // Its own window is still there, should its worker be slow to start.
        assertTrue(PendingNotificationClicks.takeWindow(work))
    }

    @Test
    fun `a click from a private tab authorises only a private window`() {
        PendingNotificationClicks.markDelivered(click("a", contextId = "gvctx.work", private = true))

        assertFalse(PendingNotificationClicks.takeWindow(work))
        assertTrue(PendingNotificationClicks.takeWindow(WindowContext("gvctx.work", private = true)))
    }

    @Test
    fun `a click taken back authorises no window and is held again`() {
        PendingNotificationClicks.park(click("a", contextId = "gvctx.work"))
        val taken = PendingNotificationClicks.take()!!
        PendingNotificationClicks.markDelivered(taken)

        PendingNotificationClicks.unmarkDelivered(taken)

        assertFalse(PendingNotificationClicks.takeWindow(work))
        assertNotNull(PendingNotificationClicks.handedOut("a"))
    }

    @Test
    fun `taking back one click leaves another of the same storage its window`() {
        val a = click("a", contextId = "gvctx.work")
        PendingNotificationClicks.markDelivered(a)
        PendingNotificationClicks.markDelivered(click("b", contextId = "gvctx.work"))

        PendingNotificationClicks.unmarkDelivered(a)

        assertTrue(PendingNotificationClicks.takeWindow(work))
        assertFalse(PendingNotificationClicks.takeWindow(work))
    }
}
