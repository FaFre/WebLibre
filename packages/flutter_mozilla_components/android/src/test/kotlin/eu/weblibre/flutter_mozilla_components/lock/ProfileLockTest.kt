/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.lock

import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue
import org.json.JSONObject

class ProfileLockSettingsTest {
    private fun parse(json: String) = ProfileLockSettings.parse(JSONObject(json))

    @Test
    fun aProfileWithoutAuthSettingsIsOpen() {
        assertEquals(ProfileLockSettings.UNLOCKED, parse("""{"id":"x","name":"n"}"""))
        assertEquals(
            ProfileLockSettings.UNLOCKED,
            parse("""{"id":"x","name":"n","authSettings":null}"""),
        )
    }

    @Test
    fun readsWhatDartWrites() {
        val settings = parse(
            """{"authSettings":{"lockMethod":"password","passwordVerifier":"abc",
               "autoLockMode":"timeout","timeout":120000000,
               "authenticationRequired":true}}""",
        )

        assertEquals(ProfileLockMethod.PASSWORD, settings.method)
        assertEquals(AutoLockMode.TIMEOUT, settings.autoLockMode)
        // Dart writes a Duration in microseconds.
        assertEquals(120_000L, settings.timeoutMs)
    }

    @Test
    fun theOldBooleanMeansTheDeviceLock() {
        val locked = parse(
            """{"authSettings":{"authenticationRequired":true,
               "autoLockMode":"background","timeout":0}}""",
        )
        val open = parse(
            """{"authSettings":{"authenticationRequired":false,
               "autoLockMode":"background","timeout":0}}""",
        )

        assertEquals(ProfileLockMethod.DEVICE, locked.method)
        assertEquals(ProfileLockMethod.NONE, open.method)
    }

    /** Dart's `unknownEnumValue`. */
    @Test
    fun anUnknownMethodFromANewerBuildIsTheDeviceLock() {
        val settings = parse("""{"authSettings":{"lockMethod":"passkey"}}""")

        assertEquals(ProfileLockMethod.DEVICE, settings.method)
    }

    @Test
    fun anUnknownAutoLockModeIsTheStrictestOne() {
        val settings = parse(
            """{"authSettings":{"lockMethod":"device","autoLockMode":"never"}}""",
        )

        assertEquals(AutoLockMode.BACKGROUND, settings.autoLockMode)
    }

    @Test
    fun aDamagedObjectFailsClosed() {
        assertEquals(
            ProfileLockSettings.UNREADABLE,
            parse("""{"authSettings":"password"}"""),
        )
        assertEquals(
            ProfileLockSettings.UNREADABLE,
            parse("""{"authSettings":{"lockMethod":3}}"""),
        )
        assertTrue(ProfileLockSettings.UNREADABLE.isLocked)
    }
}

class ProfileUnlockRegistryTest {
    private var now = 1_000_000L

    private val background = settings(AutoLockMode.BACKGROUND)
    private val timeout = settings(AutoLockMode.TIMEOUT, timeoutMs = 60_000L)
    private val startup = settings(AutoLockMode.STARTUP)

    private fun settings(
        mode: AutoLockMode,
        method: ProfileLockMethod = ProfileLockMethod.PASSWORD,
        timeoutMs: Long = 300_000L,
    ) = ProfileLockSettings(method, mode, timeoutMs)

    @BeforeTest
    fun setUp() {
        ProfileUnlockRegistry.resetForTest()
        ProfileUnlockRegistry.clock = { now }
    }

    @AfterTest
    fun tearDown() {
        ProfileUnlockRegistry.resetForTest()
    }

    @Test
    fun anOpenProfileNeedsNoUnlock() {
        assertTrue(ProfileUnlockRegistry.isUnlocked("p", ProfileLockSettings.UNLOCKED))
    }

    @Test
    fun aLockedProfileStartsLocked() {
        assertFalse(ProfileUnlockRegistry.isUnlocked("p", background))
    }

    @Test
    fun leavingEndsABackgroundUnlockAndCountsAsLeaving() {
        ProfileUnlockRegistry.record("p", background)
        assertTrue(ProfileUnlockRegistry.isUnlocked("p", background))

        val before = ProfileUnlockRegistry.departureCount()
        ProfileUnlockRegistry.evictOnLeave()

        assertFalse(ProfileUnlockRegistry.isUnlocked("p", background))
        assertEquals(before + 1, ProfileUnlockRegistry.departureCount())
    }

    @Test
    fun leavingKeepsTimeoutAndStartupUnlocks() {
        ProfileUnlockRegistry.record("t", timeout)
        ProfileUnlockRegistry.record("s", startup)

        ProfileUnlockRegistry.evictOnLeave()

        assertTrue(ProfileUnlockRegistry.isUnlocked("t", timeout))
        assertTrue(ProfileUnlockRegistry.isUnlocked("s", startup))
    }

    @Test
    fun aTimeoutUnlockEnds() {
        ProfileUnlockRegistry.record("p", timeout)

        now += 59_999L
        assertTrue(ProfileUnlockRegistry.isUnlocked("p", timeout))

        now += 1L
        assertFalse(ProfileUnlockRegistry.isUnlocked("p", timeout))
    }

    @Test
    fun aShorterTimeoutSetSinceCounts() {
        ProfileUnlockRegistry.record("p", timeout)
        now += 30_000L

        assertFalse(
            ProfileUnlockRegistry.isUnlocked(
                "p",
                settings(AutoLockMode.TIMEOUT, timeoutMs = 20_000L),
            ),
        )
    }

    @Test
    fun anUnlockUnderAnotherModeDoesNotCount() {
        ProfileUnlockRegistry.record("p", startup)

        assertFalse(ProfileUnlockRegistry.isUnlocked("p", background))
    }

