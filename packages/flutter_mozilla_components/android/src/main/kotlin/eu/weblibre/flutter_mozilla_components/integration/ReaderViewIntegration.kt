/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.integration

import android.content.Context
import android.graphics.drawable.Drawable
import android.view.View
import androidx.core.content.ContextCompat
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.updatePadding
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.ext.EventSequence
import eu.weblibre.flutter_mozilla_components.api.ReaderViewEventsImpl
import eu.weblibre.flutter_mozilla_components.api.ReaderViewControllerListener
import eu.weblibre.flutter_mozilla_components.pigeons.ReaderViewController
import mozilla.components.browser.state.selector.selectedTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.Engine
import mozilla.components.feature.readerview.ReaderViewFeature
import mozilla.components.feature.readerview.view.ReaderViewControlsView
import mozilla.components.support.base.feature.LifecycleAwareFeature
import mozilla.components.support.base.feature.UserInteractionHandler

@Suppress("UndocumentedPublicClass")
class ReaderViewIntegration(
    context: Context,
    engine: Engine,
    store: BrowserStore,
    private val view: ReaderViewControlsView,
    private val readerViewEvents: ReaderViewEventsImpl,
    readerViewController: ReaderViewController
) : LifecycleAwareFeature, UserInteractionHandler {
    private var listenerRegistered = false

    // Re-applies the controls bar inset whenever the bottom chrome changes (tab
    // bar shown/hidden, stacking mode, etc.) while the controls are on screen.
    private val bottomInsetListener: (Int) -> Unit = {
        applyControlsBarBottomInset(onlyIfVisible = true)
    }

    private val controllerListener = object : ReaderViewControllerListener {
        override fun onReaderViewToggled(enabled: Boolean) {
            if (enabled) {
                feature.showReaderView()

                readerViewController.appearanceButtonVisibility(EventSequence.next(),true) { _ -> };
            } else {
                feature.hideReaderView()
                feature.hideControls()

                readerViewController.appearanceButtonVisibility(EventSequence.next(),false) { _ -> };
            }
        }

        override fun onAppearanceButtonTap() {
            // Toggle: tapping the appearance button while the controls are open
            // closes them again, as the user expects.
            if ((view as? View)?.visibility == View.VISIBLE) {
                feature.hideControls()
            } else {
                applyControlsBarBottomInset(onlyIfVisible = false)
                feature.showControls()
            }
        }
    }

    /**
     * Lifts the reader controls bar above the current bottom chrome (Flutter
     * bottom app bar + system navigation inset) instead of a hardcoded padding,
     * which under edge-to-edge left the bar overlapped by the bottom app bar.
     * [GlobalComponents.bottomViewportInsetPx] already includes the nav inset
     * when the toolbar is visible; fall back to the nav inset alone otherwise.
     *
     * @param onlyIfVisible when true, skips bars that aren't currently shown
     * (used by the live inset listener; the bar is re-padded when next shown).
     */
    private fun applyControlsBarBottomInset(onlyIfVisible: Boolean) {
        val barView = view as? View ?: return
        if (onlyIfVisible && barView.visibility != View.VISIBLE) return

        val navInset = ViewCompat.getRootWindowInsets(barView)
            ?.getInsets(WindowInsetsCompat.Type.navigationBars())?.bottom ?: 0
        barView.updatePadding(
            bottom = maxOf(GlobalComponents.bottomViewportInsetPx, navInset),
        )
    }

    private val feature = ReaderViewFeature(context, engine, store, view)
    // Will be event based in flutter
//    { available, active ->
//        readerViewButtonVisible = available
//        readerViewButton.setSelected(active)
//
//        if (active) readerViewAppearanceButton.show() else readerViewAppearanceButton.hide()
//        toolbar.invalidateActions()
//    }

    override fun start() {
        if (!listenerRegistered) {
            readerViewEvents.addListener(controllerListener)
            GlobalComponents.addBottomViewportInsetListener(bottomInsetListener)
            listenerRegistered = true
        }
        feature.start()
    }

    override fun stop() {
        if (listenerRegistered) {
            readerViewEvents.removeListener(controllerListener)
            GlobalComponents.removeBottomViewportInsetListener(bottomInsetListener)
            listenerRegistered = false
        }
        feature.stop()
    }

    override fun onBackPressed(): Boolean {
        return feature.onBackPressed()
    }
}
