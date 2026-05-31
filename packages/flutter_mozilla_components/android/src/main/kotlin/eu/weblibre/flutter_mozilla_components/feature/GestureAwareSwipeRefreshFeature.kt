/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.feature

import android.os.Build
import android.view.HapticFeedbackConstants
import android.view.View
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.map
import mozilla.components.browser.state.action.ContentAction.UpdateRefreshCanceledStateAction
import mozilla.components.browser.state.selector.findTabOrCustomTabOrSelectedTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.EngineView
import mozilla.components.feature.session.SessionUseCases
import mozilla.components.lib.state.ext.flowScoped
import mozilla.components.support.base.feature.LifecycleAwareFeature
import mozilla.components.support.ktx.kotlinx.coroutines.flow.ifAnyChanged

/**
 * A gesture-aware variant of Mozilla's `SwipeRefreshFeature`.
 *
 * Behaves exactly like the upstream feature (coordinates a [SwipeRefreshLayout]
 * with the session's loading state and reloads on a pull-down at the top of the
 * page), with one addition: if the same touch sequence was recognized as a
 * configured touch gesture, the reload is suppressed.
 *
 * Why: the gesture recognizer in `BackGestureFilterFrameLayout` is purely
 * observational (it never consumes events), so a down-leading gesture — e.g.
 * `D-R` (back) or `D-R-U` (reload) — that starts at the top of the page also
 * drives the pull-to-refresh throbber and would otherwise fire a redundant
 * reload on release. This mirrors the reference add-on's pull-to-refresh
 * `continue()`/`end()` guards, which let pull-to-refresh act only as the
 * fallback for a plain straight-down pull that matches no gesture.
 *
 * The recognizer flags [GlobalComponents.touchConsumedByGesture] on the
 * terminating ACTION_UP (which dispatches to the ancestor container before this
 * layout's own up-handling runs [onRefresh]), so the flag is reliably set by the
 * time we consult it here.
 *
 * Derived from android-components `SwipeRefreshFeature` (MPL-2.0).
 */
class GestureAwareSwipeRefreshFeature(
    private val store: BrowserStore,
    private val reloadUrlUseCase: SessionUseCases.ReloadUrlUseCase,
    private val swipeRefreshLayout: SwipeRefreshLayout,
    private val tabId: String? = null,
    private val mainDispatcher: CoroutineDispatcher = Dispatchers.Main,
) : LifecycleAwareFeature,
    SwipeRefreshLayout.OnChildScrollUpCallback,
    SwipeRefreshLayout.OnRefreshListener {
    private var scope: CoroutineScope? = null

    init {
        swipeRefreshLayout.setOnRefreshListener(this)
        swipeRefreshLayout.setOnChildScrollUpCallback(this)
    }

    override fun start() {
        scope = store.flowScoped(dispatcher = mainDispatcher) { flow ->
            flow.map { state -> state.findTabOrCustomTabOrSelectedTab(tabId) }
                .ifAnyChanged {
                    arrayOf(it?.content?.loading, it?.content?.refreshCanceled)
                }
                .collect { tab ->
                    tab?.let {
                        if (!tab.content.loading || tab.content.refreshCanceled) {
                            swipeRefreshLayout.isRefreshing = false
                            if (tab.content.refreshCanceled) {
                                store.dispatch(UpdateRefreshCanceledStateAction(tab.id, false))
                            }
                        }
                    }
                }
        }
    }

    override fun stop() {
        scope?.cancel()
    }

    @Suppress("Deprecation")
    override fun canChildScrollUp(parent: SwipeRefreshLayout, child: View?) =
        if (child is EngineView) {
            !child.getInputResultDetail().canOverscrollTop()
        } else {
            true
        }

    override fun onRefresh() {
        // A configured touch gesture already handled this stroke; don't also
        // reload. Retract the throbber the layout showed during the pull.
        if (GlobalComponents.touchConsumedByGesture) {
            swipeRefreshLayout.isRefreshing = false
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            swipeRefreshLayout.performHapticFeedback(HapticFeedbackConstants.CONFIRM)
        }
        store.state.findTabOrCustomTabOrSelectedTab(tabId)?.let { tab ->
            reloadUrlUseCase(tab.id)
        }
    }
}
