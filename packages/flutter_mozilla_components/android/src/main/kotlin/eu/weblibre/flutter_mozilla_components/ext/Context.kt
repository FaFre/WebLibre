/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.ext

import android.content.Context
import androidx.annotation.StringRes

fun Context.getPreferenceKey(@StringRes resourceId: Int): String =
    resources.getString(resourceId)