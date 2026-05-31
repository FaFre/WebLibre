/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoGestureApi
import eu.weblibre.flutter_mozilla_components.pigeons.GestureConfig

/**
 * Stores the gesture-recognition configuration pushed from Dart. The browser
 * container's [eu.weblibre.flutter_mozilla_components.feature.GestureRecognizer]
 * reads it on the UI thread for every touch event.
 */
class GeckoGestureApiImpl : GeckoGestureApi {
    override fun setGestureConfig(config: GestureConfig) {
        GlobalComponents.gestureConfig = config
    }
}
