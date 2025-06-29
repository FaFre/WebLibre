/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.pigeons.ReaderViewEvents

// Interface for the listener
interface ReaderViewControllerListener {
    fun onReaderViewToggled(enabled: Boolean)
    fun onAppearanceButtonTap()
}

class ReaderViewEventsImpl : ReaderViewEvents {

    private val listeners = mutableSetOf<ReaderViewControllerListener>()

    override fun onToggleReaderView(enable: Boolean) {
        listeners.forEach { it.onReaderViewToggled(enable) }
    }

    override fun onAppearanceButtonTap() {
        listeners.forEach { it.onAppearanceButtonTap() }
    }

    // Method to add a listener
    fun addListener(listener: ReaderViewControllerListener) {
        listeners.add(listener)
    }

    // Method to remove a listener
    fun removeListener(listener: ReaderViewControllerListener) {
        listeners.remove(listener)
    }
}
