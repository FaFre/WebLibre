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
package eu.weblibre.flutter_mozilla_components.feature

import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertSame
import mozilla.components.concept.engine.CancellableOperation
import mozilla.components.concept.engine.webextension.MessageHandler
import mozilla.components.concept.engine.webextension.WebExtension
import mozilla.components.concept.engine.webextension.WebExtensionRuntime
import mozilla.components.support.webextensions.BuiltInWebExtensionController
import org.mockito.Mockito.mock
import org.mockito.Mockito.never
import org.mockito.Mockito.verify

/**
 * A second engine installing a built-in extension while the first engine's
 * install is still running: the UI start rebuilding a headless push start's
 * components (device test D2, where the proxy extension lost its port).
 */
class BuiltInExtensionInstallsTest {
    private val runtime = PendingRuntime()
    private val controller = BuiltInWebExtensionController(ID, "resource://test/", PORT)

    @BeforeTest
    fun setUp() {
        BuiltInExtensionInstalls.resetForTesting()
        BuiltInWebExtensionController.installedBuiltInExtensions.clear()
    }

    @AfterTest
    fun tearDown() {
        BuiltInExtensionInstalls.resetForTesting()
        BuiltInWebExtensionController.installedBuiltInExtensions.clear()
    }

    @Test
    fun `an install while one is running gets the same wrapper and no second engine install`() {
        val extension = mock(WebExtension::class.java)
        val delivered = mutableListOf<WebExtension>()

        BuiltInExtensionInstalls.install(ID, controller, runtime, onSuccess = { delivered += it })
        BuiltInExtensionInstalls.install(ID, controller, runtime, onSuccess = { delivered += it })
        assertEquals(1, runtime.pending.size, "the second install must wait for the first")

        runtime.succeed(0, extension)

        assertEquals(1, runtime.pending.size)
        assertEquals(2, delivered.size)
        delivered.forEach { assertSame(extension, it) }
    }

    @Test
    fun `the port handler is the newest one registered, on the one wrapper`() {
        val extension = mock(WebExtension::class.java)
        val headless = object : MessageHandler {}
        val full = object : MessageHandler {}

        controller.registerBackgroundMessageHandler(headless)
        BuiltInExtensionInstalls.install(ID, controller, runtime)
        controller.registerBackgroundMessageHandler(full)
        BuiltInExtensionInstalls.install(ID, controller, runtime)

        runtime.succeed(0, extension)

        verify(extension).registerBackgroundMessageHandler(PORT, full)
        verify(extension, never()).registerBackgroundMessageHandler(PORT, headless)
    }

    @Test
    fun `a waiting install tries on its own when the running one fails`() {
        val extension = mock(WebExtension::class.java)
        val errors = mutableListOf<Throwable>()
        val delivered = mutableListOf<WebExtension>()

        BuiltInExtensionInstalls.install(ID, controller, runtime, onError = { errors += it })
        BuiltInExtensionInstalls.install(ID, controller, runtime, onSuccess = { delivered += it })

        runtime.fail(0, IllegalStateException("engine refused"))
        assertEquals(1, errors.size)
        assertEquals(2, runtime.pending.size, "the waiting install asks the engine itself")

        runtime.succeed(1, extension)
        assertEquals(listOf(extension), delivered)
    }

    @Test
    fun `a waiting call whose callback throws does not keep the next one from its answer`() {
        val extension = mock(WebExtension::class.java)
        val delivered = mutableListOf<String>()

        BuiltInExtensionInstalls.install(ID, controller, runtime, onSuccess = { delivered += "first" })
        BuiltInExtensionInstalls.install(ID, controller, runtime, onSuccess = { error("second failed") })
        BuiltInExtensionInstalls.install(ID, controller, runtime, onSuccess = { delivered += "third" })

        val thrown = assertFailsWith<IllegalStateException> { runtime.succeed(0, extension) }

        assertEquals("second failed", thrown.message)
        assertEquals(listOf("first", "third"), delivered)
        assertEquals(1, runtime.pending.size)
    }

    @Test
    fun `the running install's throwing callback still answers the waiting calls`() {
        val extension = mock(WebExtension::class.java)
        val delivered = mutableListOf<WebExtension>()

        BuiltInExtensionInstalls.install(ID, controller, runtime, onSuccess = { error("first failed") })
        BuiltInExtensionInstalls.install(ID, controller, runtime, onSuccess = { delivered += it })

        assertFailsWith<IllegalStateException> { runtime.succeed(0, extension) }

        assertEquals(listOf(extension), delivered)

        // Nothing is left waiting: a later install is answered at once.
        BuiltInExtensionInstalls.install(ID, controller, runtime, onSuccess = { delivered += it })
        assertEquals(listOf(extension, extension), delivered)
    }

    @Test
    fun `an install after one finished is answered from the registry`() {
        val extension = mock(WebExtension::class.java)
        val delivered = mutableListOf<WebExtension>()

        BuiltInExtensionInstalls.install(ID, controller, runtime)
        runtime.succeed(0, extension)
        BuiltInExtensionInstalls.install(ID, controller, runtime, onSuccess = { delivered += it })

        assertEquals(1, runtime.pending.size)
        assertEquals(listOf(extension), delivered)
    }

    @Test
    fun `different extensions install side by side`() {
        BuiltInExtensionInstalls.install(ID, controller, runtime)
        BuiltInExtensionInstalls.install(
            OTHER_ID,
            BuiltInWebExtensionController(OTHER_ID, "resource://other/", PORT),
            runtime,
        )

        assertEquals(2, runtime.pending.size)
    }

    /** Answers no install until the test says so. */
    private class PendingRuntime : WebExtensionRuntime {
        val pending = mutableListOf<Pair<(WebExtension) -> Unit, (Throwable) -> Unit>>()

        override fun installBuiltInWebExtension(
            id: String,
            url: String,
            onSuccess: (WebExtension) -> Unit,
            onError: (Throwable) -> Unit,
        ): CancellableOperation {
            pending += onSuccess to onError
            return CancellableOperation.Noop()
        }

        fun succeed(index: Int, extension: WebExtension) = pending[index].first(extension)

        fun fail(index: Int, error: Throwable) = pending[index].second(error)
    }

    private companion object {
        const val ID = "test@weblibre.eu"
        const val OTHER_ID = "other@weblibre.eu"
        const val PORT = "testPort"
    }
}
