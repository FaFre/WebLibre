/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.chrome

import org.json.JSONArray
import org.json.JSONObject

/**
 * Rewrites a Chrome extension manifest into one Gecko will install.
 *
 * The two platforms agree on most of the manifest — `content_scripts`,
 * `permissions`, `host_permissions`, `action`, `options_page` and the rest mean
 * the same thing — so this changes only what actually differs, and reports each
 * change in [Translation.notes] rather than editing silently.
 *
 * Three kinds of change:
 *
 * 1. **Required additions.** Gecko will not install an unsigned extension
 *    without an id, and a Chrome package never carries one. A stable id is
 *    derived from the package itself, so re-importing the same extension
 *    replaces it rather than stacking a second copy.
 *
 * 2. **Structural differences.** MV3 background is the notable one: Chrome
 *    runs `background.service_worker`, Gecko runs `background.scripts`. The
 *    service worker file is moved, not copied, and the `type: "module"` that
 *    goes with it is dropped — Gecko's event pages are not modules.
 *
 * 3. **Chrome-only keys.** Keys that name a feature Gecko does not implement
 *    are removed so the install does not fail or leave a lie in the manifest.
 *    The alternative — leaving them — makes an extension claim a capability it
 *    will never have.
 *
 * What this deliberately does *not* do is filter `permissions`. An unknown
 * permission is a warning in Gecko, not a refusal, and silently dropping one
 * would produce an extension that installs and then misbehaves in ways that are
 * far harder to explain than a warning.
 */
object ChromeManifestTranslator {

    /** Keys that name a Chrome-only feature; Gecko has no counterpart. */
    private val CHROME_ONLY_KEYS = listOf(
        "update_url",               // Chrome Web Store auto-update endpoint
        "minimum_chrome_version",   // constrains a different browser
        "offline_enabled",          // ChromeOS/Chrome app concept
        "version_name",             // display-only, Gecko ignores it
        "side_panel",               // Chrome's side panel
        "tts_engine",               // Chrome's TTS engine registration
        "input_components",         // ChromeOS IME registration
        "platforms",                // Chrome app platform list
        "app",                      // legacy Chrome Apps
        "nacl_modules",             // Native Client; removed in Chrome itself
        "file_browser_handlers",    // ChromeOS file manager
        "file_system_provider_capabilities",
        "automation",               // Chrome's automation manifest
        "externally_connectable",   // Chrome page-to-extension messaging
    )

    /** The asset the polyfill is written to inside the converted extension. */
    const val POLYFILL_FILE = "weblibre_chrome_compat.js"

    data class Translation(
        val manifest: JSONObject,
        /** Human-readable description of every change made, in order. */
        val notes: List<String>,
    )

    /**
     * Translate [source] for installation under [geckoId], wiring
     * [polyfillFile] in ahead of the extension's own scripts.
     */
    fun translate(source: JSONObject, geckoId: String, polyfillFile: String = POLYFILL_FILE): Translation {
        val notes = mutableListOf<String>()

        // A fresh object: the caller's manifest is often still the one parsed
        // from the archive, and mutating it would make the two views disagree.
        val manifest = JSONObject(source.toString())

        translateBackground(manifest, polyfillFile, notes)
        translateContentScripts(manifest, polyfillFile, notes)
        translateContentSecurityPolicy(manifest, notes)
        stripChromeOnlyKeys(manifest, notes)
        ensureGeckoId(manifest, geckoId, notes)

        return Translation(manifest, notes)
    }

    // -------------------------------------------------------------------------
    // Background
    // -------------------------------------------------------------------------

    private fun translateBackground(manifest: JSONObject, polyfillFile: String, notes: MutableList<String>) {
        val background = manifest.optJSONObject("background")
        if (background == null) {
            // MV3 extensions may still call chrome.* from content scripts only,
            // so a missing background is not a reason to skip the polyfill.
            if (manifest.optInt("manifest_version", 2) >= 3) {
                notes += "no background section, so the compat layer is only wired into content scripts"
            }
            return
        }

        val serviceWorker = background.optString("service_worker").takeIf { it.isNotEmpty() }
        if (serviceWorker != null) {
            val scripts = JSONArray()
            scripts.put(polyfillFile)
            scripts.put(serviceWorker)
            background.put("scripts", scripts)
            background.remove("service_worker")
            notes += "moved background.service_worker ($serviceWorker) to background.scripts, as Gecko runs an event page rather than a worker"
        } else {
            val existing = background.optJSONArray("scripts")
            if (existing != null) {
                val scripts = JSONArray()
                scripts.put(polyfillFile)
                for (i in 0 until existing.length()) scripts.put(existing.optString(i))
                background.put("scripts", scripts)
            }
        }

        if (background.has("type")) {
            background.remove("type")
            notes += "dropped background.type, as Gecko's event pages are not modules"
        }
    }

