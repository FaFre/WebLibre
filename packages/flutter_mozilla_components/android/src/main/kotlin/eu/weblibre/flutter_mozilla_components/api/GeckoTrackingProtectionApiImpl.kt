/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoTrackingProtectionApi
import eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionException
import kotlinx.coroutines.suspendCancellableCoroutine
import mozilla.components.concept.engine.content.blocking.TrackingProtectionException as MozillaTrackingProtectionException
import kotlin.coroutines.resume

/**
 * Implementation of GeckoTrackingProtectionApi that manages per-site
 * Enhanced Tracking Protection exceptions using Mozilla Android Components'
 * TrackingProtectionUseCases.
 */
class GeckoTrackingProtectionApiImpl : GeckoTrackingProtectionApi {
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    override suspend fun containsException(tabId: String): Boolean =
        suspendCancellableCoroutine { continuation ->
            components.useCases.trackingProtectionUseCases.containsException(tabId) { hasException ->
                continuation.resume(hasException)
            }
        }

    override fun addException(tabId: String) {
        components.useCases.trackingProtectionUseCases.addException(tabId)
    }

    override fun removeException(tabId: String) {
        components.useCases.trackingProtectionUseCases.removeException(tabId)
    }

    override suspend fun removeExceptionByUrl(url: String) {
        // Create a simple TrackingProtectionException implementation for removal
        val exception = object : MozillaTrackingProtectionException {
            override val url: String = url
        }
        // The Mozilla API is synchronous, so this is done once the call returns
        components.useCases.trackingProtectionUseCases.removeException(exception)
    }

    override suspend fun fetchExceptions(): List<TrackingProtectionException> =
        suspendCancellableCoroutine { continuation ->
            components.useCases.trackingProtectionUseCases.fetchExceptions { mozillaExceptions ->
                val pigeonExceptions = mozillaExceptions.map { mozillaException ->
                    TrackingProtectionException(url = mozillaException.url)
                }
                continuation.resume(pigeonExceptions)
            }
        }

    override suspend fun removeAllExceptions() {
        suspendCancellableCoroutine<Unit> { continuation ->
            components.useCases.trackingProtectionUseCases.removeAllExceptions {
                continuation.resume(Unit)
            }
        }
    }
}
