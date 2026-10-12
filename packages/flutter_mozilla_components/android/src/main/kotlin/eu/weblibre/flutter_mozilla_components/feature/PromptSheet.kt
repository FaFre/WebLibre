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
package eu.weblibre.flutter_mozilla_components.feature

import android.app.Dialog
import android.content.res.Configuration
import android.graphics.Color
import android.graphics.Outline
import android.graphics.drawable.ColorDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.ViewOutlineProvider
import android.view.Window
import android.view.WindowInsets
import android.view.WindowManager
import androidx.core.content.res.use
import androidx.core.graphics.ColorUtils
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import androidx.core.view.descendants
import androidx.core.view.updatePadding
import androidx.fragment.app.DialogFragment
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import com.google.android.material.color.MaterialColors
import java.util.Collections
import java.util.WeakHashMap
import kotlin.math.ceil
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt
import mozilla.components.feature.addons.ui.AddonDialogFragment
import mozilla.components.feature.downloads.DownloadDialogFragment

/**
 * Shows the browser's native prompts as M3 modal bottom sheets, the shape of
 * the browser's own sheets (the ⋮ menu, the tab tray): flush with the bottom
 * edge and, from Android 11, running behind the navigation bar, rounded at the
 * top in the surface container color, at most 640dp wide (#651).
 *
 * The prompts are Mozilla Components' download and extension prompts and the
 * download app chooser. Mozilla's offer a bottom gravity and a full width
 * (`PromptsStyling`) but no shape, and their windows float above the
 * navigation bar. So they are restyled once shown: the window is laid out
 * behind the system bars, the content clipped to the sheet's shape and kept
 * clear of the bars, and what the layouts paint from the window background
 * takes the sheet's color.
 *
 * Tied to the layouts of Mozilla's prompts, which paint their surfaces with
 * `?android:windowBackground`: recheck on an Android Components upgrade.
 */
internal object PromptSheet {
    private const val CORNER_RADIUS_DP = 28f
    private const val MAX_WIDTH_DP = 640f

    private val fragmentManagers = Collections.newSetFromMap(WeakHashMap<FragmentManager, Boolean>())

    // `onStart` shows a dialog again after every stop; it is restyled once.
    private val styledDialogs = Collections.newSetFromMap(WeakHashMap<Dialog, Boolean>())

    private val callbacks = object : FragmentManager.FragmentLifecycleCallbacks() {
        // Called after `onStart`, so after the dialog was shown, and before
        // anything is drawn.
        override fun onFragmentStarted(fm: FragmentManager, f: Fragment) {
            if (f is DialogFragment && f.isPrompt()) f.dialog?.let(::apply)
        }
    }

    /** Restyles the prompts [fragmentManager] shows from now on. */
    fun install(fragmentManager: FragmentManager) {
        if (fragmentManagers.add(fragmentManager)) {
            fragmentManager.registerFragmentLifecycleCallbacks(callbacks, false)
        }
    }

    private fun DialogFragment.isPrompt() =
        this is DownloadDialogFragment ||
            this is AddonDialogFragment ||
            this is DownloadAppChooserDialog

    /** Restyles [dialog], which is showing, as a modal bottom sheet. */
    fun apply(dialog: Dialog) {
        val window = dialog.window ?: return
        val sheet = dialog.findViewById<ViewGroup>(android.R.id.content)?.getChildAt(0) ?: return
        if (!styledDialogs.add(dialog)) return

        val context = sheet.context
        val density = context.resources.displayMetrics.density
        val windowBackground = context.obtainStyledAttributes(intArrayOf(android.R.attr.windowBackground))
            .use { it.getDrawable(0) }
        val color = MaterialColors.getColor(
            context,
            com.google.android.material.R.attr.colorSurfaceContainerLow,
            MaterialColors.getColor(context, android.R.attr.colorBackground, Color.WHITE),
        )
        val isLight = ColorUtils.calculateLuminance(color) > 0.5

        sheet.background = ColorDrawable(color)
        (sheet as? ViewGroup)?.descendants?.forEach { view ->
            if (view.background?.paintsLike(windowBackground) == true) {
                view.background = ColorDrawable(color)
            }
        }

        val radius = CORNER_RADIUS_DP * density
        var cornerRadius = radius
        sheet.outlineProvider = object : ViewOutlineProvider() {
            override fun getOutline(view: View, outline: Outline) {
                // Rounded at the top only: the bottom corners lie below the
                // view. A rounded rectangle clips on every API level, a path
                // only from 33.
                outline.setRoundRect(
                    0,
                    0,
                    view.width,
                    view.height + ceil(cornerRadius).toInt(),
                    cornerRadius,
                )
            }
        }
        sheet.clipToOutline = true

        window.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        window.setGravity(Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL)
        window.setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        window.setWindowAnimations(com.google.android.material.R.style.Animation_Material3_BottomSheetDialog)
        capWidth(window, density)
        // Again after a rotation or a resize, once laid out for it. Only then:
        // the window is laid out on every frame of a keyboard animation, and
        // its metrics are a call to the window manager.
        var cappedFor = sheet.resources.configuration.screenSize()
        sheet.viewTreeObserver.addOnGlobalLayoutListener {
            val screenSize = sheet.resources.configuration.screenSize()
            if (screenSize != cappedFor) {
                cappedFor = screenSize
                capWidth(window, density)
            }
        }

        // Before 11 a floating window can't be laid out behind the system
        // bars: the sheet stays above the navigation bar, and the system keeps
        // it clear of the bars and the keyboard as before.
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) return

