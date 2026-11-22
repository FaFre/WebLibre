/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.security

import mozilla.components.ExperimentalAndroidComponentsApi
import mozilla.components.concept.engine.Engine
import mozilla.components.concept.engine.preferences.Branch
import mozilla.components.support.base.log.logger.Logger

/**
 * Writes Gecko prefs through the engine's browser-pref API.
 *
 * GeckoRuntimeSettings has no generic pref setter — setInt, setBoolean and
 * setString simply do not exist on it — so this is the supported way to set an
 * arbitrary pref. The write is asynchronous, which is fine here: these are
 * runtime prefs that Gecko reads on the next navigation, not builder-time
 * settings.
 */
@OptIn(ExperimentalAndroidComponentsApi::class)
class GeckoPrefs(private val engine: Engine) {

    private val logger = Logger("GeckoPrefs")

    fun setBoolean(name: String, value: Boolean) = write(name, value)

    fun setInt(name: String, value: Int) = write(name, value)

    fun setString(name: String, value: String) = write(name, value)

    private fun write(name: String, value: Any) {
        // setBrowserPref is overloaded per type, so the value has to be narrowed
        // before it can be passed on.
        when (value) {
            is Boolean -> engine.setBrowserPref(
                name,
                value,
                Branch.USER,
                onSuccess = {},
                onError = { error: Throwable -> logger.warn("Could not set pref $name", error) },
            )
            is Int -> engine.setBrowserPref(
                name,
                value,
                Branch.USER,
                onSuccess = {},
                onError = { error: Throwable -> logger.warn("Could not set pref $name", error) },
            )
            is String -> engine.setBrowserPref(
                name,
                value,
                Branch.USER,
                onSuccess = {},
                onError = { error: Throwable -> logger.warn("Could not set pref $name", error) },
            )
            else -> logger.warn("Unsupported pref type for $name")
        }
    }
}
