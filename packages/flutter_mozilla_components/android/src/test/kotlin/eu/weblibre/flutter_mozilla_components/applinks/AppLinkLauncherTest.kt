/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import android.content.ActivityNotFoundException
import android.content.Intent
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.ArgumentMatchers.anyBoolean
import org.mockito.ArgumentMatchers.anyString
import org.mockito.Mockito.mock
import org.mockito.Mockito.`when`

class AppLinkLauncherTest {
    private class FakeClock(var now: Long = 0L) : MonotonicClock {
        override fun elapsedRealtime(): Long = now
    }

    private fun resolvedFor(packageName: String?, marketplace: Boolean = false): ResolvedAppLink {
        return ResolvedAppLink(
            hasExternalApp = packageName != null,
            appIntent = if (packageName != null) mock(Intent::class.java) else null,
            packageName = packageName,
            appName = "App",
            fallbackUrl = null,
            marketplaceIntent = if (marketplace) mock(Intent::class.java) else null,
            isAmbiguous = false,
            engineSupportsScheme = false,
            scopeKey = "pkg:$packageName",
            originalScheme = "zoommtg",
            intentDataScheme = "zoommtg",
        )
    }

    private fun launcher(
        resolved: ResolvedAppLink,
        clock: FakeClock,
        onStart: (Intent) -> Unit = {},
    ): AppLinkLauncher {
        val resolver = mock(ExternalAppResolver::class.java)
        `when`(resolver.resolve(anyString(), anyBoolean(), anyBoolean())).thenReturn(resolved)
        return AppLinkLauncher(resolver, onStart, clock)
    }

    @Test
    fun noAppReturnsNoApp() {
        val l = launcher(resolvedFor(null), FakeClock())
        assertEquals(AppLinkLaunchResult.NO_APP, l.launch("zoommtg://x", AppLinkLaunchMode.MANUAL))
    }

    @Test
    fun packageMismatchIsRefused() {
        val l = launcher(resolvedFor("com.actual.app"), FakeClock())
        assertEquals(
            AppLinkLaunchResult.PACKAGE_MISMATCH,
            l.launch("zoommtg://x", AppLinkLaunchMode.AUTOMATIC, expectedPackage = "com.expected.app"),
        )
    }

    @Test
    fun successfulManualLaunchStartsActivity() {
        var started = 0
        val l = launcher(resolvedFor("com.example.app"), FakeClock()) { started++ }
        assertEquals(AppLinkLaunchResult.LAUNCHED, l.launch("zoommtg://x", AppLinkLaunchMode.MANUAL))
        assertEquals(1, started)
    }

    @Test
    fun automaticLaunchWithinCooldownIsRefused() {
        val clock = FakeClock(1000L)
        val l = launcher(resolvedFor("com.example.app"), clock)
        assertEquals(AppLinkLaunchResult.LAUNCHED, l.launch("zoommtg://x", AppLinkLaunchMode.AUTOMATIC))
        clock.now = 1500L // < 2000 ms later
        assertEquals(AppLinkLaunchResult.COOLDOWN, l.launch("zoommtg://x", AppLinkLaunchMode.AUTOMATIC))
    }

    @Test
    fun automaticLaunchAfterCooldownSucceeds() {
        val clock = FakeClock(1000L)
        val l = launcher(resolvedFor("com.example.app"), clock)
        assertEquals(AppLinkLaunchResult.LAUNCHED, l.launch("zoommtg://x", AppLinkLaunchMode.AUTOMATIC))
        clock.now = 3001L // > 2000 ms later
        assertEquals(AppLinkLaunchResult.LAUNCHED, l.launch("zoommtg://x", AppLinkLaunchMode.AUTOMATIC))
    }

    @Test
    fun manualLaunchBypassesCooldownButRecordsIt() {
        val clock = FakeClock(1000L)
        val l = launcher(resolvedFor("com.example.app"), clock)
        // Two manual launches back-to-back both succeed (user gesture bypasses the check).
        assertEquals(AppLinkLaunchResult.LAUNCHED, l.launch("zoommtg://x", AppLinkLaunchMode.MANUAL))
        assertEquals(AppLinkLaunchResult.LAUNCHED, l.launch("zoommtg://x", AppLinkLaunchMode.MANUAL))
        // But the manual launch recorded the timestamp, so a following automatic launch is cooled.
        assertEquals(AppLinkLaunchResult.COOLDOWN, l.launch("zoommtg://x", AppLinkLaunchMode.AUTOMATIC))
    }

    @Test
    fun activityNotFoundYieldsFailed() {
        val l = launcher(resolvedFor("com.example.app"), FakeClock()) {
            throw ActivityNotFoundException("no activity")
        }
        assertEquals(AppLinkLaunchResult.FAILED, l.launch("zoommtg://x", AppLinkLaunchMode.MANUAL))
    }

    @Test
    fun marketplaceModeWithoutMarketplaceIntentIsNoApp() {
        val l = launcher(resolvedFor("com.example.app", marketplace = false), FakeClock())
        assertEquals(AppLinkLaunchResult.NO_APP, l.launch("market://x", AppLinkLaunchMode.MARKETPLACE))
    }
}
