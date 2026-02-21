/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.widget

import android.content.Context
import android.graphics.drawable.Drawable
import android.net.Uri
import android.util.AttributeSet
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.content.res.AppCompatResources
import androidx.core.content.ContextCompat
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
    private val privateMaskIcon: ImageView
    private val securityIcon: ImageView
    private val titleText: TextView
    private val urlText: TextView
    private val shareButton: ImageButton
    private val openInBrowserButton: ImageButton
    private val menuButton: ImageButton

    private var sessionId: String? = null
    private var store: BrowserStore? = null
    private var urlScope: CoroutineScope? = null
    private var titleScope: CoroutineScope? = null
    private var securityScope: CoroutineScope? = null
    private var isPrivateSession: Boolean = false

    var onCloseListener: (() -> Unit)? = null
    var onShareListener: (() -> Unit)? = null
    var onOpenInBrowserListener: (() -> Unit)? = null
    var onMenuListener: (() -> Unit)? = null

    init {
        inflate(context, R.layout.custom_tab_toolbar, this)

        toolbarCard = findViewById(R.id.toolbarCard)
        closeButton = findViewById(R.id.closeButton)
        privateMaskIcon = findViewById(R.id.privateMaskIcon)
        securityIcon = findViewById(R.id.securityIcon)
        titleText = findViewById(R.id.titleText)
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

        val tab = store.state.findCustomTab(sessionId)
        isPrivateSession = tab?.content?.private == true

        if (toolbarColor != null) {
            applyCustomColors(toolbarColor)
        } else {
            applyMaterial3Colors()
            applyIcons()
        }

        tab?.let {
            updateTitle(tab)
            updateUrl(tab)
            updateSecurityIcon(tab)
        }

        observeUrlChanges()
        observeTitleChanges()
        observeSecurityChanges()
    }

    fun unbind() {
        urlScope?.cancel()
        urlScope = null
        titleScope?.cancel()
        titleScope = null
        securityScope?.cancel()
        securityScope = null
    }

    fun getMenuButton(): View = menuButton

    fun getUrl(): String? = urlText.text?.toString()

    private fun applyMaterial3Colors() {
        val surfaceColor = MaterialColors.getColor(this, com.google.android.material.R.attr.colorSurface)
        val onSurfaceColor = MaterialColors.getColor(this, com.google.android.material.R.attr.colorOnSurface)
        val onSurfaceVariantColor = MaterialColors.getColor(this, com.google.android.material.R.attr.colorOnSurfaceVariant)
        toolbarCard.setCardBackgroundColor(surfaceColor)
        titleText.setTextColor(onSurfaceColor)
        urlText.setTextColor(onSurfaceVariantColor)
    }

    private fun applyIcons() {
        val iconColor = MaterialColors.getColor(this, com.google.android.material.R.attr.colorOnSurfaceVariant)

        updatePrivateMaskIcon()
        closeButton.setImageDrawable(mdiIcon(CommunityMaterial.Icon.cmd_close, 20, iconColor))
        shareButton.setImageDrawable(mdiIcon(CommunityMaterial.Icon3.cmd_share_variant, 18, iconColor))
        openInBrowserButton.setImageDrawable(
            weblibreLogoIcon()
                ?: mdiIcon(CommunityMaterial.Icon3.cmd_open_in_new, 18, iconColor)
        )
        menuButton.setImageDrawable(mdiIcon(CommunityMaterial.Icon.cmd_dots_vertical, 18, iconColor))
    }

    private fun applyCustomColors(color: Int) {
        toolbarCard.setCardBackgroundColor(color)
        val textColor = if (isDarkColor(color)) {
            android.graphics.Color.WHITE
        } else {
            android.graphics.Color.BLACK
        }
        titleText.setTextColor(textColor)
        urlText.setTextColor(textColor)

        updatePrivateMaskIcon()
        closeButton.setImageDrawable(mdiIcon(CommunityMaterial.Icon.cmd_close, 20, textColor))
        shareButton.setImageDrawable(mdiIcon(CommunityMaterial.Icon3.cmd_share_variant, 18, textColor))
        openInBrowserButton.setImageDrawable(
            weblibreLogoIcon()
                ?: mdiIcon(CommunityMaterial.Icon3.cmd_open_in_new, 18, textColor)
        )
        menuButton.setImageDrawable(mdiIcon(CommunityMaterial.Icon.cmd_dots_vertical, 18, textColor))
    }

    private fun weblibreLogoIcon(): Drawable? = runCatching {
        val resId = context.resources.getIdentifier(
            "ic_launcher_foreground",
            "drawable",
            context.packageName,
        )
        if (resId == 0) {
            null
        } else {
            AppCompatResources.getDrawable(context, resId)
        }
    }.getOrNull()?.mutate()

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
                .collect { tab ->
                    updateUrl(tab)
                    updateTitle(tab)
                }
        }
    }

    private fun observeTitleChanges() {
        val sessionId = this.sessionId ?: return
        val store = this.store ?: return

        titleScope = store.flowScoped { flow ->
            flow
                .mapNotNull { state -> state.findCustomTab(sessionId) }
                .ifAnyChanged { tab -> arrayOf(tab.content.title) }
                .collect { tab -> updateTitle(tab) }
        }
    }

    private fun observeSecurityChanges() {
        val sessionId = this.sessionId ?: return
        val store = this.store ?: return

        securityScope = store.flowScoped { flow ->
            flow
                .mapNotNull { state -> state.findCustomTab(sessionId) }
                .ifAnyChanged {
                    tab -> arrayOf(
                        tab.content.securityInfo.isSecure,
                        tab.content.securityInfo.host,
                        tab.content.loading
                    )
                }
                .collect { tab -> updateSecurityIcon(tab) }
        }
    }

    private fun updateTitle(tab: CustomTabSessionState) {
        val title = tab.content.title
        titleText.text = if (title.isBlank()) {
            displayHost(tab.content.url)
        } else {
            title
        }
    }

    private fun updateUrl(tab: CustomTabSessionState) {
        urlText.text = displayHost(tab.content.url)
    }

    private fun displayHost(url: String): String {
        val host = Uri.parse(url).host
        return if (!host.isNullOrBlank()) {
            host
        } else {
            URLStringUtils.toDisplayUrl(url).toString()
        }
    }

    private fun updateSecurityIcon(tab: CustomTabSessionState) {
        val neutralIconColor = MaterialColors.getColor(this, com.google.android.material.R.attr.colorOnSurfaceVariant)
        val errorIconColor = MaterialColors.getColor(this, android.R.attr.colorError)

        val securityInfoKnown = tab.content.securityInfo.host.isNotBlank()

        if (tab.content.loading || !securityInfoKnown) {
            securityIcon.setImageDrawable(mdiIcon(CommunityMaterial.Icon2.cmd_lock_open_outline, 16, neutralIconColor))
        } else if (tab.content.securityInfo.isSecure) {
            securityIcon.setImageDrawable(mdiIcon(CommunityMaterial.Icon2.cmd_lock, 16, neutralIconColor))
        } else {
            securityIcon.setImageDrawable(mdiIcon(CommunityMaterial.Icon2.cmd_lock_open_outline, 16, errorIconColor))
        }
    }

    private fun updatePrivateMaskIcon() {
        privateMaskIcon.visibility = if (isPrivateSession) View.VISIBLE else View.GONE
        if (isPrivateSession) {
            val privateMaskColor = ContextCompat.getColor(context, R.color.private_tab_mask_accent)
            privateMaskIcon.setImageDrawable(
                mdiIcon(CommunityMaterial.Icon.cmd_domino_mask, 16, privateMaskColor)
            )
        } else {
            privateMaskIcon.setImageDrawable(null)
        }
    }

    private fun mdiIcon(icon: IIcon, sizeDp: Int, color: Int): IconicsDrawable {
        return IconicsDrawable(context, icon).apply {
            this.sizeDp = sizeDp
            this.colorInt = color
        }
    }
}
