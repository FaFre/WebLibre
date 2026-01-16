/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import android.content.Context
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoPublicSuffixListApi
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import mozilla.components.lib.publicsuffixlist.PublicSuffixList

class GeckoPublicSuffixListApiImpl(
    private val context: Context
) : GeckoPublicSuffixListApi {
    companion object {
        private val coroutineScope = CoroutineScope(Dispatchers.Default + SupervisorJob())
    }

    private val publicSuffixList by lazy {
        PublicSuffixList(context)
    }

    override fun getPublicSuffixPlusOne(host: String, callback: (Result<String>) -> Unit) {
        coroutineScope.launch {
            try {
                // Get the public suffix + 1 (eTLD+1) for the host
                val result = publicSuffixList.getPublicSuffixPlusOne(host).await()
                // If result is null, fall back to the original host
                callback(Result.success(result ?: host))
            } catch (e: Exception) {
                // On any error, fall back to the original host
                callback(Result.success(host))
            }
        }
    }
}
