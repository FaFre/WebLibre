/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import android.os.Handler
import android.os.Looper
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.Components
import mozilla.components.support.webextensions.WebExtensionPopupObserver

/**
 * Runs the web extension toolbar feature and popup observer for as long as the
 * components exist (issue #542).
 *
 * Both used to be bound to `BaseBrowserFragment`, which only exists once a tab
 * has been painted. A start that stayed on the home surface therefore never
 * sent Dart a single browser/page action (the menu showed only "Manage
 * extensions"), and a popup Gecko opened was never handed to Dart. Worse, the
 * observer only saw such a popup once a tab was shown later, and opened it out
 * of context.
 *
 * Neither needs a view: the toolbar feature mirrors the store to Dart, and a
 * popup is rendered by `FlutterAddonPopupFragment` in its own platform view.
 * Clicking an action does need a tab Gecko considers active, which
 * [WebExtensionActionTarget] provides before every click; see [prepareForAction].
 */
object WebExtensionActionsHost {
    private var toolbarFeature: WebExtensionToolbarFeature? = null
    private var popupObserver: WebExtensionPopupObserver? = null
    private var actionTarget: WebExtensionActionTarget? = null

    /**
     * Called from `GlobalComponents.setUp` and `tearDown`, so the running
     * features always observe the current store and speak through the current
     * Pigeon channel: an external-to-full rebuild replaces both.
     *
     * Posted to the main thread when called off it (setUp runs on a binder
     * thread on the external path): the features call Pigeon, which must be on
     * the main thread. Each run reads the components at that moment, so
     * back-to-back teardown and setup still settle on the right set.
     */
    fun onComponentsChanged() {
        onMainThread {
            stop()
            GlobalComponents.components?.let(::start)
        }
    }

    private fun start(components: Components) {
        toolbarFeature = components.features.webExtensionToolbarFeature.also { it.start() }

        popupObserver = WebExtensionPopupObserver(
            store = components.core.store,
            onOpenPopup = { extension ->
                components.addonEvents.onWebExtensionPopupRequested(
                    extension.id,
                    extension.name ?: "",
                ) {}
            },
        ).also { it.start() }

        actionTarget = WebExtensionActionTarget(
            store = components.core.store,
            createBlankSession = { components.core.engine.createSession() },
        ).also { it.start() }
    }

    /**
     * Gives the next browser/page action click a tab to resolve against. Call on
     * the main thread, right before invoking the action.
     */
    suspend fun prepareForAction() {
        actionTarget?.prepare()
    }

    private fun stop() {
        toolbarFeature?.stop()
        toolbarFeature = null
        popupObserver?.stop()
        popupObserver = null
        actionTarget?.stop()
        actionTarget = null
    }

    private fun onMainThread(block: () -> Unit) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            block()
        } else {
            Handler(Looper.getMainLooper()).post { block() }
        }
    }
}
