/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.split

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

class BindingPlanTest {
    @Test
    fun singleToPairKeepsTheShownTabAndBindsThePartner() {
        assertEquals(listOf("a", "b"), planBindings(listOf("a", null), listOf("a", "b")))
    }

    @Test
    fun pairWhoseFirstSlotWasNotShownStillKeepsTheShownTabInPlace() {
        // b is the first slot, but a stays on pane 0: slots are a layout
        // concern, panes never trade sessions for them.
        assertEquals(listOf("a", "b"), planBindings(listOf("a", null), listOf("b", "a")))
    }

    @Test
    fun pairToUnrelatedTabFreesBothPanes() {
        assertEquals(listOf("x", null), planBindings(listOf("a", "b"), listOf("x")))
    }

    @Test
    fun swapChangesNoBinding() {
        assertEquals(listOf("a", "b"), planBindings(listOf("a", "b"), listOf("b", "a")))
    }

    @Test
    fun pairReplacedByAPairSharingOneTabKeepsThatTab() {
        assertEquals(listOf("c", "b"), planBindings(listOf("a", "b"), listOf("b", "c")))
    }

    @Test
    fun memberShownAloneStaysOnItsPane() {
        assertEquals(listOf(null, "b"), planBindings(listOf("a", "b"), listOf("b")))
    }

    @Test
    fun aTabIsNeverBoundTwice() {
        assertEquals(listOf("a", null), planBindings(listOf("a", null), listOf("a", "a")))
        assertEquals(listOf("a", null), planBindings(listOf("a", "a"), listOf("a")))
    }

    @Test
    fun moreTargetsThanPanesIsRejected() {
        assertFailsWith<IllegalArgumentException> {
            planBindings(listOf("a"), listOf("a", "b"))
        }
    }
}
