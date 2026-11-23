/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
package eu.weblibre.flutter_mozilla_components.push

import android.app.Activity
import android.content.Context
import android.os.Looper
import eu.weblibre.flutter_mozilla_components.ProfileContext
import eu.weblibre.flutter_mozilla_components.lifecycle.JsonStore
import eu.weblibre.flutter_mozilla_components.lifecycle.PushOutbox
import eu.weblibre.flutter_mozilla_components.startup.AtomicJsonFile
import eu.weblibre.flutter_mozilla_components.startup.StartupPaths
import java.util.concurrent.CopyOnWriteArrayList
import java.util.concurrent.Executors
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.ExecutorCoroutineDispatcher
import kotlinx.coroutines.asCoroutineDispatcher
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withContext
import mozilla.components.concept.engine.Engine
import mozilla.components.concept.engine.webpush.WebPushHandler
import mozilla.components.concept.engine.webpush.WebPushSubscription
import org.ironfoxoss.unifiedpush.DistributorManager
import org.ironfoxoss.unifiedpush.PushScope
import org.ironfoxoss.unifiedpush.SubscriptionsDB
import org.ironfoxoss.unifiedpush.UnifiedPushFeature
import org.json.JSONObject
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.mock
import org.mockito.Mockito.never
import org.mockito.Mockito.times
import org.mockito.Mockito.verify
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config

private const val SCOPE = "https://site.example/^context"
private const val PRIVATE_SCOPE = "https://site.example/^privateBrowsingId=1"
private const val CONTEXT = "context"
private const val E1 = "https://push.example/one"
private const val E2 = "https://push.example/two"

// Base64url, because the delegate decodes keys for Gecko.
private const val K1 = "cHViMQ"
private const val K2 = "cHViMg"
private const val A1 = "YXV0aDE"
private const val PROFILE = "0199a0b1-1111-7111-8111-111111111111"

/**
 * The subscription row, the outbox and Gecko's handoffs, against the real
 * SQLite database and the real feature: what the library's own tests mock.
 */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [33])
class PushSubscriptionChangeTest {
    private class MemoryJsonStore : JsonStore {
        var json: JSONObject? = null

        override fun read(): AtomicJsonFile.Read =
            json?.let { AtomicJsonFile.Read.Present(JSONObject(it.toString())) } ?: AtomicJsonFile.Read.Absent

        override fun write(json: JSONObject) {
            this.json = JSONObject(json.toString())
        }
    }

    /** No connector: the calls are what is under test, not their effect. */
    private class RecordingDistributors : DistributorManager {
        val registered = CopyOnWriteArrayList<String>()
        val keys = mutableMapOf<String, String?>()
        val unregistered = CopyOnWriteArrayList<String>()

        override fun isAvailable(context: Context) = true

        override fun registerScope(context: Context, scope: PushScope, appServerKey: String?) {
            registered += scope
            keys[scope] = appServerKey
        }

        override fun unregisterScope(context: Context, scope: PushScope) {
            unregistered += scope
        }

        override fun registerDefaultRegistration(context: Context) = Unit

        override fun useDefaultDistributor(activity: Activity, callback: (Boolean) -> Unit) = Unit

        override fun pickDistributor(activity: Activity, callback: (Boolean) -> Unit) = Unit

        override fun removeCurrentDistributor(context: Context) = Unit
    }

    private val app: Context = RuntimeEnvironment.getApplication()
    private val outbox = MemoryJsonStore()
    private val distributors = RecordingDistributors()
    private var restricted: String? = null

    private lateinit var db: SubscriptionsDB
    private lateinit var dispatcher: ExecutorCoroutineDispatcher
    private lateinit var feature: UnifiedPushFeature
    private lateinit var handler: WebPushHandler
    private lateinit var integration: WebPushEngineIntegration

