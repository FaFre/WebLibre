/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import android.app.Activity
import android.util.Log
import android.view.SurfaceView
import android.view.View
import android.view.ViewTreeObserver
import eu.weblibre.flutter_mozilla_components.ext.forEachSurfaceView
import io.flutter.embedding.android.FlutterView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference

/**
 * Takes the engine's surface off the window when Flutter stops painting the
 * platform view, because nothing else does.
 *
 * Hiding a view does not retire a [SurfaceView]'s compositor layer, and that
 * layer is what the page is drawn into. Measured on Android 13 while the
 * previous page was still covering the route that replaced it, the embedder had
 * done its part perfectly: the `FlutterMutatorView` wrapper was `GONE`, the
 * container reported `isShown == false`, and the page was on screen regardless
 * — over Flutter's base surface, under the overlay views, which is why the
 * chrome kept working while the route underneath it was the one that vanished.
 * A surface view reconciles its layer from its own `updateSurface`, so the
 * visibility has to be set on the surface view itself, which is what this walks
 * down to do.
 *
 * The same channel gives the page native focus back ([focusEngineView]). Only
 * Dart knows whether Flutter wants the page focused, so showing never does it
 * on its own: Dart asks after a show when its focus is on the page, and cancels
 * the request when its focus leaves.
 *
 * Hiding the page also drops its native focus onto the [FlutterView]. A [FlutterView]
 * that holds focus outside touch mode (a hardware keyboard was used last) gets
 * Android's default focus highlight: a translucent wash over the whole window
 * that only a focus change removes, and that comes back with window focus after
 * the app switcher. The highlight is switched off for that view
 * ([disableFocusHighlight]); the host switches it off when it creates the view,
 * which is before the first focus gain.
 *
 * [View.INVISIBLE] rather than [View.GONE] because the browser fragment is
 * attached to the container and its view has to keep being measured and laid
 * out: an attach against a zero-sized container is one of the failures
 * `GeckoView._showNativeFragment` retries against.
 */
