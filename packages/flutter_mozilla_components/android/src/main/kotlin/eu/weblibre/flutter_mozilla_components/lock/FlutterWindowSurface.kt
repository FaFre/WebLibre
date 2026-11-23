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

import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import io.flutter.embedding.android.FlutterImageView
import io.flutter.embedding.android.FlutterSurfaceView
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener
import java.lang.ref.WeakReference

/**
 * What [BrowserLockCover] needs from Flutter's view in the browser window to
 * know that a frame drawn after the lock decision is on screen.
 *
 * Flutter reports no frame as presented on Android, with one exception: the
 * first frame drawn on a newly created surface (`onFlutterUiDisplayed`, from
 * the engine's next-frame callback, which fires only once a frame was drawn,
 * never for one it discarded). So the cover has Flutter draw on a new surface
 * and waits for that.
 */
internal interface FlutterWindowSurface {
    /**
     * Whether Flutter shows an image it rendered before the window left.
     *
     * While a page was open, Flutter rendered through an image view (hybrid
     * composition). A frame without the page reverts to its surface view
     * without passing through that image view, which keeps the frame from
     * before leaving until Flutter drops it (`PlatformViewsController.onEndFrame`,
     * `FlutterView.revertImageView`).
     */
    fun showsPreReturnImage(decor: ViewGroup): Boolean

    /**
     * Takes Flutter's surface away, so the next one is new. False when there
     * is no Flutter surface in [decor], hence nothing of Flutter's to wait for.
     */
    fun takeAway(decor: ViewGroup): Boolean

    /** Whether the surface [takeAway] took is gone. */
    fun isGone(): Boolean

    /** Brings a new surface and calls [onDrawn] once Flutter has drawn a frame on it. */
    fun bringBack(onDrawn: () -> Unit)

    /** Undoes [takeAway] and stops waiting for a frame, whatever stage it is at. */
    fun abandon()
}

/**
 * The browser window's Flutter view, which renders through a
 * [FlutterSurfaceView] (the default of `FlutterFragmentActivity`).
 *
 * Only that surface view is hidden and shown again, never the [FlutterView]:
 * the Flutter view keeps Android focus and the keyboard of the password field
 * with it. A hidden surface view releases its surface, Flutter stops rendering
 * to it and reports its UI as no longer displayed; shown again, it connects a
 * new surface, which installs the first-frame callback. That is the same path
 * the activity's own stop and start take with the whole Flutter view.
 */
internal object FlutterViewSurface : FlutterWindowSurface {
    private var flutterView: WeakReference<FlutterView>? = null
    private var surfaceView: WeakReference<FlutterSurfaceView>? = null
    private var listener: FlutterUiDisplayListener? = null
    private val mainThread by lazy { Handler(Looper.getMainLooper()) }

    override fun showsPreReturnImage(decor: ViewGroup): Boolean {
        val view = findFlutterView(decor) ?: return false
        return (0 until view.childCount).any { i ->
            val child = view.getChildAt(i)
            // At alpha 1 from `attachToRenderer` until `detachFromRenderer`.
            child is FlutterImageView && child.visibility == View.VISIBLE && child.alpha > 0f
        }
    }

    override fun takeAway(decor: ViewGroup): Boolean {
        abandon()
        val view = findFlutterView(decor) ?: return false
        val surface = (0 until view.childCount)
            .map(view::getChildAt)
            .firstOrNull { it is FlutterSurfaceView } as? FlutterSurfaceView
            ?: return false

        flutterView = WeakReference(view)
        surfaceView = WeakReference(surface)
        surface.visibility = View.GONE
        return true
    }

    override fun isGone(): Boolean {
        // No longer displayed once the surface was released; still displayed
        // while it was not.
        val view = flutterView?.get() ?: return true
        return !view.hasRenderedFirstFrame()
    }

    override fun bringBack(onDrawn: () -> Unit) {
        val view = flutterView?.get()
        val surface = surfaceView?.get()
        if (view == null || surface == null) {
            onDrawn()
            return
        }

        val displayed = object : FlutterUiDisplayListener {
            private var fired = false

            override fun onFlutterUiDisplayed() {
                if (fired) return
                fired = true
                // Not from inside the call: the Flutter view is going through
                // its listeners right now.
                mainThread.post {
                    view.removeOnFirstFrameRenderedListener(this)
                    if (listener === this) {
                        listener = null
                        flutterView = null
                        surfaceView = null
                        onDrawn()
                    }
                }
            }

            override fun onFlutterUiNoLongerDisplayed() = Unit
        }
        listener = displayed
        view.addOnFirstFrameRenderedListener(displayed)
        surface.visibility = View.VISIBLE
    }

    override fun abandon() {
        val view = flutterView?.get()
        listener?.let { view?.removeOnFirstFrameRenderedListener(it) }
        surfaceView?.get()?.let { if (it.visibility != View.VISIBLE) it.visibility = View.VISIBLE }
        listener = null
        flutterView = null
        surfaceView = null
    }

    private fun findFlutterView(root: ViewGroup): FlutterView? {
        for (i in 0 until root.childCount) {
            when (val child = root.getChildAt(i)) {
                is FlutterView -> return child
                is ViewGroup -> findFlutterView(child)?.let { return it }
            }
        }
        return null
    }
}
