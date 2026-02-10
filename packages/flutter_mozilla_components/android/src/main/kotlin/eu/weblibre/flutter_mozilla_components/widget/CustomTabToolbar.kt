/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.widget

import android.content.Context
import android.util.AttributeSet
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.TextView
import com.google.android.material.card.MaterialCardView
import com.google.android.material.color.MaterialColors
import com.mikepenz.iconics.IconicsDrawable
import com.mikepenz.iconics.typeface.IIcon
import com.mikepenz.iconics.typeface.library.community.material.CommunityMaterial
import com.mikepenz.iconics.utils.colorInt
import com.mikepenz.iconics.utils.sizeDp
import eu.weblibre.flutter_mozilla_components.R
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.mapNotNull
import mozilla.components.browser.state.selector.findCustomTab
import mozilla.components.browser.state.state.CustomTabSessionState
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.lib.state.ext.flowScoped
import mozilla.components.support.ktx.kotlinx.coroutines.flow.ifAnyChanged
import mozilla.components.support.ktx.util.URLStringUtils

/**
 * Custom tab toolbar with pill-shaped Material 3 design.
 * Uses MDI (Pictogrammers) icons via the Iconics library.
 */
class CustomTabToolbar @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : FrameLayout(context, attrs, defStyleAttr) {

    private val toolbarCard: MaterialCardView
    private val closeButton: ImageButton
    private val securityIcon: ImageView
    private val urlText: TextView
    private val shareButton: ImageButton
    private val openInBrowserButton: ImageButton
    private val menuButton: ImageButton

    private var sessionId: String? = null
    private var store: BrowserStore? = null
    private var urlScope: CoroutineScope? = null
    private var securityScope: CoroutineScope? = null

    var onCloseListener: (() -> Unit)? = null
    var onShareListener: (() -> Unit)? = null
    var onOpenInBrowserListener: (() -> Unit)? = null
    var onMenuListener: (() -> Unit)? = null

    init {
        inflate(context, R.layout.custom_tab_toolbar, this)

        toolbarCard = findViewById(R.id.toolbarCard)
        closeButton = findViewById(R.id.closeButton)
        securityIcon = findViewById(R.id.securityIcon)
        urlText = findViewById(R.id.urlText)
        shareButton = findViewById(R.id.shareButton)
        openInBrowserButton = findViewById(R.id.openInBrowserButton)
        menuButton = findViewById(R.id.menuButton)

        closeButton.setOnClickListener { onCloseListener?.invoke() }
        shareButton.setOnClickListener { onShareListener?.invoke() }
        openInBrowserButton.setOnClickListener { onOpenInBrowserListener?.invoke() }
        menuButton.setOnClickListener { onMenuListener?.invoke() }

        applyMaterial3Colors()
        applyIcons()
    }

    fun bind(sessionId: String, store: BrowserStore, toolbarColor: Int? = null) {
        this.sessionId = sessionId
        this.store = store

        toolbarColor?.let { applyCustomColors(it) }

        store.state.findCustomTab(sessionId)?.let { tab ->
            updateUrl(tab)
            updateSecurityIcon(tab)
        }

        observeUrlChanges()
        observeSecurityChanges()
    }

    fun unbind() {
        urlScope?.cancel()
        urlScope = null
        securityScope?.cancel()
        securityScope = null
    }

    fun getMenuButton(): View = menuButton

    fun getUrl(): String? = urlText.text?.toString()

    private fun applyMaterial3Colors() {
        val surfaceColor = MaterialColors.getColor(this, com.google.android.material.R.attr.colorSurface)
        val onSurfaceColor = MaterialColors.getColor(this, com.google.android.material.R.attr.colorOnSurface)
        toolbarCard.setCardBackgroundColor(surfaceColor)
        urlText.setTextColor(onSurfaceColor)
    }

    private fun applyIcons() {
        val iconColor = MaterialColors.getColor(this, com.google.android.material.R.attr.colorOnSurfaceVariant)

        closeButton.setImageDrawable(mdiIcon(CommunityMaterial.Icon.cmd_close, 20, iconColor))
        shareButton.setImageDrawable(mdiIcon(CommunityMaterial.Icon3.cmd_share_variant, 18, iconColor))
        openInBrowserButton.setImageDrawable(mdiIcon(CommunityMaterial.Icon3.cmd_open_in_new, 18, iconColor))
        menuButton.setImageDrawable(mdiIcon(CommunityMaterial.Icon.cmd_dots_vertical, 18, iconColor))
    }

    private fun applyCustomColors(color: Int) {
        toolbarCard.setCardBackgroundColor(color)
        val textColor = if (isDarkColor(color)) {
            android.graphics.Color.WHITE
        } else {
            android.graphics.Color.BLACK
        }
        urlText.setTextColor(textColor)

        closeButton.setImageDrawable(mdiIcon(CommunityMaterial.Icon.cmd_close, 20, textColor))
        shareButton.setImageDrawable(mdiIcon(CommunityMaterial.Icon3.cmd_share_variant, 18, textColor))
        openInBrowserButton.setImageDrawable(mdiIcon(CommunityMaterial.Icon3.cmd_open_in_new, 18, textColor))
        menuButton.setImageDrawable(mdiIcon(CommunityMaterial.Icon.cmd_dots_vertical, 18, textColor))
    }

    private fun isDarkColor(color: Int): Boolean {
        val darkness = 1 - (0.299 * android.graphics.Color.red(color) +
                0.587 * android.graphics.Color.green(color) +
                0.114 * android.graphics.Color.blue(color)) / 255
        return darkness >= 0.5
    }

    private fun observeUrlChanges() {
        val sessionId = this.sessionId ?: return
        val store = this.store ?: return

        urlScope = store.flowScoped { flow ->
            flow
                .mapNotNull { state -> state.findCustomTab(sessionId) }
                .ifAnyChanged { tab -> arrayOf(tab.content.url) }
                .collect { tab -> updateUrl(tab) }
        }
    }

    private fun observeSecurityChanges() {
        val sessionId = this.sessionId ?: return
        val store = this.store ?: return

        securityScope = store.flowScoped { flow ->
            flow
                .mapNotNull { state -> state.findCustomTab(sessionId) }
                .ifAnyChanged { tab -> arrayOf(tab.content.securityInfo.isSecure) }
                .collect { tab -> updateSecurityIcon(tab) }
        }
    }

    private fun updateUrl(tab: CustomTabSessionState) {
        urlText.text = URLStringUtils.toDisplayUrl(tab.content.url)
    }

    private fun updateSecurityIcon(tab: CustomTabSessionState) {
        if (tab.content.securityInfo.isSecure) {
            val color = MaterialColors.getColor(this, com.google.android.material.R.attr.colorOnSurfaceVariant)
            securityIcon.setImageDrawable(mdiIcon(CommunityMaterial.Icon2.cmd_lock, 16, color))
        } else {
            val color = MaterialColors.getColor(this, android.R.attr.colorError)
            securityIcon.setImageDrawable(mdiIcon(CommunityMaterial.Icon3.cmd_web, 16, color))
        }
    }

    private fun mdiIcon(icon: IIcon, sizeDp: Int, color: Int): IconicsDrawable {
        return IconicsDrawable(context, icon).apply {
            this.sizeDp = sizeDp
            this.colorInt = color
        }
    }
}
