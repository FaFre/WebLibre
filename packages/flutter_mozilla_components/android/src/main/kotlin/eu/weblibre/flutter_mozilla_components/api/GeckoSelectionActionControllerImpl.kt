/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.feature.DefaultSelectionActionDelegate
import eu.weblibre.flutter_mozilla_components.pigeons.CustomSelectionAction
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSelectionActionController
import mozilla.components.feature.addons.logger

/**
 * Implementation of GeckoSelectionActionController that manages custom text selection actions
 * @property selectionActionDelegate Delegate handling selection actions
 */
class GeckoSelectionActionControllerImpl(
    private val selectionActionDelegate: DefaultSelectionActionDelegate
) : GeckoSelectionActionController {

    companion object {
        private const val TAG = "GeckoSelectionActionController"
    }

    /**
     * Sets the available custom selection actions
     * @param actions List of custom selection actions to be registered
     */
    override fun setActions(actions: List<CustomSelectionAction>) {
        try {
            require(actions.distinctBy { it.id }.size == actions.size) {
                "Duplicate action IDs found in selection actions"
            }

            logger.debug("$TAG: Setting ${actions.size} custom selection actions")
            selectionActionDelegate.actions = actions.associateBy { it.id }.also { actionMap ->
                logger.debug("$TAG: Registered actions: ${actionMap.keys.joinToString()}")
            }
        } catch (e: Exception) {
            logger.error("$TAG: Failed to set selection actions", e)
            throw IllegalArgumentException("Failed to set selection actions", e)
        }
    }
}
