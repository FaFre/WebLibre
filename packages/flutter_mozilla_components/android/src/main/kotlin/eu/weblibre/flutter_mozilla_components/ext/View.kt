/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.ext

import android.view.SurfaceView
import android.view.View
import android.view.ViewGroup

/** Runs [action] on every [SurfaceView] in [view]'s subtree, [view] included. */
internal fun forEachSurfaceView(view: View, action: (SurfaceView) -> Unit) {
    if (view is SurfaceView) {
        action(view)
        return
    }
    if (view !is ViewGroup) return
    for (i in 0 until view.childCount) {
        forEachSurfaceView(view.getChildAt(i), action)
    }
}
