/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.addons

import android.content.Context
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.ExistingWorkPolicy
import androidx.work.WorkManager
import eu.weblibre.flutter_mozilla_components.ProfileContext
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import mozilla.components.concept.engine.webextension.WebExtension
import mozilla.components.concept.engine.webextension.isUnsupported
import mozilla.components.feature.addons.Addon
import mozilla.components.feature.addons.update.AddonUpdater
import mozilla.components.feature.addons.update.DefaultAddonUpdater
import mozilla.components.support.base.android.NotificationsDelegate
import mozilla.components.support.base.log.logger.Logger
import mozilla.components.support.base.worker.Frequency
import mozilla.components.support.webextensions.WebExtensionSupport
import java.util.UUID
import java.util.concurrent.TimeUnit
import kotlin.coroutines.resume

/**
 * [DefaultAddonUpdater] made to work under a [ProfileContext].
 *
 * AC's prompt is a notification whose buttons start
 * `DefaultAddonUpdater.NotificationHandlerService`. That service reads the
 * notification id and the "allowed" flag through its own context, which is
 * never the profile context the updater wrote them with: Deny cancelled an id
 * nobody had posted, and Allow stored its flag where the next update attempt
 * never looked, so the same notification came back (#688). It also crashed when
 * tapped in a process that had not set up components yet.
 *
 * The prompt is ours instead — [AddonUpdatePermissionNotification] and
 * [AddonUpdatePermissionReceiver], both explicit about which profile they act
 * for — and AC's service is removed from the manifest. Pending requests are also
 * kept ([AddonUpdatePermissionRequests]), so the add-on's page can ask too.
 *
 * Update checks are scheduled as [AddonUpdateCheckWorker] jobs, which carry the
 * profile and update through [updateAddon] only while this profile's browser
 * runs. [updater], AC's, is left the jobs it scheduled before and the results
 * it stored.
 */