    // -------------------------------------------------------------------------
    // Content scripts
    // -------------------------------------------------------------------------

    private fun translateContentScripts(manifest: JSONObject, polyfillFile: String, notes: MutableList<String>) {
        val contentScripts = manifest.optJSONArray("content_scripts") ?: return
        var injected = 0

        for (i in 0 until contentScripts.length()) {
            val entry = contentScripts.optJSONObject(i) ?: continue
            val js = entry.optJSONArray("js") ?: continue
            val prefixed = JSONArray()
            prefixed.put(polyfillFile)
            for (j in 0 until js.length()) prefixed.put(js.optString(j))
            entry.put("js", prefixed)
            injected++
        }

        if (injected > 0) {
            notes += "prefixed $injected content script entr${if (injected == 1) "y" else "ies"} with the compat layer, so chrome.* resolves in page scripts"
        }
    }

    // -------------------------------------------------------------------------
    // Content security policy
    // -------------------------------------------------------------------------

    private fun translateContentSecurityPolicy(manifest: JSONObject, notes: MutableList<String>) {
        if (manifest.optInt("manifest_version", 2) < 3) return
        val csp = manifest.opt("content_security_policy") ?: return
        if (csp is String) {
            // MV3 moved from a bare string to one policy per context.
            manifest.put(
                "content_security_policy",
                JSONObject().put("extension_pages", csp),
            )
            notes += "wrapped the MV3 content_security_policy string into an extension_pages object"
        }
    }

    // -------------------------------------------------------------------------
    // Chrome-only keys
    // -------------------------------------------------------------------------

    private fun stripChromeOnlyKeys(manifest: JSONObject, notes: MutableList<String>) {
        val removed = mutableListOf<String>()
        for (key in CHROME_ONLY_KEYS) {
            if (manifest.has(key)) {
                manifest.remove(key)
                removed += key
            }
        }
        if (removed.isNotEmpty()) {
            notes += "removed Chrome-only keys Gecko has no counterpart for: ${removed.joinToString(", ")}"
        }
    }

    // -------------------------------------------------------------------------
    // Identity
    // -------------------------------------------------------------------------

    private fun ensureGeckoId(manifest: JSONObject, geckoId: String, notes: MutableList<String>) {
        val existing = manifest
            .optJSONObject("browser_specific_settings")
            ?.optJSONObject("gecko")
            ?.optString("id")
            ?.takeIf { it.isNotEmpty() }

        if (existing != null) {
            notes += "kept the extension's own id $existing"
            return
        }

        val settings = manifest.optJSONObject("browser_specific_settings") ?: JSONObject()
        val gecko = settings.optJSONObject("gecko") ?: JSONObject()
        gecko.put("id", geckoId)
        // Chrome extensions target Chromium versions, not Gecko ones; leaving
        // this unset lets Gecko decide rather than guessing a version.
        settings.put("gecko", gecko)
        manifest.put("browser_specific_settings", settings)
        notes += "added browser_specific_settings.gecko.id = $geckoId, without which Gecko refuses an unsigned install"
    }

    /**
     * A stable id for a Chrome package.
     *
     * Chrome identifies an extension by the hash of the public key in its `key`
     * field, and by nothing else — two builds of the same extension with
     * different names are the same extension. Hashing the key when it is
     * present reproduces that, so an upgrade replaces the previous install.
     * Without a key the name is the only stable thing available.
     */
    fun deriveGeckoId(name: String?, key: String?): String {
        val seed = key?.takeIf { it.isNotBlank() } ?: name?.takeIf { it.isNotBlank() } ?: "unknown"
        val hash = fnv1a(seed).toString(16).padStart(8, '0')
        return "chrome-import-$hash@weblibre.eu"
    }

    private fun fnv1a(value: String): Long {
        var hash = 0x811c9dc5L
        for (byte in value.toByteArray()) {
            hash = hash xor (byte.toLong() and 0xFF)
            hash = (hash * 0x01000193L) and 0xFFFFFFFFL
        }
        return hash
    }
}
