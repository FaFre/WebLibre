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
    fun aNewerBannerForTheTabReplacesTheOlderOne() {
        val clock = FakeClock()
        val store = PendingAppLinkStore(clock)
        val first = store.createRequest(
            newRequest(urlClass = AppLinkUrlClass.BANNER, url = "https://a.example/x"),
        )
        clock.now = 5000L // past the dedupe window, so this is a genuinely new offer
        val second = store.createRequest(
            newRequest(
                urlClass = AppLinkUrlClass.BANNER,
                url = "https://b.example/y",
                fingerprint = "fp2",
            ),
        )

        // One live banner per tab: visiting a second app-link site replaces the offer rather than
        // stacking behind it.
        assertNull(store.peek(first.requestId))
        assertNotNull(store.peek(second.requestId))
        assertEquals(1, store.getPending(AppLinkPromptOwner.FLUTTER_BROWSER).size)
    }

    @Test
    fun aBannerForAnotherTabIsUntouched() {
        val clock = FakeClock()
        val store = PendingAppLinkStore(clock)
        val other = store.createRequest(
            newRequest(tabId = "tab2", urlClass = AppLinkUrlClass.BANNER, url = "https://a.example/x"),
        )
        clock.now = 5000L
        store.createRequest(
            newRequest(tabId = "tab1", urlClass = AppLinkUrlClass.BANNER, url = "https://b.example/y"),
        )
        assertNotNull(store.peek(other.requestId))
    }

    @Test
    fun bannersExpireSoonerThanModals() {
        val clock = FakeClock()
        val store = PendingAppLinkStore(
            clock,
            requestExpiryMs = 10_000L,
            bannerExpiryMs = 1_000L,
        )
        val banner = store.createRequest(
            newRequest(urlClass = AppLinkUrlClass.BANNER, url = "https://a.example/x"),
        )
        val modal = store.createRequest(
            newRequest(urlClass = AppLinkUrlClass.MODAL, fingerprint = "fp-modal"),
        )

        // The banner is a passive offer bounded by time; the modal is holding a navigation open
        // and keeps the long window.
        clock.now = 1001L
        assertNull(store.peek(banner.requestId))
        assertNotNull(store.peek(modal.requestId))

        clock.now = 10_001L
        assertNull(store.peek(modal.requestId))
    }

    @Test
    fun remainingTtlIsReportedSoTheSurfaceCanRetireThePromptOnTime() {
        val clock = FakeClock()
        val store = PendingAppLinkStore(clock, bannerExpiryMs = 1_000L)
        val banner = store.createRequest(
            newRequest(urlClass = AppLinkUrlClass.BANNER, url = "https://a.example/x"),
        )
        assertEquals(1_000L, store.expiresInMs(banner))

        clock.now = 400L
        assertEquals(600L, store.expiresInMs(banner))

        // Never negative: a surface schedules on this value, and expiry itself is lazy.
        clock.now = 5_000L
        assertEquals(0L, store.expiresInMs(banner))
    }

    @Test
    fun tabCloseInvalidatesRequestsAndSuppression() {
        val store = PendingAppLinkStore(FakeClock())
        val request = store.createRequest(newRequest())
        store.recordSuppression("tab1", "fp1")
        assertEquals(setOf(AppLinkPromptOwner.FLUTTER_BROWSER), store.invalidateTab("tab1"))
        assertNull(store.peek(request.requestId))
        assertFalse(store.isSuppressed("tab1", "fp1"))
    }

    @Test
    fun suppressionSurvivesRedirectsButClearsOnDirectNavAndTimeout() {
        val clock = FakeClock()
        val store = PendingAppLinkStore(clock, suppressionExpiryMs = 1000L)
        store.recordSuppression("tab1", "fp1")
        assertTrue(store.isSuppressed("tab1", "fp1"))
        // A redirect within the current load does not clear it (no load start is dispatched).
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

    @Test
    fun fallbackIssueIsClaimedOncePerWindow() {
        val clock = FakeClock()
        val store = PendingAppLinkStore(clock, fallbackIssueMs = 10_000L)
        assertTrue(store.claimFallbackIssue("tab1", "https://maps.example/place"))
        // The page re-fires the same intent on every load of the fallback page: refused, so the
        // fallback is not loaded again and the tab stops reloading.
        assertFalse(store.claimFallbackIssue("tab1", "https://maps.example/place"))
        assertFalse(store.claimFallbackIssue("tab1", "https://maps.example/place"))
    }

    @Test
    fun refusedFallbackClaimPushesTheWindowOut() {
        val clock = FakeClock()
        val store = PendingAppLinkStore(clock, fallbackIssueMs = 10_000L)
        assertTrue(store.claimFallbackIssue("tab1", "https://maps.example/place"))
        // A page firing on a timer just short of the window cannot walk around the guard.
        clock.now = 9_000L
        assertFalse(store.claimFallbackIssue("tab1", "https://maps.example/place"))
        clock.now = 18_000L
        assertFalse(store.claimFallbackIssue("tab1", "https://maps.example/place"))
        // Quiet for a full window: a genuinely new attempt may load the fallback again.
        clock.now = 28_001L
        assertTrue(store.claimFallbackIssue("tab1", "https://maps.example/place"))
    }

    @Test
    fun fallbackClaimsAreScopedPerTabAndPerUrl() {
        val clock = FakeClock()
        val store = PendingAppLinkStore(clock, fallbackIssueMs = 10_000L)
        assertTrue(store.claimFallbackIssue("tab1", "https://maps.example/place"))
        // The same link opened in another tab still gets its fallback.
        assertTrue(store.claimFallbackIssue("tab2", "https://maps.example/place"))
        // A different target in the same tab is a different claim.
        assertTrue(store.claimFallbackIssue("tab1", "https://maps.example/other"))
    }

    @Test
    fun fallbackClaimIgnoresQueryAndFragmentMutation() {
        val clock = FakeClock()
        val store = PendingAppLinkStore(clock, fallbackIssueMs = 10_000L)
        // Google Maps appends one more `coh` entry on every bounce; keying on the exact URL made
        // each one a fresh claim, so the tab kept reloading until the list saturated.
        assertTrue(store.claimFallbackIssue("tab1", "https://maps.example/place?coh=1%2C2"))
        assertFalse(store.claimFallbackIssue("tab1", "https://maps.example/place?coh=1%2C2%2C2"))
        assertFalse(store.claimFallbackIssue("tab1", "https://maps.example/place?coh=1%2C2%2C2%2C2"))
        assertFalse(store.claimFallbackIssue("tab1", "https://maps.example/place#anchor"))
        // A different path is still a different target.
        assertTrue(store.claimFallbackIssue("tab1", "https://maps.example/other?coh=1%2C2"))
    }

    @Test
    fun perTabBudgetBoundsFallbacksWhoseIdentityKeepsChanging() {
        val clock = FakeClock()
        val store = PendingAppLinkStore(
            clock,
            fallbackIssueMs = 10_000L,
            fallbackIssueBudget = 3,
            fallbackBudgetWindowMs = 30_000L,
        )
        // A page that mutates the whole path per bounce defeats the identity bound entirely.
        repeat(3) { assertTrue(store.claimFallbackIssue("tab1", "https://maps.example/place/$it")) }
        assertFalse(store.claimFallbackIssue("tab1", "https://maps.example/place/3"))

        // Another tab keeps its own allowance.
        assertTrue(store.claimFallbackIssue("tab2", "https://maps.example/place/3"))

        // Refusals keep the window rolling, so the loop cannot outlast it.
        clock.now = 29_000L
        assertFalse(store.claimFallbackIssue("tab1", "https://maps.example/place/4"))
        clock.now = 55_000L
        assertFalse(store.claimFallbackIssue("tab1", "https://maps.example/place/5"))

        // A user-initiated navigation is the escape hatch.
        store.clearFallbackIssuedForTab("tab1")
        assertTrue(store.claimFallbackIssue("tab1", "https://maps.example/place/6"))
    }

    @Test
    fun userInitiatedNavigationAndTabCloseReleaseFallbackClaims() {
        val clock = FakeClock()
        val store = PendingAppLinkStore(clock, fallbackIssueMs = 10_000L)
        assertTrue(store.claimFallbackIssue("tab1", "https://maps.example/place"))
        assertFalse(store.claimFallbackIssue("tab1", "https://maps.example/place"))

        store.clearFallbackIssuedForTab("tab1")
        assertTrue(store.claimFallbackIssue("tab1", "https://maps.example/place"))

        store.invalidateTab("tab1")
        assertTrue(store.claimFallbackIssue("tab1", "https://maps.example/place"))
    }

    @Test
    fun fallbackClaimsWithoutASessionAreStillBounded() {
        val clock = FakeClock()
        val store = PendingAppLinkStore(clock, fallbackIssueMs = 10_000L)
        assertTrue(store.claimFallbackIssue(null, "https://maps.example/place"))
        assertFalse(store.claimFallbackIssue(null, "https://maps.example/place"))
    }
}
