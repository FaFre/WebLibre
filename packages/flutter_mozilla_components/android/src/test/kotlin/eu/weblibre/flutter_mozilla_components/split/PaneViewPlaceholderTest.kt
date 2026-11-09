/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.split

import android.graphics.Color
import android.view.ContextThemeWrapper
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import com.google.android.material.button.MaterialButton
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

/**
 * A pane dragged down to a sliver shows its crashed-page placeholder as a
 * lone reload icon, and the labeled form again once it grows.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [28])
class PaneViewPlaceholderTest {
    private lateinit var pane: PaneView
    private var reloads = 0

    @Before
    fun setUp() {
        val context = ContextThemeWrapper(
            RuntimeEnvironment.getApplication(),
            com.google.android.material.R.style.Theme_MaterialComponents_Light,
        )
        pane = PaneView(context, InertEngineView(context))
    }

    private fun dp(value: Int): Int =
        (value * pane.resources.displayMetrics.density).toInt()

    private fun layOut(widthDp: Int, heightDp: Int) {
        pane.measure(
            View.MeasureSpec.makeMeasureSpec(dp(widthDp), View.MeasureSpec.EXACTLY),
            View.MeasureSpec.makeMeasureSpec(dp(heightDp), View.MeasureSpec.EXACTLY),
        )
        pane.layout(0, 0, dp(widthDp), dp(heightDp))
    }

    private fun showCrash() = pane.showCrashPlaceholder(
        title = "This page crashed",
        reload = "Reload",
        backgroundColor = Color.WHITE,
        foregroundColor = Color.BLACK,
        onReload = { reloads++ },
    )

    private fun placeholder(): ViewGroup =
        (0 until pane.childCount).map { pane.getChildAt(it) }
            .filterIsInstance<ViewGroup>()
            .single { it.getChildAt(0) is TextView && it.childCount == 2 && it.getChildAt(1) is MaterialButton }

    private fun title() = placeholder().getChildAt(0) as TextView
    private fun button() = placeholder().getChildAt(1) as MaterialButton

    @Test
    fun aRoomyPaneShowsTheTitleAndALabeledButton() {
        layOut(400, 600)
        showCrash()
        layOut(400, 600)

        assertEquals(View.VISIBLE, title().visibility)
        assertEquals("Reload", button().text.toString())
        assertNull(button().icon)
    }

    @Test
    fun aSliverShowsALoneReloadIconThatFits() {
        layOut(48, 600)
        showCrash()
        layOut(48, 600)

        assertEquals(View.GONE, title().visibility)
        assertEquals("", button().text.toString())
        assertNotNull(button().icon)
        assertEquals("Reload", button().contentDescription)
        assertTrue(button().measuredWidth <= dp(48), "button ${button().measuredWidth}px")
        assertTrue(button().measuredHeight <= dp(48), "button ${button().measuredHeight}px")

        button().performClick()
        assertEquals(1, reloads)
    }

    @Test
    fun aShortStackedPaneIsCompactToo() {
        layOut(400, 48)
        showCrash()
        layOut(400, 48)

        assertEquals(View.GONE, title().visibility)
        assertTrue(button().measuredHeight <= dp(48), "button ${button().measuredHeight}px")
    }

    @Test
    fun growingTheSliverBringsTheLabelBack() {
        layOut(48, 600)
        showCrash()
        layOut(48, 600)

        layOut(400, 600)

        assertEquals(View.VISIBLE, title().visibility)
        assertEquals("Reload", button().text.toString())
        assertNull(button().icon)
        assertTrue(button().measuredHeight >= dp(36), "button ${button().measuredHeight}px")
    }
}
