/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoTrackingProtectionApi
import eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionException
import mozilla.components.concept.engine.content.blocking.TrackingProtectionException as MozillaTrackingProtectionException

/**
 * Implementation of GeckoTrackingProtectionApi that manages per-site
 * Enhanced Tracking Protection exceptions using Mozilla Android Components'
 * TrackingProtectionUseCases.
 */
class GeckoTrackingProtectionApiImpl : GeckoTrackingProtectionApi {
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    override fun containsException(tabId: String, callback: (Result<Boolean>) -> Unit) {
        try {
            components.useCases.trackingProtectionUseCases.containsException(tabId) { hasException ->
                callback(Result.success(hasException))
            }
        } catch (e: Exception) {
            callback(Result.failure(e))
        }
    }

    override fun addException(tabId: String) {
        components.useCases.trackingProtectionUseCases.addException(tabId)
    }

    override fun removeException(tabId: String) {
        components.useCases.trackingProtectionUseCases.removeException(tabId)
    }

    override fun removeExceptionByUrl(url: String, callback: (Result<Unit>) -> Unit) {
        try {
            // Create a simple TrackingProtectionException implementation for removal
            val exception = object : MozillaTrackingProtectionException {
                override val url: String = url
            }
            components.useCases.trackingProtectionUseCases.removeException(exception)
            // The Mozilla API is synchronous, callback immediately after completion
            callback(Result.success(Unit))
        } catch (e: Exception) {
            callback(Result.failure(e))
        }
    }

    override fun fetchExceptions(callback: (Result<List<TrackingProtectionException>>) -> Unit) {
        try {
            components.useCases.trackingProtectionUseCases.fetchExceptions { mozillaExceptions ->
                val pigeonExceptions = mozillaExceptions.map { mozillaException ->
                    TrackingProtectionException(url = mozillaException.url)
                }
                callback(Result.success(pigeonExceptions))
            }
        } catch (e: Exception) {
            callback(Result.failure(e))
        }
    }

    override fun removeAllExceptions(callback: (Result<Unit>) -> Unit) {
        try {
            components.useCases.trackingProtectionUseCases.removeAllExceptions {
                callback(Result.success(Unit))
            }
        } catch (e: Exception) {
            callback(Result.failure(e))
        }
    }
}
