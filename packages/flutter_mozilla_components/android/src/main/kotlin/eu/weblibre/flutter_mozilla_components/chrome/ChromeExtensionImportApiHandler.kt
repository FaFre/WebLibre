/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.chrome

import android.content.Context
import eu.weblibre.flutter_mozilla_components.pigeons.ChromeExtensionImportApi
import eu.weblibre.flutter_mozilla_components.pigeons.ChromeExtensionImportResult
import eu.weblibre.flutter_mozilla_components.pigeons.ExtensionUpdate
import eu.weblibre.flutter_mozilla_components.pigeons.InstalledExtension
import kotlinx.coroutines.runBlocking
import mozilla.components.support.base.log.logger.Logger

/**
 * Pigeon handler for Chrome extension import and management API.
 */
class ChromeExtensionImportApiHandler(
    private val context: Context
) : ChromeExtensionImportApi {

    private val logger = Logger("ChromeExtensionImport")
    private val importer = ChromeExtensionImporter(context)
    private val permissionManager = ExtensionPermissionManager(context)
    private val extensionManager = ChromeExtensionManager(context)

    override fun importCrx(
        crxBytes: List<Int>,
        requestedPermissions: List<String>
    ): ChromeExtensionImportResult {
        return try {
            val bytes = crxBytes.map { it.toByte() }.toByteArray()

            // Check if permissions are already granted
            if (!permissionManager.arePermissionsGranted("temp", requestedPermissions)) {
                logger.warn("Permissions not granted for import")
                return ChromeExtensionImportResult(
                    success = false,
                    extensionId = null,
                    error = "Permissions not granted"
                )
            }

            val result = runBlocking { importer.importCrx(bytes) }

            if (result.success && result.extensionId != null) {
                // Grant permissions
                permissionManager.grantPermissions(result.extensionId!!, requestedPermissions)

                // Register extension
                val manifestJson = /* extract from import result */ ""
                val name = /* extract name */ "Extension"
                val version = /* extract version */ "1.0"
                extensionManager.registerExtension(
                    ChromeExtensionManager.ExtensionInfo(
                        id = result.extensionId!!,
                        name = name,
                        version = version,
                        enabled = true,
                        installTime = System.currentTimeMillis(),
                        permissions = requestedPermissions
                    )
                )
            }

            ChromeExtensionImportResult(
                success = result.success,
                extensionId = result.extensionId,
                error = result.error
            )
        } catch (e: Exception) {
            logger.error("Import failed", e)
            ChromeExtensionImportResult(
                success = false,
                extensionId = null,
                error = "Import failed: ${e.message}"
            )
        }
    }

    override fun listExtensions(): List<InstalledExtension> {
        return try {
            extensionManager.listExtensions().map { ext ->
                InstalledExtension(
                    id = ext.id,
                    name = ext.name,
                    version = ext.version,
                    enabled = ext.enabled,
                    permissions = ext.permissions
                )
            }
        } catch (e: Exception) {
            logger.error("Failed to list extensions", e)
            emptyList()
        }
    }

    override fun toggleExtension(extensionId: String, enabled: Boolean) {
        try {
            if (enabled) {
                extensionManager.enableExtension(extensionId)
            } else {
                extensionManager.disableExtension(extensionId)
            }
        } catch (e: Exception) {
            logger.error("Failed to toggle extension: $extensionId", e)
        }
    }

    override fun uninstallExtension(extensionId: String): Boolean {
        return try {
            extensionManager.uninstallExtension(extensionId)
        } catch (e: Exception) {
            logger.error("Failed to uninstall extension: $extensionId", e)
            false
        }
    }

    override fun checkForUpdate(extensionId: String): ExtensionUpdate {
        // TODO: Implement update checking
        return ExtensionUpdate(available = false)
    }
}