    @Before
    fun setUp() {
        app.deleteDatabase("feature_unifiedpush_subscriptions")
        db = SubscriptionsDB(app)
        PushOutbox.resetForTest(outbox)
        PushContextGate.decode = { CONTEXT }
        PushContextGate.isRestricted = { it != null && it == restricted }
        PushContextGate.anyRestricted = { restricted != null }
        dispatcher = Executors.newSingleThreadExecutor().asCoroutineDispatcher()
        feature = UnifiedPushFeature(app, coroutineContext = dispatcher, db = db, up = distributors)
        handler = mock(WebPushHandler::class.java)
        // An answer rather than a matcher: Kotlin null-checks `any()` against
        // the non-null parameter before Mockito sees it.
        val engine = mock(Engine::class.java) { invocation ->
            if (invocation.method.name == "registerWebPushDelegate") {
                handler
            } else {
                org.mockito.Answers.RETURNS_DEFAULTS.answer(invocation)
            }
        }
        integration = WebPushEngineIntegration(
            engine = engine,
            pushFeature = feature,
            rowVersion = ::rowVersion,
            whenReady = { it(true) },
        )
        integration.start()
    }

    @After
    fun tearDown() {
        integration.close()
        dispatcher.close()
        db.close()
        PushContextGate.resetForTest()
    }

    private suspend fun rowVersion(scope: String): String =
        withContext(dispatcher) { SubscriptionVersion.of(db.getSubscription(scope, null)) }

    private fun row(endpoint: String?, key: String? = K1, scope: String = SCOPE) {
        db.add(SubscriptionsDB.Subscription(scope, endpoint, endpoint?.let { key }, endpoint?.let { A1 }))
    }

    private fun version(endpoint: String, key: String = K1) = SubscriptionVersion.of(endpoint, key, A1)

    /** A new process: the outbox reloads from its file. */
    private fun restart() = PushOutbox.resetForTest(outbox)

    private fun drain(contextIds: Collection<String>? = null) = runBlocking { integration.drainOutbox(contextIds) }

    private fun eventually(condition: () -> Boolean) {
        val deadline = System.currentTimeMillis() + 5_000
        while (!condition()) {
            check(System.currentTimeMillis() < deadline) { "Timed out" }
            shadowOf(Looper.getMainLooper()).idle()
            Thread.sleep(20)
        }
    }

    @Test
    fun `a change written before its notification still reaches Gecko after a death`() {
        row(E1)
        // Push.onNewEndpoint: the version first, then the row, then the death
        // that used to come before the feature's delayed notification.
        PushOutbox.record(SCOPE, version(E2))
        row(E2)
        restart()

        drain()

        verify(handler, times(1)).onSubscriptionChanged(SCOPE)
        assertNull(PushOutbox.pendingVersion(SCOPE))

        restart()
        drain()
        verify(handler, times(1)).onSubscriptionChanged(SCOPE)
    }

    @Test
    fun `a drain before the row write leaves the change pending`() {
        // Startup and Resume drain on their own schedule and can fall between
        // the record and the write. Clearing the entry then would lose the
        // change again if the process died after the write.
        row(E1)
        PushOutbox.record(SCOPE, version(E2))

        drain()

        verify(handler, never()).onSubscriptionChanged(SCOPE)
        assertEquals(version(E2), PushOutbox.pendingVersion(SCOPE))

        row(E2)
        drain()
        verify(handler, times(1)).onSubscriptionChanged(SCOPE)
        assertNull(PushOutbox.pendingVersion(SCOPE))
    }

    @Test
    fun `a handoff of an older version keeps the newer change`() {
        PushOutbox.record(SCOPE, version(E2))

        PushOutbox.handedOff(SCOPE, version(E1))

        assertEquals(version(E2), PushOutbox.pendingVersion(SCOPE))
        PushOutbox.handedOff(SCOPE, version(E2))
        assertNull(PushOutbox.pendingVersion(SCOPE))
    }

    @Test
    fun `a subscribe answer clears the change it carries, and nothing is notified`() {
        val delegate = WebPushEngineDelegate(feature, { it(true) }, { it.toByteArray() }, { String(it) })
        val answered = CompletableDeferred<WebPushSubscription?>()
        delegate.onSubscribe(SCOPE, null) { answered.complete(it) }
        eventually { SCOPE in distributors.registered }

        // The distributor's answer, as Push.onNewEndpoint handles it.
        PushOutbox.record(SCOPE, version(E1))
        runBlocking(dispatcher) {
            feature.onNewEndpoint(SCOPE, org.unifiedpush.android.connector.data.PushEndpoint(E1, keys(K1), false))
        }
        val subscription = runBlocking { kotlinx.coroutines.withTimeout(5_000) { answered.await() } }

        assertEquals(E1, subscription?.endpoint)
        assertNull(PushOutbox.pendingVersion(SCOPE))
        Thread.sleep(300)
        shadowOf(Looper.getMainLooper()).idle()
        verify(handler, never()).onSubscriptionChanged(SCOPE)
    }

