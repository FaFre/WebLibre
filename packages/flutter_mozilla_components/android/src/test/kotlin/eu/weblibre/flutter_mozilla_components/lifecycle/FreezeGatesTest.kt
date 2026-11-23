/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.lifecycle

import eu.weblibre.flutter_mozilla_components.push.PushContextGate
import eu.weblibre.flutter_mozilla_components.startup.AtomicJsonFile
import java.io.IOException
import java.util.concurrent.Executor
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.action.DownloadAction
import mozilla.components.browser.state.selector.findTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.content.DownloadState
import mozilla.components.browser.state.state.createTab
import mozilla.components.browser.state.store.BrowserStore
import org.json.JSONObject
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * The gates fed by the registry (5.8, 5.11): push messages and subscription
 * changes of restricted contexts, and the download start gate with the
 * attribution it reads.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [28])
class FreezeGatesTest {
    private class MemoryJsonStore : JsonStore {
        var json: JSONObject? = null
        var failWrites = false

        /** Why the file reads as damaged, while it does. */
        var corrupt: String? = null
        var damagedCopies = 0

        override fun read(): AtomicJsonFile.Read = corrupt?.let { AtomicJsonFile.Read.Corrupt(it) }
            ?: json?.let { AtomicJsonFile.Read.Present(JSONObject(it.toString())) }
            ?: AtomicJsonFile.Read.Absent

        override fun write(json: JSONObject) {
            if (failWrites) throw IOException("disk full")
            corrupt = null
            this.json = JSONObject(json.toString())
        }

        override fun keepDamagedCopy() {
            damagedCopies++
        }
    }

    private object Storage : JsonStore {
        override fun read(): AtomicJsonFile.Read = AtomicJsonFile.Read.Absent
        override fun write(json: JSONObject) = Unit
        override fun keepDamagedCopy() = Unit
    }

    private val registry = TabLifecycleRegistry
    private val outbox = MemoryJsonStore()
    private val downloads = MemoryJsonStore()

    @Before
    fun setUp() {
        registry.setStorageForTest(Storage)
        PushOutbox.resetForTest(outbox)
        DownloadContexts.resetForTest(downloads)
        // The scope's suffix names the context, as GeckoView's does (F8).
        PushContextGate.decode = { scope ->
            scope.substringAfter('^', "").takeIf { it.isNotEmpty() }?.let {
                require(it != "bad") { "undecodable" }
                it
            }
        }
    }

    @After
    fun tearDown() {
        registry.resetForTest()
        PushContextGate.resetForTest()
    }

    @Test
    fun `a push to a frozen context is restricted, one to the default or another context is delivered`() {
        registry.beginFreeze("c1", listOf("ctx"))

        assertEquals(PushContextGate.Verdict.Restricted("ctx"), PushContextGate.verdict("https://a.example^ctx"))
        assertEquals(PushContextGate.Verdict.Deliver, PushContextGate.verdict("https://a.example^other"))
        assertEquals(PushContextGate.Verdict.Deliver, PushContextGate.verdict("https://a.example"))
    }

    @Test
    fun `a queued push skipped for a frozen context is counted once it is consumed, and once only`() {
        UndeliveredPushCounts.resetForTest(MemoryJsonStore())
        registry.beginFreeze("c1", listOf("ctx"))

        // Its completion failed: the worker retries, and it was not counted.
        assertNull(PushContextGate.consumeIfRestricted("https://a.example^ctx") { false })
        assertEquals(0, UndeliveredPushCounts.countOf("ctx"))

        assertEquals(true, PushContextGate.consumeIfRestricted("https://a.example^ctx") { true })
        assertEquals(1, UndeliveredPushCounts.countOf("ctx"))
        assertEquals(false, PushContextGate.consumeIfRestricted("https://a.example^other") { true })
    }

    @Test
    fun `an undecodable context is restricted while anything is`() {
        assertEquals(PushContextGate.Verdict.Deliver, PushContextGate.verdict("https://a.example^bad"))

        registry.beginFreeze("c1", listOf("ctx"))

        assertEquals(PushContextGate.Verdict.Restricted(null), PushContextGate.verdict("https://a.example^bad"))
    }

