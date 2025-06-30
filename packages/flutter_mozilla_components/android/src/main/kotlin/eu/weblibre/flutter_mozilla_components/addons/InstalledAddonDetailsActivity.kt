/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.addons

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.SwitchCompat
import androidx.core.view.isVisible
import eu.weblibre.flutter_mozilla_components.Components
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import mozilla.components.feature.addons.Addon
import mozilla.components.feature.addons.AddonManagerException
import mozilla.components.feature.addons.ui.translateName
import mozilla.components.support.utils.ext.getParcelableExtraCompat
import eu.weblibre.flutter_mozilla_components.R
import mozilla.components.feature.addons.R as MozComp

/**
 * An activity to show the details of a installed add-on.
 */
class InstalledAddonDetailsActivity : AppCompatActivity() {
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    private val scope = CoroutineScope(Dispatchers.IO)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_installed_add_on_details)
        val addon = requireNotNull(
            intent.getParcelableExtraCompat("add_on", Addon::class.java),
        ).also {
            bindUI(it)
        }

        bindAddon(addon)
    }

    private fun bindAddon(addon: Addon) {
        scope.launch {
            try {
                val addons = components.core.addonManager.getAddons()
                scope.launch(Dispatchers.Main) {
                    addons.find { addon.id == it.id }.let {
                        if (it == null) {
                            throw AddonManagerException(Exception("Addon ${addon.id} not found"))
                        } else {
                            bindUI(it)
                        }
                    }
                }
            } catch (e: AddonManagerException) {
                scope.launch(Dispatchers.Main) {
                    Toast.makeText(
                        baseContext,
                        MozComp.string.mozac_feature_addons_failed_to_query_extensions,
                        Toast.LENGTH_SHORT,
                    ).show()
                }
            }
        }
    }

    private fun bindUI(addon: Addon) {
        title = addon.translateName(this)

        bindEnableSwitch(addon)

        bindSettings(addon)

        bindDetails(addon)

        bindPermissions(addon)

        bindAllowInPrivateBrowsingSwitch(addon)

        bindRemoveButton(addon)
    }

    private fun bindEnableSwitch(addon: Addon) {
        val switch = findViewById<SwitchCompat>(R.id.enable_switch)
        switch.setState(addon.isEnabled())
        switch.setOnCheckedChangeListener { _, isChecked ->
            if (isChecked) {
                components.core.addonManager.enableAddon(
                    addon,
                    onSuccess = {
                        switch.setState(true)
                        Toast.makeText(
                            this,
                            getString(MozComp.string.mozac_feature_addons_successfully_enabled, addon.translateName(this)),
                            Toast.LENGTH_SHORT,
                        ).show()
                    },
                    onError = {
                        Toast.makeText(
                            this,
                            getString(MozComp.string.mozac_feature_addons_failed_to_enable, addon.translateName(this)),
                            Toast.LENGTH_SHORT,
                        ).show()
                    },
                )
            } else {
                components.core.addonManager.disableAddon(
                    addon,
                    onSuccess = {
                        switch.setState(false)
                        Toast.makeText(
                            this,
                            getString(MozComp.string.mozac_feature_addons_successfully_disabled, addon.translateName(this)),
                            Toast.LENGTH_SHORT,
                        ).show()
                    },
                    onError = {
                        Toast.makeText(
                            this,
                            getString(MozComp.string.mozac_feature_addons_failed_to_disable, addon.translateName(this)),
                            Toast.LENGTH_SHORT,
                        ).show()
                    },
                )
            }
        }
    }

    private fun bindSettings(addon: Addon) {
        val view = findViewById<View>(R.id.settings)
        view.isVisible = shouldSettingsBeVisible(addon)
        view.isEnabled = shouldSettingsBeVisible(addon)
        view.setOnClickListener {
            val intent = Intent(this, AddonSettingsActivity::class.java)
            intent.putExtra("add_on", addon)
            this.startActivity(intent)
        }
    }

    private fun bindDetails(addon: Addon) {
        findViewById<View>(R.id.details).setOnClickListener {
            val intent = Intent(this, AddonDetailsActivity::class.java)
            intent.putExtra("add_on", addon)
            this.startActivity(intent)
        }
    }

    private fun bindPermissions(addon: Addon) {
        findViewById<View>(R.id.permissions).setOnClickListener {
            val intent = Intent(this, PermissionsDetailsActivity::class.java)
            intent.putExtra("add_on", addon)
            this.startActivity(intent)
        }
    }

    private fun bindAllowInPrivateBrowsingSwitch(addon: Addon) {
        val switch = findViewById<SwitchCompat>(R.id.allow_in_private_browsing_switch)
        switch.isChecked = addon.isAllowedInPrivateBrowsing()
        switch.setOnCheckedChangeListener { _, isChecked ->
            components.core.addonManager.setAddonAllowedInPrivateBrowsing(
                addon,
                isChecked,
                onSuccess = {
                    switch.isChecked = isChecked
                },
            )
        }
    }

    private fun bindRemoveButton(addon: Addon) {
        findViewById<View>(R.id.remove_add_on).setOnClickListener {
            components.core.addonManager.uninstallAddon(
                addon,
                onSuccess = {
                    Toast.makeText(
                        this,
                        getString(MozComp.string.mozac_feature_addons_successfully_uninstalled, addon.translateName(this)),
                        Toast.LENGTH_SHORT,
                    ).show()
                    finish()
                },
                onError = { _, _ ->
                    Toast.makeText(
                        this,
                        getString(MozComp.string.mozac_feature_addons_failed_to_uninstall, addon.translateName(this)),
                        Toast.LENGTH_SHORT,
                    ).show()
                },
            )
        }
    }

    private fun SwitchCompat.setState(checked: Boolean) {
        isChecked = checked
    }

    private fun shouldSettingsBeVisible(addon: Addon) = !addon.installedState?.optionsPageUrl.isNullOrEmpty()
}