        // A floating window keeps clear of the system bars; this one runs
        // behind them and keeps only its content clear, below. In a screen
        // layout: the decor of a floating window takes the bars' insets for
        // itself otherwise, and the content never sees them.
        window.attributes = window.attributes.apply { fitInsetsTypes = 0 }
        WindowCompat.setDecorFitsSystemWindows(window, false)
        window.addFlags(
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS,
        )
        @Suppress("DEPRECATION")
        window.navigationBarColor = Color.TRANSPARENT
        window.isNavigationBarContrastEnforced = false
        WindowInsetsControllerCompat(window, window.decorView).isAppearanceLightNavigationBars = isLight

        val basePadding = intArrayOf(sheet.paddingLeft, sheet.paddingTop, sheet.paddingRight, sheet.paddingBottom)
        ViewCompat.setOnApplyWindowInsetsListener(sheet) { view, insets ->
            val bars = insets.getInsets(
                WindowInsetsCompat.Type.systemBars() or WindowInsetsCompat.Type.displayCutout(),
            )
            val keyboard = insets.getInsets(WindowInsetsCompat.Type.ime())
            val padding = intArrayOf(
                basePadding[0] + bars.left,
                basePadding[1] + bars.top,
                basePadding[2] + bars.right,
                basePadding[3] + max(bars.bottom, keyboard.bottom),
            )
            val paddingChanged = !padding.contentEquals(
                intArrayOf(view.paddingLeft, view.paddingTop, view.paddingRight, view.paddingBottom),
            )
            view.updatePadding(left = padding[0], top = padding[1], right = padding[2], bottom = padding[3])
            // The window wraps the sheet, but the pass that hands it new insets
            // measures it against its current height and lays out no further,
            // so padding added here would only be clipped. A layout of its own
            // lets the window grow or shrink to fit.
            if (paddingChanged) view.post { view.requestLayout() }

            // A sheet as tall as the window runs under the status bar, and
            // drops its corners there as an expanded M3 sheet does.
            val underStatusBar = bars.top > 0
            val newRadius = if (underStatusBar) 0f else radius
            if (newRadius != cornerRadius) {
                cornerRadius = newRadius
                view.invalidateOutline()
            }
            if (underStatusBar) {
                WindowInsetsControllerCompat(window, window.decorView).isAppearanceLightStatusBars = isLight
            }
            insets
        }
        ViewCompat.requestApplyInsets(sheet)
    }

    /**
     * At most [MAX_WIDTH_DP] wide and, from Android 11, centered clear of a
     * navigation bar on either side, as the browser's own sheets are. Before,
     * the window keeps clear of the bars itself.
     */
    private fun capWidth(window: Window, density: Float) {
        val (windowWidth, availableWidth) = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val metrics = window.windowManager.currentWindowMetrics
            val sides = metrics.windowInsets.getInsets(
                WindowInsets.Type.systemBars() or WindowInsets.Type.displayCutout(),
            )
            metrics.bounds.width().let { it to it - 2 * max(sides.left, sides.right) }
        } else {
            // The width the system leaves the window beside the bars.
            val width = (window.context.resources.configuration.screenWidthDp * density).roundToInt()
            width to width
        }
        val width = min(availableWidth, (MAX_WIDTH_DP * density).roundToInt())
        val layoutWidth = if (width >= windowWidth) ViewGroup.LayoutParams.MATCH_PARENT else width
        if (window.attributes.width != layoutWidth) {
            window.setLayout(layoutWidth, ViewGroup.LayoutParams.WRAP_CONTENT)
        }
    }

    private fun Configuration.screenSize() = screenWidthDp to screenHeightDp

    /** Whether this paints what [windowBackground] paints. */
    private fun Drawable.paintsLike(windowBackground: Drawable?): Boolean = when {
        windowBackground == null -> false
        this is ColorDrawable && windowBackground is ColorDrawable -> color == windowBackground.color
        else -> constantState != null && constantState == windowBackground.constantState
    }
}
