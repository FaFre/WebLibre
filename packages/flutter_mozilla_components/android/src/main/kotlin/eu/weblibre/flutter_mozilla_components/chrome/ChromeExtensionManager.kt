/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.chrome

import android.content.Context
import mozilla.components.support.base.log.logger.Logger
import org.json.JSONObject
import java.io.File

/**
 * Manages imported Chrome extensions.
 *
 * Provides methods to list, enable/disable, and uninstall extensions.
 */
class ChromeExtensionManager(private val context: Context) {

    companion object {
        private val logger = Logger("ChromeExtensionManager")
        private const val PREFS_NAME = "chrome_extensions"
        private const val KEY_INSTALLED_EXTENSIONS = "installed_extensions"
    }

    data class ExtensionInfo(
        val id: String,
        val name: String,
        val version: String,
        val enabled: Boolean,
        val installTime: Long,
        val permissions: List<String>
    )

    /**
     * List all installed Chrome extensions.
     */
    fun listExtensions(): List<ExtensionInfo> {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val extensionsJson = prefs.getString(KEY_INSTALLED_EXTENSIONS, "{}") ?: "{}"
        
        return try {
            val extensionsObj = JSONObject(extensionsJson)
            val result = mutableListOf<ExtensionInfo>()
            
            val keys = extensionsObj.keys()
            while (keys.hasNext()) {
                val id = keys.next()
                val ext = extensionsObj.getJSONObject(id)
                result.add(
                    ExtensionInfo(
                        id = id,
                        name = ext.optString("name", id),
                        version = ext.optString("version", "1.0"),
                        enabled = ext.optBoolean("enabled", true),
                        installTime = ext.optLong("installTime", 0L),
                        permissions = ext.optJSONArray("permissions")?.let { perms ->
                            (0 until perms.length()).map { perms.getString(it) }
                        } ?: emptyList()
                    )
                )
            }
            result
        } catch (e: Exception) {
            logger.error("Failed to list extensions", e)
            emptyList()
        }
    }

    /**
     * Get extension info by ID.
     */
    fun getExtension(id: String): ExtensionInfo? {
        return listExtensions().find { it.id == id }
    }

    /**
     * Enable an extension.
     */
    fun enableExtension(id: String) {
        updateExtensionState(id, enabled = true)
        logger.info("Enabled extension: $id")
    }

    /**
     * Disable an extension.
     */
    fun disableExtension(id: String) {
        updateExtensionState(id, enabled = false)
        logger.info("Disabled extension: $id")
    }

    /**
     * Uninstall an extension.
     */
    fun uninstallExtension(id: String): Boolean {
        return try {
            // Remove from preferences
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val extensionsJson = prefs.getString(KEY_INSTALLED_EXTENSIONS, "{}") ?: "{}"
            val extensionsObj = JSONObject(extensionsJson)
            extensionsObj.remove(id)
            prefs.edit().putString(KEY_INSTALLED_EXTENSIONS, extensionsObj.toString()).apply()
            
            // Remove extension directory if exists
            val extDir = File(context.cacheDir, "chrome_extensions/$id")
            if (extDir.exists()) {
                extDir.deleteRecursively()
            }
            
            logger.info("Uninstalled extension: $id")
            true
        } catch (e: Exception) {
            logger.error("Failed to uninstall extension: $id", e)
            false
        }
    }

    /**
     * Register a newly imported extension.
     */
    fun registerExtension(info: ExtensionInfo) {
        try {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val extensionsJson = prefs.getString(KEY_INSTALLED_EXTENSIONS, "{}") ?: "{}"
            val extensionsObj = JSONObject(extensionsJson)
            
            val extObj = JSONObject()
            extObj.put("name", info.name)
            extObj.put("version", info.version)
            extObj.put("enabled", info.enabled)
            extObj.put("installTime", info.installTime)
            extObj.put("permissions", JSONArray(info.permissions))
            
            extensionsObj.put(info.id, extObj)
            prefs.edit().putString(KEY_INSTALLED_EXTENSIONS, extensionsObj.toString()).apply()
            
            logger.info("Registered extension: ${info.id}")
        } catch (e: Exception) {
            logger.error("Failed to register extension: ${info.id}", e)
        }
    }

    private fun updateExtensionState(id: String, enabled: Boolean) {
        try {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val extensionsJson = prefs.getString(KEY_INSTALLED_EXTENSIONS, "{}") ?: "{}"
            val extensionsObj = JSONObject(extensionsJson)
            
            if (extensionsObj.has(id)) {
                val ext = extensionsObj.getJSONObject(id)
                ext.put("enabled", enabled)
                extensionsObj.put(id, ext)
                prefs.edit().putString(KEY_INSTALLED_EXTENSIONS, extensionsObj.toString()).apply()
            }
        } catch (e: Exception) {
            logger.error("Failed to update extension state: $id", e)
        }
    }
}
