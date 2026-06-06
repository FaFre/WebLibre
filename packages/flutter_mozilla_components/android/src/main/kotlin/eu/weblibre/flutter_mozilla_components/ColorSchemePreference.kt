/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import android.content.Context
import android.content.SharedPreferences
import androidx.appcompat.app.AppCompatDelegate
import androidx.core.content.edit
import androidx.preference.PreferenceManager
import mozilla.components.concept.engine.mediaquery.PreferredColorScheme

/**
 * Persists the user's preferred color scheme in the default [SharedPreferences].
 *
 * Flutter remains the source of truth for the theme, but Custom Tab / PWA sessions
 * run in a native, non-Flutter activity ([eu.weblibre.flutter_mozilla_components.activities.ExternalAppBrowserActivity]).
 * When such a session cold-starts the app, the engine is built before Flutter ever
 * runs, so it cannot ask Flutter for the scheme. Without a persisted value the engine
 * falls back to a hardcoded default and reports the wrong `prefers-color-scheme` to
 * web content (see issue #436). This lets the native side resolve the last known
 * choice on cold start.
 */
object ColorSchemePreference {
    private const val PREF_KEY = "weblibre_preferred_color_scheme"

    private const val VALUE_SYSTEM = "system"
    private const val VALUE_LIGHT = "light"
    private const val VALUE_DARK = "dark"

    /**
     * Fallback used before Flutter has written a value (e.g. the very first
     * Custom Tab / PWA launch). Must match WebLibre's default app theme
     * (`ThemeMode.dark`, general_settings.dart) so a direct launch doesn't briefly
     * disagree with the app's default.
     */
    private val DEFAULT = PreferredColorScheme.Dark

    fun read(prefs: SharedPreferences): PreferredColorScheme =
        when (prefs.getString(PREF_KEY, null)) {
            VALUE_SYSTEM -> PreferredColorScheme.System
            VALUE_LIGHT -> PreferredColorScheme.Light
            VALUE_DARK -> PreferredColorScheme.Dark
            else -> DEFAULT
        }

    fun read(context: Context): PreferredColorScheme =
        read(PreferenceManager.getDefaultSharedPreferences(context))

    fun write(prefs: SharedPreferences, scheme: PreferredColorScheme) {
        prefs.edit {
            putString(
                PREF_KEY,
                when (scheme) {
                    PreferredColorScheme.Light -> VALUE_LIGHT
                    PreferredColorScheme.Dark -> VALUE_DARK
                    PreferredColorScheme.System -> VALUE_SYSTEM
                },
            )
        }
    }

    /**
     * Maps the persisted scheme to an [AppCompatDelegate] night mode so native
     * activities (Custom Tab / PWA) render their window chrome in the mode the user
     * selected in WebLibre, instead of always following the system. This avoids the
     * window flashing dark before the page paints when WebLibre is forced to light.
     */
    fun nightMode(context: Context): Int =
        when (read(context)) {
            PreferredColorScheme.Light -> AppCompatDelegate.MODE_NIGHT_NO
            PreferredColorScheme.Dark -> AppCompatDelegate.MODE_NIGHT_YES
            PreferredColorScheme.System -> AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM
        }
}
