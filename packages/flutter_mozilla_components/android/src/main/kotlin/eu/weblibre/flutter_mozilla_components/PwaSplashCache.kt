/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import mozilla.components.concept.engine.manifest.WebAppManifest
import mozilla.components.concept.engine.manifest.WebAppManifestParser
import java.io.File
import java.io.FileOutputStream

/**
 * Simple disk cache for PWA splash screen data (manifest + icon).
 * Keyed by shortcut ID so home screen shortcuts can instantly display
 * branded splash screens without waiting for components to initialize.
 *
 * Cache layout:
 *   <filesDir>/pwa_cache/<shortcutId>/manifest.json
 *   <filesDir>/pwa_cache/<shortcutId>/icon.png
 */
object PwaSplashCache {

    private const val TAG = "PwaSplashCache"
    private val parser = WebAppManifestParser()

    private const val MANIFEST_FILE = "manifest.json"
    private const val ICON_FILE = "icon.png"

    /**
     * Saves manifest JSON and icon bitmap to disk for the given shortcut ID.
     */
    fun save(context: Context, shortcutId: String, manifest: WebAppManifest, icon: Bitmap?) {
        try {
            val dir = cacheDir(context, shortcutId)
            if (!dir.exists()) dir.mkdirs()

            val json = parser.serialize(manifest).toString()
            File(dir, MANIFEST_FILE).writeText(json)

            icon?.let { bitmap ->
                FileOutputStream(File(dir, ICON_FILE)).use { out ->
                    bitmap.compress(Bitmap.CompressFormat.PNG, 90, out)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to cache splash data for $shortcutId", e)
        }
    }

    /**
     * Loads cached manifest for the given shortcut ID, or null if not cached.
     */
    fun loadManifest(context: Context, shortcutId: String): WebAppManifest? {
        return try {
            val file = File(cacheDir(context, shortcutId), MANIFEST_FILE)
            if (!file.exists()) return null

            val json = file.readText()
            when (val result = parser.parse(json)) {
                is WebAppManifestParser.Result.Success -> result.manifest
                is WebAppManifestParser.Result.Failure -> {
                    Log.e(TAG, "Failed to parse cached manifest for $shortcutId", result.exception)
                    null
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to load cached manifest for $shortcutId", e)
            null
        }
    }

    /**
     * Loads cached icon bitmap for the given shortcut ID, or null if not cached.
     */
    fun loadIcon(context: Context, shortcutId: String): Bitmap? {
        return try {
            val file = File(cacheDir(context, shortcutId), ICON_FILE)
            if (!file.exists()) return null
            BitmapFactory.decodeFile(file.absolutePath)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to load cached icon for $shortcutId", e)
            null
        }
    }

    private fun cacheDir(context: Context, shortcutId: String): File {
        // Always use applicationContext.filesDir to avoid profile-scoped context paths
        return File(context.applicationContext.filesDir, "${PwaConstants.PWA_CACHE_DIR}/$shortcutId")
    }
}