class ProfileAddonUpdater(
    private val profileContext: ProfileContext,
    private val updater: AddonUpdater,
    /** Updates an add-on through the engine, as `AddonManager.updateAddon` does. */
    private val updateAddon: (addonId: String, onFinish: (AddonUpdater.Status) -> Unit) -> Unit,
    private val notificationsDelegate: NotificationsDelegate,
    private val frequency: Frequency,
    // The app's context: WorkManager is one per process, and getting it through
    // a profile's context would put its database in that profile.
    private val workManager: () -> WorkManager = {
        WorkManager.getInstance(profileContext.rootApplicationContext)
    },
    /** When the add-on was last checked, if ever: here, or by AC's worker before. */
    private val lastCheckedAt: (addonId: String) -> Long? =
        DefaultAddonUpdater.UpdateAttemptStorage(profileContext.rootApplicationContext).let { storage ->
            { addonId ->
                listOfNotNull(
                    AddonUpdateAttempts.get(profileContext, addonId)?.dateMillisecondsSinceEpoch,
                    storage.findUpdateAttemptBy(addonId)?.date?.time,
                ).maxOrNull()
            }
        },
    private val scope: CoroutineScope = CoroutineScope(Dispatchers.IO + SupervisorJob()),
) : AddonUpdater by updater {
    private val logger = Logger("ProfileAddonUpdater")

    private val profilePath: String
        get() = profileContext.relativePath

    /**
     * Add-ons with automatic updates on, as registered in this process. Guarded
     * by `this`, which also covers queuing and cancelling their automatic
     * checks, so turning automatic updates off cannot cross a check about to
     * run. See [updateNow].
     */
    private val scheduled = mutableSetOf<String>()

    /**
     * Same two-step flow as AC: an update that needs new permissions is
     * cancelled and the user asked. Accepting records the permissions and
     * starts a fresh update, which then passes here.
     */
    override fun onUpdatePermissionRequest(
        extension: WebExtension,
        newPermissions: List<String>,
        newOrigins: List<String>,
        newDataCollectionPermissions: List<String>,
        onPermissionsGranted: (Boolean) -> Unit,
    ) {
        val permissions = newPermissions + newOrigins

        // AC's test: permissions without a user-facing description are not
        // worth asking about.
        val needsPrompt =
            Addon.localizePermissions(permissions, profileContext).isNotEmpty() ||
                Addon.localizeDataCollectionPermissions(
                    newDataCollectionPermissions,
                    profileContext,
                ).isNotEmpty()

        if (!needsPrompt ||
            AddonUpdateGrants.consume(
                profileContext,
                extension.id,
                permissions,
                newDataCollectionPermissions,
            )
        ) {
            AddonUpdatePermissionRequests.clear(profileContext, extension.id)
            profileContext.profileId?.let { profileId ->
                AddonUpdatePermissionNotification.cancel(profileContext, profileId, extension.id)
            }
            onPermissionsGranted(true)
            return
        }

        // The engine only offers the latest version, so a grant this does not
        // cover was for one it offers no more. Kept, it would re-run an update
        // on every start (see onExtensionsLoaded), each only asking again.
        AddonUpdateGrants.clear(profileContext, extension.id)
        AddonUpdatePermissionRequests.record(
            profileContext,
            extension.id,
            permissions,
            newDataCollectionPermissions,
        )
        val posted = AddonUpdatePermissionNotification.post(
            profileContext,
            notificationsDelegate,
            extension,
            permissions,
            newDataCollectionPermissions,
        )
        if (!posted) {
            logger.warn("No profile id to ask for ${extension.id}'s new permissions with")
        }
        onPermissionsGranted(false)
    }

    /**
     * Schedules checks for [extensions], and checks at once those last checked
     * longer than [frequency] ago.
     *
     * Called when the profile's extensions load. A scheduled check does nothing
     * unless this profile's browser is running at the time, so without this an
     * add-on whose checks kept coming due with the app closed would never update.
     *
     * Overridden because AC's default calls the single add-on overload on
     * [updater], past the one here.
     */
    override fun registerForFutureUpdates(extensions: List<WebExtension>) {
        val addonIds = extensions
            .filter { extension -> !extension.isBuiltIn() && !extension.isUnsupported() }
            .map { it.id }
        addonIds.forEach(::registerForFutureUpdates)

        val interval = frequency.repeatIntervalTimeUnit.toMillis(frequency.repeatInterval)
        scope.launch {
            val now = System.currentTimeMillis()
            val due = addonIds.filter { addonId ->
                now - (lastCheckedAt(addonId) ?: 0L) !in 0 until interval
            }

            // Its own job, unlike an update asked for (see [update]), so turning
            // automatic updates off can cancel it. An offline start leaves it
            // queued until the connection is back.
            synchronized(this@ProfileAddonUpdater) {
                for (addonId in due.filter { it in scheduled }) {
                    workManager().enqueueUniqueWork(
                        AddonUpdateCheckWorker.catchUpWorkName(profilePath, addonId),
                        ExistingWorkPolicy.KEEP,
                        AddonUpdateCheckWorker.immediateRequest(profilePath, addonId, automatic = true),
                    )
                }
            }
        }
    }

    override fun registerForFutureUpdates(addonId: String) {
        synchronized(this) {
            scheduled += addonId
            workManager().enqueueUniquePeriodicWork(
                AddonUpdateCheckWorker.periodicWorkName(profilePath, addonId),
                ExistingPeriodicWorkPolicy.KEEP,
                AddonUpdateCheckWorker.periodicRequest(profilePath, addonId, frequency),
            )
        }
    }

    /** Turns automatic updates off for [addonId]. Updates asked for still run. */
    override fun unregisterForFutureUpdates(addonId: String) {
        synchronized(this) {
            scheduled -= addonId
            workManager().cancelUniqueWork(AddonUpdateCheckWorker.periodicWorkName(profilePath, addonId))
            workManager().cancelUniqueWork(AddonUpdateCheckWorker.catchUpWorkName(profilePath, addonId))
        }
        // AC's own job from before, and the add-on's stored result.
        updater.unregisterForFutureUpdates(addonId)
    }

    /** An update asked for: by the user, or by accepting new permissions. */
    override fun update(addonId: String) {
        workManager().enqueueUniqueWork(
            AddonUpdateCheckWorker.immediateWorkName(profilePath, addonId),
            ExistingWorkPolicy.KEEP,
            AddonUpdateCheckWorker.immediateRequest(profilePath, addonId, automatic = false),
        )
    }

    /**
     * Updates [addonId] once [AddonUpdateCheckWorker] found this profile's
     * browser up, and records how it ended. An [automatic] check is dropped
     * when automatic updates were turned off for the add-on after it was
     * queued; a cancelled job can already be running.
     *
     * Never through AC's [AddonUpdater.update]: that queues AC's worker as a
     * job of its own, named after the add-on alone and waiting for extensions
     * without a bound. Still queued when the app closed, it would hang in a
     * process where they never load, or update the add-on of that id in
     * whichever profile runs by then.
     */
    internal suspend fun updateNow(addonId: String, automatic: Boolean) {
        val startedAt = System.currentTimeMillis()
        val status = suspendCancellableCoroutine<AddonUpdater.Status?> { continuation ->
            synchronized(this@ProfileAddonUpdater) {
                if (automatic && addonId !in scheduled) {
                    logger.info("Not checking $addonId: its automatic updates are off")
                    continuation.resume(null)
                } else {
                    updateAddon(addonId) { status -> continuation.resume(status) }
                }
            }
        } ?: return

        AddonUpdateAttempts.save(profileContext, addonId, status, startedAt)
    }

    /**
     * Applies updates the user accepted while this profile had no engine to
     * apply them with, and drops what belongs to add-ons that are gone.
     *
     * [installedAddonIds] are the extensions the engine just reported.
     */
    fun onExtensionsLoaded(installedAddonIds: Collection<String>) {
        val installed = installedAddonIds.toSet()
        scope.launch {
            try {
                removeLegacyState()

                for (addonId in AddonUpdateGrants.pendingAddonIds(profileContext)) {
                    if (addonId in installed) {
                        update(addonId)
                    } else {
                        AddonUpdateGrants.clear(profileContext, addonId)
                    }
                }
                for (addonId in AddonUpdatePermissionRequests.pendingAddonIds(profileContext)) {
                    if (addonId !in installed) {
                        AddonUpdatePermissionRequests.clear(profileContext, addonId)
                        profileContext.profileId?.let { profileId ->
                            AddonUpdatePermissionNotification.cancel(profileContext, profileId, addonId)
                        }
                    }
                }
            } catch (error: Exception) {
                logger.error("Could not settle pending add-on updates", error)
            }
        }
    }

    /**
     * What earlier versions left behind: AC's notification channel and update
     * jobs, which belong to no profile, so they are removed once for the app,
     * and this profile's update results stored under malformed keys.
     */
    private fun removeLegacyState() {
        AddonUpdateAttempts.removeMalformed(profileContext)

        val appPrefs = AddonPrefs.get(profileContext.rootApplicationContext)
        if (appPrefs.getBoolean(AddonPrefs.PREF_LEGACY_UPDATE_STATE_REMOVED, false)) return

        try {
            AddonUpdatePermissionNotification.removeLegacyNotifications(profileContext)
            // AC's jobs from before they carried a profile; see AddonUpdateCheckWorker.
            // A cancel is only asked for until WorkManager commits it, so this is
            // marked done once both are: should one fail, or the process die
            // first, the next load tries again. Bounded, since the pending
            // updates wait for it.
            listOf(
                AddonUpdateCheckWorker.LEGACY_PERIODIC_TAG,
                AddonUpdateCheckWorker.LEGACY_IMMEDIATE_TAG,
            ).map { tag -> workManager().cancelAllWorkByTag(tag) }
                .forEach { it.result.get(30, TimeUnit.SECONDS) }
        } catch (error: Exception) {
            logger.warn("Could not remove what earlier versions left; trying again next time", error)
            return
        }
        appPrefs.edit().putBoolean(AddonPrefs.PREF_LEGACY_UPDATE_STATE_REMOVED, true).apply()
    }
}

