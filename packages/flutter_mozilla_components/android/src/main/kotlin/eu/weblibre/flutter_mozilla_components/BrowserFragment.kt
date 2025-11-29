/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.annotation.CallSuper
import mozilla.components.concept.engine.EngineView
import mozilla.components.support.base.feature.UserInteractionHandler

/**
 * Fragment used for browsing the web within the main app.
 */
class BrowserFragment() : BaseBrowserFragment(), UserInteractionHandler {
    override fun createEngine(components: Components): EngineView {
        //We cannot introduce here our wrapped context since a activity type is required to make features work correctly like context menu
        return components.core.engine.createView(requireContext()).apply {
           selectionActionDelegate = components.selectionAction
        }
    }

    @Deprecated("Deprecated in Java")
    @CallSuper
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super<BaseBrowserFragment>.onActivityResult(requestCode, data, resultCode)
    }

    @Suppress("LongMethod")
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
    }

    override fun onBackPressed(): Boolean =
        super.readerViewFeature.onBackPressed() || super.onBackPressed()

    companion object {
        fun create(sessionId: String? = null) = BrowserFragment().apply {
            arguments = Bundle().apply {
                putSessionId(sessionId)
            }
        }
    }
}
