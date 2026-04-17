/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.addons

import android.os.Bundle
import android.view.View
import android.widget.FrameLayout
import eu.weblibre.flutter_mozilla_components.ProfileContext
import mozilla.components.concept.engine.EngineView
import mozilla.components.support.locale.ActivityContextWrapper

class FlutterAddonSettingsFragment : AddonPopupBaseFragment() {
    private var addonSettingsEngineView: EngineView? = null

    override fun onCreateView(
        inflater: android.view.LayoutInflater,
        container: android.view.ViewGroup?,
        savedInstanceState: Bundle?,
    ): View {
        initializeSession()

        val profileContext = ProfileContext(
            requireContext(),
            components.profileApplicationContext.relativePath,
        )
        val engineView = components.core.engine.createView(profileContext, null)
        addonSettingsEngineView = engineView

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

        val optionsPageUrl = arguments?.getString(ARG_OPTIONS_PAGE_URL)

        if (optionsPageUrl != null) {
            engineSession?.let { session ->
                addonSettingsEngineView?.render(session)
                session.loadUrl(optionsPageUrl)
            }
        } else {
            activity?.onBackPressedDispatcher?.onBackPressed()
        }
    }

    override fun onDestroyView() {
        addonSettingsEngineView?.setActivityContext(null)
        addonSettingsEngineView = null
        super.onDestroyView()
    }

    companion object {
        private const val ARG_OPTIONS_PAGE_URL = "options_page_url"

        fun create(optionsPageUrl: String) = FlutterAddonSettingsFragment().apply {
            arguments = Bundle().apply {
                putString(ARG_OPTIONS_PAGE_URL, optionsPageUrl)
            }
        }
    }
}
