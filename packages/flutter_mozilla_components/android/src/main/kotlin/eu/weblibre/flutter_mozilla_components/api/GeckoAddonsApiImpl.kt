/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import android.content.Context
import android.content.Intent
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.addons.AddonsActivity
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoAddonsApi
import eu.weblibre.flutter_mozilla_components.pigeons.WebExtensionActionType

class GeckoAddonsApiImpl(private val context: Context) : GeckoAddonsApi {
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    override fun startAddonManagerActivity() {
        val intent = Intent(context, AddonsActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        context.startActivity(intent)
    }

    override fun invokeAddonAction(extensionId: String, actionType: WebExtensionActionType) {
        when(actionType) {
            WebExtensionActionType.BROWSER -> components.features.webExtensionToolbarFeature.invokeAddonBrowserAction(extensionId)
            WebExtensionActionType.PAGE -> components.features.webExtensionToolbarFeature.invokeAddonPageAction(extensionId)
        }
    }

    override fun installAddon(url: String, callback: (Result<Unit>) -> Unit) {
        components.core.addonManager.installAddon(
            url = url,
            onSuccess = { _ ->
                callback(Result.success(Unit))
            },
            onError = { e ->
                callback(Result.failure(e))
            }
        )
    }
}