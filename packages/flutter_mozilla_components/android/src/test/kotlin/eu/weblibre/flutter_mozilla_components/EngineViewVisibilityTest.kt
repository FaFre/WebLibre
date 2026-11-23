/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import android.app.Activity
import android.graphics.Rect
import android.os.Looper
import android.view.SurfaceView
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import io.flutter.embedding.android.FlutterView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.StandardMethodCodec
import java.nio.ByteBuffer
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

@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class EngineViewVisibilityTest {
    /** Enough of the messenger to hand the channel's own handler back. */
    private class FakeMessenger : BinaryMessenger {
        val handlers = mutableMapOf<String, BinaryMessenger.BinaryMessageHandler>()

        override fun send(channel: String, message: ByteBuffer?) = Unit

        override fun send(
            channel: String,
            message: ByteBuffer?,
            callback: BinaryMessenger.BinaryReply?,
        ) = Unit

        override fun setMessageHandler(
            channel: String,
            handler: BinaryMessenger.BinaryMessageHandler?,
        ) {
            if (handler == null) handlers.remove(channel) else handlers[channel] = handler
        }
    }

    private val activity: Activity =
        Robolectric.buildActivity(Activity::class.java).setup().get()
    private val messenger = FakeMessenger()

    private val container = FrameLayout(activity).apply { id = CONTAINER_ID }
    private val surface = SurfaceView(activity)

    /** The page's view, standing in for the focused engine view. */
    private val page = object : FrameLayout(activity) {
        var focusRequests = 0

        override fun requestFocus(direction: Int, previouslyFocusedRect: Rect?): Boolean {
            focusRequests++
            return super.requestFocus(direction, previouslyFocusedRect)
        }
    }.apply {
        isFocusable = true
        isFocusableInTouchMode = true
    }

    private val visibility = EngineViewVisibility(
        messenger,
        activityProvider = { activity },
        containerId = CONTAINER_ID,
        engineView = { page },
    )

    init {
        container.addView(surface)
        container.addView(page)
        activity.setContentView(container)
    }

    /** Drives the plugin the way Dart does, through the channel it registered. */
    private fun invoke(method: String, argument: Any? = null) {
        val handler = messenger.handlers.getValue(CHANNEL)
        val message = StandardMethodCodec.INSTANCE
            .encodeMethodCall(MethodCall(method, argument))
        message.rewind()
        handler.onMessage(message, BinaryMessenger.BinaryReply { })
    }

    private fun setVisible(visible: Boolean) = invoke("setEngineViewVisible", visible)

    private fun focusEngineView() = invoke("focusEngineView")

    @After
    fun tearDown() = visibility.dispose()

    @Test
    fun `hiding takes the surface off the window and showing puts it back`() {
        setVisible(false)
        assertEquals(View.INVISIBLE, container.visibility)
        assertEquals(View.INVISIBLE, surface.visibility)

        setVisible(true)
        assertEquals(View.VISIBLE, container.visibility)
        assertEquals(View.VISIBLE, surface.visibility)
    }

    @Test
    fun `a surface someone else hid is not lifted by showing`() {
        // Gecko released the session while the route above was covering it.
        surface.visibility = View.INVISIBLE

        setVisible(false)
        setVisible(true)

        assertEquals(View.VISIBLE, container.visibility)
        assertEquals(
            View.INVISIBLE,
            surface.visibility,
            "showing again may only lift what this hid",
        )
    }

    @Test
    fun `a surface attached while hidden is hidden too, and lifted with the rest`() {
        setVisible(false)

        // A session swapped in behind the covering route brings its own surface,
        // attached visible. The layout pass that causes is what drives this.
        val swapped = SurfaceView(activity)
        container.addView(swapped)
        visibility.refreshWhileHidden()

        assertEquals(View.INVISIBLE, swapped.visibility)

        setVisible(true)
        assertEquals(View.VISIBLE, swapped.visibility)
        assertEquals(View.VISIBLE, surface.visibility)
    }

    @Test
    fun `hiding twice still restores in one showing`() {
        setVisible(false)
        setVisible(false)
        setVisible(true)

        assertEquals(View.VISIBLE, container.visibility)
        assertEquals(View.VISIBLE, surface.visibility)
    }

    @Test
    fun `a surface attached after showing is left alone`() {
        setVisible(false)
        setVisible(true)

        val later = SurfaceView(activity)
        container.addView(later)
        visibility.refreshWhileHidden()

        assertEquals(View.VISIBLE, later.visibility)
    }

    private companion object {
        const val CONTAINER_ID = 4242
        const val CHANNEL = "eu.weblibre.flutter_mozilla_components/engine_view"
    }

    @Test
    fun `showing never takes focus by itself`() {
        // Find in Page, the address editor: a Flutter field may be meant to have
        // the focus, and an app resume shows the page too.
        setVisible(false)
        setVisible(true)
        shadowOf(Looper.getMainLooper()).idle()
        assertFalse(page.hasFocus())

        setVisible(true)
        shadowOf(Looper.getMainLooper()).idle()
        assertFalse(page.hasFocus())
    }

    @Test
    fun `asking for focus after a show gives the page focus`() {
        setVisible(false)
        setVisible(true)
        focusEngineView()
        // The layout pass the visibility change asks for.
        shadowOf(Looper.getMainLooper()).idle()

        assertTrue(page.hasFocus())
    }

    @Test
    fun `focus waits for the page to be shown and laid out`() {
        setVisible(false)
        // The embedder's wrapper is still hidden when the request arrives.
        (container.parent as View).visibility = View.GONE

        setVisible(true)
        focusEngineView()
        assertFalse(page.hasFocus())

        (container.parent as View).visibility = View.VISIBLE
        container.viewTreeObserver.dispatchOnGlobalLayout()

        assertTrue(page.hasFocus())
    }

    @Test
    fun `losing Flutter focus drops a request that was still waiting`() {
        setVisible(false)
        (container.parent as View).visibility = View.GONE
        setVisible(true)
        focusEngineView()

        // Flutter focus moved to a field before the page was ready.
        invoke("cancelEngineViewFocus")
        (container.parent as View).visibility = View.VISIBLE
        // The framework hands the first focusable view focus when a window's
        // views appear, so what is counted is the requests made from here on.
        page.focusRequests = 0
        container.viewTreeObserver.dispatchOnGlobalLayout()

        assertEquals(0, page.focusRequests)
    }

    @Test
    fun `a hide drops a focus request that was still waiting`() {
        setVisible(false)
        (container.parent as View).visibility = View.GONE
        setVisible(true)
        focusEngineView()

        setVisible(false)
        (container.parent as View).visibility = View.VISIBLE
        // The framework hands the first focusable view focus when a window's
        // views appear, so what is counted is the requests made from here on.
        page.focusRequests = 0
        container.viewTreeObserver.dispatchOnGlobalLayout()

        assertEquals(0, page.focusRequests)
    }

    /** Composites the container into a Flutter view, as the embedder does. */
    private fun compositeIntoFlutterView(): FlutterView {
        val flutterView = FlutterView(activity)
        (container.parent as ViewGroup).removeView(container)
        flutterView.addView(container)
        activity.setContentView(flutterView)
        return flutterView
    }

    @Test
    fun `hiding the page keeps the Flutter view from drawing a focus highlight`() {
        val flutterView = compositeIntoFlutterView()
        assertTrue(
            flutterView.defaultFocusHighlightEnabled,
            "the Android default, which draws a translucent wash over the whole window",
        )

        setVisible(false)

        assertFalse(flutterView.defaultFocusHighlightEnabled)
    }

    @Test
    fun `showing the page keeps the Flutter view from drawing a focus highlight too`() {
        val flutterView = compositeIntoFlutterView()

        setVisible(true)

        assertFalse(flutterView.defaultFocusHighlightEnabled)
    }

    @Test
    fun `a platform view attaching switches the highlight off before any hide`() {
        val flutterView = FlutterView(activity)
        assertTrue(flutterView.defaultFocusHighlightEnabled)

        EngineViewVisibility.keepFocusHighlightOff(flutterView)

        assertFalse(flutterView.defaultFocusHighlightEnabled)
    }
}
