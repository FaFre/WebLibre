/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.middleware

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.asCoroutineDispatcher
import kotlinx.coroutines.launch
import mozilla.components.browser.state.state.TabSessionState
import mozilla.components.concept.storage.DocumentType
import mozilla.components.concept.storage.HistoryMetadataKey
import mozilla.components.concept.storage.HistoryMetadataObservation
import mozilla.components.concept.storage.HistoryMetadataStorage
import mozilla.components.support.base.utils.NamedThreadFactory
import java.util.concurrent.Executors

class HistoryMetadataService(
    private val storage: HistoryMetadataStorage,
    private val scope: CoroutineScope = CoroutineScope(
        Executors.newSingleThreadExecutor(
            NamedThreadFactory("HistoryMetadataService"),
        ).asCoroutineDispatcher(),
    ),
) {
    private val tabsLastUpdated = mutableMapOf<String, Long>()

    fun createMetadata(tab: TabSessionState): HistoryMetadataKey {
        val existingMetadata = tab.historyMetadata
        val metadataKey = if (existingMetadata != null && existingMetadata.url == tab.content.url) {
            existingMetadata
        } else {
            HistoryMetadataKey(url = tab.content.url)
        }

        val documentTypeObservation = HistoryMetadataObservation.DocumentTypeObservation(
            documentType = when (tab.mediaSessionState) {
                null -> DocumentType.Regular
                else -> DocumentType.Media
            },
        )

        scope.launch {
            storage.noteHistoryMetadataObservation(metadataKey, documentTypeObservation)
        }

        return metadataKey
    }

    fun cleanup(olderThan: Long) {
        scope.launch {
            storage.deleteHistoryMetadataOlderThan(olderThan)
        }
    }

    fun updateMetadata(key: HistoryMetadataKey, tab: TabSessionState) {
        val now = System.currentTimeMillis()
        val lastAccess = tab.lastAccess
        if (lastAccess == 0L) {
            return
        }

        scope.launch {
            val lastUpdated = tabsLastUpdated[tab.id] ?: 0
            if (lastUpdated > lastAccess) {
                return@launch
            }

            val viewTimeObservation = HistoryMetadataObservation.ViewTimeObservation(
                viewTime = (now - lastAccess).toInt(),
            )
            storage.noteHistoryMetadataObservation(key, viewTimeObservation)
            tabsLastUpdated[tab.id] = now
        }
    }
}
