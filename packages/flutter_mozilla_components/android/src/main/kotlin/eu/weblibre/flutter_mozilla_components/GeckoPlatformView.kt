/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import android.view.View
import android.app.Activity
import android.content.Context
import android.view.ViewGroup
import android.widget.FrameLayout
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoStateEvents
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class GeckoViewFactory(
    private val activity: Activity,
    private val containerId: Int,
    private val flutterEvents: GeckoStateEvents
    ) : PlatformViewFactory(
    StandardMessageCodec.INSTANCE) {
    override fun create(context: Context?, id: Int, args: Any?): PlatformView {
        return NativeFragmentView(this.activity, this.containerId, this.flutterEvents)
    }
}

private class NativeFragmentView(
    activity: Activity?,
    containerId: Int,
    private val flutterEvents: GeckoStateEvents
) : PlatformView {
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    private val container: View

    init {
        val vParams: ViewGroup.LayoutParams =
            FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT
            )

        // Ensure activity is not null before creating the container
        if (activity == null) {
            throw IllegalStateException("Activity cannot be null when creating NativeFragmentView")
        }

        container = FrameLayout(activity)
        container.layoutParams = vParams
        container.id = containerId
    }

    override fun onFlutterViewAttached(flutterView: View) {
        super.onFlutterViewAttached(flutterView)

        components.engineReportedInitialized = false
        flutterEvents.onViewReadyStateChange(System.currentTimeMillis(), true) { _ -> }
    }

    override fun getView(): View {
        return container
    }

    override fun dispose() {
        // Clean up if needed
    }
}