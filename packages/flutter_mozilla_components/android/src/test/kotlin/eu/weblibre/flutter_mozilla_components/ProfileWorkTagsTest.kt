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

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals

class ProfileWorkTagsTest {
    private val uuid = "0199a0b1-1111-7111-8111-111111111111"

    @Test
    fun `a profile path and its uuid produce the same tag`() {
        // The enqueue side only has the relative path and the delete side only has
        // the uuid. If these disagreed, every job would be tagged with something
        // the participant never asks for — which looks exactly like no tag at all.
        assertEquals(
            ProfileWorkTags.forProfile(uuid),
            ProfileWorkTags.forRelativePath("weblibre_profiles/profile-$uuid"),
        )
    }

    @Test
    fun `case does not change ownership`() {
        assertEquals(
            ProfileWorkTags.forProfile(uuid),
            ProfileWorkTags.forProfile(uuid.uppercase()),
        )
        assertEquals(
            ProfileWorkTags.forProfile(uuid),
            ProfileWorkTags.forRelativePath("weblibre_profiles/profile-${uuid.uppercase()}"),
        )
    }

    @Test
    fun `different profiles never share a tag`() {
        assertNotEquals(
            ProfileWorkTags.forProfile(uuid),
            ProfileWorkTags.forProfile("0199a0b1-2222-7222-8222-222222222222"),
        )
    }

    @Test
    fun `an unrecognised path still gets a distinct tag`() {
        // Mistagged work is findable and fixable; untagged work is invisible to
        // every query WorkManager offers, so falling back to nothing is not an
        // option here.
        val tag = ProfileWorkTags.forRelativePath("legacy/default")
        assertNotEquals("", tag)
        assertNotEquals(ProfileWorkTags.forProfile(uuid), tag)
    }
}
