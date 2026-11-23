/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.notifications

import android.os.Parcelable
import eu.weblibre.flutter_mozilla_components.pigeons.NotificationClickOutcome
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue
import org.mockito.Mockito.mock

private const val PROFILE = "0199a0b1-1111-7111-8111-111111111111"
private const val OTHER = "0199a0b1-2222-7222-8222-222222222222"
private const val POSTING = "posting-1"
private const val GENERATION = 7L

class NotificationClickDeliveryTest {
    private val engineNotification = mock(Parcelable::class.java)
    private val handed = mutableListOf<Pair<Parcelable, String?>>()
    private val cancelled = mutableListOf<String>()

    private var served: String? = PROFILE
    private var restricted = false
    private var routed = true
    private var generation: Long? = GENERATION
    private var engineFails = false

    /** What Gecko holds, by tag, as this process heard; a tag missing here was never heard of. */
    private val geckoPostings = mutableMapOf<String, String>()

    /** What Android shows, by tag: by default, the posting [handOut] taps. */
    private val showing = mutableMapOf<String, String?>("tag" to POSTING)

    /** Runs while the engine takes the click. */
    private var whileHanding: () -> Unit = {}

    private fun delivery() = NotificationClickDelivery(
        servedProfileId = { served },
        isRestricted = { restricted },
        installedRoutingGeneration = { generation },
        routingCovers = { routed },
        shown = { tag -> if (tag in showing) NotificationClickDelivery.Shown(showing[tag]) else null },
        geckoHolds = { tag, instance -> geckoPostings[tag]?.let { it == instance } },
        handToEngine = { notification, action ->
            if (engineFails) throw IllegalStateException("no runtime")
            handed += notification to action
            whileHanding()
        },
        cancelNotification = { cancelled += it },
    )

    @BeforeTest
    fun setUp() = PendingNotificationClicks.resetForTest()

    @AfterTest
    fun tearDown() = PendingNotificationClicks.resetForTest()

    /** The storage [handOut]'s taps come from by default. */
    private val workWindow = PendingNotificationClicks.WindowContext("gvctx.work", private = false)

    /** Parks a tap on the notification under "tag", as the activity does, and returns its id. */
    private fun park(
        profileId: String = PROFILE,
        contextId: String? = "gvctx.work",
        action: String? = null,
        instance: String? = POSTING,
    ): String {
        val id = PendingNotificationClicks.newId()
        PendingNotificationClicks.park(
            PendingNotificationClicks.Click(
                id = id,
                profileId = profileId,
                tag = "tag",
                instance = instance,
                contextId = contextId,
                private = false,
                action = action,
                engineNotification = engineNotification,
            ),
        )
        return id
    }

    /** Parks a tap and takes it, as Dart does, and returns its id. */
    private fun handOut(
        profileId: String = PROFILE,
        contextId: String? = "gvctx.work",
        action: String? = null,
        instance: String? = POSTING,
    ): String = park(profileId, contextId, action, instance).also { PendingNotificationClicks.take() }

    @Test
    fun `a tap is handed to the engine and its notification cancelled`() {
        val id = handOut()

        assertEquals(NotificationClickOutcome.DELIVERED, delivery().deliver(id, GENERATION))

        assertEquals(listOf<Pair<Parcelable, String?>>(engineNotification to null), handed)
        assertEquals(listOf("tag"), cancelled)
    }

    @Test
    fun `a button is handed to the engine and leaves its notification`() {
        val id = handOut(action = "reply")

        assertEquals(NotificationClickOutcome.DELIVERED, delivery().deliver(id, GENERATION))

        assertEquals(listOf<Pair<Parcelable, String?>>(engineNotification to "reply"), handed)
        assertEquals(emptyList<String>(), cancelled)
    }

    @Test
    fun `a tap whose notification was replaced meanwhile is dropped, and the replacement stays`() {
        val id = handOut()
        showing["tag"] = "posting-2"

        assertEquals(NotificationClickOutcome.SUPERSEDED, delivery().deliver(id, GENERATION))

        assertEquals(emptyList<Pair<Parcelable, String?>>(), handed)
        assertEquals(emptyList<String>(), cancelled)
        assertNull(PendingNotificationClicks.handedOut(id))
        assertFalse(PendingNotificationClicks.takeWindow(workWindow))
    }

