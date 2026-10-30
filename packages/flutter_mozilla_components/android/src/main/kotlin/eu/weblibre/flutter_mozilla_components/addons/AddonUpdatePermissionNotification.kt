/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.addons

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.text.SpannableStringBuilder
import android.text.Spanned
import androidx.annotation.StringRes
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.text.HtmlCompat
import androidx.core.text.toSpanned
import eu.weblibre.flutter_mozilla_components.ActiveProfile
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.ProfileContext
import eu.weblibre.flutter_mozilla_components.R
import eu.weblibre.flutter_mozilla_components.startup.ProfileUuid
import eu.weblibre.flutter_mozilla_components.startup.StartupArbiter
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import mozilla.components.concept.engine.webextension.WebExtension
import mozilla.components.feature.addons.Addon
import mozilla.components.support.base.android.NotificationsDelegate
import mozilla.components.support.base.log.logger.Logger
import mozilla.components.support.ktx.android.notification.ChannelData
import mozilla.components.support.ktx.android.notification.ensureNotificationChannelExists
import java.io.File
import mozilla.components.feature.addons.R as MozComp

/**
 * The notification that asks for an add-on update's new permissions, adapted
 * from AC's `DefaultAddonUpdater`.
 *
 * Identified by a tag naming the profile and the add-on rather than by an id
 * from `SharedIdsHelper`. That helper counts per preferences file, and a
 * [ProfileContext] has a different file from the service contexts that also
 * draw notification ids from it, so an id it hands out here can already belong
 * to the media or private-tabs notification. A tag needs no lookup, so the
 * receiver can cancel the right notification in a process that has not set
 * anything up.
 */
internal object AddonUpdatePermissionNotification {
    private const val CHANNEL_ID = "eu.weblibre.addons.update_permissions"

    // AC's channel. Nothing posts to it any more; deleting it takes the
    // notifications left there, whose buttons can no longer do anything, along.
    private const val LEGACY_CHANNEL_ID = "mozilla.components.feature.addons.update.generic.channel"

    private const val TAG_PREFIX = "eu.weblibre.addons.update_permission:"

    // Any id works, the tag carries the identity. Not 1: web notifications pair
    // that with tags derived from the page.
    private const val NOTIFICATION_ID = 6880

    internal const val ACTION_ALLOW = "eu.weblibre.addons.UPDATE_PERMISSIONS_ALLOW"
    internal const val ACTION_DENY = "eu.weblibre.addons.UPDATE_PERMISSIONS_DENY"
    internal const val EXTRA_PROFILE_ID = "eu.weblibre.addons.extra.PROFILE_ID"
    internal const val EXTRA_ADDON_ID = "eu.weblibre.addons.extra.ADDON_ID"
    internal const val EXTRA_REQUEST_ID = "eu.weblibre.addons.extra.REQUEST_ID"

    private const val NARROW_MAX_LENGTH = 160
    private const val WIDE_MAX_LENGTH = 320

    private val logger = Logger("AddonUpdatePermissionNotification")

    /** Returns false, posting nothing, when [profileContext] names no profile. */
    fun post(
        profileContext: ProfileContext,
        notificationsDelegate: NotificationsDelegate,
        extension: WebExtension,
        permissions: List<String>,
        dataCollectionPermissions: List<String>,
    ): Boolean {
        val context = profileContext.rootApplicationContext
        val profileId = profileContext.profileId ?: return false

        val channelId = ensureNotificationChannelExists(
            context,
            ChannelData(
                CHANNEL_ID,
                MozComp.string.mozac_feature_addons_updater_notification_channel_2,
                NotificationManagerCompat.IMPORTANCE_LOW,
            ),
        )

        // What the buttons answer; the receiver acts only while it is still the
        // pending request. See AddonUpdatePermissionRequests.
        val requestId = AddonUpdatePermissionRequests.Request(permissions, dataCollectionPermissions).id

        fun action(action: String, @StringRes label: Int) = NotificationCompat.Action.Builder(
            R.drawable.mozac_ic_extensions_black,
            context.getString(label),
            actionIntent(context, action, profileId, extension.id, requestId),
        ).build()

        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.drawable.mozac_ic_extensions_black)
            .setContentTitle(
                context.getString(
                    MozComp.string.mozac_feature_addons_updater_notification_title_2,
                    extension.getMetadata()?.name ?: extension.id,
                ),
            )
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setStyle(
                NotificationCompat.BigTextStyle()
                    .bigText(contentText(context, permissions, dataCollectionPermissions)),
            )
            .addAction(
                action(ACTION_ALLOW, MozComp.string.mozac_feature_addons_updater_notification_update_button),
            )
            .addAction(
                action(ACTION_DENY, MozComp.string.mozac_feature_addons_updater_notification_cancel_button),
            )
            .setAutoCancel(true)
            .build()

