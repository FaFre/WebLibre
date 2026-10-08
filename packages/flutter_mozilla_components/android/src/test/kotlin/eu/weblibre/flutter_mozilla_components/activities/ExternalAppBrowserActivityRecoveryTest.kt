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
import android.os.Bundle
import android.os.Looper
import eu.weblibre.flutter_mozilla_components.PwaSessionCreator
import eu.weblibre.flutter_mozilla_components.startup.StartupArbiter
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import kotlinx.coroutines.CompletableDeferred
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config

/**
 * A PWA window whose session is recreated (`recoverPwaSession`) while the
 * window goes to the background: the recovery finishes after
 * `onSaveInstanceState`, when a fragment transaction would throw.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [28])
class ExternalAppBrowserActivityRecoveryTest {
    private val recovered = CompletableDeferred<String>()

    @Before
    fun setUp() {
        // No profile committed: the window opens without a lock, and starts.
        StartupArbiter.resetForTest()
        ExternalAppBrowserActivity.createPwaSession = { _, _, _ -> recovered.await() }
    }

    @After
    fun tearDown() {
        ExternalAppBrowserActivity.createPwaSession = PwaSessionCreator::create
    }

    private fun idle() = shadowOf(Looper.getMainLooper()).idle()

    @Test
    fun aRecoveryThatFinishesInTheBackgroundIsShownOnResume() {
        // A PWA launch with no session: the window recovers one.
        val intent = Intent(RuntimeEnvironment.getApplication(), ExternalAppBrowserActivity::class.java)
            .putExtra(ExternalAppBrowserActivity.EXTRA_WEB_APP_MANIFEST_URL, "https://app.example/")
        val controller = Robolectric.buildActivity(ExternalAppBrowserActivity::class.java, intent)
        controller.get().setTheme(com.google.android.material.R.style.Theme_Material3_DayNight_NoActionBar)
        controller.setup()
        idle()
        val activity = controller.get()

        // Away before the recovery finishes.
        controller.pause().stop()
        controller.saveInstanceState(Bundle())
        assertTrue(activity.supportFragmentManager.isStateSaved)

        recovered.complete("recovered-session")
        idle()

        // Not acted on while away: nothing thrown, and not read as a failed
        // recovery that removes the task. The new session is kept.
        assertFalse(activity.isFinishing)
        assertEquals(
            "recovered-session",
            activity.intent.getStringExtra(ExternalAppBrowserActivity.EXTRA_CUSTOM_TAB_SESSION_ID),
        )

        controller.start().resume()
        idle()

        // Shown on resume. This process has no components to show it with, so
        // showing it ends the window, which is how this sees that it happened
        // now and not while the window was away.
        assertTrue(activity.isFinishing)

        controller.pause().stop().destroy()
    }
}