    @Test
    fun `a tap whose notification was closed meanwhile is dropped`() {
        val id = handOut()
        showing.clear()

        assertEquals(NotificationClickOutcome.SUPERSEDED, delivery().deliver(id, GENERATION))
        assertEquals(emptyList<Pair<Parcelable, String?>>(), handed)
    }

    @Test
    fun `a tap whose notification no longer shows is not handed to Dart`() {
        park()
        showing["tag"] = "posting-2"
        val current = park(instance = "posting-2")

        assertEquals(current, delivery().take()?.id)
        assertNull(delivery().take())
    }

    @Test
    fun `a tap on a notification posted before instances is delivered as before`() {
        showing["tag"] = null
        val id = handOut(instance = null)

        assertEquals(NotificationClickOutcome.DELIVERED, delivery().deliver(id, GENERATION))
        assertEquals(listOf("tag"), cancelled)
    }

    @Test
    fun `a replacement posted while the engine takes the click is not cancelled`() {
        val id = handOut()
        whileHanding = { showing["tag"] = "posting-2" }

        assertEquals(NotificationClickOutcome.DELIVERED, delivery().deliver(id, GENERATION))
        assertEquals(emptyList<String>(), cancelled)
    }

    @Test
    fun `a tap is not delivered once Gecko holds a replacement that Android does not show yet`() {
        val id = handOut()
        // Gecko replaced it; Android still shows the posting the user tapped.
        geckoPostings["tag"] = "posting-2"

        assertEquals(NotificationClickOutcome.SUPERSEDED, delivery().deliver(id, GENERATION))

        assertEquals(emptyList<Pair<Parcelable, String?>>(), handed)
        assertEquals(emptyList<String>(), cancelled)
    }

    @Test
    fun `a tap is delivered while Gecko holds the posting it was on`() {
        val id = handOut()
        geckoPostings["tag"] = POSTING

        assertEquals(NotificationClickOutcome.DELIVERED, delivery().deliver(id, GENERATION))
    }

    @Test
    fun `a tap on a posting of an earlier process goes by what Android shows`() {
        // Nothing heard of "tag" in this process: Gecko holds what it restored.
        val id = handOut()

        assertEquals(NotificationClickOutcome.DELIVERED, delivery().deliver(id, GENERATION))
    }

    @Test
    fun `a routing snapshot installed since Dart checked it holds the tap back`() {
        val id = handOut()
        generation = GENERATION + 1

        assertEquals(NotificationClickOutcome.ROUTING_CHANGED, delivery().deliver(id, GENERATION))

        assertEquals(emptyList<Pair<Parcelable, String?>>(), handed)
        assertNotNull(PendingNotificationClicks.handedOut(id))
        assertFalse(PendingNotificationClicks.takeWindow(workWindow))
    }

    @Test
    fun `no routing snapshot installed holds the tap back`() {
        val id = handOut()
        generation = null

        assertEquals(NotificationClickOutcome.ROUTING_CHANGED, delivery().deliver(id, GENERATION))
        assertEquals(emptyList<Pair<Parcelable, String?>>(), handed)
    }

    @Test
    fun `a storage whose installed route cannot carry traffic gets nothing and the tap is kept`() {
        val id = handOut()
        routed = false

        assertEquals(NotificationClickOutcome.ROUTE_UNAVAILABLE, delivery().deliver(id, GENERATION))

        assertEquals(emptyList<Pair<Parcelable, String?>>(), handed)
        assertEquals(emptyList<String>(), cancelled)
        assertNotNull(PendingNotificationClicks.handedOut(id))
        assertFalse(PendingNotificationClicks.takeWindow(workWindow))
    }

    @Test
    fun `delivering opens the window of the storage it came from`() {
        val id = handOut(contextId = "gvctx.work")

        delivery().deliver(id, GENERATION)

        assertTrue(
            PendingNotificationClicks.takeWindow(PendingNotificationClicks.WindowContext("gvctx.work", private = false)),
        )
    }

    @Test
    fun `a tap is delivered once`() {
        val id = handOut()
        delivery().deliver(id, GENERATION)

        assertEquals(NotificationClickOutcome.NOT_FOUND, delivery().deliver(id, GENERATION))
        assertEquals(1, handed.size)
    }

