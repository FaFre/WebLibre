/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.addons

import android.content.Context
import eu.weblibre.flutter_mozilla_components.pigeons.AddonUpdateAttemptInfo
import eu.weblibre.flutter_mozilla_components.pigeons.AddonUpdateStatus
import mozilla.components.feature.addons.update.AddonUpdater

/**
 * How the last update each add-on ran here ended, in the profile's [AddonPrefs].
 *
 * AC records only what its own update worker runs, which nothing starts any
 * more (see [ProfileAddonUpdater.updateNow]), and takes results from no one
 * else. What it recorded before is still read next to these.
 */
internal object AddonUpdateAttempts {
    // Keys used to start with AddonPrefs' toString(), which differs in every
    // process, so nothing was ever read back after a restart.
    private const val MALFORMED_KEY_MARKER = ".PREF_MANUAL_UPDATE_ATTEMPT_PREFIX"

    fun save(
        context: Context,
        addonId: String,
        status: AddonUpdateStatus,
        message: String? = null,
        now: Long = System.currentTimeMillis(),
    ) {
        AddonPrefs.get(context).edit()
            .putLong(timestampKey(addonId), now)
            .putString(statusKey(addonId), status.name)
            .putString(messageKey(addonId), message)
            .apply()
    }

    /**
     * Records what the engine reported for an update started at [startedAt]. The
     * engine reports an update stopped to ask for new permissions as an error
     * like any other, so one that asked during this update is recorded as that.
     */
    fun save(context: Context, addonId: String, status: AddonUpdater.Status, startedAt: Long) {
        val needsPermissions = status is AddonUpdater.Status.Error &&
            AddonUpdatePermissionRequests.askedSince(context, addonId, startedAt)
        if (needsPermissions) {
            save(context, addonId, AddonUpdateStatus.NEEDS_PERMISSIONS)
        } else {
            save(context, addonId, status.toPigeon(), (status as? AddonUpdater.Status.Error)?.message)
        }
    }

    fun get(context: Context, addonId: String): AddonUpdateAttemptInfo? {
        val prefs = AddonPrefs.get(context)
        val timestamp = prefs.getLong(timestampKey(addonId), -1L)
        if (timestamp < 0) return null

        return AddonUpdateAttemptInfo(
            addonId = addonId,
            dateMillisecondsSinceEpoch = timestamp,
            status = prefs.getString(statusKey(addonId), null)
                ?.let { runCatching { AddonUpdateStatus.valueOf(it) }.getOrNull() },
            message = prefs.getString(messageKey(addonId), null),
        )
    }

    fun clear(context: Context, addonId: String) {
        AddonPrefs.get(context).edit()
            .remove(timestampKey(addonId))
            .remove(statusKey(addonId))
            .remove(messageKey(addonId))
            .apply()
    }

    /** Drops what the malformed keys left behind, three keys per update run. */
    fun removeMalformed(context: Context) {
        val prefs = AddonPrefs.get(context)
        val malformed = prefs.all.keys.filter { MALFORMED_KEY_MARKER in it }
        if (malformed.isEmpty()) return

        prefs.edit().apply { malformed.forEach(::remove) }.apply()
    }

    private fun timestampKey(addonId: String) =
        "${AddonPrefs.PREF_MANUAL_UPDATE_ATTEMPT_PREFIX}$addonId.timestamp"

    private fun statusKey(addonId: String) =
        "${AddonPrefs.PREF_MANUAL_UPDATE_ATTEMPT_PREFIX}$addonId.status"

    private fun messageKey(addonId: String) =
        "${AddonPrefs.PREF_MANUAL_UPDATE_ATTEMPT_PREFIX}$addonId.message"
}

internal fun AddonUpdater.Status.toPigeon(): AddonUpdateStatus = when (this) {
    AddonUpdater.Status.NotInstalled -> AddonUpdateStatus.NOT_INSTALLED
    AddonUpdater.Status.SuccessfullyUpdated -> AddonUpdateStatus.SUCCESSFULLY_UPDATED
    AddonUpdater.Status.NoUpdateAvailable -> AddonUpdateStatus.NO_UPDATE_AVAILABLE
    is AddonUpdater.Status.Error -> AddonUpdateStatus.ERROR
}
