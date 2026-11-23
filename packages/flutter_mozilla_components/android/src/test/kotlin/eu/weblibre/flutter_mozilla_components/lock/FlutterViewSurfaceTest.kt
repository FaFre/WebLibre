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
package eu.weblibre.flutter_mozilla_components.lock

import android.app.Activity
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import io.flutter.embedding.android.FlutterImageView
import io.flutter.embedding.android.FlutterSurfaceView
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import org.junit.After
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config

/** The browser window's Flutter view, as [BrowserLockCover] works with it. */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class FlutterViewSurfaceTest {
    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    /** Renders through a [FlutterSurfaceView], its default. */
    private val flutterView = FlutterView(activity)

    private val decor: ViewGroup

    init {
        activity.setContentView(FrameLayout(activity).apply { addView(flutterView) })
        decor = activity.window.decorView as ViewGroup
    }

    @After
    fun tearDown() {
        FlutterViewSurface.abandon()
    }

    @Test
    fun anImageViewAttachedToTheRendererIsAnImageFromBefore() {
        assertFalse(FlutterViewSurface.showsPreReturnImage(decor))

        val imageView = FlutterImageView(activity, 8, 8, FlutterImageView.SurfaceKind.background).apply {
            // What `attachToRenderer` leaves it at; a new one starts at 0.
            alpha = 1f
        }
        flutterView.addView(imageView)
        assertTrue(FlutterViewSurface.showsPreReturnImage(decor))

        // What `detachFromRenderer` does once the surface view shows its first frame.
        imageView.alpha = 0f
        assertFalse(FlutterViewSurface.showsPreReturnImage(decor))
    }

    @Test
    fun onlyTheSurfaceViewIsTakenAwayAndAbandoningBringsItBack() {
        assertTrue(FlutterViewSurface.takeAway(decor))

        assertEquals(View.GONE, surfaceView().visibility)
        assertEquals(View.VISIBLE, flutterView.visibility, "the Flutter view keeps focus and the keyboard")

        FlutterViewSurface.abandon()
        assertEquals(View.VISIBLE, surfaceView().visibility)
    }

    @Test
    fun theFirstFrameDrawnOnTheNewSurfaceIsReported() {
        FlutterViewSurface.takeAway(decor)
        // The renderer reports nothing displayed once the surface is released.
        assertTrue(FlutterViewSurface.isGone())

        var drawn = false
        FlutterViewSurface.bringBack { drawn = true }
        assertEquals(View.VISIBLE, surfaceView().visibility)
        assertFalse(drawn)

        // What the renderer tells the Flutter view once the engine has drawn
        // the first frame on the new surface.
        rendererListener().onFlutterUiDisplayed()
        shadowOf(Looper.getMainLooper()).idle()
        assertTrue(drawn)
    }

    @Test
    fun abandoningStopsWaitingForTheFrame() {
        FlutterViewSurface.takeAway(decor)
        var drawn = false
        FlutterViewSurface.bringBack { drawn = true }

        FlutterViewSurface.abandon()
        rendererListener().onFlutterUiDisplayed()
        shadowOf(Looper.getMainLooper()).idle()

        assertFalse(drawn)
    }

    @Test
    fun aWindowWithoutAFlutterViewHasNoSurfaceToTakeAway() {
        val other = Robolectric.buildActivity(Activity::class.java).setup().get()
        other.setContentView(FrameLayout(other))

        assertFalse(FlutterViewSurface.takeAway(other.window.decorView as ViewGroup))
    }

    private fun surfaceView(): View =
        (0 until flutterView.childCount).map(flutterView::getChildAt).first { it is FlutterSurfaceView }

    /** The listener the Flutter view registers with its engine's renderer. */
    private fun rendererListener(): FlutterUiDisplayListener =
        FlutterView::class.java.getDeclaredField("flutterUiDisplayListener").let {
            it.isAccessible = true
            it.get(flutterView) as FlutterUiDisplayListener
        }
}
