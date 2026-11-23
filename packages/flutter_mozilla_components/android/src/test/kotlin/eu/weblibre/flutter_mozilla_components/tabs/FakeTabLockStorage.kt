/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.tabs

/** A lock storage whose writes can be made to fail, standing in for a full disk. */
internal class FakeTabLockStorage(var persisted: Set<String> = emptySet()) : TabCloseProtection.Storage {
    var failWrites = false

    override fun read(): Set<String> = persisted

    override fun write(tabIds: Set<String>): Boolean {
        if (failWrites) return false
        persisted = tabIds
        return true
    }
}
