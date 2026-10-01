/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.chrome

import android.content.Context
import mozilla.components.support.base.log.logger.Logger
import org.json.JSONArray

/**
 * Manages permissions for imported Chrome extensions.
 *
 * Tracks which permissions each extension has requested and granted,
 * and provides methods to check and modify permission states.
 */
class ExtensionPermissionManager(private val context: Context) {

    companion object {
        private val logger = Logger("ExtensionPermissionManager")
        private const val PREFS_NAME = "chrome_extension_permissions"
        private const val KEY_GRANTED_PERMISSIONS = "granted_permissions"
    }

    /**
     * Check if all requested permissions are granted for an extension.
     */
    fun arePermissionsGranted(extensionId: String, requestedPermissions: List<String>): Boolean {
        val granted = getGrantedPermissions(extensionId)
        return requestedPermissions.all { perm ->
            isPermissionGranted(extensionId, perm) || isPermissionAlwaysAllowed(perm)
        }
    }

    /**
     * Check if a specific permission is granted for an extension.
     */
    fun isPermissionGranted(extensionId: String, permission: String): Boolean {
        val granted = getGrantedPermissions(extensionId)
        return granted.contains(permission)
    }

    /**
     * Grant permissions for an extension.
     */
    fun grantPermissions(extensionId: String, permissions: List<String>) {
        val allPermissions = getGrantedPermissions(extensionId) + permissions
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().putStringSet(extensionId, allPermissions.toSet()).apply()
        logger.info("Granted permissions for $extensionId: $permissions")
    }

    /**
     * Revoke a specific permission for an extension.
     */
    fun revokePermission(extensionId: String, permission: String) {
        val granted = getGrantedPermissions(extensionId).toMutableSet()
        granted.remove(permission)
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().putStringSet(extensionId, granted).apply()
        logger.debug("Revoked permission '$permission' for $extensionId")
    }

    /**
     * Get all granted permissions for an extension.
     */
    fun getGrantedPermissions(extensionId: String): Set<String> {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return prefs.getStringSet(extensionId, emptySet()) ?: emptySet()
    }

    /**
     * Check if a permission is always allowed (no user consent needed).
     */
    fun isPermissionAlwaysAllowed(permission: String): Boolean {
        // These permissions are safe and don't require user consent
        return when (permission) {
            "activeTab" -> true
            "tabs" -> true  // Read-only tab info
            "scripting" -> true
            else -> false
        }
    }

    /**
     * Check if a permission requires user confirmation.
     */
    fun requiresConfirmation(permission: String): Boolean {
        return !isPermissionAlwaysAllowed(permission)
    }

    /**
     * Get permissions that need confirmation.
     */
    fun getPermissionsRequiringConfirmation(requestedPermissions: List<String>): List<String> {
        return requestedPermissions.filter { requiresConfirmation(it) }
    }
}
