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
package eu.weblibre.flutter_mozilla_components.startup

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

class Iso8601Test {
    @Test
    fun writesThreeFractionalDigitsLikeDart() {
        assertEquals("1970-01-01T00:00:00.000Z", Iso8601.format(0))
        assertEquals("2026-11-14T10:30:05.007Z", Iso8601.format(1_794_652_205_007))
    }

    @Test
    fun readsEveryFormDartWrites() {
        assertEquals(1_794_652_205_007, Iso8601.parse("2026-11-14T10:30:05.007Z"))
        assertEquals(1_794_652_205_007, Iso8601.parse("2026-11-14T10:30:05.007999Z"))
        assertEquals(1_794_652_205_000, Iso8601.parse("2026-11-14T10:30:05Z"))
    }

    @Test
    fun anythingElseIsNull() {
        assertNull(Iso8601.parse(null))
        assertNull(Iso8601.parse(""))
        assertNull(Iso8601.parse("2026-02-30T00:00:00.000Z"))
        assertNull(Iso8601.parse("yesterday"))
    }
}
