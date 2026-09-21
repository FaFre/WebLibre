/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import android.content.Context
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoPublicSuffixListApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import mozilla.components.lib.publicsuffixlist.PublicSuffixList

class GeckoPublicSuffixListApiImpl(
    private val context: Context
) : GeckoPublicSuffixListApi {
    private val publicSuffixList by lazy {
        PublicSuffixList(context)
    }

    override suspend fun getPublicSuffixPlusOne(host: String): String =
        withContext(Dispatchers.Default) {
            try {
                // Get the public suffix + 1 (eTLD+1) for the host
                val result = publicSuffixList.getPublicSuffixPlusOne(host).await()
                // If result is null, fall back to the original host
                result ?: host
            } catch (e: Exception) {
                // On any error, fall back to the original host
                host
            }
        }
}