    @Test
    fun `an id native never gave out is not found`() {
        assertEquals(NotificationClickOutcome.NOT_FOUND, delivery().deliver("guessed", GENERATION))
        assertEquals(emptyList<Pair<Parcelable, String?>>(), handed)
    }

    @Test
    fun `a restricted storage gets nothing and the tap is kept`() {
        val id = handOut()
        restricted = true

        assertEquals(NotificationClickOutcome.CONTEXT_RESTRICTED, delivery().deliver(id, GENERATION))

        assertEquals(emptyList<Pair<Parcelable, String?>>(), handed)
        assertEquals(emptyList<String>(), cancelled)
        assertFalse(PendingNotificationClicks.takeWindow(workWindow))

        // After a Resume the same tap goes through.
        restricted = false
        assertEquals(NotificationClickOutcome.DELIVERED, delivery().deliver(id, GENERATION))
    }

    @Test
    fun `without components the tap is kept for later`() {
        val id = handOut()
        served = null

        assertEquals(NotificationClickOutcome.ENGINE_UNAVAILABLE, delivery().deliver(id, GENERATION))

        served = PROFILE
        assertEquals(NotificationClickOutcome.DELIVERED, delivery().deliver(id, GENERATION))
    }

    @Test
    fun `a tap of another profile is dropped, never delivered`() {
        val id = handOut(profileId = OTHER)

        assertEquals(NotificationClickOutcome.NOT_FOUND, delivery().deliver(id, GENERATION))

        assertEquals(emptyList<Pair<Parcelable, String?>>(), handed)
        assertEquals(emptyList<String>(), cancelled)
        assertNull(PendingNotificationClicks.handedOut(id))
    }

    @Test
    fun `a released tap keeps its notification and cannot be delivered`() {
        val id = handOut()

        delivery().release(id, dismissNotification = false)

        assertEquals(emptyList<String>(), cancelled)
        assertNull(PendingNotificationClicks.handedOut(id))
        assertEquals(NotificationClickOutcome.NOT_FOUND, delivery().deliver(id, GENERATION))
        assertEquals(emptyList<Pair<Parcelable, String?>>(), handed)
    }

    @Test
    fun `a released tap can take its notification with it`() {
        val id = handOut()

        delivery().release(id, dismissNotification = true)

        assertEquals(listOf("tag"), cancelled)
        assertNull(PendingNotificationClicks.handedOut(id))
        assertEquals(emptyList<Pair<Parcelable, String?>>(), handed)
    }

    @Test
    fun `a released tap leaves a replacement of its notification`() {
        val id = handOut()
        showing["tag"] = "posting-2"

        delivery().release(id, dismissNotification = true)

        assertEquals(emptyList<String>(), cancelled)
        assertNull(PendingNotificationClicks.handedOut(id))
    }

    @Test
    fun `releasing another profile's tap only drops it`() {
        val id = handOut(profileId = OTHER)

        delivery().release(id, dismissNotification = true)

        assertEquals(emptyList<String>(), cancelled)
        assertNull(PendingNotificationClicks.handedOut(id))
    }

    @Test
    fun `releasing an id native never gave out does nothing`() {
        delivery().release("guessed", dismissNotification = true)

        assertEquals(emptyList<String>(), cancelled)
    }

    @Test
    fun `a released tap does not open a window`() {
        val id = handOut()

        delivery().release(id, dismissNotification = true)

        assertFalse(PendingNotificationClicks.takeWindow(workWindow))
    }

    @Test
    fun `a click the engine could not take opens no window and stays Dart's to release`() {
        val id = handOut()
        engineFails = true

        assertFailsWith<IllegalStateException> { delivery().deliver(id, GENERATION) }

        // A window authorised in its name would hold other storages' windows back.
        assertFalse(PendingNotificationClicks.takeWindow(workWindow))
        assertEquals(emptyList<String>(), cancelled)
        assertNotNull(PendingNotificationClicks.handedOut(id))

        delivery().release(id, dismissNotification = false)
        assertNull(PendingNotificationClicks.handedOut(id))
        assertEquals(emptyList<String>(), cancelled)
    }
}
