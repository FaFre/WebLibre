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
import androidx.activity.OnBackPressedCallback
import androidx.appcompat.app.AppCompatActivity
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.R
import mozilla.components.concept.engine.EngineView
import mozilla.components.feature.addons.Addon
import mozilla.components.feature.addons.ui.translateName
import mozilla.components.support.utils.ext.getParcelableCompat

/**
 * An activity to show the internal settings of an add-on with [EngineView].
 *
 * Used when the addon's manifest specifies `openOptionsPageInTab = false`,
 * rendering the settings page inside an [AddonPopupBaseFragment] with proper
 * prompt and download support.
 */
class AddonInternalSettingsActivity : AppCompatActivity() {
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_add_on_settings)

        val addon = requireNotNull(
            intent.getParcelableExtra<Addon>("add_on"),
        )

        title = addon.translateName(this)

        val fragment = AddonInternalSettingsFragment.create(addon)

        supportFragmentManager
            .beginTransaction()
            .replace(R.id.addonSettingsContainer, fragment)
            .commit()

        onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                if (!fragment.onBackPressed()) {
                    finish()
                }
            }
        })
    }

    override fun onCreateView(parent: View?, name: String, context: Context, attrs: AttributeSet): View? =
        when (name) {
            EngineView::class.java.name -> components.core.engine.createView(context, attrs).asView()
            else -> super.onCreateView(parent, name, context, attrs)
        }

    /**
     * A fragment to show the internal settings of an add-on with [EngineView].
     *
     * Creates a fresh engine session and loads the addon's options page URL into it.
     */
    class AddonInternalSettingsFragment : AddonPopupBaseFragment() {

        private val addonSettingsEngineView: EngineView
            get() = requireView().findViewById<View>(R.id.addonSettingsEngineView) as EngineView

        override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
            initializeSession()
            return inflater.inflate(R.layout.fragment_add_on_settings, container, false)
        }

        override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
            super.onViewCreated(view, savedInstanceState)

            val optionsPageUrl = arguments?.getParcelableCompat("add_on", Addon::class.java)
                ?.installedState?.optionsPageUrl

            if (optionsPageUrl != null) {
                engineSession?.let { session ->
                    addonSettingsEngineView.render(session)
                    session.loadUrl(optionsPageUrl)
                }
            } else {
                activity?.finish()
            }
        }

        companion object {
            fun create(addon: Addon) = AddonInternalSettingsFragment().apply {
                arguments = Bundle().apply {
                    putParcelable("add_on", addon)
                }
            }
        }
    }
}
