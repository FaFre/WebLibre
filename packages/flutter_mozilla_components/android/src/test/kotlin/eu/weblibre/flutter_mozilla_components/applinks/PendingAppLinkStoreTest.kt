/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import eu.weblibre.flutter_mozilla_components.pigeons.AppLinkPromptOwner
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

class PendingAppLinkStoreTest {
    private class FakeClock(var now: Long = 0L) : MonotonicClock {
        override fun elapsedRealtime(): Long = now
    }

    private fun newRequest(
        tabId: String = "tab1",
        fingerprint: String = "fp1",
        owner: AppLinkPromptOwner = AppLinkPromptOwner.FLUTTER_BROWSER,
        urlClass: AppLinkUrlClass = AppLinkUrlClass.MODAL,
        url: String = "zoommtg://join",
        isUserGesture: Boolean = false,
    ) = NewAppLinkRequest(
        owner = owner,
        tabId = tabId,
        contextId = null,
        sourceUrl = null,
        isPrivate = false,
        isWallet = false,
        isProtectedContext = false,
        canRemember = true,
        isModal = urlClass == AppLinkUrlClass.MODAL,
        urlClass = urlClass,
        url = url,
        expectedPackage = null,
        fallbackUrl = null,
        engineSupportsScheme = false,
        isMarketplace = false,
        targetFingerprint = fingerprint,
        appName = "App",
        packageName = "com.app",
        scopeKey = "pkg:com.app",
        isUserGesture = isUserGesture,
    )

    @Test
    fun idsAreMonotonic() {
        val store = PendingAppLinkStore(FakeClock())
        val a = store.createRequest(newRequest(fingerprint = "a"))
        val b = store.createRequest(newRequest(fingerprint = "b"))
        assertNotEquals(a.requestId, b.requestId)
        assertTrue(b.requestId > a.requestId)
    }

    @Test
    fun queryIsNonConsumingAndConsumeIsAtomic() {
        val store = PendingAppLinkStore(FakeClock())
        val request = store.createRequest(newRequest())
        assertEquals(1, store.getPending(AppLinkPromptOwner.FLUTTER_BROWSER).size)
        // Non-consuming.
        assertEquals(1, store.getPending(AppLinkPromptOwner.FLUTTER_BROWSER).size)
        assertEquals(request.requestId, store.consume(request.requestId)?.requestId)
        // Double-consume is a no-op.
        assertNull(store.consume(request.requestId))
    }

    @Test
    fun ownerFilterSeparatesSurfaces() {
        val store = PendingAppLinkStore(FakeClock())
        store.createRequest(newRequest(owner = AppLinkPromptOwner.FLUTTER_BROWSER, fingerprint = "a"))
        store.createRequest(newRequest(owner = AppLinkPromptOwner.NATIVE_EXTERNAL, fingerprint = "b"))
        assertEquals(1, store.getPending(AppLinkPromptOwner.FLUTTER_BROWSER).size)
        assertEquals(1, store.getPending(AppLinkPromptOwner.NATIVE_EXTERNAL).size)
    }

    @Test
    fun dedupeCollapsesWithinWindowButNotAcrossUserGesture() {
        val clock = FakeClock()
        val store = PendingAppLinkStore(clock, dedupeWindowMs = 2000L)
        val first = store.createRequest(newRequest())
        clock.now = 1000L
        val second = store.createRequest(newRequest())
        assertEquals(first.requestId, second.requestId)

        // A user-gesture attempt is never deduped.
        val gesture = store.createRequest(newRequest(isUserGesture = true))
        assertNotEquals(first.requestId, gesture.requestId)
    }

    @Test
    fun distinctFingerprintsSharingAScopeAreNotDeduped() {
        val store = PendingAppLinkStore(FakeClock())
        val a = store.createRequest(newRequest(fingerprint = "path-a"))
        val b = store.createRequest(newRequest(fingerprint = "path-b"))
        assertNotEquals(a.requestId, b.requestId)
    }

    @Test
    fun bannerTargetCommitKeepsRequestButUnrelatedCommitInvalidates() {
        val store = PendingAppLinkStore(FakeClock())
        val banner = store.createRequest(
            newRequest(urlClass = AppLinkUrlClass.BANNER, url = "https://youtu.be/x"),
        )
        // The banner's own target committing keeps it alive.
        store.onCommittedNavigation("tab1", "https://youtu.be/x")
        assertNotNull(store.peek(banner.requestId))
        // An unrelated commit invalidates it.
        store.onCommittedNavigation("tab1", "https://example.com/other")
        assertNull(store.peek(banner.requestId))
    }

    @Test
    fun bannerSurvivesSameSiteRedirectAndNormalisation() {
        val store = PendingAppLinkStore(FakeClock())
        // The intercepted URL is rarely byte-identical to the committed one: the initial
        // load redirects/normalises (www stripped, tracking params added, trailing slash).
        val banner = store.createRequest(
            newRequest(urlClass = AppLinkUrlClass.BANNER, url = "https://www.reddit.com/r/foo"),
        )
        store.onCommittedNavigation("tab1", "https://reddit.com/r/foo/?utm_source=share")
        assertNotNull(store.peek(banner.requestId))

        // A commit to a genuinely different site still invalidates it.
        store.onCommittedNavigation("tab1", "https://twitter.com/reddit")
        assertNull(store.peek(banner.requestId))
    }

    @Test
    fun tabCloseInvalidatesRequestsAndSuppression() {
        val store = PendingAppLinkStore(FakeClock())
        val request = store.createRequest(newRequest())
        store.recordSuppression("tab1", "fp1")
        store.invalidateTab("tab1")
        assertNull(store.peek(request.requestId))
        assertFalse(store.isSuppressed("tab1", "fp1"))
    }

    @Test
    fun suppressionSurvivesRedirectsButClearsOnDirectNavAndTimeout() {
        val clock = FakeClock()
        val store = PendingAppLinkStore(clock, suppressionExpiryMs = 1000L)
        store.recordSuppression("tab1", "fp1")
        assertTrue(store.isSuppressed("tab1", "fp1"))
        // Ordinary committed navigation does not clear it.
        store.onCommittedNavigation("tab1", "https://redirect.example")
        assertTrue(store.isSuppressed("tab1", "fp1"))
        // Direct navigation clears it.
        store.clearSuppressionForTab("tab1")
        assertFalse(store.isSuppressed("tab1", "fp1"))

        // Timeout clears it.
        store.recordSuppression("tab1", "fp2")
        clock.now = 1001L
        assertFalse(store.isSuppressed("tab1", "fp2"))
    }

    @Test
    fun requestsExpire() {
        val clock = FakeClock()
        val store = PendingAppLinkStore(clock, requestExpiryMs = 1000L)
        val request = store.createRequest(newRequest())
        clock.now = 1001L
        assertNull(store.consume(request.requestId))
    }

    @Test
    fun fallbackReentryIsReusableInWindowAndExpires() {
        val clock = FakeClock()
        val store = PendingAppLinkStore(clock, fallbackReentryMs = 10_000L)
        store.recordFallbackReentry("https://fallback.example/")
        assertTrue(store.isFallbackReentry("https://fallback.example/"))
        // Reusable within its window (does not consume).
        assertTrue(store.isFallbackReentry("https://fallback.example/"))
        clock.now = 10_001L
        assertFalse(store.isFallbackReentry("https://fallback.example/"))
    }
}
