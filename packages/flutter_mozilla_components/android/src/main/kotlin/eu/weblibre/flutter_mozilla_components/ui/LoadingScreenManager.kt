/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.ui

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.view.ContextThemeWrapper
import android.view.LayoutInflater
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import androidx.core.graphics.ColorUtils
import eu.weblibre.flutter_mozilla_components.PwaConstants
import eu.weblibre.flutter_mozilla_components.PwaSplashCache
import eu.weblibre.flutter_mozilla_components.R

/**
 * Displays a loading screen during PWA and Custom Tab initialization.
 *
 * - PWA with cached data: shows cached icon, app name, and theme color instantly from disk.
 * - PWA without cache / Custom Tab: shows WebLibre logo with domain name.
 *
 * No component dependencies — everything is resolved from intent extras and disk cache.
 */
class LoadingScreenManager private constructor(
    private val activity: Activity,
    private val container: FrameLayout
) {
    private var currentLoadingView: View? = null

    // Material3 theme wrapper for activities that use non-Material themes (e.g. AppCompat.Translucent)
    private val themedContext: Context
        get() = ContextThemeWrapper(activity, com.google.android.material.R.style.Theme_Material3_DayNight_NoActionBar)

    companion object {
        fun forActivity(activity: Activity, container: FrameLayout) =
            LoadingScreenManager(activity, container)

        fun isPwaIntent(intent: Intent?) =
            intent?.hasExtra(PwaConstants.EXTRA_PWA_PROFILE_UUID) == true

        fun hasCachedSplashData(intent: Intent?) =
            intent?.hasExtra(PwaConstants.EXTRA_PWA_SHORTCUT_ID) == true
    }

    /**
     * Shows the loading screen immediately based on intent analysis.
     * Can be called before components are initialized.
     */
    fun showLoadingForIntent(intent: Intent) {
        cleanup()

        val view = LayoutInflater.from(themedContext).inflate(
            R.layout.loading_screen, container, false
        )

        val iconView = view.findViewById<ImageView>(R.id.loading_icon)
        val nameView = view.findViewById<TextView>(R.id.loading_name)
        val statusView = view.findViewById<TextView>(R.id.loading_status)

        val shortcutId = intent.getStringExtra(PwaConstants.EXTRA_PWA_SHORTCUT_ID)
        val manifest = shortcutId?.let { PwaSplashCache.loadManifest(activity, it) }

        if (manifest != null) {
            // PWA with cached data — branded splash
            nameView.text = manifest.shortName ?: manifest.name ?: "Web App"

            val cachedIcon = PwaSplashCache.loadIcon(activity, shortcutId)
            if (cachedIcon != null) {
                iconView.setImageBitmap(cachedIcon)
            }

            manifest.themeColor?.let { themeColor ->
                applyThemeColor(view, themeColor, nameView, statusView)
            }
        } else {
            // Custom Tab or uncached PWA — WebLibre logo + domain
            val url = intent.dataString
            nameView.text = url?.let { extractDomain(it) } ?: "Web App"
        }

        container.addView(view)
        currentLoadingView = view
    }

    fun hideLoading(animate: Boolean = true) {
        currentLoadingView?.let { view ->
            if (animate) {
                view.animate()
                    .alpha(0f)
                    .setDuration(200)
                    .setListener(object : AnimatorListenerAdapter() {
                        override fun onAnimationEnd(animation: Animator) {
                            cleanup()
                        }
                    })
                    .start()
            } else {
                cleanup()
            }
        }
    }

    fun cleanup() {
        currentLoadingView?.let { container.removeView(it) }
        currentLoadingView = null
    }

    private fun applyThemeColor(view: View, themeColor: Int, nameView: TextView, statusView: TextView) {
        view.setBackgroundColor(themeColor)

        val isDark = ColorUtils.calculateLuminance(themeColor) < 0.5
        val primaryTextColor = if (isDark) Color.WHITE else Color.BLACK
        val secondaryTextColor = ColorUtils.setAlphaComponent(primaryTextColor, 0xB3)

        nameView.setTextColor(primaryTextColor)
        statusView.setTextColor(secondaryTextColor)
    }

    private fun extractDomain(url: String): String {
        return try {
            android.net.Uri.parse(url).host ?: url
        } catch (_: Exception) {
            url
        }
    }
}
