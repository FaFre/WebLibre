/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import android.content.Context
import android.content.Intent
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.addons.AddonInternalSettingsActivity
import eu.weblibre.flutter_mozilla_components.addons.AddonsActivity
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoAddonsApi
import eu.weblibre.flutter_mozilla_components.pigeons.WebExtensionActionType
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import mozilla.components.concept.engine.webextension.InstallationMethod

class GeckoAddonsApiImpl(private val context: Context) : GeckoAddonsApi {
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }
    private val scope = CoroutineScope(Dispatchers.IO)

    override fun startAddonManagerActivity() {
        val intent = Intent(context, AddonsActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        context.startActivity(intent)
    }

    override fun startAddonSettingsActivity(extensionId: String) {
        scope.launch {
            val addon = runCatching {
                components.core.addonManager.getAddons()
                    .find { it.id == extensionId }
            }.getOrNull()

            if (addon == null) {
                withContext(Dispatchers.Main) {
                    startAddonManagerActivity()
                }
                return@launch
            }

            val optionsPageUrl = addon.installedState?.optionsPageUrl
            if (optionsPageUrl.isNullOrEmpty()) {
                withContext(Dispatchers.Main) {
                    startAddonManagerActivity()
                }
                return@launch
            }

            withContext(Dispatchers.Main) {
                if (addon.installedState?.openOptionsPageInTab == true) {
                    components.useCases.tabsUseCases.selectOrAddTab(
                        url = optionsPageUrl,
                        ignoreFragment = true,
                    )
                    val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                    launchIntent?.addFlags(
                        Intent.FLAG_ACTIVITY_NEW_TASK or
                            Intent.FLAG_ACTIVITY_CLEAR_TOP or
                            Intent.FLAG_ACTIVITY_SINGLE_TOP,
                    )
                    if (launchIntent != null) {
                        context.startActivity(launchIntent)
                    } else {
                        startAddonManagerActivity()
                    }
                } else {
                    val intent = Intent(context, AddonInternalSettingsActivity::class.java)
                    intent.putExtra("add_on", addon)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    context.startActivity(intent)
                }
            }
        }
    }

    override fun invokeAddonAction(extensionId: String, actionType: WebExtensionActionType) {
        when(actionType) {
            WebExtensionActionType.BROWSER -> components.features.webExtensionToolbarFeature.invokeAddonBrowserAction(extensionId)
            WebExtensionActionType.PAGE -> components.features.webExtensionToolbarFeature.invokeAddonPageAction(extensionId)
        }
    }

    override fun installAddon(url: String, callback: (Result<Unit>) -> Unit) {
        val installMethod = if (url.startsWith("file://")) {
            InstallationMethod.FROM_FILE
        } else {
            null
        }

        components.core.addonManager.installAddon(
            url = url,
            installationMethod = installMethod,
            onSuccess = { _ ->
                callback(Result.success(Unit))
            },
            onError = { e ->
                callback(Result.failure(e))
            }
        )
    }
}