/**
 * New permissions the user accepted from an update notification, held until the
 * update that asked for them comes back through
 * [ProfileAddonUpdater.onUpdatePermissionRequest].
 *
 * Stored in the profile's [AddonPrefs], so callers must pass that profile's
 * context. A grant covers exactly the permissions the notification showed: an
 * update that asks for more, because the developer shipped yet another version
 * in between, prompts again instead of inheriting an earlier "Update".
 *
 * A grant expires after [GRANT_LIFETIME_MS]. One that is never consumed — the
 * add-on later updated without needing it, say — would otherwise re-run an
 * update on every start and silently cover those permissions indefinitely.
 */
internal object AddonUpdateGrants {
    private const val PERMISSIONS_KEY_PREFIX = "update_permission_grant."
    private const val GRANTED_AT_KEY_PREFIX = "update_permission_grant_time."

    private const val PERMISSION_PREFIX = "permission:"
    private const val DATA_COLLECTION_PREFIX = "data_collection:"

    internal val GRANT_LIFETIME_MS = TimeUnit.DAYS.toMillis(7)

    fun grant(
        context: Context,
        addonId: String,
        permissions: List<String>,
        dataCollectionPermissions: List<String>,
        now: Long = System.currentTimeMillis(),
    ) {
        AddonPrefs.get(context).edit()
            .putStringSet(
                PERMISSIONS_KEY_PREFIX + addonId,
                encode(permissions, dataCollectionPermissions).toSet(),
            )
            .putLong(GRANTED_AT_KEY_PREFIX + addonId, now)
            .commit()
    }

