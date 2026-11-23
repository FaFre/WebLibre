/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.notifications

import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

class GeckoPostingsTest {
    @BeforeTest
    fun setUp() = GeckoPostings.resetForTest()

    @AfterTest
    fun tearDown() = GeckoPostings.resetForTest()

    @Test
    fun `a tag never shown in this process is not known`() {
        assertNull(GeckoPostings.holds("chat", "posting-1"))
    }

    @Test
    fun `the posting shown last under a tag is the one Gecko holds`() {
        GeckoPostings.shown("chat", "posting-1")
        GeckoPostings.shown("chat", "posting-2")

        assertEquals(false, GeckoPostings.holds("chat", "posting-1"))
        assertEquals(true, GeckoPostings.holds("chat", "posting-2"))
    }

    @Test
    fun `tags are their own`() {
        GeckoPostings.shown("chat", "posting-1")
        GeckoPostings.shown("mail", "posting-2")

        assertEquals(true, GeckoPostings.holds("chat", "posting-1"))
    }

    @Test
    fun `only the current posting is published`() {
        GeckoPostings.shown("chat", "posting-1")
        GeckoPostings.shown("chat", "posting-2")
        val published = mutableListOf<String>()

        assertEquals(false, GeckoPostings.publishIfCurrent("chat", "posting-1") { published += "posting-1" })
        assertEquals(true, GeckoPostings.publishIfCurrent("chat", "posting-2") { published += "posting-2" })
        assertEquals(listOf("posting-2"), published)
    }

    @Test
    fun `a posting that could not be shown is withdrawn while it is current`() {
        GeckoPostings.shown("chat", "posting-1")
        var cancelled = 0

        assertEquals(true, GeckoPostings.withdraw("chat", "posting-1") { cancelled++ })

        assertEquals(1, cancelled)
        assertNull(GeckoPostings.holds("chat", "posting-1"))
    }

    @Test
    fun `withdrawing a replaced posting leaves the replacement`() {
        GeckoPostings.shown("chat", "posting-1")
        GeckoPostings.shown("chat", "posting-2")
        var cancelled = 0

        assertEquals(false, GeckoPostings.withdraw("chat", "posting-1") { cancelled++ })

        assertEquals(0, cancelled)
        assertEquals(true, GeckoPostings.holds("chat", "posting-2"))
    }

    @Test
    fun `a closed tag is forgotten`() {
        GeckoPostings.shown("chat", "posting-1")
        GeckoPostings.closed("chat")

        assertNull(GeckoPostings.holds("chat", "posting-1"))
    }
}
