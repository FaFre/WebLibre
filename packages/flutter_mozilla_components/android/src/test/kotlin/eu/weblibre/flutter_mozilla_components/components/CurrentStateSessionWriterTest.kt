/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.components

import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import kotlin.concurrent.thread
import kotlin.test.Test
import java.io.IOException
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertTrue
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.createTab

private val withTabs = BrowserState(tabs = listOf(createTab("https://example.org")))
private val empty = BrowserState()

/** Records every write, optionally holding the first one open until released. */
private class RecordingStorage(
    private val holdFirstWrite: CountDownLatch? = null,
    private val firstWriteStarted: CountDownLatch? = null,
    /** What every write reports, as `SessionStorage.save` does on an I/O failure. */
    private val succeeds: Boolean = true,
) : mozilla.components.browser.session.storage.AutoSave.Storage {
    val written = mutableListOf<BrowserState>()

    override fun save(state: BrowserState): Boolean {
        synchronized(written) { written += state }
        if (written.size == 1) {
            firstWriteStarted?.countDown()
            holdFirstWrite?.await(5, TimeUnit.SECONDS)
        }
        return succeeds
    }
}

class CurrentStateSessionWriterTest {
    @Test
    fun `a read while not writing waits for the write in progress`() {
        // An autosave read the store with a tab that is closed just after, and is
        // mid-write: a Quit reading the file now must see that write, not the
        // file from before it.
        val release = CountDownLatch(1)
        val started = CountDownLatch(1)
        val storage = RecordingStorage(holdFirstWrite = release, firstWriteStarted = started)
        val writer = CurrentStateSessionWriter(storage, { withTabs }, isCleared = { true })

        val autosave = thread { writer.save(withTabs) }
        assertTrue(started.await(5, TimeUnit.SECONDS))

        var writesSeen = -1
        val quit = thread {
            writer.whileNotWriting { writesSeen = synchronized(storage.written) { storage.written.size } }
        }

        quit.join(200)
        assertTrue(quit.isAlive)

        release.countDown()
        autosave.join(5_000)
        quit.join(5_000)

        // The write had finished by the time the file was read.
        assertEquals(1, writesSeen)
    }

    @Test
    fun `a stale autosave snapshot is replaced by the current state`() {
        val storage = RecordingStorage()
        val writer = CurrentStateSessionWriter(storage, { empty }, isCleared = { true })

        // AutoSave read the store before every tab was removed.
        writer.save(withTabs)

        assertEquals(listOf(empty), storage.written)
    }

    @Test
    fun `a write queued behind another reads the state at its own turn`() {
        var current = withTabs
        val release = CountDownLatch(1)
        val started = CountDownLatch(1)
        val storage = RecordingStorage(holdFirstWrite = release, firstWriteStarted = started)
        val writer = CurrentStateSessionWriter(storage, { current }, isCleared = { true })

        // An autosave is mid-write with the tabs still there...
        val autosave = thread { writer.save(withTabs) }
        assertTrue(started.await(5, TimeUnit.SECONDS))

        // ...when they are all removed and the removal is saved explicitly.
        current = empty
        val explicit = thread { writer.saveCurrentState() }

        // It waits for the write in progress instead of racing it.
        explicit.join(200)
        assertTrue(explicit.isAlive)
        assertEquals(1, synchronized(storage.written) { storage.written.size })

        release.countDown()
        autosave.join(5_000)
        explicit.join(5_000)

        // The removal is what ends up on disk, whatever order the threads ran in.
        assertEquals(listOf(withTabs, empty), storage.written)
    }

    @Test
    fun `a write that did not reach disk is an error`() {
        val writer = CurrentStateSessionWriter(
            RecordingStorage(succeeds = false),
            { withTabs },
            isCleared = { true },
        )

        assertFailsWith<IOException> { writer.saveCurrentStateOrThrow() }
    }

    @Test
    fun `an empty session whose file was not removed is an error`() {
        val writer = CurrentStateSessionWriter(
            RecordingStorage(),
            { empty },
            isCleared = { false },
        )

        assertFailsWith<IOException> { writer.saveCurrentStateOrThrow() }
    }

    @Test
    fun `a session with tabs is not checked for removal`() {
        var checked = false
        val writer = CurrentStateSessionWriter(
            RecordingStorage(),
            { withTabs },
            isCleared = { checked = true; false },
        )

        writer.saveCurrentStateOrThrow()

        assertEquals(false, checked)
    }

    @Test
    fun `a durable save that worked returns normally`() {
        val storage = RecordingStorage()
        val writer = CurrentStateSessionWriter(storage, { empty }, isCleared = { true })

        writer.saveCurrentStateOrThrow()

        assertEquals(listOf(empty), storage.written)
    }
}
