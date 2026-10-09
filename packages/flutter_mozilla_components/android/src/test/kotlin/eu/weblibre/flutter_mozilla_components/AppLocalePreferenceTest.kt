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
import android.content.res.Configuration
import java.util.Locale
import kotlin.test.assertEquals
import kotlin.test.assertSame
import org.junit.After
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

/** The app's UI language, as native windows apply it to themselves. */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [28])
class AppLocalePreferenceTest {
    private val context: Context = RuntimeEnvironment.getApplication()

    @After
    fun tearDown() {
        AppLocalePreference.write(context, null)
    }

    private fun lockTitleIn(languageTag: String): String {
        AppLocalePreference.write(context, languageTag)
        return AppLocalePreference.wrap(context).getString(R.string.weblibre_lock_title)
    }

    @Test
    fun aWindowFollowsTheSystemUntilALanguageIsChosen() {
        assertSame(context, AppLocalePreference.wrap(context))
    }

    @Test
    fun aChosenLanguageIsWhatTheWindowSpeaks() {
        assertEquals("Profil ist gesperrt", lockTitleIn("de"))
        assertEquals("El perfil está bloqueado", lockTitleIn("es"))
        assertEquals("Профиль заблокирован", lockTitleIn("ru"))
    }

    @Test
    fun chineseFindsItsResourcesWithoutARegion() {
        // Dart sends "zh"; the resources are values-zh-rCN.
        assertEquals("配置文件已锁定", lockTitleIn("zh"))
    }

    @Test
    fun followingTheSystemAgainUndoesIt() {
        AppLocalePreference.write(context, "de")
        AppLocalePreference.write(context, null)

        assertSame(context, AppLocalePreference.wrap(context))
    }

    @Test
    fun theOverrideSetsTheLanguageAndNothingElse() {
        // An override is applied on top of every later configuration: anything
        // else it defined would stay as it was when the window opened.
        val override = AppLocalePreference.localeOverride(Locale.GERMAN)

        assertEquals("de", override.locales[0].language)
        assertEquals(Configuration.ORIENTATION_UNDEFINED, override.orientation)
        assertEquals(Configuration.SCREEN_WIDTH_DP_UNDEFINED, override.screenWidthDp)
        assertEquals(Configuration.SCREEN_HEIGHT_DP_UNDEFINED, override.screenHeightDp)
        assertEquals(
            Configuration.SMALLEST_SCREEN_WIDTH_DP_UNDEFINED,
            override.smallestScreenWidthDp,
        )
        assertEquals(Configuration.DENSITY_DPI_UNDEFINED, override.densityDpi)
        assertEquals(0f, override.fontScale)
        assertEquals(Configuration.UI_MODE_TYPE_UNDEFINED, override.uiMode)
    }

    @Test
    fun aWindowFollowsLaterConfigurationChangesInItsLanguage() {
        AppLocalePreference.write(context, "de")
        val wrapped = AppLocalePreference.wrap(context)

        // Rotated and the font size raised after the window opened, applied
        // the way the platform applies it to every live set of resources.
        val changed = Configuration(context.resources.configuration).apply {
            orientation = Configuration.ORIENTATION_LANDSCAPE
            fontScale = 1.3f
            screenWidthDp = 800
        }
        applyToAllResources(changed)

        val config = wrapped.resources.configuration
        assertEquals(Configuration.ORIENTATION_LANDSCAPE, config.orientation)
        assertEquals(1.3f, config.fontScale)
        assertEquals(800, config.screenWidthDp)
        assertEquals("de", config.locales[0].language)
    }

    /**
     * What the system does on a configuration change, through the framework's
     * `ResourcesManager` (hidden). Robolectric's own `configurationChange`
     * overwrites an activity's configuration object instead, which would hide
     * an override that pins values.
     */
    private fun applyToAllResources(config: Configuration) {
        val managerClass = Class.forName("android.app.ResourcesManager")
        val manager = managerClass.getMethod("getInstance").invoke(null)
        val apply = managerClass.methods.first {
            it.name.startsWith("applyConfigurationToResources") && it.parameterCount == 2
        }
        synchronized(manager) { apply.invoke(manager, config, null) }
    }

    @Test
    fun theProcessLanguageIsLeftAlone() {
        // What Gecko and Flutter see as the device's must not move with it.
        val before = Locale.getDefault()

        lockTitleIn("de")

        assertEquals(before, Locale.getDefault())
        assertEquals(before, context.resources.configuration.locales[0])
    }
}
