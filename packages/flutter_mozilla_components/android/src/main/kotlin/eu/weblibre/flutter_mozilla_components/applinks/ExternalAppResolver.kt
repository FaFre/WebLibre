/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import android.content.ComponentName
import android.content.Intent
import android.content.pm.ResolveInfo
import android.net.Uri
import android.os.Build
import android.provider.Browser.EXTRA_APPLICATION_ID
import androidx.core.net.toUri
import mozilla.components.support.base.log.logger.Logger
import java.net.URISyntaxException
import java.util.Locale

private const val EXTRA_BROWSER_FALLBACK_URL = "browser_fallback_url"
private const val MARKET_INTENT_URI_PACKAGE_PREFIX = "market://details?id="
private const val ANDROID_RESOLVER_PACKAGE_NAME = "android"
private const val APP_LABEL_MAX_LENGTH = 64
private val PLAY_STORE_URL_REGEX = Regex("https?://play\\.google\\.com/store/.*")

/**
 * Immutable result of resolving a URL against installed apps
 * (APP_LINKS_OWN_IMPLEMENTATION_PLAN.md §2.7). Holds a sanitised, launchable [appIntent]
 * (trusted component set), never a page-controlled one.
 */
data class ResolvedAppLink(
    val hasExternalApp: Boolean,
    val appIntent: Intent?,
    val packageName: String?,
    val appName: String?,
    val fallbackUrl: String?,
    val marketplaceIntent: Intent?,
    val isAmbiguous: Boolean,
    val engineSupportsScheme: Boolean,
    val scopeKey: String,
    val originalScheme: String?,
    val intentDataScheme: String?,
)

/**
 * Resolves URLs to external apps, preserving every security-critical behaviour of
 * `AppLinksUseCases.createBrowsableIntents` and adding the §2.7 field allowlist. The launched
 * intent is rebuilt from a strict allowlist: `ACTION_VIEW`, `CATEGORY_BROWSABLE`, the data URI,
 * and a documented compatibility extra — every page-supplied component, selector, bounds,
 * identifier, clip/grant state, incoming flag, and browser-fallback metadata is cleared.
 *
 * A ~30 s resolution cache (AC's `APP_LINKS_CACHE_INTERVAL`) serves the synchronous classify path
 * and the "show the button?" queries. There is no package-broadcast invalidator: the mandatory
 * pre-launch re-resolution in [AppLinkLauncher] is the correctness guard.
 */
