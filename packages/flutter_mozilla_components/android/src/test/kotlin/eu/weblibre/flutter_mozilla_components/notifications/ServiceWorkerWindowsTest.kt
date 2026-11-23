/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.notifications

import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import mozilla.components.concept.engine.EngineSession
import org.mockito.Mockito.mock

class ServiceWorkerWindowsTest {
    @Test
    fun `a marked session's tab is a service worker's window, once`() {
        val session = mock(EngineSession::class.java)
        ServiceWorkerWindows.mark(session)

        assertTrue(ServiceWorkerWindows.take(session))
        assertFalse(ServiceWorkerWindows.take(session))
    }

    @Test
    fun `another session's tab is not`() {
        ServiceWorkerWindows.mark(mock(EngineSession::class.java))

        assertFalse(ServiceWorkerWindows.take(mock(EngineSession::class.java)))
    }

    @Test
    fun `a tab with no engine session is not`() {
        assertFalse(ServiceWorkerWindows.take(null))
    }
}
