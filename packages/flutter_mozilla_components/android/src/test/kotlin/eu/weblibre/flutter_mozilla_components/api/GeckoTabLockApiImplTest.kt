/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.pigeons.TabLockChange
import eu.weblibre.flutter_mozilla_components.pigeons.TabLockRejection
import eu.weblibre.flutter_mozilla_components.tabs.FakeTabLockStorage
import eu.weblibre.flutter_mozilla_components.tabs.TabCloseProtection
import java.io.IOException
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.createCustomTab
import mozilla.components.browser.state.state.createTab
import mozilla.components.browser.state.store.BrowserStore

/**
 * A lock is acknowledged only once its tab is in the session file, and a lock
 * that could not be saved never comes back as acknowledged on a retry.
 */
class GeckoTabLockApiImplTest {
    private val storage = FakeTabLockStorage()
    private val store = BrowserStore(
        BrowserState(
            tabs = listOf(
                createTab("https://a.example", id = "a"),
                createTab("https://p.example", id = "p", private = true),
            ),
            customTabs = listOf(createCustomTab("https://c.example", id = "custom")),
        ),
    )

    private var saves = 0
    private var failSave: (() -> Unit)? = null

    private val api = GeckoTabLockApiImpl(
        session = {
            TabLockSession(store) {
                saves++
                failSave?.invoke()
            }
        },
        mainDispatcher = Dispatchers.Unconfined,
        ioDispatcher = Dispatchers.Unconfined,
    )

    @BeforeTest
    fun setUp() {
        TabCloseProtection.setStorageForTest(storage)
    }

    @AfterTest
    fun tearDown() {
        TabCloseProtection.resetForTest()
    }

    private fun lock(tabId: String) = runBlocking { api.setTabLocked(tabId, locked = true) }

    @Test
    fun `a lock is acknowledged after the session was saved`() {
        assertEquals(TabLockChange(previouslyLocked = false), lock("a"))

        assertEquals(1, saves)
        assertTrue(TabCloseProtection.isLocked("a"))
        assertEquals(setOf("a"), storage.persisted)
    }

    @Test
    fun `a lock whose session save fails is taken back`() {
        failSave = { throw IOException("disk full") }

        val change = lock("a")

        assertEquals(TabLockRejection.NOT_PERSISTED, change.rejection)
        assertFalse(TabCloseProtection.isLocked("a"))
    }

    @Test
    fun `a retry after a failed save and a failed revert saves the session again`() {
        // The save fails, and so does the write that would take the lock back.
        failSave = {
            storage.failWrites = true
            throw IOException("disk full")
        }
        assertEquals(TabLockRejection.NOT_PERSISTED, lock("a").rejection)
        assertTrue(TabCloseProtection.isLocked("a"), "left locked: the safe side")

        storage.failWrites = false
        failSave = null
        val retry = lock("a")

        // Native held it already, but that lock was never acknowledged: the
        // retry is acknowledged only once the session is on disk.
        assertEquals(TabLockChange(previouslyLocked = true), retry)
        assertEquals(2, saves)
    }

    @Test
    fun `a retry whose save fails again is refused and keeps the earlier lock`() {
        failSave = {
            storage.failWrites = true
            throw IOException("disk full")
        }
        lock("a")
        storage.failWrites = false

        val retry = lock("a")

        assertEquals(TabLockRejection.NOT_PERSISTED, retry.rejection)
        assertTrue(retry.previouslyLocked)
        assertTrue(TabCloseProtection.isLocked("a"))
    }

    @Test
    fun `private, custom and unknown tabs are refused without saving`() {
        assertEquals(TabLockRejection.PRIVATE_TAB, lock("p").rejection)
        assertEquals(TabLockRejection.CUSTOM_TAB, lock("custom").rejection)
        assertEquals(TabLockRejection.UNKNOWN_TAB, lock("gone").rejection)

        assertEquals(0, saves)
        assertTrue(TabCloseProtection.lockedTabIds().isEmpty())
    }

    @Test
    fun `an unlock needs no session save`() {
        lock("a")

        val change = runBlocking { api.setTabLocked("a", locked = false) }

        assertEquals(TabLockChange(previouslyLocked = true), change)
        assertEquals(1, saves)
        assertFalse(TabCloseProtection.isLocked("a"))
    }

    @Test
    fun `reconciling keeps only the database's locks of open tabs`() {
        TabCloseProtection.bootstrap(listOf("a", "closed-since"))

        val pruned = api.reconcileLockedTabs(listOf("closed-since"))

        assertEquals(setOf("a", "closed-since"), pruned.toSet())
        assertTrue(TabCloseProtection.lockedTabIds().isEmpty())
    }
}
