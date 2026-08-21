/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import android.content.Context
import android.content.SharedPreferences
import androidx.preference.PreferenceManager

/**
 * Profile-scoped access to the app-wide default preferences, for state Dart
 * replicates into native and native has to be able to read back on a cold start
 * that never attaches a Flutter engine.
 *
 * Both halves matter. [of] always resolves the *root* application context,
 * whichever context a caller hands in: such state is pushed from Dart before any
 * [ProfileContext] exists, so the writer can only ever hold the raw application
 * context — while callers on the profile-switch path naturally hold a
 * [ProfileContext], which renames the underlying prefs file and would otherwise
 * read a different store than the one written. [key] carries the profile
 * instead, so a headless start under profile B cannot restore profile A's state.
 */
internal object ProfilePrefs {
    fun of(context: Context): SharedPreferences =
        PreferenceManager.getDefaultSharedPreferences(
            (context as? ProfileContext)?.rootApplicationContext ?: context.applicationContext,
        )

    /**
     * Scopes [base] to the *committed* profile, or returns `null` when the process
     * has not committed one yet.
     *
     * There is deliberately no unprefixed fallback. Returning [base] when the
     * profile is unknown wrote one profile's state into a key every other profile
     * also reads, and re-resolving `current_profile` here could bind a different
     * profile than the one the process is actually running. A `null` means "not
     * addressable yet"; callers skip the read or the write.
     */
    fun key(base: String): String? = ActiveProfile.prefix?.let { "$base.$it" }
}
