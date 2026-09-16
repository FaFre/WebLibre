/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import kotlin.test.assertFalse
import kotlin.test.assertTrue
import org.junit.Test

class FragmentHealthTest {
    private fun collapsed(
        view: Pair<Int, Int>,
        container: Pair<Int, Int>,
        layoutPending: Boolean = false,
    ) = isCollapsedWithoutCause(
        viewWidth = view.first,
        viewHeight = view.second,
        containerWidth = container.first,
        containerHeight = container.second,
        layoutPending = layoutPending,
    )

    @Test
    fun `a laid-out view is healthy`() {
        assertFalse(collapsed(view = 1080 to 2000, container = 1080 to 2000))
    }

    @Test
    fun `a zero view in a sized container is corrupted`() {
        // What the check was introduced for: the container has room and the
        // fragment's view is not using it.
        assertTrue(collapsed(view = 0 to 0, container = 1080 to 2000))
        assertTrue(collapsed(view = 1080 to 0, container = 1080 to 2000))
    }

    @Test
    fun `a zero view in a zero container is not corrupted`() {
        // Freeform minimise, or a platform view between layouts mid-resize.
        assertFalse(collapsed(view = 0 to 0, container = 0 to 0))
        assertFalse(collapsed(view = 0 to 0, container = 1080 to 0))
    }

    @Test
    fun `a zero view waiting on layout is not corrupted`() {
        // The container just grew; the child's layout pass has not run yet.
        assertFalse(collapsed(view = 0 to 0, container = 1080 to 2000, layoutPending = true))
    }
}
