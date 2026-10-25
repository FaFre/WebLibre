/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.protection

import android.content.Context
import mozilla.components.support.base.log.logger.Logger
import org.json.JSONObject

/**
 * Reads the protection declarations out of the built-in extensions' manifests.
 *
 * A built-in extension is a directory under `assets/extensions/`. Reading the
 * declaration from the manifest rather than keeping a list here means adding a
 * protection extension is one change in one place — its own manifest — and the
 * monitor picks it up on the next start with nothing else to update.
 *
 * An extension that declares nothing is skipped silently: most built-in
 * extensions (reader view, cookie manager, sandbox capture) touch no
 * fingerprint surface, and that is not an error.
 */
object ProtectionDeclarationLoader {

    private val logger = Logger("ProtectionDeclarationLoader")

    private const val EXTENSIONS_DIR = "extensions"
    private const val MANIFEST_NAME = "manifest.json"

    /** Declarations from every built-in extension that declares any. */
    fun load(context: Context): List<ProtectionDeclaration> {
        val declarations = mutableListOf<ProtectionDeclaration>()

        val extensionDirs = try {
            context.assets.list(EXTENSIONS_DIR) ?: return declarations
        } catch (e: Exception) {
            logger.warn("Could not list built-in extensions", e)
            return declarations
        }

        for (directory in extensionDirs) {
            val manifest = readManifest(context, directory) ?: continue
            val id = geckoId(manifest) ?: continue
            ProtectionDeclaration.parse(id, manifest)?.let(declarations::add)
        }

        return declarations
    }

    private fun readManifest(context: Context, directory: String): String? {
        return try {
            context.assets
                .open("$EXTENSIONS_DIR/$directory/$MANIFEST_NAME")
                .bufferedReader()
                .use { it.readText() }
        } catch (e: Exception) {
            // A directory without a manifest is not an extension.
            null
        }
    }

    private fun geckoId(manifestJson: String): String? {
        return try {
            JSONObject(manifestJson)
                .optJSONObject("browser_specific_settings")
                ?.optJSONObject("gecko")
                ?.optString("id")
                ?.takeIf { it.isNotEmpty() }
        } catch (e: Exception) {
            null
        }
    }
}
