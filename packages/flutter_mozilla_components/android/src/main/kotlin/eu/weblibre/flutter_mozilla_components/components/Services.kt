/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.components

import android.content.Context
import androidx.preference.PreferenceManager
import eu.weblibre.flutter_mozilla_components.R
import eu.weblibre.flutter_mozilla_components.ext.getPreferenceKey
import mozilla.components.feature.app.links.AppLinksInterceptor
import mozilla.components.feature.tabs.TabsUseCases

/**
 * Component group which encapsulates foreground-friendly services.
 */
class Services(
    private val context: Context,
    private val tabsUseCases: TabsUseCases,
) {
    private val prefs = PreferenceManager.getDefaultSharedPreferences(context)

    val appLinksInterceptor by lazy {
        AppLinksInterceptor(
            context,
            launchInApp = {
                prefs.getBoolean(context.getPreferenceKey(R.string.pref_key_launch_external_app), false)
            },
        )
    }
}
