/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.services

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import mozilla.components.concept.engine.Engine
import mozilla.components.feature.customtabs.AbstractCustomTabsService
import mozilla.components.feature.customtabs.store.CustomTabsServiceStore

class CustomTabsService : AbstractCustomTabsService() {
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    override val customTabsServiceStore: CustomTabsServiceStore by lazy { components.core.customTabsStore }
    override val engine: Engine by lazy { components.core.engine }
}