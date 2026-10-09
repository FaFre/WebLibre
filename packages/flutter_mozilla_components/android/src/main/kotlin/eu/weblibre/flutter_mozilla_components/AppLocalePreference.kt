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
package eu.weblibre.flutter_mozilla_components

import android.content.Context
import android.content.SharedPreferences
import android.content.res.Configuration
import android.os.LocaleList
import androidx.annotation.VisibleForTesting
import androidx.core.content.edit
import androidx.preference.PreferenceManager
import java.util.Locale

/**
 * The language of the app's own UI, mirrored for WebLibre's native windows.
 *
 * Flutter picks its UI language itself (`GeneralSettings.appLocale`), so the
 * native windows used to follow the system language instead: with German
 * chosen in the app and an English system, a Custom Tab's lock panel was
 * English next to the browser's German one.
 *
 * Applied to each native window's own context ([wrap]), never app-wide.
 * `AppCompatDelegate.setApplicationLocales` would also change `MainActivity`,
 * and Flutter reads its platform locales off that activity as the device's:
 * they are the languages Gecko asks websites for by default, and the region
 * search defaults to. For the same reason the browser's own native dialogs,
 * which live in `MainActivity`, keep the system language.
 *
 * App-wide storage rather than per profile, as [ColorSchemePreference] and
 * for the same reason: a window can open before any profile is committed and
 * before Flutter runs. The process serves one profile, whose Dart half writes
 * this on every start.
 */
object AppLocalePreference {
    private const val PREF_KEY = "weblibre_app_locale"

    /** The language as a BCP 47 tag, or null while it follows the system. */
    fun read(prefs: SharedPreferences): String? = prefs.getString(PREF_KEY, null)

    fun read(context: Context): String? =
        read(PreferenceManager.getDefaultSharedPreferences(context))

    /** [languageTag] null follows the system again. */
    fun write(context: Context, languageTag: String?) {
        PreferenceManager.getDefaultSharedPreferences(context).edit {
            if (languageTag == null) remove(PREF_KEY) else putString(PREF_KEY, languageTag)
        }
    }

    /**
     * [base] in the app's language, for a native window's `attachBaseContext`;
     * [base] itself while the app follows the system.
     *
     * Applied when the window is created. One already open keeps its language
     * until it is opened again: these windows handle configuration changes
     * themselves and are never recreated.
     */
    fun wrap(base: Context): Context {
        val locale = read(base)?.let(Locale::forLanguageTag) ?: return base
        if (locale.language.isEmpty()) return base

        return base.createConfigurationContext(localeOverride(locale))
    }

    /**
     * An override that sets the language and leaves everything else undefined.
     *
     * Not a copy of the base configuration: an override is applied on top of
     * every configuration the window gets later, and these windows take
     * rotation, resizing, density, font scale and night mode as configuration
     * changes rather than being recreated. A copied value would stay as it was
     * when the window opened. AppCompat builds its own overrides this way.
     */
    @VisibleForTesting
    internal fun localeOverride(locale: Locale): Configuration =
        Configuration().apply { setLocales(LocaleList(locale)) }
}
