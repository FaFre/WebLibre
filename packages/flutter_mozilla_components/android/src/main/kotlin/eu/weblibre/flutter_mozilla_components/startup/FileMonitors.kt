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

/**
 * Monitors keyed by the file they guard.
 *
 * The stores in this package are constructed wherever they are needed — a fresh
 * instance per call — so `@Synchronized` on their methods locks an object nothing
 * else shares, and two read-modify-write cycles interleave freely. The atomic
 * rename underneath keeps readers from seeing a torn file, but it cannot stop the
 * second writer from overwriting what the first one computed: a queued launch is
 * lost, or an acknowledged one comes back.
 *
 * A monitor therefore has to belong to the *file*, not to whoever happened to open
 * it. Keyed by path rather than being a single global lock so that a test pointing
 * two stores at two temporary directories still runs unserialised.
 *
 * Only within this process. A second process is excluded by the arbiter, and a
 * second Dart isolate by the profile-access lease.
 */
internal object FileMonitors {
    private val monitors = HashMap<String, Any>()

    fun forPath(path: String): Any = synchronized(monitors) {
        monitors.getOrPut(path) { Any() }
    }
}