    @Test
    fun `a frozen context's change waits for Resume, then goes with its version`() {
        restricted = CONTEXT
        // A subscription whose endpoint was cleared, which the library updates.
        row(null)
        PushOutbox.record(SCOPE, version(E2))
        runBlocking(dispatcher) {
            feature.onNewEndpoint(SCOPE, org.unifiedpush.android.connector.data.PushEndpoint(E2, keys(K1), false))
        }

        eventually { PushOutbox.scopesOf(listOf(CONTEXT)).isNotEmpty() }
        verify(handler, never()).onSubscriptionChanged(SCOPE)
        assertEquals(version(E2), PushOutbox.pendingVersion(SCOPE))

        restricted = null
        drain(listOf(CONTEXT))

        verify(handler, times(1)).onSubscriptionChanged(SCOPE)
        assertTrue(PushOutbox.scopesOf(listOf(CONTEXT)).isEmpty())
        assertNull(PushOutbox.pendingVersion(SCOPE))
    }

    @Test
    fun `a death's change of a frozen context waits for Resume on the startup drain`() {
        // Written, then the process died before the delayed notification could
        // defer it: the entry has a version but no context.
        restricted = CONTEXT
        row(E2)
        PushOutbox.record(SCOPE, version(E2))
        restart()

        drain()

        verify(handler, never()).onSubscriptionChanged(SCOPE)
        assertEquals(listOf(SCOPE), PushOutbox.scopesOf(listOf(CONTEXT)))
        assertEquals(version(E2), PushOutbox.pendingVersion(SCOPE))

        restricted = null
        drain(listOf(CONTEXT))
        verify(handler, times(1)).onSubscriptionChanged(SCOPE)
        assertNull(PushOutbox.pendingVersion(SCOPE))
    }

    @Test
    fun `a renewal registers each row as it is in its own turn`() {
        val kept = "https://kept.example/"
        val gone = "https://gone.example/"
        db.add(SubscriptionsDB.Subscription(scope = kept, appServerKey = "old-key"))
        db.add(SubscriptionsDB.Subscription(scope = gone, appServerKey = "key"))
        var turns = 0
        val renewal = RegistrationRenewal(app, db, distributors, inTurn = { block ->
            // Between the listing and the first subscription's turn: one site
            // unsubscribes (row first, its UNREGISTER queued after this turn),
            // the other subscribes again with a new key.
            if (++turns == 2) {
                db.remove(gone)
                db.add(SubscriptionsDB.Subscription(scope = kept, appServerKey = "new-key"))
            }
            block()
        })

        runBlocking { renewal.run { false } }

        assertEquals(listOf(kept), distributors.registered.toList())
        assertEquals("new-key", distributors.keys[kept])
    }

    @Test
    fun `a removed subscription takes its pending change along`() {
        row(E1)
        PushOutbox.record(SCOPE, version(E2))
        PushOutbox.defer(SCOPE, CONTEXT)

        PushOutbox.removed(SCOPE)

        assertNull(PushOutbox.pendingVersion(SCOPE))
        assertTrue(PushOutbox.deliverable { false }.isEmpty())
    }

    @Test
    fun `private browsing gets no subscription, nor one an earlier build stored`() {
        row(E1, scope = PRIVATE_SCOPE)
        val delegate = WebPushEngineDelegate(feature, { it(true) }, { it.toByteArray() }, { String(it) })
        var got: Any? = "unanswered"
        var subscribed: Any? = "unanswered"

        delegate.onGetSubscription(PRIVATE_SCOPE) { got = it }
        delegate.onSubscribe("https://other.example/^privateBrowsingId=1", null) { subscribed = it }

        assertNull(got)
        assertNull(subscribed)
        Thread.sleep(300)
        assertTrue(distributors.registered.isEmpty())
        assertEquals(listOf(PRIVATE_SCOPE), db.listSubscriptions().map { it.scope })
    }

