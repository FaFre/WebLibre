/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSplitViewApi
import eu.weblibre.flutter_mozilla_components.pigeons.SplitViewState
import eu.weblibre.flutter_mozilla_components.split.SplitStateMirror
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Receives the split view state from Dart.
 *
 * Completes only after the state is in the mirror and the panes were laid out
 * for it, on the main thread. Dart's `pair()` waits for this before it selects
 * the new tab, so the selection reaches the coordinator after the pair does and
 * the split appears at once instead of the new tab showing alone first.
 */
class GeckoSplitViewApiImpl : GeckoSplitViewApi {
    override suspend fun setSplitState(state: SplitViewState) {
        withContext(Dispatchers.Main.immediate) {
            if (SplitStateMirror.accept(state)) {
                GlobalComponents.components?.browserPanes?.reconcileNow()
            }
        }
    }
}
