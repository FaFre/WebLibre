/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.chrome

import org.json.JSONArray
import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test

class ChromeManifestTranslatorTest {

    /** A minimal MV2 manifest for an extension that only uses chrome.tabs. */
    private fun minimalManifest(
        name: String = "Test Extension",
        version: String = "1.0",
        manifestVersion: Int = 2,
        backgroundScripts: List<String> = emptyList(),
        contentScripts: List<Any> = emptyList(),
        extra: JSONObject = JSONObject(),
    ): JSONObject {
        val manifest = JSONObject()
        manifest.put("name", name)
        manifest.put("version", version)
        manifest.put("manifest_version", manifestVersion)
        manifest.put("permissions", JSONArray(listOf("tabs")))

        if (backgroundScripts.isNotEmpty()) {
            val bg = JSONObject()
            bg.put("scripts", JSONArray(backgroundScripts))
            manifest.put("background", bg)
        }

        if (contentScripts.isNotEmpty()) {
            manifest.put("content_scripts", JSONArray(contentScripts))
        }

        if (manifestVersion >= 3) {
            manifest.put("action", JSONObject().put("default_popup", "popup.html"))
        }

        manifest.putAll(extra)
        return manifest
    }

    // -------------------------------------------------------------------------
    // Manifest V3 background rewrite
    // -------------------------------------------------------------------------

    @Test
    fun `mv3 moves service_worker to scripts with compat layer first`() {
        val manifest = minimalManifest(
            backgroundScripts = listOf("worker.js"),
            manifestVersion = 3,
        )
        val result = ChromeManifestTranslator.translate(manifest, "test-id@weblibre.eu")

        val bg = result.manifest.getJSONObject("background")
        val scripts = bg.getJSONArray("scripts")
        assertEquals(2, scripts.length())
        assertEquals(ChromeManifestTranslator.POLYFILL_FILE, scripts.getString(0))
        assertEquals("worker.js", scripts.getString(1))
        assertFalse(bg.has("service_worker"))
        assertFalse(bg.has("type"))

        assertTrue(result.notes.any { it.contains("service_worker") })
    }

    @Test
    fun `mv3 drops background.type`() {
        val manifest = minimalManifest(backgroundScripts = listOf("bg.js"), manifestVersion = 3)
        manifest.getJSONObject("background").put("type", "module")

        val result = ChromeManifestTranslator.translate(manifest, "test-id@weblibre.eu")

        assertFalse(result.manifest.getJSONObject("background").has("type"))
        assertTrue(result.notes.any { it.contains("background.type") })
    }

    @Test
    fun `mv2 background.scripts keeps existing order and gets the compat layer prepended`() {
        val manifest = minimalManifest(backgroundScripts = listOf("a.js", "b.js"))
        val result = ChromeManifestTranslator.translate(manifest, "test-id@weblibre.eu")

        val scripts = result.manifest.getJSONObject("background").getJSONArray("scripts")
        assertEquals(3, scripts.length())
        assertEquals(ChromeManifestTranslator.POLYFILL_FILE, scripts.getString(0))
        assertEquals("a.js", scripts.getString(1))
        assertEquals("b.js", scripts.getString(2))
    }

    @Test
    fun `missing background does not crash but a mv3 still notes polyfill wiring`() {
        val manifest = minimalManifest(manifestVersion = 3).apply {
            remove("background")
        }
        val result = ChromeManifestTranslator.translate(manifest, "test-id@weblibre.eu")

        assertFalse(result.manifest.has("background"))
        assertTrue(result.notes.any { it.contains("compat layer") || it.contains("content script") })
    }

    // -------------------------------------------------------------------------
    // Content scripts
    // -------------------------------------------------------------------------