    @Test
    fun `private rows go after their registrations, with their changes, and nothing else does`() {
        row(E1)
        row(E2, scope = PRIVATE_SCOPE)
        PushOutbox.record(PRIVATE_SCOPE, version(E2))
        val rowAtUnregister = mutableListOf<Boolean>()
        val cleanup = PrivateSubscriptionCleanup(app, db, distributors, inTurn = { block ->
            rowAtUnregister += db.getSubscription(PRIVATE_SCOPE, null) != null
            block()
        })

        val left = runBlocking(dispatcher) { cleanup.run { false } }

        assertEquals(0, left)
        // The row was still there when the connector unregistered: a death
        // in between leaves it for the next start.
        assertEquals(listOf(true), rowAtUnregister)
        assertEquals(listOf(PRIVATE_SCOPE), distributors.unregistered.toList())
        assertEquals(listOf(SCOPE), db.listSubscriptions().map { it.scope })
        assertNull(PushOutbox.pendingVersion(PRIVATE_SCOPE))
    }

    @Test
    fun `a private row whose unregister failed stays for the next start`() {
        row(E2, scope = PRIVATE_SCOPE)
        val cleanup = PrivateSubscriptionCleanup(app, db, distributors, inTurn = { error("connector unavailable") })

        val left = runBlocking(dispatcher) { cleanup.run { false } }

        assertEquals(1, left)
        assertEquals(listOf(PRIVATE_SCOPE), db.listSubscriptions().map { it.scope })
    }

    @Test
    fun `a renewal never registers a private row again`() {
        row(E1)
        row(E2, scope = PRIVATE_SCOPE)
        val renewal = RegistrationRenewal(app, db, distributors, inTurn = { it() })

        runBlocking { renewal.run { false } }

        assertEquals(listOf(SCOPE), distributors.registered.toList())
    }

    @Test
    fun `a start that failed answers Gecko without the transport`() {
        row(E1)
        val delegate = WebPushEngineDelegate(feature, { it(false) }, { it.toByteArray() }, { String(it) })
        var got: Any? = "unanswered"
        var subscribed: Any? = "unanswered"
        var unsubscribed: Boolean? = null

        delegate.onGetSubscription(SCOPE) { got = it }
        delegate.onSubscribe("https://other.example/", null) { subscribed = it }
        delegate.onUnsubscribe(SCOPE) { unsubscribed = it }

        assertNull(got)
        assertNull(subscribed)
        assertEquals(false, unsubscribed)
        assertEquals(listOf(SCOPE), db.listSubscriptions().map { it.scope })
        assertTrue(distributors.registered.isEmpty())
    }

    @Test
    fun `a cold NEW_ENDPOINT leaves the row for the next start's renewal`() {
        // Without Push nothing can tell Gecko; a row written here made the
        // renewal find the same values and stay quiet.
        val profile = ProfileContext(app, StartupPaths.relativeProfilePath(PROFILE))
        SubscriptionsDB(profile).use { it.add(SubscriptionsDB.Subscription(SCOPE, E1, K1, A1)) }

        UnifiedPushReceiver().onNewEndpoint(
            profile,
            org.unifiedpush.android.connector.data.PushEndpoint(E2, keys(K2), false),
            SCOPE,
        )

        SubscriptionsDB(profile).use { assertEquals(E1, it.getSubscription(SCOPE, null)?.endpoint) }
    }

    @Test
    fun `the row reports an endpoint or key change, and nothing else`() {
        // unifiedpush-ac 1.0.8 passes one bind argument for five placeholders,
        // so every `!= ?` compares with NULL and a populated row never changes.
        row(E1)

        assertFalse(db.updateEndpoint(SCOPE, E1, K1, A1), "unchanged")
        assertTrue(db.updateEndpoint(SCOPE, E2, K1, A1), "endpoint only")
        assertEquals(E2, db.getSubscription(SCOPE, null)?.endpoint)
        assertTrue(db.updateEndpoint(SCOPE, E2, K2, A1), "key only")
        assertEquals(K2, db.getSubscription(SCOPE, null)?.publicKey)
        assertFalse(db.updateEndpoint(SCOPE, E2, K2, A1), "unchanged again")
    }

    private fun keys(publicKey: String) =
        org.unifiedpush.android.connector.data.PublicKeySet(publicKey, A1)
}
