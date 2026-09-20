/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.settings

import android.content.Context
import android.content.SharedPreferences
import androidx.core.content.edit
import eu.weblibre.flutter_mozilla_components.ProfileContext

/**
 * Native-readable mirror of the browser settings a window needs before Flutter
 * has replicated them.
 *
 * Most engine settings are pushed from Dart at startup and only ever read after
 * that, so holding them in memory on `GlobalComponents` is enough. A few are
 * read earlier than that: `GeckoBrowserService.initialize` — and with it the
 * first browser window — runs well before `main.dart` activates the engine
 * settings replication, so whatever the in-memory default says is what the user
 * gets until it catches up. Mirroring those settings here lets that window read
 * the real value straight away, the same trick the intent gatekeeper uses to
 * decide about an intent without starting Flutter.
 *
 * Takes a [ProfileContext] rather than any [Context] on purpose: the setting is
 * per profile (`GeneralSettings` lives in the profile's `user.db`), and
 * [ProfileContext.getSharedPreferences] namespaces the file by profile
 * directory. Handed a process-global context this would seed profile B's first
 * window with profile A's choice.
 *
 * The mirror is a seed, never the source of truth — the in-memory value wins as
 * soon as Dart has spoken for the profile in question.
 */
object BrowserSettingsPreferences {
    const val PREFS_NAME = "weblibre_browser_settings"
    const val KEY_PULL_TO_REFRESH_ENABLED = "pull_to_refresh_enabled"

    fun get(context: ProfileContext): SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    /** Defaults to true, matching `GeneralSettings.pullToRefreshEnabled`. */
    fun isPullToRefreshEnabled(context: ProfileContext): Boolean =
        get(context).getBoolean(KEY_PULL_TO_REFRESH_ENABLED, true)

    fun setPullToRefreshEnabled(context: ProfileContext, enabled: Boolean) {
        get(context).edit { putBoolean(KEY_PULL_TO_REFRESH_ENABLED, enabled) }
    }
}
