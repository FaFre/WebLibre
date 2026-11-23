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
package eu.weblibre.flutter_mozilla_components.push

import kotlin.test.assertFalse
import kotlin.test.assertTrue
import org.junit.Test

class PrivatePushScopesTest {
    @Test
    fun `a scope of private browsing is private, alone or beside other attributes`() {
        assertTrue(PrivatePushScopes.isPrivate("http://localhost:8080/^privateBrowsingId=1"))
        assertTrue(PrivatePushScopes.isPrivate("https://site.example/app/^privateBrowsingId=1&userContextId=2"))
        assertTrue(PrivatePushScopes.isPrivate("https://site.example/^geckoViewUserContextId=gvctx64&privateBrowsingId=1"))
    }

    @Test
    fun `a scope without the attribute, or with its default, is not`() {
        assertFalse(PrivatePushScopes.isPrivate("http://localhost:8080/"))
        assertFalse(PrivatePushScopes.isPrivate("https://site.example/^geckoViewUserContextId=gvctx64"))
        assertFalse(PrivatePushScopes.isPrivate("https://site.example/^privateBrowsingId=0"))
        assertFalse(PrivatePushScopes.isPrivate("https://site.example/^privateBrowsingId="))
        assertFalse(PrivatePushScopes.isPrivate("https://site.example/^privateBrowsingIdX=1"))
    }

    @Test
    fun `a regular scope whose query reads as the attribute is taken for private`() {
        // The same string as the private scope of `https://site.example/sw/?x`:
        // GeckoView hands over nothing that tells them apart, so it is refused.
        assertTrue(PrivatePushScopes.isPrivate("https://site.example/sw/?x^privateBrowsingId=1"))
    }

    @Test
    fun `only the suffix after the last caret is read`() {
        assertFalse(PrivatePushScopes.isPrivate("https://site.example/^privateBrowsingId=1/^userContextId=2"))
    }
}
