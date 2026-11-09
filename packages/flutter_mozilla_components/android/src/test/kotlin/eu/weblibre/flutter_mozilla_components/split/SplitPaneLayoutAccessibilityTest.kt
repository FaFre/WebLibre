/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.split

import android.view.View
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [28])
class SplitPaneLayoutAccessibilityTest {
    /**
     * A view group with an accessibility node provider drops its real
     * children from the accessibility tree (`ViewGroup
     * .onInitializeAccessibilityNodeInfoInternal` returns before adding them).
     * The pages are this layout's children, so it must never have one, split
     * or not. Robolectric does not fill in node children, so the rule is
     * checked at its cause; the TalkBack row of the device matrix checks the
     * effect.
     */
    @Test
    fun theLayoutHasNoNodeProvider() {
        val layout = SplitPaneLayout(RuntimeEnvironment.getApplication())
        assertNull(layout.accessibilityNodeProvider)
    }

    /** The divider is its own focusable child, hidden while there is none. */
    @Test
    fun theDividerIsAFocusableChildHiddenWithoutASplit() {
        val layout = SplitPaneLayout(RuntimeEnvironment.getApplication())
        assertEquals(1, layout.childCount)
        val handle = layout.getChildAt(0)
        assertTrue(handle.isFocusable)
        assertEquals(View.GONE, handle.visibility)
        assertNull(handle.accessibilityNodeProvider)
    }
}