class ExternalAppResolver(
    private val packages: PackageResolver,
    private val clock: MonotonicClock = MonotonicClock.SYSTEM,
    private val cacheTtlMs: Long = APP_LINKS_CACHE_INTERVAL,
) {
    private val logger = Logger("ExternalAppResolver")

    private data class CacheEntry(val timestamp: Long, val key: Int, val value: ResolvedAppLink)

    @Volatile
    private var cache: CacheEntry? = null

    /**
     * Resolve [url] against installed apps.
     *
     * @param includeHttpAppLinks when `false`, an app resolving an engine-supported (http(s)) URL
     * is not treated as an external app — the engine keeps the load. Manual "Open in app" callers
     * pass `true` so a YouTube link surfaces the YouTube app.
     * @param useCache consult/populate the short-lived resolution cache. Launch paths pass `false`
     * so they always re-resolve immediately before `startActivity`.
     */
    fun resolve(
        url: String,
        includeHttpAppLinks: Boolean,
        useCache: Boolean = true,
    ): ResolvedAppLink {
        val key = (url + "|" + includeHttpAppLinks).hashCode()
        val now = clock.elapsedRealtime()
        if (useCache) {
            cache?.let { entry ->
                if (entry.key == key && now <= entry.timestamp + cacheTtlMs) {
                    return entry.value
                }
            }
        }

        val result = resolveUncached(url, includeHttpAppLinks)
        if (useCache) {
            cache = CacheEntry(now, key, result)
        }
        return result
    }

    fun clearCache() {
        cache = null
    }

    private fun resolveUncached(url: String, includeHttpAppLinks: Boolean): ResolvedAppLink {
        val originalScheme = try {
            url.toUri().scheme?.lowercase(Locale.ROOT)
        } catch (e: Exception) {
            null
        }
        val engineSupported = AppLinkSchemes.isEngineSupported(originalScheme)
        val hostScope = AppLinkHostNormalizer.hostScopeKey(runCatching { url.toUri().host }.getOrNull())

        fun empty(scope: String, intentDataScheme: String? = null) = ResolvedAppLink(
            hasExternalApp = false,
            appIntent = null,
            packageName = null,
            appName = null,
            fallbackUrl = null,
            marketplaceIntent = null,
            isAmbiguous = false,
            engineSupportsScheme = engineSupported,
            scopeKey = scope,
            originalScheme = originalScheme,
            intentDataScheme = intentDataScheme,
        )

        // Always-denied schemes never resolve or launch externally (§2.2). Return early so no
        // fallback or marketplace intent is extracted from them.
        if (AppLinkSchemes.isAlwaysDenied(originalScheme)) {
            return empty(hostScope ?: "")
        }

        val parsed = safeParseUri(url) ?: return empty(hostScope ?: "")
        val dataScheme = parsed.data?.scheme?.lowercase(Locale.ROOT)

        // Reject a sanitised intent whose data scheme is itself always-denied.
        if (parsed.data == null || AppLinkSchemes.isAlwaysDenied(dataScheme)) {
            return empty(hostScope ?: "", dataScheme)
        }

        val requestedPackage = parsed.`package`
        val appIntent = buildLaunchIntent(parsed)
        val pageFallback = parsed.getStringExtra(EXTRA_BROWSER_FALLBACK_URL)

        // Resolve the external-app handler. A browser default for an http(s) link is not itself an
        // "open in app" target — as with no default or the Android chooser sentinel — so look past
        // it for a non-browser handler (e.g. the YouTube app for a youtube.com link the default
        // browser also handles). Browsers are excluded only for engine-supported (http) schemes.
        var isAmbiguous = false
        var resolvedPackage: String? = null
        var resolvedActivityName: String? = null
        var resolvedInfo: ResolveInfo? = null

        val defaultInfo = packages.resolveDefaultActivity(appIntent)
        val defaultPackage = defaultInfo?.activityInfo?.packageName
        val defaultIsUsableApp = defaultPackage != null &&
            defaultPackage != packages.selfPackageName &&
            defaultPackage != ANDROID_RESOLVER_PACKAGE_NAME &&
            !(engineSupported && packages.isInstalledBrowser(defaultPackage))

        when {
            defaultIsUsableApp -> {
                resolvedPackage = defaultPackage
                resolvedActivityName = defaultInfo?.activityInfo?.name
                resolvedInfo = defaultInfo
            }
            // A page must not relaunch WebLibre through the app-link path: if WebLibre itself is the
            // default handler, keep the load in-browser rather than hunting for other apps.
            defaultPackage == packages.selfPackageName -> {
                resolvedPackage = null
            }
            // No usable default (none / chooser / a browser for an http link): pick a non-browser
            // handler. A single one launches directly (rememberable); several stay ambiguous (chooser).
            else -> {
                val candidates = packages.queryActivities(appIntent).filter { info ->
                    val pkg = info.activityInfo?.packageName
                    info.filter != null &&
                        pkg != null &&
                        pkg != packages.selfPackageName &&
                        !(engineSupported && packages.isInstalledBrowser(pkg))
                }
                candidates.firstOrNull()?.let { chosen ->
                    resolvedPackage = chosen.activityInfo?.packageName
                    resolvedActivityName = chosen.activityInfo?.name
                    resolvedInfo = chosen
                    isAmbiguous = candidates.size > 1
                }
            }
        }

        // hasExternalApp mirrors AC's appIntent decision, minus the launchInApp() policy gate
        // (policy lives in the classifier). A resolved package is never a browser for an http link
        // (excluded above), so the only remaining http gate is includeHttpAppLinks.
        val hasExternalApp = when {
            resolvedPackage == null -> false
            // http(s) app links only count when the caller asks for them.
            engineSupported && !includeHttpAppLinks -> false
            else -> true
        }

        // Bind the trusted, resolved component (never a page-supplied one).
        if (hasExternalApp && resolvedPackage != null && resolvedActivityName != null && !isAmbiguous) {
            appIntent.component = ComponentName(resolvedPackage, resolvedActivityName)
        }

        val appName = if (hasExternalApp && resolvedInfo != null) {
            sanitizeAppLabel(packages.applicationLabel(resolvedInfo))
        } else {
            null
        }

        // Fallback: accepted only if http(s), the original scheme is not engine-supported, and it is
        // not a Play Store URL for an already-installed app.
        val fallbackUrl = pageFallback?.let { validateFallback(it, engineSupported, appInstalled = resolvedPackage != null) }

        // Marketplace intent: only when the target package is not installed.
        val marketplaceIntent = requestedPackage
            ?.takeIf { !packages.isPackageInstalled(it) }
            ?.let { safeParseRawUri(MARKET_INTENT_URI_PACKAGE_PREFIX + it) }
            ?.apply { flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK }

        // Scope key: host for engine-supported (http) links; resolved package otherwise (§2.5).
        val scopeKey = when {
            engineSupported && hostScope != null -> hostScope
            resolvedPackage != null -> AppLinkHostNormalizer.packageScopeKey(resolvedPackage) ?: (hostScope ?: "")
            else -> hostScope ?: ""
        }

        return ResolvedAppLink(
            hasExternalApp = hasExternalApp,
            appIntent = if (hasExternalApp) appIntent else null,
            packageName = if (hasExternalApp) resolvedPackage else null,
            appName = appName,
            fallbackUrl = fallbackUrl,
            marketplaceIntent = marketplaceIntent,
            isAmbiguous = isAmbiguous,
            engineSupportsScheme = engineSupported,
            scopeKey = scopeKey,
            originalScheme = originalScheme,
            intentDataScheme = dataScheme,
        )
    }

    /** Parse an `intent:`/URL into an Intent, rejecting self-package targets. */
    private fun safeParseUri(url: String): Intent? {
        val intent = safeParseRawUri(url, Intent.URI_INTENT_SCHEME) ?: return null
        return if (intent.`package` == packages.selfPackageName) {
            // Ignore intents that would relaunch WebLibre.
            null
        } else {
            intent
        }
    }

    private fun safeParseRawUri(uri: String, flags: Int = 0): Intent? {
        return try {
            Intent.parseUri(uri, flags)
        } catch (e: URISyntaxException) {
            logger.error("failed to parse URI", e)
            null
        } catch (e: NumberFormatException) {
            // Intent.parseUri may throw NumberFormatException on malformed numeric extras.
            logger.error("failed to parse URI", e)
            null
        }
    }

    /**
     * Rebuild [source] into a sanitised, launchable intent using a field allowlist (§2.7):
     * force ACTION_VIEW; add CATEGORY_BROWSABLE; retain only the data URI and documented
     * compatibility extras; clear every page-supplied structural field and all incoming flags.
     */
    private fun buildLaunchIntent(source: Intent): Intent {
        val sanitized = Intent(Intent.ACTION_VIEW)
        source.data?.let { sanitized.data = it }
        sanitized.addCategory(Intent.CATEGORY_BROWSABLE)

        // Preserve an explicit `intent:...;package=` target: it is a package-id constraint (not a
        // component, which could point at a non-exported activity), so resolution/launch targets the
        // app the link actually names instead of some other handler or WebLibre itself. `safeParseUri`
        // already rejected a self-package target. This mirrors AC's createBrowsableIntents.
        source.`package`?.let { pkg ->
            if (pkg != packages.selfPackageName) sanitized.`package` = pkg
        }

        // Explicitly clear every structural field a page could weaponise.
        sanitized.component = null
        sanitized.selector = null
        sanitized.sourceBounds = null
        sanitized.clipData = null
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            sanitized.identifier = null
        }
        // flags = FLAG_ACTIVITY_NEW_TASK — assignment, not `or`. Clears page-supplied flags such as
        // FLAG_GRANT_READ_URI_PERMISSION.
        sanitized.flags = Intent.FLAG_ACTIVITY_NEW_TASK

        // Documented compatibility extra only. EXTRA_BROWSER_FALLBACK_URL is deliberately not copied
        // onto the launched intent (it is extracted separately for the interceptor).
        sanitized.putExtra(EXTRA_APPLICATION_ID, packages.selfPackageName)

        return sanitized
    }

    private fun validateFallback(
        rawFallback: String,
        originalSchemeEngineSupported: Boolean,
        appInstalled: Boolean,
    ): String? {
        val scheme = try {
            Uri.parse(rawFallback).scheme?.lowercase(Locale.ROOT)
        } catch (e: Exception) {
            return null
        }
        if (!AppLinkSchemes.isHttpOrHttps(scheme)) return null
        if (originalSchemeEngineSupported) return null
        val isPlayStoreUrlForInstalledApp = PLAY_STORE_URL_REGEX.matches(rawFallback) && appInstalled
        if (isPlayStoreUrlForInstalledApp) return null
        return rawFallback
    }

    /** App labels are app-controlled: strip control/bidi characters and length-bound. */
    private fun sanitizeAppLabel(label: String?): String? {
        if (label.isNullOrEmpty()) return null
        val cleaned = buildString {
            for (ch in label) {
                val type = Character.getType(ch)
                if (type == Character.CONTROL.toInt() || type == Character.FORMAT.toInt()) {
                    continue
                }
                append(ch)
            }
        }.trim()
        if (cleaned.isEmpty()) return null
        return if (cleaned.length > APP_LABEL_MAX_LENGTH) {
            cleaned.substring(0, APP_LABEL_MAX_LENGTH)
        } else {
            cleaned
        }
    }

    companion object {
        const val APP_LINKS_CACHE_INTERVAL = 30 * 1000L
    }
}
