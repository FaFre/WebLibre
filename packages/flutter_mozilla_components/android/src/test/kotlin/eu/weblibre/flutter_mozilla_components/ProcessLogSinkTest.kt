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

import mozilla.components.support.base.log.Log
import mozilla.components.support.base.log.sink.LogSink
import org.json.JSONException
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.shadows.ShadowLog

/** Where mozilla-components' log lines go before, during and after a Flutter engine. */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [33])
class ProcessLogSinkTest {
    private val first = RecordingSink()
    private val second = RecordingSink()

    @Before
    fun setUp() {
        ShadowLog.clear()
        ProcessLogSink.setDebuggableForTesting(true)
    }

    @After
    fun tearDown() {
        ProcessLogSink.detach(first)
        ProcessLogSink.detach(second)
        ProcessLogSink.setDebuggableForTesting(false)
    }

    @Test
    fun `a debuggable build writes every line while no engine holds them`() {
        log(Log.Priority.DEBUG, "WebLibreAppLinks", "uri=https://example.org/?q=secret")
        log(Log.Priority.WARN, "StartupArbiter", "Reserving maintenance")

        assertEquals(
            listOf(
                "WebLibreAppLinks: uri=https://example.org/?q=secret",
                "StartupArbiter: Reserving maintenance",
            ),
            logcat(),
        )
    }

    @Test
    fun `a release build writes the audited tags only`() {
        ProcessLogSink.setDebuggableForTesting(false)

        // The app-link interceptor's line at info, with a full URL in it.
        log(Log.Priority.INFO, "WebLibreAppLinks", "onLoadRequest uri=https://example.org/?q=secret")
        log(Log.Priority.ERROR, "GeckoPwaApiImpl", "Failed to persist PWA launch token for https://example.org/")
        log(Log.Priority.INFO, "StartupArbiter", "Committed profile 0191 (launcher)")

        assertEquals(listOf("StartupArbiter: Committed profile 0191 (launcher)"), logcat())
    }

    @Test
    fun `a release build drops debug lines and exception messages, even for an audited tag`() {
        ProcessLogSink.setDebuggableForTesting(false)
        val error = JSONException("Unterminated string at 12 of {\"url\":\"https://example.org/")

        log(Log.Priority.DEBUG, "StartupArbiter", "Selection released: picker closed")
        ProcessLogSink.sink.log(Log.Priority.ERROR, "StartupArbiter", error, "Profile commitment callback failed")

        assertEquals(
            listOf("StartupArbiter: Profile commitment callback failed (org.json.JSONException)"),
            logcat(),
        )
    }

    @Test
    fun `an attached engine takes every line instead of logcat, in a release build too`() {
        ProcessLogSink.setDebuggableForTesting(false)
        ProcessLogSink.attach(first, first)
        log(Log.Priority.INFO, "Push", "Committed")

        assertEquals(listOf("Push: Committed"), first.lines)
        assertEquals(emptyList<String>(), logcat())
    }

    @Test
    fun `a later engine replaces the earlier one, and the earlier one's detach changes nothing`() {
        ProcessLogSink.attach(first, first)
        ProcessLogSink.attach(second, second)
        ProcessLogSink.detach(first)
        log(Log.Priority.INFO, "Push", "Committed")

        assertEquals(emptyList<String>(), first.lines)
        assertEquals(listOf("Push: Committed"), second.lines)
    }

    @Test
    fun `lines go back to logcat once the engine detaches`() {
        ProcessLogSink.attach(first, first)
        ProcessLogSink.detach(first)
        log(Log.Priority.ERROR, "Push", "Lost")

        assertEquals(emptyList<String>(), first.lines)
        assertEquals(listOf("Push: Lost"), logcat())
    }

    private fun log(priority: Log.Priority, tag: String, message: String) =
        ProcessLogSink.sink.log(priority, tag, null, message)

    private fun logcat(): List<String> = ShadowLog.getLogs().map { "${it.tag}: ${it.msg}" }

    private class RecordingSink : LogSink {
        val lines = mutableListOf<String>()

        override fun log(
            priority: Log.Priority,
            tag: String?,
            throwable: Throwable?,
            message: String,
        ) {
            lines += "$tag: $message"
        }
    }
}