    @Test
    fun theBrowsersUnlockIsSharedWithItsAge() {
        ProfileUnlockRegistry.recordShared("p", AutoLockMode.TIMEOUT, 60_000L, ageMs = 50_000L)

        assertTrue(ProfileUnlockRegistry.isUnlocked("p", timeout))
        now += 10_000L
        assertFalse(ProfileUnlockRegistry.isUnlocked("p", timeout))
    }

    @Test
    fun aBackgroundReportFromTheBrowserClearsTheWindowsUnlock() {
        ProfileUnlockRegistry.record("p", startup)

        ProfileUnlockRegistry.recordShared("p", AutoLockMode.BACKGROUND, 0L, ageMs = 0L)

        assertFalse(ProfileUnlockRegistry.isUnlocked("p", startup))
    }

    @Test
    fun forgettingTheSharedUnlockLocks() {
        ProfileUnlockRegistry.record("p", startup)

        ProfileUnlockRegistry.forgetShared("p")

        assertFalse(ProfileUnlockRegistry.isUnlocked("p", startup))
    }

    @Test
    fun theBrowserCannotTakeBackAWindowsBackgroundUnlock() {
        ProfileUnlockRegistry.record("p", background)

        ProfileUnlockRegistry.forgetShared("p")
        ProfileUnlockRegistry.recordShared("p", AutoLockMode.BACKGROUND, 0L, ageMs = 0L)

        assertTrue(ProfileUnlockRegistry.isUnlocked("p", background))

        ProfileUnlockRegistry.evictOnLeave()
        assertFalse(ProfileUnlockRegistry.isUnlocked("p", background))
    }

    @Test
    fun onlyTimeoutAndStartupUnlocksAreHandedToTheBrowser() {
        ProfileUnlockRegistry.record("b", background)
        ProfileUnlockRegistry.record("t", timeout)
        ProfileUnlockRegistry.record("s", startup)
        now += 5_000L

        assertNull(ProfileUnlockRegistry.shared("b"))
        assertEquals(SharedUnlock(AutoLockMode.TIMEOUT, 60_000L, 5_000L), ProfileUnlockRegistry.shared("t"))
        assertEquals(AutoLockMode.STARTUP, ProfileUnlockRegistry.shared("s")?.mode)

        now += 60_000L
        assertNull(ProfileUnlockRegistry.shared("t"))
    }

    // Deferred departures: a pause is only leaving once something settles it.

    private val windowA = Any()
    private val windowB = Any()

    @Test
    fun aPauseTheWindowComesBackFromIsNotLeaving() {
        ProfileUnlockRegistry.record("p", background)
        val before = ProfileUnlockRegistry.departureCount()
        var left = false

        // A permission dialog, the share sheet, an internal trampoline.
        ProfileUnlockRegistry.windowPaused(windowA) { left = true }
        ProfileUnlockRegistry.windowResumed(windowA)

        assertTrue(ProfileUnlockRegistry.isUnlocked("p", background))
        assertEquals(before, ProfileUnlockRegistry.departureCount())
        assertFalse(left)
    }

    @Test
    fun goingOutOfSightAfterAPauseIsLeaving() {
        ProfileUnlockRegistry.record("p", background)
        val before = ProfileUnlockRegistry.departureCount()
        var left = false

        ProfileUnlockRegistry.windowPaused(windowA) { left = true }
        ProfileUnlockRegistry.windowStopped(windowA)

        assertFalse(ProfileUnlockRegistry.isUnlocked("p", background))
        assertEquals(before + 1, ProfileUnlockRegistry.departureCount())
        assertTrue(left)
    }

    @Test
    fun anotherWindowTakingTheFrontIsLeavingBeforeItChecks() {
        ProfileUnlockRegistry.record("p", background)
        val before = ProfileUnlockRegistry.departureCount()
        var left = false

        // The next window resumes before this one stops.
        ProfileUnlockRegistry.windowPaused(windowA) { left = true }
        ProfileUnlockRegistry.windowResumed(windowB)

        assertFalse(ProfileUnlockRegistry.isUnlocked("p", background))
        assertTrue(left)

        // Settled once, not again when it stops.
        ProfileUnlockRegistry.windowStopped(windowA)
        assertEquals(before + 1, ProfileUnlockRegistry.departureCount())
    }

    @Test
    fun aStopWithoutAPendingPauseIsNotLeaving() {
        ProfileUnlockRegistry.record("p", background)
        val before = ProfileUnlockRegistry.departureCount()

        // A rotation's stop, or the cleanup in `onDestroy`.
        ProfileUnlockRegistry.windowStopped(windowA)

        assertTrue(ProfileUnlockRegistry.isUnlocked("p", background))
        assertEquals(before, ProfileUnlockRegistry.departureCount())
    }

    @Test
    fun aClosedPictureInPictureWindowLeft() {
        ProfileUnlockRegistry.record("p", background)
        var left = false

        ProfileUnlockRegistry.windowLeft { left = true }

        assertFalse(ProfileUnlockRegistry.isUnlocked("p", background))
        assertTrue(left)
    }

    @Test
    fun leavingStillKeepsTimeoutAndStartupUnlocks() {
        ProfileUnlockRegistry.record("t", timeout)
        ProfileUnlockRegistry.record("s", startup)

        ProfileUnlockRegistry.windowPaused(windowA) {}
        ProfileUnlockRegistry.windowStopped(windowA)

        assertTrue(ProfileUnlockRegistry.isUnlocked("t", timeout))
        assertTrue(ProfileUnlockRegistry.isUnlocked("s", startup))
    }
}
