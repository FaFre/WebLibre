/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.widget

import android.view.Window
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import mozilla.components.browser.state.selector.findCustomTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.support.base.feature.LifecycleAwareFeature
import mozilla.components.support.base.feature.UserInteractionHandler

/**
 * Feature that connects [CustomTabToolbar] to browser state.
 * Handles lifecycle, state observation, and window color updates.
 */
class CustomTabToolbarFeature(
    private val store: BrowserStore,
    private val toolbar: CustomTabToolbar,
    private val sessionId: String,
    private val window: Window
) : LifecycleAwareFeature, DefaultLifecycleObserver, UserInteractionHandler {

    override fun start() {
        val tab = store.state.findCustomTab(sessionId) ?: return

        val toolbarColor = tab.config.colorSchemes?.defaultColorSchemeParams?.toolbarColor

        toolbar.bind(sessionId, store, toolbarColor)

        toolbarColor?.let { color ->
            window.statusBarColor = color
            window.navigationBarColor = color
        }
    }

    override fun stop() {
        toolbar.unbind()
    }

    override fun onDestroy(owner: LifecycleOwner) {
        stop()
        super<DefaultLifecycleObserver>.onDestroy(owner)
    }

    override fun onBackPressed(): Boolean = false
}