    @Test
    fun `the compat layer is prepended to each content script entry's js array`() {
        val cs = JSONArray()
        val entry = JSONObject()
        entry.put("matches", JSONArray(listOf("<all_urls>")))
        entry.put("js", JSONArray(listOf("script.js")))
        cs.put(entry)

        val manifest = minimalManifest(contentScripts = listOf(cs))
        val result = ChromeManifestTranslator.translate(manifest, "test-id@weblibre.eu")

        val rewritten = result.manifest.getJSONArray("content_scripts")
        assertEquals(1, rewritten.length())
        val scripts = rewritten.getJSONObject(0).getJSONArray("js")
        assertEquals(2, scripts.length())
        assertEquals(ChromeManifestTranslator.POLYFILL_FILE, scripts.getString(0))
        assertEquals("script.js", scripts.getString(1))
    }

    @Test
    fun `a content script entry without js is left alone`() {
        val cs = JSONArray()
        val entry = JSONObject()
        entry.put("matches", JSONArray(listOf("<all_urls>")))
        // no js key
        cs.put(entry)

        val manifest = minimalManifest(contentScripts = listOf(cs))
        val result = ChromeManifestTranslator.translate(manifest, "test-id@weblibre.eu")

        val rewritten = result.manifest.getJSONArray("content_scripts")
        assertEquals(1, rewritten.length())
        assertFalse(rewritten.getJSONObject(0).has("js"))
    }

    // -------------------------------------------------------------------------
    // CSP wrapping for MV3
    // -------------------------------------------------------------------------

    @Test
    fun `mv2 csp string is left untouched`() {
        val manifest = minimalManifest(manifestVersion = 2).apply {
            put("content_security_policy", "script-src 'self'; object-src 'self'")
        }
        val result = ChromeManifestTranslator.translate(manifest, "test-id@weblibre.eu")
        assertEquals("script-src 'self'; object-src 'self'", result.manifest.getString("content_security_policy"))
    }

    @Test
    fun `mv3 bare-string csp is wrapped into extension_pages`() {
        val manifest = minimalManifest(manifestVersion = 3).apply {
            put("content_security_policy", "script-src 'self'; object-src 'self'")
        }
        val result = ChromeManifestTranslator.translate(manifest, "test-id@weblibre.eu")

        val csp = result.manifest.getJSONObject("content_security_policy")
        assertEquals("script-src 'self'; object-src 'self'", csp.getString("extension_pages"))
    }

    // -------------------------------------------------------------------------
    // Chrome-only keys stripped
    // -------------------------------------------------------------------------

    @Test
    fun `chrome-only keys are removed and noted`() {
        val manifest = minimalManifest().apply {
            put("update_url", "https://clients2.google.com/service/update2/crx")
            put("minimum_chrome_version", "99.0")
        }
        val result = ChromeManifestTranslator.translate(manifest, "test-id@weblibre.eu")

        assertFalse(result.manifest.has("update_url"))
        assertFalse(result.manifest.has("minimum_chrome_version"))
        assertTrue(result.notes.any { it.contains("remove") })
    }

    @Test
    fun `keys present on the manifest are removed individually`() {
        val manifest = minimalManifest().apply {
            put("side_panel", JSONObject())
            put("tts_engine", JSONObject())
            put("input_components", JSONArray())
        }
        val result = ChromeManifestTranslator.translate(manifest, "test-id@weblibre.eu")

        assertFalse(result.manifest.has("side_panel"))
        assertFalse(result.manifest.has("tts_engine"))
        assertFalse(result.manifest.has("input_components"))
    }

    // -------------------------------------------------------------------------
    // Gecko id
    // -------------------------------------------------------------------------

    @Test
    fun `an extension without browser_specific_settings gets a derived gecko id`() {
        val manifest = minimalManifest(name = "Test", version = "1.0")
        val result = ChromeManifestTranslator.translate(manifest, "derived-id@weblibre.eu")

        assertEquals(
            "derived-id@weblibre.eu",
            result.manifest.getJSONObject("browser_specific_settings").getJSONObject("gecko").getString("id"),
        )
    }