    @Test
    fun `deferred subscription changes are kept per scope and become deliverable after the lift`() {
        val gen = registry.beginFreeze("c1", listOf("ctx"))!!
        assertTrue(PushOutbox.defer("https://a.example^ctx", "ctx"))
        assertTrue(PushOutbox.defer("https://a.example^ctx", "ctx"))

        assertTrue(PushOutbox.deliverable(registry::isRestricted).isEmpty())
        assertEquals(1, outbox.json!!.getJSONObject("entries").length())

        registry.removeRecords(listOf("ctx"), gen)
        assertEquals(listOf("https://a.example^ctx"), PushOutbox.deliverable(registry::isRestricted))

        PushOutbox.delivered("https://a.example^ctx")
        assertEquals(0, outbox.json!!.getJSONObject("entries").length())
    }

    @Test
    fun `a deferral that was not written is written again by the next one of its scope`() {
        registry.beginFreeze("c1", listOf("ctx"))!!
        outbox.failWrites = true
        assertFalse(PushOutbox.defer("https://a.example^ctx", "ctx"))
        outbox.failWrites = false

        // Already in memory, but not on disk: not reported durable unwritten.
        assertTrue(PushOutbox.defer("https://a.example^ctx", "ctx"))

        assertEquals("ctx", outbox.json!!.getJSONObject("entries").getString("https://a.example^ctx"))
    }

    @Test
    fun `a deferred change of an undecodable scope waits until nothing is restricted`() {
        val first = registry.beginFreeze("c1", listOf("ctx"))!!
        val second = registry.beginFreeze("c2", listOf("ctx2"))!!
        assertTrue(PushOutbox.defer("https://a.example^bad", PushContextGate.ANY_CONTEXT))

        registry.removeRecords(listOf("ctx"), first)
        assertTrue(PushOutbox.deliverable(PushContextGate::isDeferralRestricted).isEmpty())

        registry.removeRecords(listOf("ctx2"), second)
        assertEquals(
            listOf("https://a.example^bad"),
            PushOutbox.deliverable(PushContextGate::isDeferralRestricted),
        )
    }

    @Test
    fun `the outbox survives a restart`() {
        PushOutbox.defer("https://a.example^ctx", "ctx")

        PushOutbox.resetForTest(outbox)

        assertEquals(listOf("https://a.example^ctx"), PushOutbox.scopesOf(listOf("ctx")))
    }

    @Test
    fun `a damaged outbox is kept aside before the next deferral replaces it`() {
        outbox.corrupt = "malformed json"
        PushOutbox.resetForTest(outbox)

        assertTrue(PushOutbox.defer("https://a.example^ctx", "ctx"))

        assertEquals(1, outbox.damagedCopies)
        assertEquals(listOf("https://a.example^ctx"), PushOutbox.scopesOf(listOf("ctx")))
    }

    @Test
    fun `a deferral that cannot be written says so`() {
        outbox.failWrites = true

        assertFalse(PushOutbox.defer("https://a.example^ctx", "ctx"))
    }

    @Test
    fun `downloads are attributed to their tab's context when added, and forgotten when removed`() {
        val store = BrowserStore(
            BrowserState(
                tabs = listOf(
                    createTab("https://a.example", id = "a", contextId = "ctx"),
                    createTab("https://d.example", id = "d"),
                ),
            ),
            middleware = listOf(DownloadAttributionMiddleware()),
        )

        store.dispatch(DownloadAction.AddDownloadAction(DownloadState("https://a.example/f", id = "1", sessionId = "a")))
        store.dispatch(DownloadAction.AddDownloadAction(DownloadState("https://d.example/f", id = "2", sessionId = "d")))
        store.dispatch(DownloadAction.AddDownloadAction(DownloadState("https://x.example/f", id = "3", sessionId = "gone")))

        assertEquals("ctx", DownloadContexts.contextOf("1"))
        assertEquals(DownloadContexts.DEFAULT, DownloadContexts.contextOf("2"))
        assertNull(DownloadContexts.contextOf("3"))

        store.dispatch(DownloadAction.RemoveDownloadAction("1"))
        assertNull(DownloadContexts.contextOf("1"))
    }

