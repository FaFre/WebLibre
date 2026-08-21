package eu.weblibre.flutter_mozilla_components.sync

import android.content.Context
import androidx.core.content.edit
import mozilla.components.support.base.log.logger.Logger
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

/** One device as it was last seen in the FxA constellation. */
internal data class CachedSyncDevice(
    val deviceId: String,
    val displayName: String,
    val isCurrentDevice: Boolean,
    val canSendTab: Boolean,
)

/**
 * Last-known account profile and device constellation, in profile-scoped preferences.
 *
 * Everything the sync UI displays about the account and its devices otherwise only
 * exists behind a live network request. The FxA profile is fetched over the wire,
 * and the constellation is in-memory only — `FxaDeviceConstellation.state()` is set
 * exclusively by a successful `refreshDevices()` and is never persisted, so it is
 * null on every cold start. One failed request therefore turned a signed-in account
 * into "Not signed in" and a named device into "Unknown", with no way back until
 * the next real auth transition.
 *
 * This is display state and nothing more. It is never consulted for *whether* the
 * account is authenticated — that always comes from the account manager, which
 * reads the account record itself.
 *
 * Written through on every successful read of the real thing, cleared on logout.
 */
internal class SyncStateCache(private val context: Context) {
    companion object {
        /**
         * Must stay listed in `ActiveProfile.FXA_SHARED_PREFERENCE_NAMES`, which is
         * what carries a profile's preference files through backup, restore, and
         * delete. A cache left out of that set survives a profile deletion and comes
         * back attached to whoever next takes the id.
         */
        const val STORAGE_NAME = "weblibreSyncCache"

        private const val KEY_EMAIL = "accountEmail"
        private const val KEY_DISPLAY_NAME = "accountDisplayName"
        private const val KEY_DEVICES = "devices"

        private const val FIELD_ID = "id"
        private const val FIELD_NAME = "name"
        private const val FIELD_CURRENT = "current"
        private const val FIELD_SEND_TAB = "sendTab"
    }

    private val logger = Logger("SyncStateCache")

    private fun prefs() = context.getSharedPreferences(STORAGE_NAME, Context.MODE_PRIVATE)

    fun email(): String? = prefs().getString(KEY_EMAIL, null)

    fun displayName(): String? = prefs().getString(KEY_DISPLAY_NAME, null)

    /**
     * Records what the profile fetch returned.
     *
     * A null field leaves the stored value alone rather than erasing it: FxA
     * profiles legitimately carry no display name, and a partial response must not
     * cost us the part we already knew.
     */
    fun putProfile(email: String?, displayName: String?) {
        if (email == null && displayName == null) return

        prefs().edit {
            email?.let { putString(KEY_EMAIL, it) }
            displayName?.let { putString(KEY_DISPLAY_NAME, it) }
        }
    }

    fun devices(): List<CachedSyncDevice> {
        val raw = prefs().getString(KEY_DEVICES, null) ?: return emptyList()

        return try {
            val array = JSONArray(raw)
            (0 until array.length()).mapNotNull { index ->
                val entry = array.optJSONObject(index) ?: return@mapNotNull null
                val id = entry.optString(FIELD_ID).takeIf { it.isNotEmpty() }
                    ?: return@mapNotNull null

                CachedSyncDevice(
                    deviceId = id,
                    displayName = entry.optString(FIELD_NAME).takeIf { it.isNotEmpty() }
                        ?: return@mapNotNull null,
                    isCurrentDevice = entry.optBoolean(FIELD_CURRENT, false),
                    canSendTab = entry.optBoolean(FIELD_SEND_TAB, false),
                )
            }
        } catch (e: JSONException) {
            logger.warn("Discarding unreadable cached device list", e)
            emptyList()
        }
    }

    /** Names by device id, for joining remote tabs onto the devices that hold them. */
    fun deviceNames(): Map<String, String> =
        devices().associate { it.deviceId to it.displayName }

    fun currentDeviceName(): String? =
        devices().firstOrNull { it.isCurrentDevice }?.displayName

    /**
     * Replaces the cached constellation.
     *
     * An empty list is not written: `refreshDevices()` never produces one for a
     * connected account, so an empty result means the caller had nothing rather
     * than that the account has no devices.
     */
    fun putDevices(devices: List<CachedSyncDevice>) {
        if (devices.isEmpty()) return

        val array = JSONArray()
        for (device in devices) {
            array.put(
                JSONObject().apply {
                    put(FIELD_ID, device.deviceId)
                    put(FIELD_NAME, device.displayName)
                    put(FIELD_CURRENT, device.isCurrentDevice)
                    put(FIELD_SEND_TAB, device.canSendTab)
                },
            )
        }

        prefs().edit { putString(KEY_DEVICES, array.toString()) }
    }

    /**
     * Drops the account identity, keeping the devices.
     *
     * For a sign-in that may be a *different* account: the profile fetch that would
     * replace these values can fail, and showing the previous account's email is
     * worse than showing none.
     */
    fun clearProfile() {
        prefs().edit {
            remove(KEY_EMAIL)
            remove(KEY_DISPLAY_NAME)
        }
    }

    fun clear() {
        prefs().edit { clear() }
    }
}
