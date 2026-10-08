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
package eu.weblibre.flutter_mozilla_components.lock

import android.app.Activity
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.LinearLayout
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * What a lock panel sits on: the page and the launch status, which names the
 * destination and offers to open it in the browser.
 */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class CoveredViewsTest {
    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    private val pageField = EditText(activity)
    private val page = FrameLayout(activity).apply { addView(pageField) }

    private val statusButton = Button(activity)
    private val status = LinearLayout(activity).apply {
        addView(statusButton)
        // Set up deliberately, so putting back the default would be wrong.
        importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_YES
    }

    private val covered = CoveredViews(listOf(page, status))

    init {
        activity.setContentView(
            FrameLayout(activity).apply {
                addView(page)
                addView(status)
            },
        )
    }

    @Test
    fun bothAreHiddenFromAccessibilityAndBlockFocus() {
        covered.cover()

        for (view in listOf(page, status)) {
            assertEquals(View.IMPORTANT_FOR_ACCESSIBILITY_NO_HIDE_DESCENDANTS, view.importantForAccessibility)
            assertEquals(ViewGroup.FOCUS_BLOCK_DESCENDANTS, view.descendantFocusability)
        }
        assertFalse(statusButton.isImportantForAccessibility)
        assertFalse(statusButton.requestFocus())
    }

    @Test
    fun thePageLosesFocusSoAKeyboardCannotTypeIntoIt() {
        assertTrue(pageField.requestFocus())

        covered.cover()

        assertFalse(pageField.hasFocus())
        assertFalse(pageField.requestFocus())
    }

    @Test
    fun uncoveringPutsBackTheSetupAndTheFocus() {
        assertTrue(pageField.requestFocus())
        val pageAccessibility = page.importantForAccessibility
        val pageFocusability = page.descendantFocusability

        covered.cover()
        covered.uncover()

        assertEquals(pageAccessibility, page.importantForAccessibility)
        assertEquals(pageFocusability, page.descendantFocusability)
        assertEquals(View.IMPORTANT_FOR_ACCESSIBILITY_YES, status.importantForAccessibility)
        assertTrue(pageField.hasFocus())
    }

    @Test
    fun coveringTwiceKeepsTheFirstSetup() {
        covered.cover()
        covered.cover()
        covered.uncover()

        assertEquals(View.IMPORTANT_FOR_ACCESSIBILITY_YES, status.importantForAccessibility)
        assertFalse(covered.isCovered)
    }
}
