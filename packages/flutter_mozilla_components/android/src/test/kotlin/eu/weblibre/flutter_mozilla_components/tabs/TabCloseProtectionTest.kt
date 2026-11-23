/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.tabs

import android.content.Context
import eu.weblibre.flutter_mozilla_components.ActiveProfile
import eu.weblibre.flutter_mozilla_components.startup.StartupArbiter
import eu.weblibre.flutter_mozilla_components.startup.StartupPaths
import java.io.File
import java.io.IOException
import java.nio.file.Files
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import org.json.JSONObject
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

private const val PROFILE_A = "0199a0b1-1111-7111-8111-111111111111"

/**
 * Native's copy of the tab locks: every change is durable before it is answered,
 * and a change that could not be written leaves the previous set in force.
 */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class TabCloseProtectionTest {
    private val context: Context = RuntimeEnvironment.getApplication()
    private val tempDirs = mutableListOf<File>()

    @Before
    fun setUp() {
        StartupArbiter.resetForTest()
        TabCloseProtection.resetForTest()
    }

    @After
    fun tearDown() {
        TabCloseProtection.resetForTest()
        StartupArbiter.resetForTest()
        tempDirs.forEach { it.deleteRecursively() }
    }

    /** Commits [profileId] as this process's profile, as a headless start does. */
    private fun commitProfile(profileId: String) {
        val filesDir = Files.createTempDirectory("weblibre_tab_locks").toFile()
        tempDirs += filesDir
        val paths = StartupPaths(filesDir)
        val profileDir = File(paths.profilesDir, "profile-$profileId")
        profileDir.mkdirs()
        File(profileDir, StartupPaths.PROFILE_METADATA_FILE_NAME).writeText(
            JSONObject().put("id", profileId).put("name", "Profile").toString(),
        )

        StartupArbiter.initialize(paths, { })
        StartupArbiter.tryCommitExternal(null, trusted = false)
        assertEquals("profile-$profileId", ActiveProfile.prefix)
    }

    @Test
    fun `the bootstrap is trusted and works before any tab exists`() {
        commitProfile(PROFILE_A)
        TabCloseProtection.attach(context)

        TabCloseProtection.bootstrap(listOf("restored-later"))

        assertTrue(TabCloseProtection.isLocked("restored-later"))
    }

    @Test
    fun `locks survive a restart of the process`() {
        commitProfile(PROFILE_A)
        TabCloseProtection.attach(context)
        TabCloseProtection.bootstrap(listOf("a"))
        TabCloseProtection.set("b", locked = true)

        // A new process: nothing in memory, read back from the profile's prefs.
        TabCloseProtection.resetForTest()
        TabCloseProtection.attach(context)

        assertEquals(setOf("a", "b"), TabCloseProtection.lockedTabIds())
    }

    @Test
    fun `nothing is readable or writable before the profile is committed`() {
        TabCloseProtection.attach(context)

        assertFalse(TabCloseProtection.isLocked("a"))
        assertFailsWith<IOException> { TabCloseProtection.bootstrap(listOf("a")) }
    }

    @Test
    fun `set returns the previous value`() {
        TabCloseProtection.setStorageForTest(FakeTabLockStorage())

        assertFalse(TabCloseProtection.set("a", locked = true))
        assertTrue(TabCloseProtection.set("a", locked = true))
        assertTrue(TabCloseProtection.set("a", locked = false))
        assertFalse(TabCloseProtection.isLocked("a"))
    }

    @Test
    fun `a lock that cannot be written is taken back`() {
        val storage = FakeTabLockStorage().apply { failWrites = true }
        TabCloseProtection.setStorageForTest(storage)

        assertFailsWith<IOException> { TabCloseProtection.set("a", locked = true) }

        assertFalse(TabCloseProtection.isLocked("a"))
        assertTrue(storage.persisted.isEmpty())
    }

    @Test
    fun `an unlock that cannot be written leaves the tab locked`() {
        val storage = FakeTabLockStorage(persisted = setOf("a"))
        TabCloseProtection.setStorageForTest(storage)
        storage.failWrites = true

        assertFailsWith<IOException> { TabCloseProtection.set("a", locked = false) }

        assertTrue(TabCloseProtection.isLocked("a"))
    }

    @Test
    fun `a failed bootstrap keeps the persisted set in force`() {
        val storage = FakeTabLockStorage(persisted = setOf("a", "native-only"))
        TabCloseProtection.setStorageForTest(storage)
        storage.failWrites = true

        assertFailsWith<IOException> { TabCloseProtection.bootstrap(listOf("a")) }

        assertEquals(setOf("a", "native-only"), TabCloseProtection.lockedTabIds())
    }

    @Test
    fun `replace prunes and reports what it dropped`() {
        TabCloseProtection.setStorageForTest(FakeTabLockStorage(persisted = setOf("a", "b", "c")))

        val pruned = TabCloseProtection.replace(listOf("a", "c"))

        assertEquals(setOf("b"), pruned)
        assertEquals(setOf("a", "c"), TabCloseProtection.lockedTabIds())
    }

    @Test
    fun `a replace that cannot be written prunes nothing`() {
        val storage = FakeTabLockStorage(persisted = setOf("a", "b"))
        TabCloseProtection.setStorageForTest(storage)
        storage.failWrites = true

        assertFailsWith<IOException> { TabCloseProtection.replace(listOf("a")) }

        assertEquals(setOf("a", "b"), TabCloseProtection.lockedTabIds())
    }

    @Test
    fun `lockedAmong keeps the caller's order`() {
        TabCloseProtection.setStorageForTest(FakeTabLockStorage(persisted = setOf("c", "a")))

        assertEquals(listOf("a", "c"), TabCloseProtection.lockedAmong(listOf("a", "b", "c")))
    }
}