    /**
     * Whether a live grant covers this request. A covering grant is used up;
     * one that does not cover it is left for the caller to drop.
     */
    fun consume(
        context: Context,
        addonId: String,
        permissions: List<String>,
        dataCollectionPermissions: List<String>,
        now: Long = System.currentTimeMillis(),
    ): Boolean {
        val granted = liveGrant(context, addonId, now) ?: return false
        if (!granted.containsAll(encode(permissions, dataCollectionPermissions))) {
            return false
        }

        clear(context, addonId)
        return true
    }

    /** Add-ons holding a live grant. Expired grants are removed on the way. */
    fun pendingAddonIds(
        context: Context,
        now: Long = System.currentTimeMillis(),
    ): Set<String> =
        AddonPrefs.get(context).all.keys
            .filter { it.startsWith(PERMISSIONS_KEY_PREFIX) }
            .map { it.removePrefix(PERMISSIONS_KEY_PREFIX) }
            .filter { addonId -> liveGrant(context, addonId, now) != null }
            .toSet()

    fun clear(context: Context, addonId: String) {
        AddonPrefs.get(context).edit()
            .remove(PERMISSIONS_KEY_PREFIX + addonId)
            .remove(GRANTED_AT_KEY_PREFIX + addonId)
            .commit()
    }

    private fun liveGrant(context: Context, addonId: String, now: Long): Set<String>? {
        val prefs = AddonPrefs.get(context)
        val granted = prefs.getStringSet(PERMISSIONS_KEY_PREFIX + addonId, null) ?: return null
        val grantedAt = prefs.getLong(GRANTED_AT_KEY_PREFIX + addonId, 0L)

        if (now - grantedAt !in 0..GRANT_LIFETIME_MS) {
            clear(context, addonId)
            return null
        }
        return granted.toSet()
    }

    /**
     * What a request asks for, sorted and without repeats, so the same request
     * always encodes the same way. Data collection is asked for separately from
     * permissions, so the two are kept apart even where a name could appear in
     * both lists.
     */
    fun encode(
        permissions: List<String>,
        dataCollectionPermissions: List<String>,
    ): List<String> =
        permissions.toSortedSet().map { PERMISSION_PREFIX + it } +
            dataCollectionPermissions.toSortedSet().map { DATA_COLLECTION_PREFIX + it }
}

/**
 * Update permission requests still waiting for an answer, so the add-on's page
 * can ask as well: the notification can be swiped away, and is never shown
 * while notifications are off.
 *
 * Stored in the profile's [AddonPrefs], like [AddonUpdateGrants]. A request
 * belongs to the version it was asked from: once another one is installed the
 * update went through some other way, and the request is dropped when next read.
 *
 * A later check can replace a request while the page or the notification still
 * shows the earlier one, so both answer by [Request.id], never by add-on alone.
 */
internal object AddonUpdatePermissionRequests {
    private const val PERMISSIONS_KEY_PREFIX = "update_permission_request."
    private const val DATA_COLLECTION_KEY_PREFIX = "update_permission_request_data_collection."
    private const val VERSION_KEY_PREFIX = "update_permission_request_version."
    private const val ASKED_AT_KEY_PREFIX = "update_permission_request_time."

