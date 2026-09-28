/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import androidx.annotation.VisibleForTesting
import androidx.core.content.edit
import mozilla.components.feature.downloads.ui.DownloaderApp

/**
 * The download manager the user asked to always use, set from the chooser's
 * "Always use this app" box and cleared from the downloads settings.
 *
 * Stored as the app's package *and* activity, never its label or a
 * [DownloaderApp]: a `DownloaderApp` carries the URL and MIME type of the one
 * download it was offered for, and a label changes with the device language. On
 * every download the choice is looked up in the list Mozilla's
 * `DownloadsFeature` offers for *that* URL and MIME type ([resolve]), so an app
 * that has been uninstalled, or cannot take this particular download, is simply
 * not used — the chooser shows instead, and the choice stays for the downloads
 * the app can take.
 *
 * WebLibre itself is a valid choice and is handled differently: remembering it
 * skips the chooser by not forwarding to third parties at all
 * ([shouldForwardToThirdParties]), so the download takes the normal first-party
 * path and its confirmation still shows.
 *
 * Profile-scoped ([ProfilePrefs.key]), like [DownloadLocationPreference], so a
 * Custom Tab started headlessly under profile B never uses profile A's app, and
 * the choice travels with the profile through backup, restore and delete.
 */
object DownloadManagerPreference {
    private const val PREF_KEY = "browser.weblibre.preferredDownloadManager"

    /** A remembered download manager, by component. */
    data class Choice(val packageName: String, val activityName: String) {
        internal fun encode(): String = ComponentName(packageName, activityName).flattenToString()

        companion object {
            internal fun decode(value: String): Choice? =
                ComponentName.unflattenFromString(value)?.let {
                    Choice(it.packageName, it.className)
                }

            fun of(app: DownloaderApp): Choice = Choice(app.packageName, app.activityName)
        }
    }

    /** The remembered choice, or `null` to ask every time. */
    fun read(context: Context): Choice? {
        val key = ProfilePrefs.key(PREF_KEY) ?: return null

        return ProfilePrefs.of(context).getString(key, null)?.let(Choice::decode)
    }

    /**
     * Remembers [choice]. Without a committed profile there is nothing to scope
     * the value to, and it is dropped rather than written where every profile
     * would read it.
     */
    fun write(context: Context, choice: Choice) {
        val key = ProfilePrefs.key(PREF_KEY) ?: return

        ProfilePrefs.of(context).edit { putString(key, choice.encode()) }
    }

    /** Forgets the choice, so the chooser asks again. */
    fun clear(context: Context) {
        val key = ProfilePrefs.key(PREF_KEY) ?: return

        ProfilePrefs.of(context).edit { remove(key) }
    }

    /**
     * The app to hand the current download to: the remembered one, if it is
     * among the [apps] offered for this download.
     *
     * Matching on the activity as well as the package, because one package can
     * register several download activities, and the one remembered is the one
     * the user picked.
     */
    @VisibleForTesting
    internal fun resolve(choice: Choice?, apps: List<DownloaderApp>): DownloaderApp? {
        if (choice == null) {
            return null
        }

        return apps.firstOrNull {
            it.packageName == choice.packageName && it.activityName == choice.activityName
        }
    }

    /** Whether [choice] is WebLibre itself, whichever of its activities was offered. */
    fun isThisApp(context: Context, choice: Choice?): Boolean =
        choice != null && choice.packageName == context.packageName

    /**
     * What `DownloadsFeature.shouldForwardToThirdParties` should answer.
     *
     * The external-manager switch stays the gate. With WebLibre remembered the
     * answer is no, which is exactly the first-party path the switch being off
     * takes — including its confirmation dialog — rather than selecting WebLibre
     * in the chooser, which would start the download without one.
     */
    fun shouldForwardToThirdParties(context: Context): Boolean =
        shouldForwardToThirdParties(context, GlobalComponents.useExternalDownloadManager, read(context))

    @VisibleForTesting
    internal fun shouldForwardToThirdParties(
        context: Context,
        useExternalDownloadManager: Boolean,
        choice: Choice?,
    ): Boolean = useExternalDownloadManager && !isThisApp(context, choice)

    /**
     * The name to show for [choice]: the activity's current label, or `null`
     * once the app is no longer installed.
     */
    fun label(context: Context, choice: Choice): String? {
        val packageManager = context.packageManager

        return try {
            packageManager
                .getActivityInfo(ComponentName(choice.packageName, choice.activityName), 0)
                .loadLabel(packageManager)
                .toString()
        } catch (e: PackageManager.NameNotFoundException) {
            // The activity went away with an update while the app itself stayed;
            // the app's name still says which one was remembered.
            try {
                packageManager
                    .getApplicationInfo(choice.packageName, 0)
                    .loadLabel(packageManager)
                    .toString()
            } catch (e: PackageManager.NameNotFoundException) {
                null
            }
        }
    }
}
