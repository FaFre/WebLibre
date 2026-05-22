/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import android.net.Uri
import eu.weblibre.flutter_mozilla_components.ext.EventSequence
import eu.weblibre.flutter_mozilla_components.pigeons.SandboxCaptureEntry
import eu.weblibre.flutter_mozilla_components.pigeons.SandboxCaptureHostEvents
import java.util.concurrent.ConcurrentHashMap

// Per-tab sandbox capture state consulted by AppRequestInterceptor on every
// load. The registry is authoritative for runtime decisions and is populated
// from three sources:
//   1. Pre-Gecko-init rehydration from <profileDir>/files/sandbox_captures.json
//      (see SandboxCaptureFeature.preRestoreBootstrap).
//   2. Dart pushing resetAll / mark / unmark at runtime via the
//      SandboxCaptureApi pigeon channel.
//   3. The search-results entry point when the user opens a root capture.
object SandboxCaptureRegistry {
    data class SandboxEntry(
        val captureId: String,
        val sourceUrl: String,
        val redirectUrl: String,
        val status: String,
    )

    private val store = ConcurrentHashMap<String, SandboxEntry>()

    fun get(tabId: String): SandboxEntry? = store[tabId]

    fun put(tabId: String, entry: SandboxEntry) {
        store[tabId] = entry
    }

    fun remove(tabId: String) {
        store.remove(tabId)
    }

    fun resetAll(newEntries: Map<String, SandboxEntry>) {
        store.clear()
        store.putAll(newEntries)
    }

    fun snapshot(): Map<String, SandboxEntry> = HashMap(store)

    // Returns true for URLs the loopback CaptureServer owns: /captures/* and
    // /loader*. Used by the interceptor to allow self-redirects and by the
    // middleware to skip re-dispatching Dart-originated navigations.
    fun isLoopbackRedirect(url: String): Boolean {
        val parsed = Uri.parse(url)
        if (parsed.scheme != "http") return false
        if (parsed.host != "127.0.0.1") return false
        val path = parsed.path.orEmpty()
        return path.startsWith("/captures") || path.startsWith("/loader")
    }
}

// Inert external schemes that never trigger a network request from the
// current tab. When a sandbox tab navigates to one of these we let the
// normal AppLinksInterceptor handle it (usually by dispatching an Android
// intent).
object InertExternalSchemes {
    private val schemes = setOf(
        "mailto",
        "tel",
        "sms",
        "mms",
        "geo",
        "intent",
        "market",
        "maps",
    )

    fun matches(uri: Uri): Boolean {
        val scheme = uri.scheme?.lowercase() ?: return false
        return schemes.contains(scheme)
    }
}

// Holds the lazily-initialised SandboxCaptureHostEvents pigeon sender so the
// interceptor and middleware can fire-and-forget dispatch link clicks / new
// tabs without knowing about the Flutter binding lifecycle.
object SandboxCaptureBridge {
    @Volatile
    var events: SandboxCaptureHostEvents? = null

    fun dispatchLinkClick(parentTabId: String, targetUrl: String) {
        val e = events ?: return
        e.onSandboxLinkClick(EventSequence.next(), parentTabId, targetUrl) {}
    }

    fun dispatchNewTab(parentTabId: String, newTabId: String, targetUrl: String) {
        val e = events ?: return
        e.onSandboxNewTab(EventSequence.next(), parentTabId, newTabId, targetUrl) {}
    }
}

fun SandboxCaptureEntry.toRegistryEntry(): SandboxCaptureRegistry.SandboxEntry {
    return SandboxCaptureRegistry.SandboxEntry(
        captureId = captureId,
        sourceUrl = sourceUrl,
        redirectUrl = redirectUrl,
        status = status,
    )
}