    @Test
    fun `an extension that already has a gecko id keeps it`() {
        val manifest = minimalManifest().apply {
            put("browser_specific_settings", JSONObject().put("gecko", JSONObject().put("id", "existing@mozilla.org")))
        }
        val result = ChromeManifestTranslator.translate(manifest, "derived-id@weblibre.eu")

        assertEquals("existing@mozilla.org", result.manifest.getJSONObject("browser_specific_settings").getJSONObject("gecko").getString("id"))
        assertTrue(result.notes.any { it.contains("kept") })
    }

    @Test
    fun `no browser_specific_settings at all is created when missing`() {
        val manifest = minimalManifest()
        val result = ChromeManifestTranslator.translate(manifest, "derived-id@weblibre.eu")

        assertTrue(result.manifest.has("browser_specific_settings"))
        assertTrue(result.manifest.getJSONObject("browser_specific_settings").has("gecko"))
    }

    @Test
    fun `deriving a gecko id from a key uses the key's hash`() {
        val idFromKey = ChromeManifestTranslator.deriveGeckoId(name = "Test", key = "some-base64-key==")
        val idFromSameKey = ChromeManifestTranslator.deriveGeckoId(name = "Other", key = "some-base64-key==")

        assertEquals(idFromKey, idFromSameKey)
        assertTrue(idFromKey.startsWith("chrome-import-"))
    }

    @Test
    fun `deriving a gecko id without a key falls back to the name`() {
        val id1 = ChromeManifestTranslator.deriveGeckoId(name = "Same Name", key = null)
        val id2 = ChromeManifestTranslator.deriveGeckoId(name = "Same Name", key = null)
        val id3 = ChromeManifestTranslator.deriveGeckoId(name = "Different", key = null)

        assertEquals(id1, id2)
        assertNotEquals(id1, id3)
    }

    @Test
    fun `deriving a gecko id without anything produces a stable unknown id`() {
        val id = ChromeManifestTranslator.deriveGeckoId(name = null, key = null)
        assertTrue(id.startsWith("chrome-import-"))
        // Deterministic across calls.
        assertEquals(id, ChromeManifestTranslator.deriveGeckoId(name = null, key = null))
    }

    // -------------------------------------------------------------------------
    // Translation is non-mutating to the source
    // -------------------------------------------------------------------------

    @Test
    fun `translating does not mutate the original manifest`() {
        val manifest = minimalManifest(name = "Original")
        ChromeManifestTranslator.translate(manifest, "derived-id@weblibre.eu")

        assertFalse(manifest.has("browser_specific_settings"))
        assertFalse(manifest.has("content_security_policy"))
    }

    // -------------------------------------------------------------------------
    // Notes are present and ordered
    // -------------------------------------------------------------------------

    @Test
    fun `a full translation emits notes for every change made`() {
        val manifest = minimalManifest(
            name = "Full Test",
            version = "2.0",
            manifestVersion = 3,
            backgroundScripts = listOf("worker.js"),
            contentScripts = listOf(JSONObject().apply {
                put("matches", JSONArray(listOf("<all_urls>")))
                put("js", JSONArray(listOf("content.js")))
            }),
            extra = JSONObject().apply {
                put("update_url", "https://example.com/update")
                put("minimum_chrome_version", "90")
                put("content_security_policy", "script-src 'self'")
            },
        )

        val result = ChromeManifestTranslator.translate(manifest, "full-test@weblibre.eu")

        assertTrue(result.notes.any { it.contains("service_worker") })
        assertTrue(result.notes.any { it.contains("content script") })
        assertTrue(result.notes.any { it.contains("update_url") })
        assertTrue(result.notes.any { it.contains("minimum_chrome_version") })
        assertTrue(result.notes.any { it.contains("csp") })
        assertTrue(result.notes.any { it.contains("gecko.id") })
        assertTrue(result.notes.any { it.contains("background.type") })
    }
}
