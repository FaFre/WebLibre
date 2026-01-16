/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.pigeons.AutoplayStatus
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSitePermissionsApi
import eu.weblibre.flutter_mozilla_components.pigeons.SitePermissionStatus
import eu.weblibre.flutter_mozilla_components.pigeons.SitePermissions as PigeonSitePermissions
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import mozilla.components.concept.engine.permission.SitePermissions as MozillaSitePermissions
import mozilla.components.concept.engine.permission.SitePermissions.Status as MozillaStatus
import mozilla.components.concept.engine.permission.SitePermissions.AutoplayStatus as MozillaAutoplayStatus

class GeckoSitePermissionsApiImpl : GeckoSitePermissionsApi {
    companion object {
        private val coroutineScope = CoroutineScope(Dispatchers.Default + SupervisorJob())
    }

    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    override fun getSitePermissions(
        origin: String,
        private: Boolean,
        callback: (Result<PigeonSitePermissions?>) -> Unit
    ) {
        coroutineScope.launch {
            try {
                val permissions = withContext(Dispatchers.IO) {
                    components.core.permissionStorage.findSitePermissionsBy(origin, private)
                }
                callback(Result.success(permissions?.toPigeonSitePermissions()))
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    override fun setSitePermissions(
        permissions: PigeonSitePermissions,
        private: Boolean,
        callback: (Result<Unit>) -> Unit
    ) {
        coroutineScope.launch {
            try {
                val existingPermissions = withContext(Dispatchers.IO) {
                    components.core.permissionStorage.findSitePermissionsBy(permissions.origin, private)
                }

                val mozillaPermissions = permissions.toMozillaSitePermissions(existingPermissions)

                withContext(Dispatchers.IO) {
                    if (existingPermissions != null) {
                        components.core.permissionStorage.updateSitePermissions(mozillaPermissions, private)
                    } else {
                        components.core.permissionStorage.add(mozillaPermissions, private)
                    }
                }
                callback(Result.success(Unit))
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    override fun deleteSitePermissions(
        origin: String,
        private: Boolean,
        callback: (Result<Unit>) -> Unit
    ) {
        coroutineScope.launch {
            try {
                val permissions = withContext(Dispatchers.IO) {
                    components.core.permissionStorage.findSitePermissionsBy(origin, private)
                }
                if (permissions != null) {
                    withContext(Dispatchers.IO) {
                        components.core.permissionStorage.deleteSitePermissions(permissions, private)
                    }
                }
                callback(Result.success(Unit))
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }
}

// Extension function to convert Mozilla SitePermissions to Pigeon format
private fun MozillaSitePermissions.toPigeonSitePermissions(): PigeonSitePermissions {
    return PigeonSitePermissions(
        origin = this.origin,
        camera = this.camera.toSitePermissionStatus(),
        microphone = this.microphone.toSitePermissionStatus(),
        location = this.location.toSitePermissionStatus(),
        notification = this.notification.toSitePermissionStatus(),
        persistentStorage = this.localStorage.toSitePermissionStatus(),
        crossOriginStorageAccess = this.crossOriginStorageAccess.toSitePermissionStatus(),
        mediaKeySystemAccess = this.mediaKeySystemAccess.toSitePermissionStatus(),
        localDeviceAccess = null, // Not directly available in Mozilla SitePermissions
        localNetworkAccess = null, // Not directly available in Mozilla SitePermissions
        autoplayAudible = this.autoplayAudible.toAutoplayStatus(),
        autoplayInaudible = this.autoplayInaudible.toAutoplayStatus(),
        savedAt = this.savedAt,
    )
}

// Extension function to convert Pigeon to Mozilla format
private fun PigeonSitePermissions.toMozillaSitePermissions(
    existing: MozillaSitePermissions?
): MozillaSitePermissions {
    val now = System.currentTimeMillis()
    return MozillaSitePermissions(
        origin = this.origin,
        camera = this.camera?.toMozillaStatus() ?: existing?.camera ?: MozillaStatus.NO_DECISION,
        microphone = this.microphone?.toMozillaStatus() ?: existing?.microphone ?: MozillaStatus.NO_DECISION,
        location = this.location?.toMozillaStatus() ?: existing?.location ?: MozillaStatus.NO_DECISION,
        notification = this.notification?.toMozillaStatus() ?: existing?.notification ?: MozillaStatus.NO_DECISION,
        localStorage = this.persistentStorage?.toMozillaStatus() ?: existing?.localStorage ?: MozillaStatus.NO_DECISION,
        crossOriginStorageAccess = this.crossOriginStorageAccess?.toMozillaStatus() ?: existing?.crossOriginStorageAccess ?: MozillaStatus.NO_DECISION,
        mediaKeySystemAccess = this.mediaKeySystemAccess?.toMozillaStatus() ?: existing?.mediaKeySystemAccess ?: MozillaStatus.NO_DECISION,
        autoplayAudible = this.autoplayAudible?.toMozillaAutoplayStatus() ?: existing?.autoplayAudible ?: MozillaAutoplayStatus.BLOCKED,
        autoplayInaudible = this.autoplayInaudible?.toMozillaAutoplayStatus() ?: existing?.autoplayInaudible ?: MozillaAutoplayStatus.ALLOWED,
        savedAt = if (existing != null) existing.savedAt else now,
    )
}

// Helper conversion functions
private fun MozillaStatus.toSitePermissionStatus(): SitePermissionStatus {
    return when (this) {
        MozillaStatus.ALLOWED -> SitePermissionStatus.ALLOWED
        MozillaStatus.BLOCKED -> SitePermissionStatus.BLOCKED
        MozillaStatus.NO_DECISION -> SitePermissionStatus.NO_DECISION
    }
}

private fun SitePermissionStatus.toMozillaStatus(): MozillaStatus {
    return when (this) {
        SitePermissionStatus.ALLOWED -> MozillaStatus.ALLOWED
        SitePermissionStatus.BLOCKED -> MozillaStatus.BLOCKED
        SitePermissionStatus.NO_DECISION -> MozillaStatus.NO_DECISION
    }
}

private fun MozillaAutoplayStatus.toAutoplayStatus(): AutoplayStatus {
    return when (this) {
        MozillaAutoplayStatus.ALLOWED -> AutoplayStatus.ALLOWED
        MozillaAutoplayStatus.BLOCKED -> AutoplayStatus.BLOCKED
    }
}

private fun AutoplayStatus.toMozillaAutoplayStatus(): MozillaAutoplayStatus {
    return when (this) {
        AutoplayStatus.ALLOWED -> MozillaAutoplayStatus.ALLOWED
        AutoplayStatus.BLOCKED -> MozillaAutoplayStatus.BLOCKED
        AutoplayStatus.BLOCK_AUDIBLE -> MozillaAutoplayStatus.BLOCKED
        AutoplayStatus.ALLOW_ON_WIFI -> MozillaAutoplayStatus.ALLOWED
    }
}
