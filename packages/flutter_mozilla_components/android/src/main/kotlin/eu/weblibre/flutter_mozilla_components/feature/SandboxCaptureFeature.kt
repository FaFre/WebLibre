/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import android.content.Context
import eu.weblibre.flutter_mozilla_components.ActiveProfile
import eu.weblibre.flutter_mozilla_components.PwaConstants
import eu.weblibre.flutter_mozilla_components.pigeons.SandboxCaptureApi
import eu.weblibre.flutter_mozilla_components.pigeons.SandboxCaptureEntry
import eu.weblibre.flutter_mozilla_components.pigeons.SandboxCaptureHostEvents
import io.flutter.plugin.common.BinaryMessenger
import mozilla.components.concept.engine.Engine
import mozilla.components.support.base.log.logger.Logger
import mozilla.components.support.webextensions.BuiltInWebExtensionController
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

// Installs the bundled sandbox-capture WebExtension (subresource firewall)
// and serves as the Dart -> Kotlin SandboxCaptureApi endpoint. The extension
// is stateless; no content-message handler is registered.
object SandboxCaptureFeature : SandboxCaptureApi {
    private val logger = Logger("SandboxCapture")

    private const val EXTENSION_ID = "sandbox-capture@weblibre.eu"
    private const val EXTENSION_URL =
        "resource://android/assets/extensions/sandbox_capture/"

    // Highest sandbox_captures.json envelope version this build understands.
    // Bump in lockstep with `_version` in Dart's SandboxCaptureStore. A
    // newer envelope leaves the registry empty for the current cold start
    // so sandbox tabs reopen as about:blank rather than potentially being
    // mis-rehydrated.
    private const val SUPPORTED_VERSION = 1

    private val extensionController = BuiltInWebExtensionController(
        EXTENSION_ID,
        EXTENSION_URL,
        // The extension doesn't open a content port; we pass a dummy channel
        // name because BuiltInWebExtensionController requires one.
        "sandboxCapture",
    )

    fun install(engine: Engine) {
        extensionController.install(
            engine,
            onSuccess = {
                logger.debug("Installed sandbox_capture webextension")
            },
            onError = { throwable ->
                logger.error("Failed to install sandbox_capture", throwable)
            },
        )
    }

    // Rehydrate the registry from disk before Gecko tab restore fires any
    // AppRequestInterceptor.onLoadRequest. Each entry is stamped with
    // redirectUrl="about:blank" so the first load after cold start shows a
    // blank page rather than hitting the live web. Dart will call resetAll
    // again after CaptureServer comes up to supply the real loader/capture
    // URLs.
    fun preRestoreBootstrap(context: Context) {
        try {
            val file = sandboxCapturesFile(context) ?: return
            if (!file.exists()) return

            val json = JSONObject(file.readText())

            // Treat a missing `version` field as v1 to stay compatible with
            // envelopes written before versioning was introduced. Reject
            // newer versions loudly — see SUPPORTED_VERSION comment.
            val version = json.optInt("version", 1)
            if (version > SUPPORTED_VERSION) {
                logger.warn(
                    "sandbox_captures.json version $version is newer than " +
                        "SUPPORTED_VERSION=$SUPPORTED_VERSION; starting empty " +
                        "to avoid mis-rehydrating.",
                )
                SandboxCaptureRegistry.resetAll(emptyMap())
                return
            }

            val entries = json.optJSONArray("entries") ?: return
            val populated = HashMap<String, SandboxCaptureRegistry.SandboxEntry>()

            for (i in 0 until entries.length()) {
                val obj = entries.optJSONObject(i) ?: continue
                val tabId = obj.optString("tabId")
                val captureId = obj.optString("captureId")
                val sourceUrl = obj.optString("sourceUrl")
                val status = obj.optString("status", "pending")
                if (tabId.isEmpty() || captureId.isEmpty() || sourceUrl.isEmpty()) {
                    continue
                }
                populated[tabId] = SandboxCaptureRegistry.SandboxEntry(
                    captureId = captureId,
                    sourceUrl = sourceUrl,
                    redirectUrl = "about:blank",
                    status = status,
                )
            }

            SandboxCaptureRegistry.resetAll(populated)
            logger.debug("Rehydrated ${populated.size} sandbox tab(s) from disk")
        } catch (t: Throwable) {
            logger.error("Failed to rehydrate sandbox registry; starting empty", t)
            SandboxCaptureRegistry.resetAll(emptyMap())
        }
    }

    fun wireFlutterEvents(binaryMessenger: BinaryMessenger) {
        SandboxCaptureApi.setUp(binaryMessenger, this)
        SandboxCaptureBridge.events = SandboxCaptureHostEvents(binaryMessenger)
    }

    fun detachFlutterEvents(binaryMessenger: BinaryMessenger) {
        SandboxCaptureApi.setUp(binaryMessenger, null)
        SandboxCaptureBridge.events = null
    }

    // SandboxCaptureApi implementation: Dart -> Kotlin.

    override fun resetAll(entries: List<SandboxCaptureEntry>) {
        val map = HashMap<String, SandboxCaptureRegistry.SandboxEntry>()
        for (e in entries) {
            map[e.tabId] = e.toRegistryEntry()
        }
        SandboxCaptureRegistry.resetAll(map)
    }

    override fun mark(entry: SandboxCaptureEntry) {
        SandboxCaptureRegistry.put(entry.tabId, entry.toRegistryEntry())
    }

    override fun unmark(tabId: String) {
        SandboxCaptureRegistry.remove(tabId)
    }

    // JSON mirror file under the active profile dir. Dart writes it on every
    // mutation; Kotlin reads it during pre-Gecko bootstrap.
    private fun sandboxCapturesFile(context: Context): File? {
        if (ActiveProfile.prefix == null) {
            ActiveProfile.resolveFromDisk(context)
        }
        val prefix = ActiveProfile.prefix ?: return null
        val profileDir = File(
            context.filesDir,
            "${PwaConstants.PROFILES_DIR_NAME}/$prefix",
        )
        return File(profileDir, "files/sandbox_captures.json")
    }

    // Exposed for Dart tests that want to verify the JSON format without
    // writing a binding — the Dart side uses the same path convention.
    fun sandboxCapturesJson(entries: List<SandboxCaptureRegistry.SandboxEntry>, tabIds: List<String>): String {
        require(entries.size == tabIds.size)
        val array = JSONArray()
        entries.forEachIndexed { i, e ->
            array.put(
                JSONObject().apply {
                    put("tabId", tabIds[i])
                    put("captureId", e.captureId)
                    put("sourceUrl", e.sourceUrl)
                    put("status", e.status)
                },
            )
        }
        return JSONObject()
            .put("version", SUPPORTED_VERSION)
            .put("entries", array)
            .toString()
    }
}
