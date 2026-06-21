/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import android.content.SharedPreferences
import androidx.annotation.VisibleForTesting
import androidx.core.content.edit
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.webextension.MessageHandler
import mozilla.components.concept.engine.webextension.Port
import mozilla.components.concept.engine.webextension.WebExtensionRuntime
import mozilla.components.support.base.log.logger.Logger
import mozilla.components.support.webextensions.BuiltInWebExtensionController
import org.json.JSONObject

/**
 * Bridges WebLibre's "pure black" setting into Mozilla's reader view extension so
 * the dark color scheme can be rendered as pure black (AMOLED).
 *
 * Flutter remains the source of truth for the setting (see
 * general_settings.dart `pureBlack` and engine_settings_replication.dart).
 * Mozilla's reader view extension (`readerview@mozac.org`) is a prebuilt part of
 * `org.mozilla.components:feature-readerview`; we override its bundled assets
 * (readerview.css / readerview.js) to honor an `amoled` body class.
 *
 * The flag is delivered into the reader page over a dedicated **content** port
 * ([APPEARANCE_PORT]) registered on the reader tab's engine session. We use a
 * content port (registered whenever a tab's reader view becomes active, see
 * [registerSession]) rather than the extension's background script because the
 * reader extension's background is a non-persistent event page that gets
 * suspended when idle, dropping pushes; the reader page (and therefore its
 * content port) is alive exactly while reader view is on screen. The value is
 * pushed when the page connects ([MessageHandler.onPortConnected]) and again
 * whenever the user toggles the setting ([setPureBlack]).
 *
 * Registration is driven by the BrowserStore reader-active state (see
 * Events.kt), not the user's reader toggle, so it also covers reader views that
 * were restored on app start ("resume last tab") without an explicit toggle.
 *
 * The value is also persisted in [SharedPreferences] so it survives process
 * restarts (e.g. a cold-started Custom Tab / PWA reader view before Flutter has
 * pushed the setting).
 */
object ReaderViewAppearanceFeature {
    private val logger = Logger("reader-view-appearance")

    private const val EXTENSION_ID = "readerview@mozac.org"
    private const val EXTENSION_URL = "resource://android/assets/extensions/readerview/"
    private const val APPEARANCE_PORT = "weblibreReaderviewActive"

    private const val PREF_KEY = "weblibre_reader_pure_black"
    private const val MESSAGE_KEY_AMOLED = "amoled"

    @Volatile
    private var pureBlack: Boolean = false

    @VisibleForTesting
    // Internal var to make it mutable for unit testing purposes only.
    internal var extensionController = BuiltInWebExtensionController(
        EXTENSION_ID,
        EXTENSION_URL,
        APPEARANCE_PORT,
    )

    private val messageHandler = object : MessageHandler {
        override fun onPortConnected(port: Port) {
            // Push the current value as soon as the reader page connects, so it
            // can correct the cached value it applied on load.
            port.postMessage(currentMessage())
        }
    }

    private fun currentMessage(): JSONObject =
        JSONObject().put(MESSAGE_KEY_AMOLED, pureBlack)

    /**
     * Installs Mozilla's reader view extension early and seeds the persisted
     * value. The reader view feature itself (from android-components) reuses the
     * already-installed extension via the shared built-in extension registry, so
     * installing it here does not interfere with its lifecycle.
     */
    fun install(runtime: WebExtensionRuntime, prefs: SharedPreferences) {
        pureBlack = prefs.getBoolean(PREF_KEY, false)

        extensionController.install(
            runtime,
            onSuccess = {
                logger.debug("Installed reader view extension: ${it.id}")
            },
            onError = { throwable ->
                logger.error("Failed to install reader view extension", throwable)
            },
        )
    }

    /**
     * Registers the appearance content port on an engine session whose reader
     * view has become active. Idempotent (safe to call again for the same
     * session). Pushes the current value immediately if the port is already
     * connected (e.g. a restored reader page that connected before this ran);
     * otherwise [MessageHandler.onPortConnected] pushes it once the page connects.
     */
    fun registerSession(session: EngineSession) {
        extensionController.registerContentMessageHandler(
            session,
            messageHandler,
            APPEARANCE_PORT,
        )

        pushTo(session)
    }

    /**
     * Updates the pure-black flag, persists it, and pushes it to every currently
     * active reader page so the change is reflected immediately without having to
     * re-enter reader view.
     *
     * @param sessions the engine sessions of all tabs whose reader view is active.
     */
    fun setPureBlack(enabled: Boolean, prefs: SharedPreferences, sessions: List<EngineSession>) {
        pureBlack = enabled
        prefs.edit { putBoolean(PREF_KEY, enabled) }

        sessions.forEach { pushTo(it) }
    }

    private fun pushTo(session: EngineSession) {
        if (extensionController.portConnected(session, APPEARANCE_PORT)) {
            extensionController.sendContentMessage(currentMessage(), session, APPEARANCE_PORT)
        }
    }
}
