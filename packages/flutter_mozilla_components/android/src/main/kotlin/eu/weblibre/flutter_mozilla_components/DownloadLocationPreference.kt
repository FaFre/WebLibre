/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import android.content.Context
import android.os.Environment
import android.provider.DocumentsContract
import androidx.annotation.VisibleForTesting
import androidx.core.content.edit
import androidx.core.net.toUri

/**
 * Where downloads are written: the folder the user picked, or the public
 * Downloads directory.
 *
 * Flutter owns the choice (a Storage Access Framework tree URI, picked and
 * granted there) and replicates it here, because the components that need it
 * are built long before — and sometimes entirely without — a Flutter engine:
 * the engine's download delegate at [components.Core] construction, the
 * download service, and the Custom Tab / PWA activity. Same argument as
 * [ColorSchemePreference], and the same shape.
 *
 * Profile-scoped ([ProfilePrefs.key]): downloads settings live in the profile's
 * own database, so a headless start under profile B must not write into the
 * folder profile A chose.
 */
object DownloadLocationPreference {
    private const val PREF_KEY = "browser.weblibre.downloadDirectoryUri"

    /**
     * The public Downloads folder — the value every call site used before this
     * existed, and the fallback whenever the configured folder cannot be used.
     */
    fun defaultLocation(): String =
        Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).path

    /**
     * The folder to write to, as `DownloadState.directoryPath` wants it: either a
     * `content://` tree URI or a filesystem path.
     *
     * A configured folder is only returned while the persisted grant for it still
     * stands. Mozilla's writer does not treat a lost grant as a reason to fall
     * back — `DefaultDownloadFileWriter.verifySafPermission` throws, failing the
     * download outright — so the check has to happen before the location is
     * handed out. Revoking access in the system settings, or picking a folder on
     * a card that is no longer mounted, then costs the preference rather than the
     * download.
     *
     * Read once per download request, which is also how often the grant can have
     * changed underneath us.
     */
    fun read(context: Context): String = resolve(context, configured(context))

    /**
     * The location [configured] resolves to. Split out from [read] so the rule
     * can be tested without a committed profile to store a value under.
     */
    @VisibleForTesting
    internal fun resolve(context: Context, configured: String?): String {
        if (configured == null) {
            return defaultLocation()
        }

        val location = normalizeTreeUri(configured)

        return if (isUsable(context, location)) location else defaultLocation()
    }

    /**
     * The tree URI a configured location is addressed by.
     *
     * A folder has two URI forms, and only one of them works here. The grant the
     * picker took is recorded against the tree URI the system returned
     * (`…/tree/<id>`), and Mozilla's writer compares `directoryPath` against that
     * list by exact equality before it will write anything. But a picker that
     * hands back `DocumentFile.fromTreeUri(...).uri` — as the one WebLibre uses
     * does — gives the *document* form of the same folder,
     * `…/tree/<id>/document/<id>`, which matches no grant. Stored as-is it would
     * fail the check here, and had it been let through it would have thrown in
     * `verifySafPermission` and failed the download outright.
     *
     * Normalizing on read rather than only on write, so a value stored by a build
     * that did not know this — or carried in by a settings import — resolves too.
     */
    @VisibleForTesting
    internal fun normalizeTreeUri(location: String): String {
        if (!location.startsWith("content://")) {
            return location
        }

        val uri = try {
            location.toUri()
        } catch (e: IllegalArgumentException) {
            return location
        }

        val authority = uri.authority ?: return location

        return try {
            DocumentsContract.buildTreeDocumentUri(
                authority,
                DocumentsContract.getTreeDocumentId(uri),
            ).toString()
        } catch (e: IllegalArgumentException) {
            // Not a tree URI at all; nothing to normalize towards.
            location
        }
    }

    /** The configured folder, whether or not it is still usable. */
    fun configured(context: Context): String? {
        val key = ProfilePrefs.key(PREF_KEY) ?: return null

        return ProfilePrefs.of(context).getString(key, null)?.takeIf { it.isNotEmpty() }
    }

    /**
     * Replaces the configured folder. `null` restores the default.
     *
     * Without a committed profile there is no key to write under; the value is
     * dropped rather than written unscoped, which would hand this profile's
     * folder to whichever profile starts next. Dart replicates on every start, so
     * the write lands again once a profile is committed.
     */
    fun write(context: Context, directoryUri: String?) {
        val key = ProfilePrefs.key(PREF_KEY) ?: return

        ProfilePrefs.of(context).edit {
            if (directoryUri.isNullOrEmpty()) {
                remove(key)
            } else {
                putString(key, directoryUri)
            }
        }
    }

    /**
     * Whether [location] can still be written to.
     *
     * Only SAF URIs can lose access; a plain path is the default and is always
     * taken at face value, exactly as it was before this preference existed.
     */
    private fun isUsable(context: Context, location: String): Boolean {
        if (!location.startsWith("content://")) {
            return true
        }

        val uri = try {
            location.toUri()
        } catch (e: IllegalArgumentException) {
            return false
        }

        // The same predicate the writer verifies with, so "usable here" and
        // "accepted there" cannot disagree.
        return context.contentResolver.persistedUriPermissions.any {
            it.uri == uri && it.isReadPermission && it.isWritePermission
        }
    }
}
