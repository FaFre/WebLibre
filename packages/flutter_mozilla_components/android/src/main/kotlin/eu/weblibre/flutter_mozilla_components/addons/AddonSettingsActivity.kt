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
import androidx.fragment.app.Fragment
import eu.weblibre.flutter_mozilla_components.Components
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.EngineView
import mozilla.components.feature.addons.Addon
import mozilla.components.feature.addons.ui.translateName
import mozilla.components.support.utils.ext.getParcelableCompat
import mozilla.components.support.utils.ext.getParcelableExtraCompat
import eu.weblibre.flutter_mozilla_components.R

/**
 * An activity to show the settings of an add-on.
 */
class AddonSettingsActivity : AppCompatActivity() {
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_add_on_settings)

        val addon = requireNotNull(
            intent.getParcelableExtraCompat("add_on", Addon::class.java),
        )

        title = addon.translateName(this)

        supportFragmentManager
            .beginTransaction()
            .replace(R.id.addonSettingsContainer, AddonSettingsFragment.create(addon))
            .commit()
    }

    override fun onCreateView(parent: View?, name: String, context: Context, attrs: AttributeSet): View? =
        when (name) {
            EngineView::class.java.name -> components.core.engine.createView(context, attrs).asView()
            else -> super.onCreateView(parent, name, context, attrs)
        }

    /**
     * A fragment to show the settings of an add-on with [EngineView].
     */
    class AddonSettingsFragment : Fragment() {
        private val components by lazy {
            requireNotNull(GlobalComponents.components) { "Components not initialized" }
        }

        private lateinit var optionsPageUrl: String
        private lateinit var engineSession: EngineSession

        override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
            optionsPageUrl = requireNotNull(
                arguments?.getParcelableCompat(
                    "add_on",
                    Addon::class.java,
                )?.installedState?.optionsPageUrl,
            )

            engineSession = components.core.engine.createSession()

            return inflater.inflate(R.layout.fragment_add_on_settings, container, false)
        }

        override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
            super.onViewCreated(view, savedInstanceState)

            val addonSettingsEngineView = view.findViewById<View>(R.id.addonSettingsEngineView) as EngineView
            addonSettingsEngineView.render(engineSession)
            engineSession.loadUrl(optionsPageUrl)
        }

        override fun onDestroyView() {
            engineSession.close()
            super.onDestroyView()
        }

        companion object {
            /**
             * Create an [AddonSettingsFragment] with add_on as a required parameter.
             */
            fun create(addon: Addon) = AddonSettingsFragment().apply {
                arguments = Bundle().apply {
                    putParcelable("add_on", addon)
                }
            }
        }
    }
}