        logger.info("Asking for new permissions to update ${extension.id}")
        notificationsDelegate.notify(
            notificationTag = tag(profileId, extension.id),
            notificationId = NOTIFICATION_ID,
            notification = notification,
        )
        return true
    }

    fun cancel(context: Context, profileId: String, addonId: String) {
        NotificationManagerCompat.from(context).cancel(tag(profileId, addonId), NOTIFICATION_ID)
    }

    fun removeLegacyNotifications(context: Context) {
        val manager = NotificationManagerCompat.from(context)
        if (manager.getNotificationChannel(LEGACY_CHANNEL_ID) != null) {
            manager.deleteNotificationChannel(LEGACY_CHANNEL_ID)
        }
    }

    private fun tag(profileId: String, addonId: String) = "$TAG_PREFIX$profileId:$addonId"

    private fun actionIntent(
        context: Context,
        action: String,
        profileId: String,
        addonId: String,
        requestId: String,
    ): PendingIntent {
        val intent = Intent(context, AddonUpdatePermissionReceiver::class.java).apply {
            this.action = action
            // Pending intents are told apart by their data, never their extras,
            // and FLAG_UPDATE_CURRENT rewrites the extras of the one that
            // matches. With the request in the data, a later request gets its
            // own intent instead: the buttons still showing the earlier one
            // cannot turn into a yes to permissions nobody has seen.
            data = Uri.Builder()
                .scheme("weblibre")
                .authority("addon-update-permission")
                .appendPath(profileId)
                .appendPath(addonId)
                .appendPath(requestId)
                .build()
            putExtra(EXTRA_PROFILE_ID, profileId)
            putExtra(EXTRA_ADDON_ID, addonId)
            putExtra(EXTRA_REQUEST_ID, requestId)
        }

        return PendingIntent.getBroadcast(
            context,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }

    private fun contentText(
        context: Context,
        permissions: List<String>,
        dataCollectionPermissions: List<String>,
    ): Spanned {
        val hasPermissions = permissions.isNotEmpty()
        val hasDataCollectionPermissions = dataCollectionPermissions.isNotEmpty()

        val intro = context.getString(MozComp.string.mozac_feature_addons_updater_notification_short_intro)
        val builder = SpannableStringBuilder(HtmlCompat.fromHtml("$intro<br>", HtmlCompat.FROM_HTML_MODE_COMPACT))

        if (hasPermissions) {
            val localizedPermissions = Addon.localizePermissions(permissions, context, forUpdate = true)
            val permissionsText = abbreviate(
                context.getString(
                    MozComp.string.mozac_feature_addons_updater_notification_heading_permissions,
                    localizedPermissions.joinToString(" "),
                ),
                saveSpaceForOtherSection = hasDataCollectionPermissions,
            )
            builder.append(HtmlCompat.fromHtml(permissionsText, HtmlCompat.FROM_HTML_MODE_COMPACT))

            if (hasDataCollectionPermissions) {
                builder.append(HtmlCompat.fromHtml("<br>", HtmlCompat.FROM_HTML_MODE_COMPACT))
            }
        }

        if (hasDataCollectionPermissions) {
            val localizedPermissions =
                Addon.localizeDataCollectionPermissions(dataCollectionPermissions, context)
            val permissionsText = abbreviate(
                context.getString(
                    MozComp.string.mozac_feature_addons_updater_notification_heading_data_collection_permissions,
                    Addon.formatLocalizedDataCollectionPermissions(localizedPermissions),
                ),
                saveSpaceForOtherSection = hasPermissions,
            )
            builder.append(HtmlCompat.fromHtml(permissionsText, HtmlCompat.FROM_HTML_MODE_COMPACT))
        }

        return builder.toSpanned()
    }

    // A system notification cannot grow indefinitely, and the intro needs room.
    private fun abbreviate(text: String, saveSpaceForOtherSection: Boolean): String {
        val maxLength = if (saveSpaceForOtherSection) NARROW_MAX_LENGTH else WIDE_MAX_LENGTH
        return if (text.length > maxLength) {
            text.take(maxLength - 1) + Typography.ellipsis
        } else {
            text
        }
    }
}

