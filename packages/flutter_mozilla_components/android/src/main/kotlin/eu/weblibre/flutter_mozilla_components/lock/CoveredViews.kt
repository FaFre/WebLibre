/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
package eu.weblibre.flutter_mozilla_components.lock

import android.view.View
import android.view.ViewGroup
import java.lang.ref.WeakReference

/**
 * The views a lock panel sits on top of, taken out of reach while it does.
 *
 * Covered on screen is not covered: a screen reader still reads a view
 * underneath, and a hardware keyboard keeps typing into whatever had focus.
 * [cover] hides [views] from accessibility and blocks focus into them;
 * [uncover] puts back how they were set up before, and the focus.
 */
internal class CoveredViews(private val views: List<ViewGroup>) {
    private class Setup(
        val view: ViewGroup,
        val importantForAccessibility: Int,
        val descendantFocusability: Int,
    )

    /** Null while uncovered. */
    private var setup: List<Setup>? = null

    private var focusBeforeCover: WeakReference<View>? = null

    val isCovered: Boolean
        get() = setup != null

    fun cover() {
        if (setup != null) return

        val focused = views.firstNotNullOfOrNull { it.findFocus() }
        focusBeforeCover = focused?.let(::WeakReference)

        setup = views.map { view ->
            Setup(view, view.importantForAccessibility, view.descendantFocusability)
        }
        views.forEach { view ->
            view.importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO_HIDE_DESCENDANTS
            view.descendantFocusability = ViewGroup.FOCUS_BLOCK_DESCENDANTS
        }

        // Blocking keeps focus from moving in, but leaves a view that has it.
        // Cleared after blocking, so it cannot land back in here.
        focused?.clearFocus()
    }

    fun uncover() {
        val setup = setup ?: return
        this.setup = null

        setup.forEach {
            it.view.importantForAccessibility = it.importantForAccessibility
            it.view.descendantFocusability = it.descendantFocusability
        }

        focusBeforeCover?.get()?.takeIf { it.isAttachedToWindow }?.requestFocus()
        focusBeforeCover = null
    }
}
