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

import android.content.Context
import android.content.pm.ApplicationInfo
import androidx.annotation.VisibleForTesting
import java.util.concurrent.atomic.AtomicBoolean
import mozilla.components.support.base.log.Log
import mozilla.components.support.base.log.sink.AndroidLogSink
import mozilla.components.support.base.log.sink.LogSink

/**
 * The one sink AC's `Log` has in this process. Lines go to logcat until a
 * Flutter engine takes them ([attach]), and go back to logcat once it detaches.
 *
 * `Log` cannot remove a sink, which is why there is only this one. The Dart sink
 * used to be added when Gecko initialized, and that had two problems:
 * - Nothing received the lines logged before Gecko initialized: the startup
 *   arbiter's, the push migration's, and every line of a start that has no
 *   Flutter engine, such as a headless push delivery.
 * - Every engine that initialized Gecko added another sink. The old ones kept
 *   delivering to messengers that had detached.
 *
 * What reaches logcat while no engine holds the lines depends on the build:
 * - A debuggable build writes every line.
 * - A release build writes only the lines of [RELEASE_LOGCAT_TAGS], without
 *   debug lines and without exception messages or stack traces. The rest of
 *   the browser's lines carry URLs. The app-link interceptor, for one, logs
 *   every load's URL and the previous one at info level. Those lines go
 *   nowhere until Dart takes them, as before this sink existed.
 *
 * The sink itself stays inside this module: the app only calls [install], and
 * does not have mozilla-components' log classes on its classpath.
 */
object ProcessLogSink {
    /**
     * The `Logger` tags a release build writes to logcat while no engine holds
     * the lines. A tag goes on this list only after all of its messages have been
     * checked to name nothing a page or the user supplied: no URL, host, title or
     * typed text. Exception messages can quote anything, so they never go out.
     *
     * - `StartupArbiter`: profile, lease and request ids, startup states and the
     *   arbiter's own reason strings.
     */
    @VisibleForTesting
    internal val RELEASE_LOGCAT_TAGS = setOf("StartupArbiter")

    private class Holder(val owner: Any, val sink: LogSink)

    private val installed = AtomicBoolean(false)
    private val logcat = AndroidLogSink()

    @Volatile
    private var debuggable = false

    @Volatile
    private var holder: Holder? = null

    @VisibleForTesting
    internal val sink: LogSink = object : LogSink {
        override fun log(
            priority: Log.Priority,
            tag: String?,
            throwable: Throwable?,
            message: String,
        ) {
            val current = holder
            when {
                current != null -> current.sink.log(priority, tag, throwable, message)
                debuggable -> logcat.log(priority, tag, throwable, message)
                priority == Log.Priority.DEBUG || tag !in RELEASE_LOGCAT_TAGS -> Unit
                throwable == null -> logcat.log(priority, tag, null, message)
                else -> logcat.log(priority, tag, null, "$message (${throwable.javaClass.name})")
            }
        }
    }

    /** Adds the sink to `Log`, once per process. */
    fun install(context: Context) {
        if (!installed.compareAndSet(false, true)) return
        debuggable = context.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE != 0
        Log.addSink(sink)
    }

    /** Test seam: what a debuggable or a release build writes to logcat. */
    @VisibleForTesting
    internal fun setDebuggableForTesting(value: Boolean) {
        debuggable = value
    }

    /** Sends the lines to [sink] until [owner] detaches. It replaces any earlier owner. */
    @Synchronized
    internal fun attach(owner: Any, sink: LogSink) {
        holder = Holder(owner, sink)
    }

    /** Sends the lines back to logcat, unless another owner has attached since [owner] did. */
    @Synchronized
    internal fun detach(owner: Any) {
        if (holder?.owner === owner) holder = null
    }
}
