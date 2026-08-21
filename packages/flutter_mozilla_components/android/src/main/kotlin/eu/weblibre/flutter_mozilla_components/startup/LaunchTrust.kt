/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
package eu.weblibre.flutter_mozilla_components.startup

import android.content.Context
import android.content.Intent
import android.content.pm.ShortcutManager
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.browser.customtabs.CustomTabsIntent
import eu.weblibre.flutter_mozilla_components.PwaConstants
import eu.weblibre.flutter_mozilla_components.gatekeeper.IntentGatekeeperPreferences

/**
 * Decides what a launch *is*, from nothing but the intent and global state.
 *
 * Shared rather than owned by [IntentReceiverActivity] because two entry points
 * need the same answer and must not be able to disagree about it.
 * `IntentReceiverActivity` asks in order to route; `MainActivity` asks in order
 * to write the answer into the startup intent queue, because a queued launch is
 * replayed into a Dart side that is forbidden — by design — from deriving trust
 * from raw intent extras. A queue entry that forgot it was trusted can never get
 * that back, and the extras it still carries are exactly the ones any app on the
 * device can forge.
 *
 * Everything here reads global preferences and the pinned-shortcut list only, so
 * it is legal before a profile is committed. That is the point: this is what lets
 * an unvalidated `pwa_profile_uuid` be discarded rather than acted on.
 */
object LaunchTrust {
    private const val TAG = "LaunchTrust"

    /** Builds the launch facts and classifies them. */
    fun classify(context: Context, intent: Intent): LaunchDescriptor {
        val app = context.applicationContext
        val profileUuid = intent.getStringExtra(PwaConstants.EXTRA_PWA_PROFILE_UUID)
        val token = intent.getStringExtra(PwaConstants.EXTRA_PWA_TOKEN)
        val trusted = profileUuid != null && isTrustedPwaLaunch(app, intent, profileUuid, token)

        if (profileUuid != null && !trusted) {
            Log.w(TAG, "Discarding untrusted PWA profile metadata on ${intent.action}")
        }

        return LaunchClassifier.classify(
            LaunchFacts(
                action = intent.action,
                dataUri = intent.dataString,
                categories = intent.categories.orEmpty(),
                hasCustomTabSession = intent.hasExtra(CustomTabsIntent.EXTRA_SESSION),
                pwaProfileId = profileUuid?.lowercase(),
                pwaTrusted = trusted,
                shortcutType = intent.getStringExtra(PwaConstants.EXTRA_SHORTCUT_TYPE),
                shareUrl = if (intent.action == Intent.ACTION_SEND) {
                    extractShareUrl(intent)
                } else {
                    null
                },
                customTabsEnabled = IntentGatekeeperPreferences.isCustomTabsEnabled(app),
            ),
        )
    }

    /**
     * Whether this launch's `pwa_token` actually authenticates the profile it
     * claims. Presence of the extras is worth nothing on its own — that is what
     * every app on the device can supply.
     *
     * This is the Android half only: pull the claim off the [Intent], hand the
     * two lookups to [PwaLaunchTrustRule], and log what it decided. The rule
     * itself is pure Kotlin so it can be unit tested — see [PwaLaunchTrustRule].
     */
    fun isTrustedPwaLaunch(
        context: Context,
        intent: Intent,
        profileUuid: String,
        token: String?,
    ): Boolean {
        val prefs = context.getSharedPreferences(
            PwaConstants.PROFILE_MAPPING_PREFS,
            Context.MODE_PRIVATE,
        )

        val trusted = PwaLaunchTrustRule.isTrusted(
            claim = PwaTrustClaim(
                action = intent.action,
                intentUrl = intent.dataString,
                profileUuid = profileUuid,
                token = token,
                contextId = intent.getStringExtra(PwaConstants.EXTRA_PWA_CONTEXT_ID).orEmpty(),
                installStartUrl = intent.getStringExtra(PwaConstants.EXTRA_PWA_INSTALL_START_URL),
            ),
            tokens = { key -> prefs.getString(key, null) },
            // By name, and lazily: enumerating pinned shortcuts is a system call,
            // and the preference mirror answers first for everything installed
            // since tokens started being written there.
            pinnedShortcuts = { pinnedShortcutClaims(context) },
        )

        if (!trusted) {
            Log.w(TAG, "PWA token mismatch for ${intent.dataString}")
        }
        return trusted
    }

    private fun pinnedShortcutClaims(context: Context): List<PinnedShortcutClaim> {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return emptyList()

        val manager = context.getSystemService(ShortcutManager::class.java)
            ?: return emptyList()

        return runCatching {
            manager.pinnedShortcuts.mapNotNull { shortcut ->
                val intent = shortcut.intent ?: return@mapNotNull null
                PinnedShortcutClaim(
                    profileUuid = intent.getStringExtra(PwaConstants.EXTRA_PWA_PROFILE_UUID),
                    token = intent.getStringExtra(PwaConstants.EXTRA_PWA_TOKEN),
                    url = intent.dataString,
                    installStartUrl = intent.getStringExtra(
                        PwaConstants.EXTRA_PWA_INSTALL_START_URL,
                    ),
                )
            }
        }.getOrElse { error ->
            Log.w(TAG, "Could not enumerate pinned shortcuts", error)
            emptyList()
        }
    }

    /** The URL a share carries, if it carries one this app can open. */
    fun extractShareUrl(intent: Intent): String? {
        fun String?.toHttpUrl(): String? {
            val candidate = this?.trim().orEmpty()
            return candidate.takeIf {
                it.startsWith("http://") || it.startsWith("https://")
            }
        }

        intent.getStringExtra(Intent.EXTRA_TEXT)?.toHttpUrl()?.let { return it }

        @Suppress("DEPRECATION")
        val streamUri: Uri? = intent.getParcelableExtra(Intent.EXTRA_STREAM)
        streamUri?.toString().toHttpUrl()?.let { return it }

        intent.dataString.toHttpUrl()?.let { return it }

        return null
    }
}
