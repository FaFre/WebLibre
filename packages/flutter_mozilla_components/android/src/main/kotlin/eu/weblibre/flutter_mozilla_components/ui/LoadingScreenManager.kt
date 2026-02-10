/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.ui

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.ObjectAnimator
import android.app.Activity
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Color
import android.view.LayoutInflater
import android.view.View
import android.view.animation.AccelerateDecelerateInterpolator
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import androidx.core.graphics.ColorUtils
import eu.weblibre.flutter_mozilla_components.PwaConstants
import eu.weblibre.flutter_mozilla_components.R
import mozilla.components.browser.icons.BrowserIcons
import mozilla.components.browser.icons.IconRequest
import mozilla.components.concept.engine.manifest.WebAppManifest
import mozilla.components.support.base.log.logger.Logger
import kotlinx.coroutines.*

/**
 * Manager for displaying branded loading screens during PWA and Custom Tab initialization.
 * Handles loading of icons, theming, and animations.
 */
class LoadingScreenManager private constructor(
    private val activity: Activity,
    private val container: FrameLayout
) {
    private val logger = Logger("LoadingScreenManager")
    private var currentLoadingView: View? = null
    private var pulseAnimator: ObjectAnimator? = null

    companion object {
        /**
         * Creates a LoadingScreenManager for the given activity.
         * The container should be the root view where loading screens will be added.
         */
        fun forActivity(activity: Activity, container: FrameLayout): LoadingScreenManager {
            return LoadingScreenManager(activity, container)
        }

        /**
         * Detects if an intent is for a PWA based on the extras.
         */
        fun isPwaIntent(intent: Intent?): Boolean {
            return intent?.hasExtra(PwaConstants.EXTRA_PWA_PROFILE_UUID) == true
        }

        /**
         * Extracts URL from an intent.
         */
        fun extractUrl(intent: Intent?): String? {
            return intent?.dataString
        }
    }

    /**
     * Shows the appropriate loading screen immediately based on intent analysis.
     * This can be called before components are initialized.
     * 
     * @param intent The intent to analyze for type detection
     */
    fun showLoadingForIntent(intent: Intent) {
        when {
            isPwaIntent(intent) -> showPwaPlaceholder(intent)
            else -> showCustomTabPlaceholder(intent)
        }
    }

    /**
     * Shows a PWA placeholder loading screen immediately (before components are ready).
     * Uses URL to extract domain as temporary app name.
     */
    private fun showPwaPlaceholder(intent: Intent) {
        cleanup()
        
        val view = LayoutInflater.from(activity).inflate(
            R.layout.pwa_loading_screen,
            container,
            false
        )
        
        // Extract URL and use domain as temporary name
        val url = intent.dataString
        val domain = url?.let { extractDomain(it) } ?: "Web App"
        
        // Set temporary app name (will be replaced with actual name once manifest loads)
        val nameView = view.findViewById<TextView>(R.id.pwa_name)
        nameView.text = domain
        
        // Show WebLibre logo as placeholder (already set in XML layout)
        val iconView = view.findViewById<ImageView>(R.id.pwa_icon)
        iconView.alpha = 0.5f
        
        // Start pulsing animation
        startPulseAnimation(view)
        
        container.addView(view)
        currentLoadingView = view
    }

    /**
     * Shows a Custom Tab placeholder loading screen immediately (before components are ready).
     */
    private fun showCustomTabPlaceholder(intent: Intent) {
        cleanup()
        
        val view = LayoutInflater.from(activity).inflate(
            R.layout.custom_tab_loading_screen,
            container,
            false
        )
        
        // Extract and display domain
        val url = intent.dataString ?: return
        val domainView = view.findViewById<TextView>(R.id.custom_tab_domain)
        domainView.text = extractDomain(url)
        
        container.addView(view)
        currentLoadingView = view
    }

    /**
     * Enhances the current loading screen with actual PWA data once components are ready.
     * This updates the placeholder with real manifest data.
     */
    fun enhancePwaLoading(
        manifest: WebAppManifest,
        browserIcons: BrowserIcons,
        coroutineScope: CoroutineScope
    ) {
        currentLoadingView?.let { view ->
            // Apply theme colors if available
            manifest.themeColor?.let { colorInt ->
                view.setBackgroundColor(colorInt)

                val isDark = ColorUtils.calculateLuminance(colorInt) < 0.5
                val primaryTextColor = if (isDark) Color.WHITE else Color.BLACK
                val secondaryTextColor = ColorUtils.setAlphaComponent(primaryTextColor, 0xB3)

                view.findViewById<TextView>(R.id.pwa_name)?.setTextColor(primaryTextColor)
                view.findViewById<TextView>(R.id.pwa_status)?.setTextColor(secondaryTextColor)
            }
            
            // Update app name
            val nameView = view.findViewById<TextView>(R.id.pwa_name)
            val appName = manifest.shortName ?: manifest.name
            if (appName != null && nameView.text != appName) {
                nameView.text = appName
            }
            
            // Load the PWA icon asynchronously and update
            coroutineScope.launch(Dispatchers.IO) {
                loadPwaIcon(manifest, browserIcons)?.let { bitmap ->
                    withContext(Dispatchers.Main) {
                        val iconView = view.findViewById<ImageView>(R.id.pwa_icon)
                        iconView.alpha = 1.0f
                        iconView.setImageBitmap(bitmap)
                    }
                }
            }
        }
    }

    /**
     * Enhances the Custom Tab loading screen with favicon once components are ready.
     */
    fun enhanceCustomTabLoading(
        url: String,
        browserIcons: BrowserIcons,
        coroutineScope: CoroutineScope
    ) {
        currentLoadingView?.let { view ->
            coroutineScope.launch(Dispatchers.IO) {
                try {
                    val iconRequest = IconRequest(
                        url = url,
                        size = IconRequest.Size.DEFAULT
                    )
                    val iconResult = browserIcons.loadIcon(iconRequest).await()
                    iconResult?.bitmap?.let { bitmap ->
                        withContext(Dispatchers.Main) {
                            val iconView = view.findViewById<ImageView>(R.id.custom_tab_icon)
                            iconView.setImageBitmap(bitmap)
                            iconView.alpha = 1.0f
                        }
                    }
                } catch (e: Exception) {
                    logger.debug("Failed to load favicon for $url")
                }
            }
        }
    }

    /**
     * Hides the loading screen with an optional fade-out animation.
     */
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

    /**
     * Cleans up the loading view and animations.
     */
    fun cleanup() {
        pulseAnimator?.cancel()
        pulseAnimator = null
        
        currentLoadingView?.let { view ->
            container.removeView(view)
        }
        currentLoadingView = null
    }

    private fun startPulseAnimation(view: View) {
        val pulseView = view.findViewById<View>(R.id.pwa_icon_pulse)
            ?: return
        
        pulseView.alpha = 0.0f
        pulseAnimator = ObjectAnimator.ofFloat(pulseView, "alpha", 0.0f, 0.3f, 0.0f).apply {
            duration = 1500
            repeatCount = ObjectAnimator.INFINITE
            interpolator = AccelerateDecelerateInterpolator()
            start()
        }
    }

    private suspend fun loadPwaIcon(
        manifest: WebAppManifest,
        browserIcons: BrowserIcons
    ): Bitmap? {
        return try {
            val iconResource = manifest.icons
                .filter { it.purpose.contains(WebAppManifest.Icon.Purpose.MASKABLE) ||
                         it.purpose.contains(WebAppManifest.Icon.Purpose.ANY) }
                .maxByOrNull { (it.sizes?.maxOf { size -> size.width * size.height } ?: 0) }
                ?: manifest.icons.firstOrNull()

            iconResource?.let { icon ->
                val iconRequest = IconRequest(
                    url = manifest.startUrl,
                    size = IconRequest.Size.LAUNCHER,
                    resources = listOf(
                        IconRequest.Resource(
                            url = icon.src,
                            type = IconRequest.Resource.Type.MANIFEST_ICON,
                            sizes = icon.sizes?.map { size ->
                                mozilla.components.concept.engine.manifest.Size(size.width, size.height)
                            } ?: emptyList(),
                            mimeType = icon.type,
                            maskable = icon.purpose.contains(WebAppManifest.Icon.Purpose.MASKABLE)
                        )
                    )
                )
                
                val result = browserIcons.loadIcon(iconRequest).await()
                result?.bitmap
            }
        } catch (e: Exception) {
            logger.error("Failed to load PWA icon", e)
            null
        }
    }

    private fun extractDomain(url: String): String {
        return try {
            val uri = android.net.Uri.parse(url)
            uri.host ?: url
        } catch (e: Exception) {
            url
        }
    }
}
