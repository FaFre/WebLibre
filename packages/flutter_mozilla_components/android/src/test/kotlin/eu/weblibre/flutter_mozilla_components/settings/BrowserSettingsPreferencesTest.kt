/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.settings

import android.content.Context
import androidx.core.content.edit
import eu.weblibre.flutter_mozilla_components.ProfileContext
import eu.weblibre.flutter_mozilla_components.pigeons.PullToRefreshSettings
import kotlin.test.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

/**
 * The pull-to-refresh mirror a window reads before Dart has replicated the
 * profile's settings.
 *
 * Its failures are quiet: a window that reads the wrong value just reloads (or
 * doesn't) at a distance the user never chose, until Dart catches up.
 */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class BrowserSettingsPreferencesTest {
    private val application: Context = RuntimeEnvironment.getApplication()

    private fun profile(dirName: String) = ProfileContext(application, "profiles/$dirName")

    @Test
    fun `a profile that stored nothing gets the shipped defaults`() {
        assertEquals(
            BrowserSettingsPreferences.DEFAULT_PULL_TO_REFRESH,
            BrowserSettingsPreferences.getPullToRefresh(profile("fresh")),
        )
    }

    @Test
    fun `stored settings read back`() {
        val context = profile("stored")
        val settings = PullToRefreshSettings(enabled = false, triggerDistanceDp = 128.0)

        BrowserSettingsPreferences.setPullToRefresh(context, settings)

        assertEquals(settings, BrowserSettingsPreferences.getPullToRefresh(context))
    }

    @Test
    fun `one profile's settings do not seed another's`() {
        BrowserSettingsPreferences.setPullToRefresh(
            profile("first"),
            PullToRefreshSettings(enabled = false, triggerDistanceDp = 160.0),
        )

        assertEquals(
            BrowserSettingsPreferences.DEFAULT_PULL_TO_REFRESH,
            BrowserSettingsPreferences.getPullToRefresh(profile("second")),
        )
    }

    @Test
    fun `a mirror written before the distance existed keeps its enabled flag`() {
        // What an existing install has on disk after updating: only the flag.
        val context = profile("upgraded")
        BrowserSettingsPreferences.get(context).edit {
            putBoolean(BrowserSettingsPreferences.KEY_PULL_TO_REFRESH_ENABLED, false)
        }

        assertEquals(
            PullToRefreshSettings(
                enabled = false,
                triggerDistanceDp =
                    BrowserSettingsPreferences.DEFAULT_PULL_TO_REFRESH_TRIGGER_DISTANCE_DP,
            ),
            BrowserSettingsPreferences.getPullToRefresh(context),
        )
    }
}
