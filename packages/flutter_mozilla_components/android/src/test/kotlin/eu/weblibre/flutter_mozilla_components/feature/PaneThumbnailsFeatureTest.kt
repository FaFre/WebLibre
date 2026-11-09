/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import android.graphics.Bitmap
import eu.weblibre.flutter_mozilla_components.split.BrowserPanes
import kotlin.test.assertEquals
import kotlin.test.assertSame
import kotlinx.coroutines.Dispatchers
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.createTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.EngineView
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.ArgumentCaptor
import org.mockito.Mockito
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [28])
class PaneThumbnailsFeatureTest {
    private class Panes(private val views: Map<String, EngineView>) : BrowserPanes {
        override val focusedEngineView: EngineView? = null
        override val allEngineViews: List<EngineView> = views.values.toList()
        override val visibleTabIds: Set<String> = views.keys
        override val lastPresentedTabIds: Set<String> = views.keys
        override fun engineViewFor(tabId: String): EngineView? = views[tabId]
        override fun isDividerHitOnScreen(rawX: Float, rawY: Float) = false
        override fun reconcileNow() = Unit
    }

    /**
     * The capture of `a` returns after focus moved to `b`: the bitmap is
     * `a`'s page, taken from `a`'s pane, and must be stored for `a`.
     */
    @Test
    fun theBitmapIsStoredForTheTabItWasTakenFrom() {
        // Thumbnails are stored by a middleware; this one records them.
        val stored = mutableListOf<ContentAction.UpdateThumbnailAction>()
        val store = BrowserStore(
            initialState = BrowserState(
                tabs = listOf(
                    createTab("https://a.example", id = "a"),
                    createTab("https://b.example", id = "b"),
                ),
                selectedTabId = "a",
            ),
            middleware = listOf { _, next, action ->
                if (action is ContentAction.UpdateThumbnailAction) {
                    stored += action
                } else {
                    next(action)
                }
            },
        )
        val viewA = Mockito.mock(EngineView::class.java)
        val viewB = Mockito.mock(EngineView::class.java)
        val feature = PaneThumbnailsFeature(
            context = RuntimeEnvironment.getApplication(),
            panes = { Panes(mapOf("a" to viewA, "b" to viewB)) },
            store = store,
            dispatcher = Dispatchers.Unconfined,
        )
        feature.start()

        store.dispatch(ContentAction.UpdateFirstContentfulPaintStateAction("a", true))
        store.dispatch(ContentAction.UpdateLoadingStateAction("a", false))

        @Suppress("UNCHECKED_CAST")
        val callback = ArgumentCaptor.forClass(Function1::class.java)
            as ArgumentCaptor<(Bitmap?) -> Unit>
        Mockito.verify(viewA).captureThumbnail(callback.capture() ?: { _ -> })
        Mockito.verifyNoInteractions(viewB)

        store.dispatch(TabListAction.SelectTabAction("b"))
        val bitmap = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888)
        callback.value(bitmap)

        assertEquals(listOf("a"), stored.map { it.sessionId })
        assertSame(bitmap, stored.single().thumbnail)
        feature.stop()
    }
}
