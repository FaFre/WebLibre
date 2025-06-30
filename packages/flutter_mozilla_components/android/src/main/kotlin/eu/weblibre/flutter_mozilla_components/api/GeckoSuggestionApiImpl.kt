/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.api.GeckoDeleteBrowsingDataControllerImpl.Companion
import eu.weblibre.flutter_mozilla_components.ext.toWebPBytes
import eu.weblibre.flutter_mozilla_components.pigeons.AutocompleteResult
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSuggestion
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSuggestionApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSuggestionEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSuggestionType
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import mozilla.components.concept.engine.Engine
import org.mozilla.gecko.util.ThreadUtils.runOnUiThread

class GeckoSuggestionApiImpl(
    private val suggestionEvents: GeckoSuggestionEvents
) : GeckoSuggestionApi {
    companion object {
        private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    }

    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    override fun getAutocompleteSuggestion(
        query: String,
        callback: (Result<AutocompleteResult?>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                val suggestion = components.core.historyStorage.getAutocompleteSuggestion(query)

                callback(Result.success( suggestion?.let { AutocompleteResult(
                    input = it.input,
                    url = it.url,
                    text = it.text,
                    totalItems = it.totalItems.toLong(),
                    source = it.source
                )}

                ))
            }
        }
    }

    override fun querySuggestions(text: String, providers: List<GeckoSuggestionType>) {
        for(provider in providers) {
            coroutineScope.launch {
                val results = when(provider) {
                    GeckoSuggestionType.SESSION -> components.search.sessionSuggestions.onInputChanged(text)
                    GeckoSuggestionType.CLIPBOARD -> components.search.clipboardSuggestions.onInputChanged(text)
                    GeckoSuggestionType.HISTORY -> components.search.historySuggestions.onInputChanged(text)
                }

                val mappedResults = results.map { result ->
                    GeckoSuggestion(
                        id = result.id,
                        title = result.title,
                        score = result.score.toLong(),
                        description = result.description,
                        type = provider,
                        editSuggestion = result.editSuggestion,
                        icon = result.icon?.toWebPBytes()
                    )
                }

                runOnUiThread {
                    suggestionEvents.onSuggestionResult(
                        System.currentTimeMillis(),
                        provider,
                        mappedResults
                    ) { }
                }
            }
        }
    }
}