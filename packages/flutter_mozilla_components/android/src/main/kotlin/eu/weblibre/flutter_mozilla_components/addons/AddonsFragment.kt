/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.addons

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import eu.weblibre.flutter_mozilla_components.Components
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import mozilla.components.feature.addons.Addon
import mozilla.components.feature.addons.AddonManagerException
import mozilla.components.feature.addons.ui.AddonsManagerAdapter
import mozilla.components.feature.addons.ui.AddonsManagerAdapterDelegate
import mozilla.components.support.base.feature.ViewBoundFeatureWrapper
import eu.weblibre.flutter_mozilla_components.R
import mozilla.components.feature.addons.R as MozComp

/**
 * Fragment use for managing add-ons.
 */
class AddonsFragment : Fragment(), AddonsManagerAdapterDelegate {
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    private val webExtensionPromptFeature = ViewBoundFeatureWrapper<WebExtensionPromptFeature>()
    private lateinit var recyclerView: RecyclerView
    private val scope = CoroutineScope(Dispatchers.IO)
    private lateinit var addons: List<Addon>
    private var adapter: AddonsManagerAdapter? = null

    private val addonProgressOverlay: View
        get() = requireView().findViewById(R.id.addonProgressOverlay)

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?,
    ): View {
        return inflater.inflate(R.layout.fragment_add_ons, container, false)
    }

    override fun onViewCreated(rootView: View, savedInstanceState: Bundle?) {
        super.onViewCreated(rootView, savedInstanceState)
        bindRecyclerView(rootView)
        webExtensionPromptFeature.set(
            feature = WebExtensionPromptFeature(
                store = components.core.store,
                context = requireContext(),
                fragmentManager = parentFragmentManager,
            ),
            owner = this,
            view = rootView,
        )
    }

    override fun onStart() {
        super.onStart()

        this@AddonsFragment.view?.let { view ->
            bindRecyclerView(view)
        }

        addonProgressOverlay.visibility = View.GONE
    }

    private fun bindRecyclerView(rootView: View) {
        recyclerView = rootView.findViewById(R.id.add_ons_list)
        recyclerView.layoutManager = LinearLayoutManager(requireContext())
        scope.launch {
            try {
                addons = components.core.addonManager.getAddons()

                scope.launch(Dispatchers.Main) {
                    adapter = AddonsManagerAdapter(
                        this@AddonsFragment,
                        addons,
                        store = components.core.store,
                    )
                    recyclerView.adapter = adapter
                }
            } catch (e: AddonManagerException) {
                scope.launch(Dispatchers.Main) {
                    Toast.makeText(
                        activity,
                        MozComp.string.mozac_feature_addons_failed_to_query_extensions,
                        Toast.LENGTH_SHORT,
                    ).show()
                }
            }
        }
    }

    override fun onAddonItemClicked(addon: Addon) {
        if (addon.isInstalled()) {
            val intent = Intent(context, InstalledAddonDetailsActivity::class.java)
            intent.putExtra("add_on", addon)
            startActivity(intent)
        } else {
            val intent = Intent(context, AddonDetailsActivity::class.java)
            intent.putExtra("add_on", addon)
            startActivity(intent)
        }
    }

    override fun onInstallAddonButtonClicked(addon: Addon) {
        if (isInstallationInProgress) {
            return
        }
        installAddon(addon)
    }

    private val installAddon: ((Addon) -> Unit) = { addon ->
        addonProgressOverlay.visibility = View.VISIBLE
        isInstallationInProgress = true
        components.core.addonManager.installAddon(
            url = addon.downloadUrl,
            onSuccess = {
                runIfFragmentIsAttached {
                    isInstallationInProgress = false
                    this@AddonsFragment.view?.let { view ->
                        bindRecyclerView(view)
                    }
                    addonProgressOverlay.visibility = View.GONE
                }
            },
            onError = { _ ->
                runIfFragmentIsAttached {
                    addonProgressOverlay.visibility = View.GONE
                    isInstallationInProgress = false
                }
            },
        )
    }

    /**
     * Whether or not an add-on installation is in progress.
     */
    private var isInstallationInProgress = false
}
