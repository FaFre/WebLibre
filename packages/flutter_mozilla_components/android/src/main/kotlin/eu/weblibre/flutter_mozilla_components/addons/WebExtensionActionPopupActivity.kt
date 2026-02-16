/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.addons

import android.content.Context
import android.os.Bundle
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.app.AppCompatActivity
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.R
import mozilla.components.browser.state.action.WebExtensionAction
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.EngineView
import mozilla.components.lib.state.ext.consumeFrom

/**
 * An activity to show the pop up action of a web extension.
 */
class WebExtensionActionPopupActivity : AppCompatActivity() {
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    private lateinit var webExtensionId: String

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_add_on_settings)

        webExtensionId = requireNotNull(intent.getStringExtra("web_extension_id"))
        intent.getStringExtra("web_extension_name")?.let {
            title = it
        }

        supportFragmentManager
            .beginTransaction()
            .replace(R.id.addonSettingsContainer, WebExtensionActionPopupFragment.create(webExtensionId))
            .commit()
    }

    override fun onCreateView(parent: View?, name: String, context: Context, attrs: AttributeSet): View? =
        when (name) {
            EngineView::class.java.name -> components.core.engine.createView(context, attrs).asView()
            else -> super.onCreateView(parent, name, context, attrs)
        }

    /**
     * A fragment to show the web extension action popup with [EngineView].
     *
     * Extends [AddonPopupBaseFragment] to get proper session lifecycle management,
     * prompt handling, and download support.
     */
    class WebExtensionActionPopupFragment : AddonPopupBaseFragment(), EngineSession.Observer {

        private lateinit var webExtensionId: String

        private val safeArguments get() = requireNotNull(arguments)
        private var sessionConsumed
            get() = safeArguments.getBoolean("isSessionConsumed", false)
            set(value) {
                safeArguments.putBoolean("isSessionConsumed", value)
            }

        private val addonSettingsEngineView: EngineView
            get() = requireView().findViewById<View>(R.id.addonSettingsEngineView) as EngineView

        override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
            webExtensionId = requireNotNull(arguments?.getString("web_extension_id"))

            // Grab the popup session from the store if available and register it as a custom tab.
            components.core.store.state.extensions[webExtensionId]?.popupSession?.let {
                initializeSession(it)
            }

            return inflater.inflate(R.layout.fragment_add_on_settings, container, false)
        }

        override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
            super.onViewCreated(view, savedInstanceState)

            val session = engineSession
            if (session != null) {
                addonSettingsEngineView.render(session)
                consumePopupSession()
            } else {
                consumeFrom(components.core.store) { state ->
                    state.extensions[webExtensionId]?.let { extState ->
                        val popupSession = extState.popupSession
                        if (popupSession != null) {
                            initializeSession(popupSession)
                            addonSettingsEngineView.render(popupSession)
                            popupSession.register(this)
                            consumePopupSession()
                            engineSession = popupSession
                        } else if (sessionConsumed) {
                            // Session was consumed but lost (e.g. Android recreated the activity).
                            activity?.finish()
                        }
                    }
                }
            }
        }

        override fun onDestroyView() {
            super.onDestroyView()
        }

        private fun consumePopupSession() {
            components.core.store.dispatch(
                WebExtensionAction.UpdatePopupSessionAction(webExtensionId, popupSession = null),
            )
            sessionConsumed = true
        }

        companion object {
            fun create(webExtensionId: String) = WebExtensionActionPopupFragment().apply {
                arguments = Bundle().apply {
                    putString("web_extension_id", webExtensionId)
                }
            }
        }
    }
}
