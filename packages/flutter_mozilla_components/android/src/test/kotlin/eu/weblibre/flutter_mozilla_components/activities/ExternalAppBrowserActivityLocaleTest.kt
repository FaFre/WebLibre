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
package eu.weblibre.flutter_mozilla_components.activities

import android.content.Intent
import android.content.res.Configuration
import android.widget.TextView
import eu.weblibre.flutter_mozilla_components.AppLocalePreference
import eu.weblibre.flutter_mozilla_components.PwaSessionCreator
import eu.weblibre.flutter_mozilla_components.R
import eu.weblibre.flutter_mozilla_components.startup.StartupArbiter
import kotlin.test.assertEquals
import kotlinx.coroutines.awaitCancellation
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

/** A Custom Tab or PWA window shows its own UI in the app's language. */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [28])
class ExternalAppBrowserActivityLocaleTest {
    private val context = RuntimeEnvironment.getApplication()

    @Before
    fun setUp() {
        StartupArbiter.resetForTest()
        // Keeps the window waiting on a session instead of handing off.
        ExternalAppBrowserActivity.createPwaSession = { _, _, _ -> awaitCancellation() }
        AppLocalePreference.write(context, "de")
    }

    @After
    fun tearDown() {
        ExternalAppBrowserActivity.createPwaSession = PwaSessionCreator::create
        AppLocalePreference.write(context, null)
    }

    @Test
    fun theLockPanelIsInTheAppsLanguageAndTheWindowStaysDark() {
        val intent = Intent(context, ExternalAppBrowserActivity::class.java)
            .putExtra(ExternalAppBrowserActivity.EXTRA_WEB_APP_MANIFEST_URL, "https://app.example/")
        val controller = Robolectric.buildActivity(ExternalAppBrowserActivity::class.java, intent)
        controller.get().setTheme(com.google.android.material.R.style.Theme_Material3_DayNight_NoActionBar)
        controller.setup()
        val activity = controller.get()

        assertEquals(
            "Profil ist gesperrt",
            activity.findViewById<TextView>(R.id.lock_title).text.toString(),
        )
        // AppCompat applies the app's colour scheme to the same configuration;
        // it must not drop the language, nor the language the night mode.
        // Dark is the scheme before the app has written one.
        assertEquals(
            Configuration.UI_MODE_NIGHT_YES,
            activity.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK,
        )

        controller.pause().stop().destroy()
    }
}
