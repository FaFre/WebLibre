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
package eu.weblibre.simple_intent_receiver

import android.content.Context
import android.content.Intent

/** A redeemed "Allow once" / "Always allow" notification approval. */
data class NotificationApproval(
    val token: String,
    val alwaysAllowPackage: String?,
)

/**
 * The one-shot approvals a blocked-intent notification hands back.
 *
 * When the user taps "Allow once", `GatekeeperNotificationActionReceiver` re-fires
 * the blocked intent with a token it wrote to shared prefs. Redeeming that token
 * is what turns the relaunch into an approved one: the caller is reported as
 * *internal*, so neither gatekeeper asks again about a package the user has
 * already answered for.
 *
 * Public, and separate from the plugin, because the redemption has to happen
 * wherever the intent is first taken — and that is not always the plugin. A launch
 * the startup broker queues never reaches the plugin at all, so the broker has to
 * redeem the approval itself and write the outcome into the queue; otherwise the
 * replay arrives carrying the sender's package, meets that package's block policy,
 * and is dropped — the one launch the user explicitly allowed.
 */
object IntentApprovals {
    // Stable names that must match the notification replay path and shared-prefs
    // schema in `IntentGatekeeperPreferences`.
    private const val PREFS_NAME = "weblibre_intent_gatekeeper"
    private const val KEY_NOTIFICATION_APPROVAL_TOKENS = "notification_approval_tokens"
    private const val KEY_NOTIFICATION_APPROVAL_PACKAGE_PREFIX = "notification_approval_package_"

    const val EXTRA_NOTIFICATION_APPROVAL_TOKEN =
        "eu.weblibre.gatekeeper.notification_approval_token"

    /** Names the package the user asked to allow from now on, for the consumer. */
    const val EXTRA_ALWAYS_ALLOW_PACKAGE = "eu.weblibre.gatekeeper.always_allow_package"

    /**
     * Redeems the token [intent] carries, if it carries a live one.
     *
     * One shot: the token is removed here, so a second delivery of the same intent
     * gets nothing. Null means this launch carries no approval — never that it was
     * denied.
     */
    fun consume(context: Context, intent: Intent): NotificationApproval? {
        val token = intent.getStringExtra(EXTRA_NOTIFICATION_APPROVAL_TOKEN) ?: return null

        val prefs = prefs(context)
        val tokens = prefs.getStringSet(KEY_NOTIFICATION_APPROVAL_TOKENS, emptySet())
            ?.toMutableSet()
            ?: return null
        if (!tokens.remove(token)) return null

        val alwaysAllowPackage =
            prefs.getString("$KEY_NOTIFICATION_APPROVAL_PACKAGE_PREFIX$token", null)

        prefs.edit()
            .putStringSet(KEY_NOTIFICATION_APPROVAL_TOKENS, tokens)
            .remove("$KEY_NOTIFICATION_APPROVAL_PACKAGE_PREFIX$token")
            .apply()

        return NotificationApproval(token, alwaysAllowPackage)
    }

    /**
     * Puts a redeemed approval back for whoever handles the launch next.
     *
     * Redeeming is a decision to act on the launch. A caller that redeems and then
     * finds it is not the one delivering after all has to undo it, or the approval
     * is spent on nobody and the user's answer is lost.
     */
    fun restore(context: Context, approval: NotificationApproval) {
        val prefs = prefs(context)
        val tokens = prefs.getStringSet(KEY_NOTIFICATION_APPROVAL_TOKENS, emptySet())
            ?.toMutableSet()
            ?: mutableSetOf()
        tokens.add(approval.token)

        prefs.edit()
            .putStringSet(KEY_NOTIFICATION_APPROVAL_TOKENS, tokens)
            .apply {
                approval.alwaysAllowPackage?.let {
                    putString("$KEY_NOTIFICATION_APPROVAL_PACKAGE_PREFIX${approval.token}", it)
                }
            }
            .apply()
    }

    /**
     * Rewrites [intent]'s approval extras into what a consumer downstream reads.
     *
     * The redeemed token goes, because it no longer authorises anything and a
     * consumer that saw it would be reading a spent credential. What replaces it is
     * the *outcome*: the always-allow package, which is the only part the app still
     * has to act on. Mirrors what the plugin does to the extras map on the live
     * path, so a launch reads the same either way.
     */
    fun applyTo(intent: Intent, approval: NotificationApproval?): Intent = intent.apply {
        removeExtra(EXTRA_NOTIFICATION_APPROVAL_TOKEN)
        removeExtra(EXTRA_ALWAYS_ALLOW_PACKAGE)
        approval?.alwaysAllowPackage?.let { putExtra(EXTRA_ALWAYS_ALLOW_PACKAGE, it) }
    }

    private fun prefs(context: Context) =
        context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
}