    data class Request(
        val permissions: List<String>,
        val dataCollectionPermissions: List<String>,
    ) {
        /**
         * Names exactly what accepting grants. Derived rather than stored, so a
         * check asking again for the same permissions keeps it.
         */
        val id: String = UUID.nameUUIDFromBytes(
            AddonUpdateGrants.encode(permissions, dataCollectionPermissions)
                .joinToString("\n")
                .toByteArray(),
        ).toString()
    }

    @Synchronized
    fun record(
        context: Context,
        addonId: String,
        permissions: List<String>,
        dataCollectionPermissions: List<String>,
        installedVersion: String? = installedVersion(addonId),
        now: Long = System.currentTimeMillis(),
    ) {
        AddonPrefs.get(context).edit()
            .putStringSet(PERMISSIONS_KEY_PREFIX + addonId, permissions.toSet())
            .putStringSet(DATA_COLLECTION_KEY_PREFIX + addonId, dataCollectionPermissions.toSet())
            .putString(VERSION_KEY_PREFIX + addonId, installedVersion)
            .putLong(ASKED_AT_KEY_PREFIX + addonId, now)
            .commit()
    }

    /**
     * Whether an update asked for new permissions at [since] or later. The
     * engine reports such an update as failed, with nothing else to tell it
     * from one that failed for another reason.
     */
    fun askedSince(context: Context, addonId: String, since: Long): Boolean =
        AddonPrefs.get(context).getLong(ASKED_AT_KEY_PREFIX + addonId, -1L) >= since

    /** [installedVersion] is null while the engine has not reported its extensions. */
    @Synchronized
    fun get(
        context: Context,
        addonId: String,
        installedVersion: String? = installedVersion(addonId),
    ): Request? {
        val prefs = AddonPrefs.get(context)
        val permissions = prefs.getStringSet(PERMISSIONS_KEY_PREFIX + addonId, null) ?: return null

        if (installedVersion != null &&
            installedVersion != prefs.getString(VERSION_KEY_PREFIX + addonId, null)
        ) {
            clear(context, addonId)
            return null
        }

        return Request(
            permissions = permissions.sorted(),
            dataCollectionPermissions = prefs
                .getStringSet(DATA_COLLECTION_KEY_PREFIX + addonId, null)
                .orEmpty()
                .sorted(),
        )
    }

    /**
     * Grants the pending request if it is still the one with [requestId], the
     * one the user saw. Grants nothing once a later check asked for something
     * else.
     */
    @Synchronized
    fun accept(context: Context, addonId: String, requestId: String): Boolean {
        val request = get(context, addonId)?.takeIf { it.id == requestId } ?: return false

        // The same grant the notification's Update button records, used up by
        // the update that follows when it asks again.
        AddonUpdateGrants.grant(context, addonId, request.permissions, request.dataCollectionPermissions)
        clear(context, addonId)
        return true
    }

    /**
     * Puts off the request [requestId] names. False, changing nothing, when a
     * later check replaced it: whatever still asks is asking for that one.
     */
    @Synchronized
    fun decline(context: Context, addonId: String, requestId: String): Boolean {
        val pending = get(context, addonId) ?: return true
        if (pending.id != requestId) return false

        clear(context, addonId)
        return true
    }

    fun pendingAddonIds(context: Context): Set<String> =
        AddonPrefs.get(context).all.keys
            .filter { it.startsWith(PERMISSIONS_KEY_PREFIX) }
            .mapTo(mutableSetOf()) { it.removePrefix(PERMISSIONS_KEY_PREFIX) }

    @Synchronized
    fun clear(context: Context, addonId: String) {
        AddonPrefs.get(context).edit()
            .remove(PERMISSIONS_KEY_PREFIX + addonId)
            .remove(DATA_COLLECTION_KEY_PREFIX + addonId)
            .remove(VERSION_KEY_PREFIX + addonId)
            .remove(ASKED_AT_KEY_PREFIX + addonId)
            .commit()
    }

    private fun installedVersion(addonId: String): String? =
        WebExtensionSupport.installedExtensions[addonId]?.getMetadata()?.version
}
