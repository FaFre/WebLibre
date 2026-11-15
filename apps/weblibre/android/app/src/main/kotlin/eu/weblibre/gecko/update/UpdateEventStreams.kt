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
package eu.weblibre.gecko.update

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger

/**
 * The two event sinks, process-wide: an installer status broadcast can arrive
 * in a process whose engine was replaced, or that has none yet. Sending is
 * never delivering: an event sent while no Dart listener is attached is
 * dropped, and one that is sent may still be dropped by Dart. The journal
 * keeps every outcome until Dart acknowledges it, and Dart reconciles on
 * start and resume.
 *
 * Each engine registers its own handlers ([Registration]); a sink is cleared
 * only by the registration that set it, so a dying engine never clears the
 * sink of the engine that replaced it.
 *
 * Sinks are only touched on the main thread.
 */
object UpdateEventStreams {
    private val main = Handler(Looper.getMainLooper())

    private val installer = OwnedSink<InstallerStatusEvent>()
    private val play = OwnedSink<PlayInstallStateEvent>()

    /** A sink and the registration that set it. */
    private class OwnedSink<T> {
        private var sink: PigeonEventSink<T>? = null
        private var owner: Registration? = null

        fun listen(sink: PigeonEventSink<T>, owner: Registration) {
            this.sink = sink
            this.owner = owner
        }

        fun clearIfOwnedBy(owner: Registration) {
            if (this.owner !== owner) return
            sink = null
            this.owner = null
        }

        fun send(event: T) {
            sink?.success(event)
        }
    }

    /** One engine's handlers. */
    class Registration internal constructor() {
        internal val installerHandler = object : StreamInstallerEventsStreamHandler() {
            override fun onListen(p0: Any?, sink: PigeonEventSink<InstallerStatusEvent>) =
                installer.listen(sink, this@Registration)

            override fun onCancel(p0: Any?) = installer.clearIfOwnedBy(this@Registration)
        }

        internal val playHandler = object : StreamPlayEventsStreamHandler() {
            override fun onListen(p0: Any?, sink: PigeonEventSink<PlayInstallStateEvent>) =
                play.listen(sink, this@Registration)

            override fun onCancel(p0: Any?) = play.clearIfOwnedBy(this@Registration)
        }
    }

    /** At engine attachment, before Dart can listen. */
    fun register(messenger: BinaryMessenger): Registration {
        val registration = Registration()
        StreamInstallerEventsStreamHandler.register(messenger, registration.installerHandler)
        StreamPlayEventsStreamHandler.register(messenger, registration.playHandler)
        return registration
    }

    /** The engine is going: its sinks go with it, never another engine's. */
    fun unregister(registration: Registration) {
        main.post {
            installer.clearIfOwnedBy(registration)
            play.clearIfOwnedBy(registration)
        }
    }

    fun sendInstaller(event: InstallerStatusEvent) {
        main.post { installer.send(event) }
    }

    fun sendPlay(event: PlayInstallStateEvent) {
        main.post { play.send(event) }
    }
}
