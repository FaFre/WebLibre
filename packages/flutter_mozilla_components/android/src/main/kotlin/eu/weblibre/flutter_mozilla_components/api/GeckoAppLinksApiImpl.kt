/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import android.content.Context
import android.content.Intent
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoAppLinksApi
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

/**
 * Implementation of GeckoAppLinksApi that detects and launches external applications
 * that can handle URLs.
 *
 * This uses Mozilla Android Components' AppLinksUseCases to properly detect if a native
 * app is available to handle a URL, matching the behavior in Firefox/Fenix.
 */
class GeckoAppLinksApiImpl(
    private val context: Context
) : GeckoAppLinksApi {
    companion object {
        private val coroutineScope = CoroutineScope(Dispatchers.Default + SupervisorJob())
    }

    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    override fun hasExternalApp(url: String, callback: (Result<Boolean>) -> Unit) {
        coroutineScope.launch {
            try {
                val redirect = components.useCases.appLinksUseCases.appLinkRedirect(url)
                callback(Result.success(redirect.hasExternalApp()))
            } catch (e: Exception) {
                callback(Result.success(false))
            }
        }
    }

    override fun openAppLink(url: String, callback: (Result<Boolean>) -> Unit) {
        coroutineScope.launch {
            try {
                val redirect = components.useCases.appLinksUseCases.appLinkRedirect(url)

                if (!redirect.hasExternalApp()) {
                    callback(Result.success(false))
                    return@launch
                }

                // Set FLAG_ACTIVITY_NEW_TASK to launch in new task
                // This prevents issues with app task stacks
                redirect.appIntent?.flags = Intent.FLAG_ACTIVITY_NEW_TASK

                components.useCases.appLinksUseCases.openAppLink.invoke(redirect.appIntent)
                callback(Result.success(true))
            } catch (e: Exception) {
                callback(Result.success(false))
            }
        }
    }
}
