/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ActivityInfo
import android.content.pm.ResolveInfo
import android.provider.Browser.EXTRA_APPLICATION_ID
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

/**
 * §2.7 resolution and intent sanitisation. Robolectric supplies the real [Intent] and
 * `Intent.parseUri`; the [PackageResolver] is faked, so what installed apps exist is part of the
 * test rather than of the device.
 */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class ExternalAppResolverTest {

    private class FakeClock(var now: Long = 0L) : MonotonicClock {
        override fun elapsedRealtime(): Long = now
    }

    /**
     * @param defaultActivity what `resolveActivity(MATCH_DEFAULT_ONLY)` answers — null for "no
     * default", `"android"` for the chooser sentinel.
     * @param candidates every activity `queryIntentActivities` lists.
     * @param browsers which of those packages count as installed browsers.
     */
    private class FakePackages(
        override val selfPackageName: String = "eu.weblibre",
        val defaultActivity: String? = null,
        val candidates: List<String> = emptyList(),
        val browsers: Set<String> = emptySet(),
        val installed: Set<String> = emptySet(),
        val labels: Map<String, String> = emptyMap(),
    ) : PackageResolver {
        var queryCount = 0

        private fun info(packageName: String) = ResolveInfo().apply {
            activityInfo = ActivityInfo().apply {
                this.packageName = packageName
                name = "$packageName.MainActivity"
            }
            filter = IntentFilter()
        }

        override fun queryActivities(intent: Intent): List<ResolveInfo> {
            queryCount++
            return candidates.map(::info)
        }

        override fun resolveDefaultActivity(intent: Intent): ResolveInfo? =
            defaultActivity?.let(::info)

        override fun isPackageInstalled(packageName: String) = packageName in installed

        override fun isInstalledBrowser(packageName: String) = packageName in browsers

        override fun applicationLabel(resolveInfo: ResolveInfo): String? =
            labels[resolveInfo.activityInfo?.packageName]
    }

    private fun resolver(packages: PackageResolver, clock: MonotonicClock = FakeClock()) =
        ExternalAppResolver(packages, clock)

    // ---- Looking past a browser default for an http app link ----

    @Test
    fun `finds a non-browser handler when another browser is the default`() {
        val resolved = resolver(
            FakePackages(
                defaultActivity = "org.other.browser",
                candidates = listOf("org.other.browser", "com.google.android.youtube"),
                browsers = setOf("org.other.browser"),
                labels = mapOf("com.google.android.youtube" to "YouTube"),
            ),
        ).resolve("https://youtube.com/watch?v=1", includeHttpAppLinks = true)

        assertTrue(resolved.hasExternalApp)
        assertEquals("com.google.android.youtube", resolved.packageName)
        assertEquals("YouTube", resolved.appName)
        assertFalse(resolved.isAmbiguous)
    }

    /**
     * The regression that matters most in practice: holding the browser role is the ordinary state
     * for this app, so if WebLibre being the default short-circuits the candidate search, http app
     * links stop surfacing on exactly the devices whose users chose WebLibre.
     */
    @Test
    fun `finds a non-browser handler when WebLibre itself is the default browser`() {
        val resolved = resolver(
            FakePackages(
                defaultActivity = "eu.weblibre",
                candidates = listOf("eu.weblibre", "com.google.android.youtube"),
                browsers = setOf("eu.weblibre"),
                labels = mapOf("com.google.android.youtube" to "YouTube"),
            ),
        ).resolve("https://youtube.com/watch?v=1", includeHttpAppLinks = true)

        assertTrue(resolved.hasExternalApp)
        assertEquals("com.google.android.youtube", resolved.packageName)
    }

    /** The self guard still holds where it was meant to: an `intent:` URL naming WebLibre. */
    @Test
    fun `does not hunt for another app when WebLibre handles a custom scheme by default`() {
        val resolved = resolver(
            FakePackages(
                defaultActivity = "eu.weblibre",
                candidates = listOf("eu.weblibre", "com.other.app"),
            ),
        ).resolve("zoommtg://zoom.us/join?confno=1", includeHttpAppLinks = true)

        assertFalse(resolved.hasExternalApp)
        assertNull(resolved.packageName)
    }

    @Test
    fun `http app links are withheld unless the caller asks for them`() {
        val packages = FakePackages(
            defaultActivity = "com.google.android.youtube",
            candidates = listOf("com.google.android.youtube"),
        )
        val resolved = resolver(packages)
            .resolve("https://youtube.com/watch?v=1", includeHttpAppLinks = false)

        assertFalse(resolved.hasExternalApp)
        assertNull(resolved.appIntent)
    }

    // ---- Ambiguity ----

    @Test
    fun `several candidates stay ambiguous, unnamed and unbound`() {
        val resolved = resolver(
            FakePackages(
                defaultActivity = ANDROID_RESOLVER,
                candidates = listOf("com.first.app", "com.second.app"),
                labels = mapOf("com.first.app" to "First"),
            ),
        ).resolve("zoommtg://zoom.us/join?confno=1", includeHttpAppLinks = true)

        assertTrue(resolved.hasExternalApp)
        assertTrue(resolved.isAmbiguous)
        // Naming the first candidate would promise an app the tap does not open: the launch raises
        // the system chooser instead.
        assertNull(resolved.appName)
        assertNull(resolved.appIntent?.component)
    }

    @Test
    fun `a single candidate is bound to its component and named`() {
        val resolved = resolver(
            FakePackages(
                defaultActivity = ANDROID_RESOLVER,
                candidates = listOf("com.only.app"),
                labels = mapOf("com.only.app" to "Only"),
            ),
        ).resolve("zoommtg://zoom.us/join?confno=1", includeHttpAppLinks = true)

        assertFalse(resolved.isAmbiguous)
        assertEquals("Only", resolved.appName)
        assertEquals("com.only.app", resolved.appIntent?.component?.packageName)
    }

    // ---- §2.7 intent sanitisation ----

    @Test
    fun `the launched intent is rebuilt from an allowlist`() {
        val hostile = "intent://evil.example/#Intent;scheme=https;" +
            "action=android.intent.action.CALL;" +
            "component=com.victim/.SecretActivity;" +
            "S.browser_fallback_url=https%3A%2F%2Ffallback.example%2F;" +
            "launchFlags=0x1;end"

        val resolved = resolver(
            FakePackages(
                defaultActivity = "com.some.app",
                candidates = listOf("com.some.app"),
            ),
        ).resolve(hostile, includeHttpAppLinks = true)

        val intent = assertNotNull(resolved.appIntent)
        // The page's action, component and flags are all replaced, never merged.
        assertEquals(Intent.ACTION_VIEW, intent.action)
        assertEquals("com.some.app", intent.component?.packageName)
        assertTrue(intent.categories.orEmpty().contains(Intent.CATEGORY_BROWSABLE))
        assertEquals(Intent.FLAG_ACTIVITY_NEW_TASK, intent.flags and Intent.FLAG_ACTIVITY_NEW_TASK)
        assertEquals(0, intent.flags and 0x1)
        assertNull(intent.selector)
        // The fallback is extracted for the interceptor, never carried on the launch.
        assertNull(intent.getStringExtra("browser_fallback_url"))
        assertEquals("eu.weblibre", intent.getStringExtra(EXTRA_APPLICATION_ID))
    }

    @Test
    fun `an intent naming WebLibre itself never resolves`() {
        val resolved = resolver(
            FakePackages(candidates = listOf("com.some.app")),
        ).resolve(
            "intent://x/#Intent;scheme=https;package=eu.weblibre;end",
            includeHttpAppLinks = true,
        )

        assertFalse(resolved.hasExternalApp)
    }

    @Test
    fun `always-denied schemes never resolve, and neither do their fallbacks`() {
        for (url in listOf(
            "javascript:alert(1)",
            "JavaScript:alert(1)",
            "file:///etc/passwd",
            "intent://x/#Intent;scheme=file;S.browser_fallback_url=https%3A%2F%2Ff.example%2F;end",
        )) {
            val resolved = resolver(
                FakePackages(
                    defaultActivity = "com.some.app",
                    candidates = listOf("com.some.app"),
                ),
            ).resolve(url, includeHttpAppLinks = true)

            assertFalse(resolved.hasExternalApp, url)
            assertNull(resolved.fallbackUrl, url)
            assertNull(resolved.marketplaceIntent, url)
        }
    }

    // ---- Fallback validation ----

    @Test
    fun `a fallback is taken only for a non-engine scheme, and only over http`() {
        val packages = FakePackages()

        val custom = resolver(packages).resolve(
            "intent://join/#Intent;scheme=zoommtg;S.browser_fallback_url=https%3A%2F%2Fzoom.us%2Fj;end",
            includeHttpAppLinks = true,
        )
        assertEquals("https://zoom.us/j", custom.fallbackUrl)

        // An `intent:` URL is not itself engine-supported, whatever its inner scheme says, so its
        // fallback still stands — this is AC's rule too, which reads the navigation URL's scheme.
        val intentToHttps = resolver(packages).resolve(
            "intent://x/#Intent;scheme=https;S.browser_fallback_url=https%3A%2F%2Ff.example%2F;end",
            includeHttpAppLinks = true,
        )
        assertEquals("https://f.example/", intentToHttps.fallbackUrl)

        // An engine-supported *original* already has somewhere to go: itself. Only a URL that
        // carries the intent fragment directly reaches this branch.
        val http = resolver(packages).resolve(
            "https://real.example/#Intent;S.browser_fallback_url=https%3A%2F%2Ff.example%2F;end",
            includeHttpAppLinks = true,
        )
        assertNull(http.fallbackUrl)

        // A non-http fallback would be a second app link wearing a fallback's clothes.
        val nested = resolver(packages).resolve(
            "intent://join/#Intent;scheme=zoommtg;S.browser_fallback_url=market%3A%2F%2Fdetails;end",
            includeHttpAppLinks = true,
        )
        assertNull(nested.fallbackUrl)
    }

    @Test
    fun `a Play Store fallback is dropped when the app is already installed`() {
        val url = "intent://join/#Intent;scheme=zoommtg;" +
            "S.browser_fallback_url=https%3A%2F%2Fplay.google.com%2Fstore%2Fapps%3Fid%3Dx;end"

        val withApp = resolver(
            FakePackages(defaultActivity = "com.zoom", candidates = listOf("com.zoom")),
        ).resolve(url, includeHttpAppLinks = true)
        assertNull(withApp.fallbackUrl)

        val withoutApp = resolver(FakePackages()).resolve(url, includeHttpAppLinks = true)
        assertNotNull(withoutApp.fallbackUrl)
    }

    // ---- Marketplace ----

    @Test
    fun `a marketplace intent is offered only for a package that is not installed`() {
        val url = "intent://join/#Intent;scheme=zoommtg;package=us.zoom.videomeetings;end"

        val missing = resolver(FakePackages()).resolve(url, includeHttpAppLinks = true)
        assertNotNull(missing.marketplaceIntent)

        val present = resolver(
            FakePackages(installed = setOf("us.zoom.videomeetings")),
        ).resolve(url, includeHttpAppLinks = true)
        assertNull(present.marketplaceIntent)
    }

    // ---- Scope keys ----

    @Test
    fun `scope keys are the host for http and the package for a custom scheme`() {
        val http = resolver(
            FakePackages(
                defaultActivity = "com.google.android.youtube",
                candidates = listOf("com.google.android.youtube"),
            ),
        ).resolve("https://WWW.YouTube.com/watch", includeHttpAppLinks = true)
        assertEquals("host:www.youtube.com", http.scopeKey)

        val custom = resolver(
            FakePackages(defaultActivity = "us.zoom", candidates = listOf("us.zoom")),
        ).resolve("zoommtg://zoom.us/join", includeHttpAppLinks = true)
        assertEquals("pkg:us.zoom", custom.scopeKey)
    }

    // ---- Caching ----

    @Test
    fun `the cache serves repeats, expires, and keeps distinct urls apart`() {
        val clock = FakeClock()
        val packages = FakePackages(
            defaultActivity = ANDROID_RESOLVER,
            candidates = listOf("com.some.app"),
        )
        val resolver = resolver(packages, clock)

        resolver.resolve("zoommtg://a", includeHttpAppLinks = true)
        resolver.resolve("zoommtg://a", includeHttpAppLinks = true)
        assertEquals(1, packages.queryCount)

        // A different URL must not be answered from another URL's entry, and must not evict it:
        // one shared slot was the old behaviour and it meant the cache almost never hit.
        resolver.resolve("zoommtg://b", includeHttpAppLinks = true)
        resolver.resolve("zoommtg://a", includeHttpAppLinks = true)
        assertEquals(2, packages.queryCount)

        clock.now = ExternalAppResolver.APP_LINKS_CACHE_INTERVAL + 1
        resolver.resolve("zoommtg://a", includeHttpAppLinks = true)
        assertEquals(3, packages.queryCount)
    }

    @Test
    fun `launch paths bypass the cache entirely`() {
        val packages = FakePackages(
            defaultActivity = ANDROID_RESOLVER,
            candidates = listOf("com.some.app"),
        )
        val resolver = resolver(packages)

        resolver.resolve("zoommtg://a", includeHttpAppLinks = true)
        resolver.resolve("zoommtg://a", includeHttpAppLinks = true, useCache = false)
        assertEquals(2, packages.queryCount)
    }

    @Test
    fun `an oversized url is refused rather than shortened`() {
        val packages = FakePackages(
            defaultActivity = "com.some.app",
            candidates = listOf("com.some.app"),
        )
        val tail = "a".repeat(ExternalAppResolver.MAX_URL_LENGTH * 2)

        // Truncating would hand the app a different target than the prompt showed — a mailto:
        // without its body, an intent: without its metadata — so an oversized link resolves to
        // nothing at all and never reaches Intent.parseUri.
        val http = resolver(packages).resolve("https://example.com/?q=$tail", includeHttpAppLinks = true)
        assertFalse(http.hasExternalApp)
        assertNull(http.appIntent)
        assertNull(http.fallbackUrl)
        assertNull(http.marketplaceIntent)
        assertEquals(0, packages.queryCount)
        // The scheme still survives, which is what lets the classifier keep an http page loading
        // in the browser instead of denying it.
        assertTrue(http.engineSupportsScheme)

        val custom = resolver(packages).resolve("zoommtg://join?x=$tail", includeHttpAppLinks = true)
        assertFalse(custom.hasExternalApp)
        assertFalse(custom.engineSupportsScheme)
    }

    // ---- Ambiguous launches must not resolve back to a browser ----

    @Test
    fun `an ambiguous http resolution excludes browsers and itself from the chooser`() {
        val resolved = resolver(
            FakePackages(
                defaultActivity = "eu.weblibre",
                candidates = listOf("eu.weblibre", "org.other.browser", "com.first.app", "com.second.app"),
                browsers = setOf("eu.weblibre", "org.other.browser"),
            ),
        ).resolve("https://shared.example/x", includeHttpAppLinks = true)

        assertTrue(resolved.isAmbiguous)
        // Unbound, so `startActivity` would resolve it implicitly — straight back to the default
        // browser. These are the components the chooser has to be told to leave out.
        assertNull(resolved.appIntent?.component)
        assertEquals(
            setOf("eu.weblibre", "org.other.browser"),
            resolved.excludedComponents.map { it.packageName }.toSet(),
        )
    }

    @Test
    fun `a bound resolution carries no exclusions`() {
        val resolved = resolver(
            FakePackages(
                defaultActivity = ANDROID_RESOLVER,
                candidates = listOf("com.only.app"),
            ),
        ).resolve("zoommtg://zoom.us/join", includeHttpAppLinks = true)

        assertFalse(resolved.isAmbiguous)
        assertTrue(resolved.excludedComponents.isEmpty())
    }

    // ---- Intent data URL (used by protected-site matching) ----

    @Test
    fun `the intent data url exposes the real target of an intent url`() {
        val resolved = resolver(FakePackages()).resolve(
            "intent://secret.example/path#Intent;scheme=https;end",
            includeHttpAppLinks = true,
        )
        assertEquals("https://secret.example/path", resolved.intentDataUrl)
    }

    private companion object {
        const val ANDROID_RESOLVER = "android"
    }
}
