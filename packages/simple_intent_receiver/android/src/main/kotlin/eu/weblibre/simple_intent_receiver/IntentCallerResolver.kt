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

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build

/**
 * The single definition of `Intent.fromPackageName`.
 *
 * Public because provenance has to be recorded at the moment the intent arrives,
 * and that is not always in this plugin: a launch that arrives before Flutter can
 * receive it is queued natively and replayed minutes later, by which point
 * `getReferrer()` answers about whatever activity is running *now*. The queue has
 * to write down the caller resolved here, or the gatekeeper sees an unknown
 * external app as internal and never prompts.
 *
 * A second implementation for the queue would be the same bug with extra steps:
 * the two would agree until one of them was edited.
 */
object IntentCallerResolver {

    /**
     * Identity of the app that sent [intent], as the gatekeeper reads it.
     *
     * `null` means "internal or unknown" and is not a gap to be filled in later:
     * it is what the gatekeeper treats as needing no prompt, so a caller that
     * cannot be established must never be replaced with a guess.
     */
    fun resolve(context: Context, activity: Activity?, intent: Intent): String? {
        val raw = resolveRaw(activity, intent) ?: return null
        // Treat system packages (launcher, shell, SystemUI, etc.) as internal — the
        // gatekeeper shouldn't prompt the user when the OS itself forwards an intent.
        if (isSystemPackage(context, raw)) return null
        return raw
    }

    /**
     * Best-effort caller package, before the system-package filter.
     *
     * Everything except the last branch is caller-controlled and therefore
     * spoofable: an app can claim to be another package. Consumers must not grant
     * anything on it that the caller could not already do itself.
     *
     * [intent]'s own referrer extras are read *before* `Activity.getReferrer()`,
     * and the order matters for exactly one caller. `getReferrer()` reads
     * `getIntent()`, which during `onNewIntent` is still the intent that launched
     * the activity — so a resolver that started there would answer about the
     * previous launch for anything inspecting a new intent before it is set. For
     * the live path the two are the same object, and `getReferrer()` reads the
     * same two extras first anyway, so nothing changes there.
     */
    fun resolveRaw(activity: Activity?, intent: Intent): String? {
        // 1. Explicit referrer extras on the intent being resolved.
        @Suppress("DEPRECATION")
        val referrerUri: Uri? = try {
            intent.getParcelableExtra(Intent.EXTRA_REFERRER)
        } catch (e: RuntimeException) {
            null
        }
        if (referrerUri?.scheme == ANDROID_APP_SCHEME) {
            referrerUri.host?.let { return it }
        }

        intent.getStringExtra(Intent.EXTRA_REFERRER_NAME)?.let { name ->
            Uri.parse(name).takeIf { it.scheme == ANDROID_APP_SCHEME }?.host?.let { return it }
        }

        // 2. The launch referrer the system recorded for this activity.
        //    Android can throw when the referrer carries data it cannot deserialise.
        val activityReferrer = try {
            activity?.referrer
        } catch (e: RuntimeException) {
            null
        }
        activityReferrer?.let { uri ->
            if (uri.scheme == ANDROID_APP_SCHEME) {
                uri.host?.let { return it }
            }
        }

        // 3. Caller for startActivityForResult flows. Supplied by the system and
        //    the only branch here that cannot be forged.
        return activity?.callingPackage
    }

    @Suppress("TooGenericExceptionCaught")
    fun isSystemPackage(context: Context, packageName: String): Boolean {
        return try {
            val pm = context.packageManager
            val info = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                pm.getApplicationInfo(packageName, PackageManager.ApplicationInfoFlags.of(0))
            } else {
                @Suppress("DEPRECATION")
                pm.getApplicationInfo(packageName, 0)
            }
            val systemFlags = ApplicationInfo.FLAG_SYSTEM or ApplicationInfo.FLAG_UPDATED_SYSTEM_APP
            (info.flags and systemFlags) != 0
        } catch (_: PackageManager.NameNotFoundException) {
            false
        } catch (_: Exception) {
            false
        }
    }

    private const val ANDROID_APP_SCHEME = "android-app"
}