    @Test
    fun `a context menu save is attributed to the tab it was asked from, though the request names no session`() {
        val store = BrowserStore(
            BrowserState(
                tabs = listOf(
                    createTab("https://a.example", id = "a", contextId = "ctx"),
                    createTab("https://s.example", id = "selected", contextId = "elsewhere"),
                ),
                selectedTabId = "selected",
            ),
            middleware = listOf(DownloadAttributionMiddleware()),
        )

        // Save image or Save file: `GeckoDownloadsApiImpl.requestDownload` puts
        // the request on its source tab, with no session of its own.
        store.dispatch(ContentAction.UpdateDownloadAction("a", DownloadState("https://a.example/i.png", id = "1")))
        // AC's `DownloadsFeature` then adds what the tab holds.
        store.dispatch(DownloadAction.AddDownloadAction(store.state.findTab("a")!!.content.download!!))

        assertEquals("ctx", DownloadContexts.contextOf("1"))
    }

    @Test
    fun `the download gate refuses a frozen context's download and unknown ones while anything is frozen`() {
        DownloadContexts.record("frozen", "ctx")
        DownloadContexts.record("elsewhere", "other")
        DownloadContexts.record("default", DownloadContexts.DEFAULT)
        val download = { id: String -> DownloadState("https://a.example/f", id = id) }

        assertTrue(DownloadStartGate.mayStart(download("unknown")))

        registry.beginFreeze("c1", listOf("ctx"))

        assertFalse(DownloadStartGate.mayStart(download("frozen")))
        assertFalse(DownloadStartGate.mayStart(download("unknown")))
        assertTrue(DownloadStartGate.mayStart(download("elsewhere")))
        assertTrue(DownloadStartGate.mayStart(download("default")))
    }

    @Test
    fun `a held-back download says why, for its paused notification`() {
        DownloadContexts.record("frozen", "ctx")
        DownloadContexts.record("deleting", "gone")
        DownloadContexts.record("default", DownloadContexts.DEFAULT)
        val download = { id: String -> DownloadState("https://a.example/f", id = id) }

        assertNull(DownloadStartGate.holdOf(download("unknown")))

        registry.beginFreeze("c1", listOf("ctx"))
        registry.beginFreeze("c2", listOf("gone"))
        registry.beginDeletion("c2")

        assertEquals(DownloadStartGate.Hold.FROZEN, DownloadStartGate.holdOf(download("frozen")))
        assertEquals(DownloadStartGate.Hold.DELETING, DownloadStartGate.holdOf(download("deleting")))
        assertEquals(DownloadStartGate.Hold.UNKNOWN_CONTEXT, DownloadStartGate.holdOf(download("unknown")))
        assertNull(DownloadStartGate.holdOf(download("default")))
    }

    @Test
    fun `a download whose context could not be recorded is unknown`() {
        downloads.failWrites = true

        DownloadContexts.record("1", "ctx")

        assertNull(DownloadContexts.contextOf("1"))
    }

    @Test
    fun `download contexts count at once and are written later, off the caller's thread`() {
        val queued = mutableListOf<Runnable>()
        DownloadContexts.resetForTest(downloads, writer = Executor { queued += it })

        DownloadContexts.record("1", "ctx")
        DownloadContexts.record("2", DownloadContexts.DEFAULT)

        assertEquals("ctx", DownloadContexts.contextOf("1"))
        assertNull(downloads.json)
        // One write, of the entries as they are when it runs.
        assertEquals(1, queued.size)
        queued.single().run()
        assertEquals(setOf("1", "2"), downloads.json!!.keys().asSequence().toSet())
    }

    @Test
    fun `a context whose later write failed becomes unknown`() {
        val queued = mutableListOf<Runnable>()
        DownloadContexts.resetForTest(downloads, writer = Executor { queued += it })
        downloads.failWrites = true

        DownloadContexts.record("1", "ctx")
        queued.single().run()

        assertNull(DownloadContexts.contextOf("1"))
    }
}
