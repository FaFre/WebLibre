/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.components

import android.content.Context
import mozilla.components.feature.awesomebar.provider.ClipboardSuggestionProvider
import mozilla.components.feature.awesomebar.provider.HistoryStorageSuggestionProvider
import mozilla.components.feature.awesomebar.provider.SessionSuggestionProvider

class Search(
    private val context: Context,
    private val core: Core,
    private val useCases: UseCases,
) {
    val sessionSuggestions by lazy {
        SessionSuggestionProvider(
            context.resources,
            core.store,
            useCases.tabsUseCases.selectTab,
        )
    }

    val clipboardSuggestions by lazy {
        ClipboardSuggestionProvider(
            context,
            useCases.sessionUseCases.loadUrl,
        )
    }

    val historySuggestions by lazy {
        HistoryStorageSuggestionProvider(
            core.historyStorage,
            useCases.sessionUseCases.loadUrl,
            core.icons,
            core.engine,
        )
    }
}