class EngineViewVisibility(
    messenger: BinaryMessenger,
    private val activityProvider: () -> Activity?,
    private val containerId: Int,
    /**
     * The page that takes native focus. In the main browser this is the focused
     * split pane: the coordinator keeps `activeEngineView` on it while the
     * browser is resumed.
     */
    private val engineView: () -> View? = {
        GlobalComponents.components?.activeEngineView?.asView()
    },
) {
    private val channel = MethodChannel(messenger, CHANNEL).apply {
        setMethodCallHandler(::onMethodCall)
    }

    /** The views this hid, so that showing again lifts those and nothing else. */
    private val hidden = mutableListOf<WeakReference<View>>()

    /** The container being kept hidden, and the observer watching it. */
    private var watching: WeakReference<View>? = null
    private var observer: ViewTreeObserver? = null
    private val onGlobalLayout = ViewTreeObserver.OnGlobalLayoutListener { refreshWhileHidden() }

    /** A focus request still waiting for the page to be shown and laid out. */
    private var pendingFocus: PendingFocus? = null

    private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setEngineViewVisible" -> {
                val visible = call.arguments as? Boolean
                if (visible == null) {
                    result.error(
                        "invalid_argument",
                        "setEngineViewVisible expects a boolean",
                        null,
                    )
                    return
                }

                setVisible(visible)
                result.success(null)
            }

            "focusEngineView" -> {
                focusEngineViewWhenShown()
                result.success(null)
            }

            "cancelEngineViewFocus" -> {
                cancelPendingFocus()
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    /**
     * Applies [visible] to the container and to the engine's surface views.
     *
     * Never conditional on the container looking hidden already. `isShown` was
     * false every single time the page was still on the window, so a guard on
     * it skips exactly the case this exists for.
     *
     * Showing again lifts what this hid, and only that. A surface someone else
     * took out of the hierarchy's view — Gecko releasing a session, say — was
     * not hidden here and is not this class's to put back, so the views that
     * were actually changed are the ones remembered and restored.
     */
    private fun setVisible(visible: Boolean) {
        val container = activityProvider()?.findViewById<View>(containerId) ?: return

        // Before the hide below moves native focus onto the Flutter view, so
        // that move never installs the highlight.
        disableFocusHighlight(container)

        Log.i(
            TAG,
            "setEngineViewVisible($visible): container was " +
                "${describe(container)}, wrapper ${describe(container.parent as? View)}",
        )

        if (visible) {
            stopWatching()
            hidden.forEach { reference ->
                val view = reference.get() ?: return@forEach
                if (view.visibility == View.INVISIBLE) {
                    view.visibility = View.VISIBLE
                }
            }
            hidden.clear()
            // Deliberately no focus here. A show says nothing about where
            // Flutter focus is: it also arrives on every app resume, while a
            // Flutter field (Find in Page, the address editor) may be the one
            // that is meant to have it. Dart asks for the focus
            // ([focusEngineView]) when its own focus is on the page.
            return
        }

        cancelPendingFocus()
        hideTree(container)
        startWatching(container)
    }

    /**
     * Gives the page native focus, immediately.
     *
     * Flutter clears a platform view's native focus when its own focus moves
     * elsewhere, into a sheet or a dialog, but focus coming back doesn't
     * restore it: the page would stay without its caret, its keyboard and the
     * keys typed until a tap.
     */
    private fun focusEngineView() {
        cancelPendingFocus()
        val view = engineView() ?: return
        if (!view.hasFocus()) {
            view.requestFocus()
        }
    }

    /**
     * [focusEngineView] once the page can take focus.
     *
     * Showing flips the visibility in the same call, but the embedder's wrapper
     * may still be hidden or not laid out, and [View.requestFocus] then fails
     * without anything retrying. A page that is not shown yet is retried on
     * each layout pass until it is, or until the next hide or [dispose].
     */
    private fun focusEngineViewWhenShown() {
        cancelPendingFocus()
        val view = engineView() ?: return
        if (view.canTakeFocusNow()) {
            focusEngineView()
            return
        }

        val treeObserver = view.viewTreeObserver
        if (!treeObserver.isAlive) {
            return
        }

        val pending = PendingFocus(view)
        treeObserver.addOnGlobalLayoutListener(pending)
        pendingFocus = pending
    }

    private fun View.canTakeFocusNow() = isShown && isLaidOut && width > 0 && height > 0

    private fun cancelPendingFocus() {
        pendingFocus?.cancel()
        pendingFocus = null
    }

    private inner class PendingFocus(view: View) : ViewTreeObserver.OnGlobalLayoutListener {
        private val target = WeakReference(view)
        private var observer: ViewTreeObserver? = view.viewTreeObserver

        override fun onGlobalLayout() {
            val view = target.get()
            if (view == null) {
                cancel()
                return
            }

            if (view.canTakeFocusNow()) {
                // Cancels this listener first, so the request below is the last.
                focusEngineView()
            }
        }

        fun cancel() {
            val treeObserver = observer ?: return
            observer = null
            if (treeObserver.isAlive) {
                treeObserver.removeOnGlobalLayoutListener(this)
            }
        }
    }

    /**
     * Keeps the [FlutterView] that [container] is composited into from drawing
     * the default focus highlight.
     *
     * The flag is only consulted when the view's focus changes
     * (`View.switchDefaultFocusHighlight`), so this has to be set before the
     * view gets focus, and it is harmless to set again.
     */
    private fun disableFocusHighlight(container: View) {
        var ancestor = container.parent
        while (ancestor != null) {
            if (ancestor is FlutterView) {
                keepFocusHighlightOff(ancestor)
                return
            }
            ancestor = ancestor.parent
        }
    }

    /** Hides [container] and every surface under it, remembering each one. */
    private fun hideTree(container: View) {
        hide(container)
        forEachSurfaceView(container) { hide(it) }
    }

    private fun hide(view: View) {
        if (view.visibility != View.VISIBLE) {
            return
        }

        view.visibility = View.INVISIBLE
        hidden += WeakReference(view)
    }

    /**
     * Re-hides the subtree while it is meant to be hidden.
     *
     * A session swapped in behind a covering route brings its own surface view,
     * attached visible, painting the page over Flutter again — the very
     * symptom, arriving after the hide that was supposed to prevent it. A
     * layout pass is what a new surface causes, so that is what this hangs off.
     *
     * Idempotent by construction: [hide] only touches views that are visible,
     * so a pass that changes nothing requests no layout and cannot feed itself.
     */
    internal fun refreshWhileHidden() {
        val container = watching?.get() ?: return
        hideTree(container)
    }

    private fun startWatching(container: View) {
        if (observer != null) {
            return
        }

        val treeObserver = container.viewTreeObserver
        if (!treeObserver.isAlive) {
            return
        }

        treeObserver.addOnGlobalLayoutListener(onGlobalLayout)
        observer = treeObserver
        watching = WeakReference(container)
    }

    private fun stopWatching() {
        val treeObserver = observer ?: return
        observer = null
        watching = null

        // A dead observer has already dropped its listeners, and the live one
        // the container holds now is not the one this registered on.
        if (treeObserver.isAlive) {
            treeObserver.removeOnGlobalLayoutListener(onGlobalLayout)
        }
    }

    /**
     * One line per change, kept in release builds: the state this reports is
     * the whole diagnosis of a page that outstays its frame, and it only costs
     * a line per navigation.
     */
    private fun describe(view: View?): String {
        if (view == null) {
            return "null"
        }

        val visibility = when (view.visibility) {
            View.VISIBLE -> "VISIBLE"
            View.INVISIBLE -> "INVISIBLE"
            else -> "GONE"
        }

        return "${view.javaClass.simpleName} $visibility ${view.width}x${view.height} " +
            "shown=${view.isShown} attached=${view.isAttachedToWindow}"
    }

    fun dispose() {
        cancelPendingFocus()
        stopWatching()
        hidden.clear()
        channel.setMethodCallHandler(null)
    }

    companion object {
        private const val TAG = "EngineViewVisibility"
        private const val CHANNEL = "eu.weblibre.flutter_mozilla_components/engine_view"

        /**
         * Switches the default focus highlight off for [flutterView]. Also
         * called when a platform view attaches to it, which is earlier than
         * any hide, so a focus gain before the first one draws no highlight
         * either.
         *
         * Deliberately never restored: the [FlutterView] is the app's single
         * view and draws all of its UI itself, so the translucent wash is never
         * wanted on it, whether or not a platform view is attached.
         */
        internal fun keepFocusHighlightOff(flutterView: View) {
            flutterView.defaultFocusHighlightEnabled = false
        }
    }
}
