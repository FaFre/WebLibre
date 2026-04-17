/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.addons

import android.os.Bundle
import android.view.View
import android.widget.FrameLayout
import eu.weblibre.flutter_mozilla_components.ProfileContext
import mozilla.components.browser.state.action.WebExtensionAction
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.EngineView
import mozilla.components.lib.state.ext.consumeFrom
import mozilla.components.support.locale.ActivityContextWrapper

class FlutterAddonPopupFragment : AddonPopupBaseFragment(), EngineSession.Observer {
    private var addonPopupEngineView: EngineView? = null
    private var sessionConsumed
        get() = arguments?.getBoolean("isSessionConsumed", false) ?: false
        set(value) {
            arguments?.putBoolean("isSessionConsumed", value)
        }

    override fun onCreateView(
        inflater: android.view.LayoutInflater,
        container: android.view.ViewGroup?,
        savedInstanceState: Bundle?,
    ): View {
        val extensionId = requireNotNull(arguments?.getString(ARG_EXTENSION_ID))

        components.core.store.state.extensions[extensionId]?.popupSession?.let {
            initializeSession(it)
        }

        val profileContext = ProfileContext(
            requireContext(),
            components.profileApplicationContext.relativePath,
        )
        val engineView = components.core.engine.createView(profileContext, null)
        addonPopupEngineView = engineView

        val originalContext =
            ActivityContextWrapper.getOriginalContext(requireActivity()) ?: requireActivity()
        engineView.setActivityContext(originalContext)

        val root = FrameLayout(profileContext)
        val nativeView = engineView.asView()
        nativeView.layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT,
        )
        root.addView(nativeView)
        return root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val extensionId = requireNotNull(arguments?.getString(ARG_EXTENSION_ID))
        val currentSession = engineSession

        if (currentSession != null) {
            addonPopupEngineView?.render(currentSession)
            consumePopupSession(extensionId)
        } else {
            consumeFrom(components.core.store) { state ->
                state.extensions[extensionId]?.let { extState ->
                    val popupSession = extState.popupSession
                    if (popupSession != null) {
                        initializeSession(popupSession)
                        addonPopupEngineView?.render(popupSession)
                        popupSession.register(this)
                        consumePopupSession(extensionId)
                        engineSession = popupSession
                    } else if (sessionConsumed) {
                        activity?.onBackPressedDispatcher?.onBackPressed()
                    }
                }
            }
        }
    }

    override fun onDestroyView() {
        addonPopupEngineView?.setActivityContext(null)
        addonPopupEngineView = null
        super.onDestroyView()
    }

    private fun consumePopupSession(extensionId: String) {
        components.core.store.dispatch(
            WebExtensionAction.UpdatePopupSessionAction(extensionId, popupSession = null),
        )
        sessionConsumed = true
    }

    companion object {
        private const val ARG_EXTENSION_ID = "extension_id"

        fun create(extensionId: String) = FlutterAddonPopupFragment().apply {
            arguments = Bundle().apply {
                putString(ARG_EXTENSION_ID, extensionId)
            }
        }
    }
}