/**
 * Answers [AddonUpdatePermissionNotification]'s buttons.
 *
 * May be the first thing to run in its process, so it follows the headless
 * entry point rules: it only commits a profile after a peek says the
 * notification belongs to the one this process would bind, and it re-checks
 * against what was actually committed (see `PushMessageWorker`). When the
 * notification belongs elsewhere it is left showing, still answerable once that
 * profile runs again.
 */
class AddonUpdatePermissionReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val profileId = intent.getStringExtra(AddonUpdatePermissionNotification.EXTRA_PROFILE_ID) ?: return
        val addonId = intent.getStringExtra(AddonUpdatePermissionNotification.EXTRA_ADDON_ID) ?: return
        val requestId = intent.getStringExtra(AddonUpdatePermissionNotification.EXTRA_REQUEST_ID) ?: return

        when (intent.action) {
            AddonUpdatePermissionNotification.ACTION_DENY -> {
                // Only where that profile already runs: answering "not now" is
                // no reason to commit one. Nothing can have replaced the request
                // elsewhere either, since only a running profile checks, and the
                // add-on's page still offers the update until the next check.
                val profileContext = ActiveProfile.resolveContext(context.applicationContext)
                    ?.takeIf { it.profileId == profileId }
                if (profileContext == null) {
                    AddonUpdatePermissionNotification.cancel(context, profileId, addonId)
                    return
                }

                val pendingResult = goAsync()
                scope.launch {
                    try {
                        // Left showing when a later request replaced this one:
                        // the notification is that one's now.
                        if (AddonUpdatePermissionRequests.decline(profileContext, addonId, requestId)) {
                            AddonUpdatePermissionNotification.cancel(context, profileId, addonId)
                        }
                    } catch (error: Throwable) {
                        logger.error("Could not put off the update of $addonId", error)
                    } finally {
                        pendingResult.finish()
                    }
                }
            }

            AddonUpdatePermissionNotification.ACTION_ALLOW -> {
                val pendingResult = goAsync()
                scope.launch {
                    try {
                        allow(context.applicationContext, profileId, addonId, requestId)
                    } catch (error: Throwable) {
                        logger.error("Could not accept the update of $addonId", error)
                    } finally {
                        pendingResult.finish()
                    }
                }
            }
        }
    }

    private suspend fun allow(
        application: Context,
        profileId: String,
        addonId: String,
        requestId: String,
    ) {
        // Null is "not knowable yet" (maintenance, a selection, a restart).
        val candidate = StartupArbiter.peekProfileFolder()
            ?.let { ProfileUuid.fromDirName(File(it).name) }
        if (candidate != profileId) {
            logger.info("Leaving the update of $addonId for $profileId; this process is $candidate")
            return
        }

        val profileContext = ActiveProfile.resolveOrCommitContext(application) ?: return
        if (profileContext.profileId != profileId) return

        if (!AddonUpdatePermissionRequests.accept(profileContext, addonId, requestId)) {
            logger.info("The update of $addonId asks for something else now; nothing granted")
            // With nothing pending the notification is stale. Otherwise it shows
            // the request that replaced this one, which is still to be answered.
            if (AddonUpdatePermissionRequests.get(profileContext, addonId) == null) {
                AddonUpdatePermissionNotification.cancel(application, profileId, addonId)
            }
            return
        }
        AddonUpdatePermissionNotification.cancel(application, profileId, addonId)
        logger.info("New permissions for $addonId were granted")

        // Without a live engine for this profile, ProfileAddonUpdater applies
        // the grant once the profile's extensions next load.
        withContext(Dispatchers.Main) {
            GlobalComponents.components
                ?.takeIf { it.profileApplicationContext.profileId == profileId }
                ?.existingCore
                ?.addonUpdater
                ?.update(addonId)
        }
    }

    private companion object {
        val logger = Logger("AddonUpdatePermissionReceiver")
        val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    }
}
