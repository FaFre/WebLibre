/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.activities

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import mozilla.components.support.utils.EXTRA_ACTIVITY_REFERRER_CATEGORY
import mozilla.components.support.utils.EXTRA_ACTIVITY_REFERRER_PACKAGE
import mozilla.components.support.utils.ext.packageManagerCompatHelper

/**
 * Records which app sent [intent] so the session created from it carries a `caller`.
 *
 * AC's `CustomTabIntentProcessor` reads the caller through `SafeIntent.externalPackage()`, which
 * only looks at the [EXTRA_ACTIVITY_REFERRER_PACKAGE] extra — nothing populates it for us, so a
 * receiver has to stamp it before handing the intent to the processors or every custom tab ends up
 * with `Source.External.CustomTab(null)`. Mirrors Fenix's `IntentReceiverActivity`
 * `addReferrerInformation`.
 *
 * The app-links authentication carve-out
 * ([eu.weblibre.flutter_mozilla_components.applinks.WebLibreAppLinksInterceptor]) is the consumer:
 * it lets a sign-in callback return to the app that opened the tab.
 */
fun Activity.addExternalCallerInformation(intent: Intent) {
    val caller = resolveExternalCallerPackage(intent) ?: return
    intent.putExtra(EXTRA_ACTIVITY_REFERRER_PACKAGE, caller)

    // ApplicationInfo.category is API 26+; this module builds against minSdk 24.
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        try {
            val category = packageManagerCompatHelper.getApplicationInfoCompat(caller, 0).category
            intent.putExtra(EXTRA_ACTIVITY_REFERRER_CATEGORY, category)
        } catch (e: PackageManager.NameNotFoundException) {
            // The caller is not resolvable — the package id alone is enough for our purposes.
        }
    }
}

/**
 * Best-effort identity of the app that sent [intent].
 *
 * [Activity.getCallingPackage] is supplied by the system and cannot be forged, so it wins when
 * present (only set for `startActivityForResult` callers). The referrer chain below is
 * caller-controlled and therefore spoofable — an app can claim to be another package. Consumers
 * must not grant anything on it that the caller could not already do itself.
 */
@Suppress("TooGenericExceptionCaught")
fun Activity.resolveExternalCallerPackage(intent: Intent): String? {
    callingPackage?.let { return it }

    // Android can throw when the referrer carries data it cannot deserialise.
    val activityReferrer = try {
        referrer
    } catch (e: RuntimeException) {
        null
    }
    activityReferrer?.let { uri ->
        if (uri.scheme == ANDROID_APP_SCHEME) {
            uri.host?.let { return it }
        }
    }

    @Suppress("DEPRECATION")
    val referrerUri: Uri? = intent.getParcelableExtra(Intent.EXTRA_REFERRER)
    if (referrerUri?.scheme == ANDROID_APP_SCHEME) {
        referrerUri.host?.let { return it }
    }

    intent.getStringExtra(Intent.EXTRA_REFERRER_NAME)?.let { name ->
        Uri.parse(name).takeIf { it.scheme == ANDROID_APP_SCHEME }?.host?.let { return it }
    }

    return null
}

private const val ANDROID_APP_SCHEME = "android-app"
