/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import android.content.Intent
import android.os.Bundle
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.PopupWindow
import androidx.annotation.CallSuper
import com.google.android.material.appbar.AppBarLayout
import com.google.android.material.color.MaterialColors
import com.google.android.material.materialswitch.MaterialSwitch
import com.mikepenz.iconics.IconicsDrawable
import com.mikepenz.iconics.typeface.IIcon
import com.mikepenz.iconics.typeface.library.community.material.CommunityMaterial
import com.mikepenz.iconics.utils.colorInt
import com.mikepenz.iconics.utils.sizeDp
import eu.weblibre.flutter_mozilla_components.widget.CustomTabToolbar
import eu.weblibre.flutter_mozilla_components.widget.CustomTabToolbarFeature
import mozilla.components.browser.state.selector.findCustomTab
import mozilla.components.browser.state.state.ExternalAppType
import mozilla.components.concept.engine.EngineView
import mozilla.components.feature.customtabs.CustomTabWindowFeature
import mozilla.components.feature.pwa.feature.ManifestUpdateFeature
import mozilla.components.feature.pwa.feature.WebAppActivityFeature
import mozilla.components.feature.pwa.feature.WebAppContentFeature
import mozilla.components.feature.pwa.feature.WebAppHideToolbarFeature
import mozilla.components.feature.pwa.feature.WebAppSiteControlsFeature
import mozilla.components.support.base.feature.UserInteractionHandler
import mozilla.components.support.base.feature.ViewBoundFeatureWrapper
import mozilla.components.support.base.log.logger.Logger
import mozilla.components.support.ktx.android.arch.lifecycle.addObservers

/**
 * Fragment used for browsing the web within external apps (Custom Tabs and PWAs).
 * Extends [BaseBrowserFragment] with Custom Tab toolbar features and PWA support.
 */
class ExternalAppBrowserFragment : BaseBrowserFragment(), UserInteractionHandler {

    private val customTabsToolbarFeature = ViewBoundFeatureWrapper<CustomTabToolbarFeature>()
    private val hideToolbarFeature = ViewBoundFeatureWrapper<WebAppHideToolbarFeature>()
    private val windowFeature = ViewBoundFeatureWrapper<CustomTabWindowFeature>()

    private var customTabToolbar: CustomTabToolbar? = null
    private var activePopup: PopupWindow? = null

    private val customTabSessionId: String?
        get() = arguments?.getString(CUSTOM_TAB_SESSION_ID_KEY)

    private val webAppManifestUrl: String?
        get() = arguments?.getString(WEB_APP_MANIFEST_URL_KEY)

    override fun createEngine(components: Components): EngineView {
        return components.core.engine.createView(requireContext()).apply {
            selectionActionDelegate = components.selectionAction
        }.also { engineView ->
            components.externalAppEngineView = engineView
        }
    }

    @Suppress("LongMethod")
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val sessionId = customTabSessionId ?: return

        view.post {
            if (GlobalComponents.components == null) return@post
            initializeCustomTabFeatures(view, sessionId)
        }
    }

    override fun onEngineSetupComplete() {
        val sessionId = customTabSessionId ?: return
        val store = components.core.store
        val customTab = store.state.findCustomTab(sessionId) ?: return

        val isPwaOrTwa = customTab.config.externalAppType == ExternalAppType.PROGRESSIVE_WEB_APP ||
            customTab.config.externalAppType == ExternalAppType.TRUSTED_WEB_ACTIVITY

        if (!isPwaOrTwa) {
            setupCustomTabToolbar(sessionId)
        }
    }

    private fun setupCustomTabToolbar(sessionId: String) {
        val view = requireView()

        val toolbar = CustomTabToolbar(requireContext()).apply {
            layoutParams = AppBarLayout.LayoutParams(
                AppBarLayout.LayoutParams.MATCH_PARENT,
                AppBarLayout.LayoutParams.WRAP_CONTENT
            )
        }
        customTabToolbar = toolbar

        binding.customTabAppBar.apply {
            removeAllViews()
            addView(toolbar)
            visibility = View.VISIBLE
        }

        toolbar.onCloseListener = {
            requireActivity().finishAndRemoveTask()
        }
        toolbar.onShareListener = {
            shareCurrentUrl(sessionId)
        }
        toolbar.onOpenInBrowserListener = {
            openInBrowser(sessionId)
        }
        toolbar.onMenuListener = {
            showCustomTabMenu(sessionId)
        }

        customTabsToolbarFeature.set(
            feature = CustomTabToolbarFeature(
                store = components.core.store,
                toolbar = toolbar,
                sessionId = sessionId,
                window = requireActivity().window
            ),
            owner = this,
            view = view
        )
    }

    private fun showCustomTabMenu(sessionId: String) {
        val toolbar = customTabToolbar ?: return
        val store = components.core.store
        val customTab = store.state.findCustomTab(sessionId) ?: return
        val anchorView = toolbar.getMenuButton()

        val menuView = LayoutInflater.from(requireContext())
            .inflate(R.layout.custom_tab_menu, null)

        val popup = PopupWindow(
            menuView,
            android.view.ViewGroup.LayoutParams.WRAP_CONTENT,
            android.view.ViewGroup.LayoutParams.WRAP_CONTENT,
            true
        ).apply {
            elevation = 10f
            isOutsideTouchable = true
        }
        activePopup = popup

        val iconColor = MaterialColors.getColor(anchorView, com.google.android.material.R.attr.colorOnSurfaceVariant)
        val disabledColor = MaterialColors.getColor(anchorView, com.google.android.material.R.attr.colorOutline)

        // Navigation row icons
        val canGoBack = customTab.content.canGoBack
        val canGoForward = customTab.content.canGoForward

        val backBtn = menuView.findViewById<ImageButton>(R.id.menuBack)
        val forwardBtn = menuView.findViewById<ImageButton>(R.id.menuForward)

        backBtn.setImageDrawable(mdiIcon(CommunityMaterial.Icon.cmd_arrow_left, 22, if (canGoBack) iconColor else disabledColor))
        backBtn.isEnabled = canGoBack
        backBtn.alpha = if (canGoBack) 1.0f else 0.38f
        backBtn.setOnClickListener {
            components.useCases.sessionUseCases.goBack(sessionId)
            popup.dismiss()
        }

        forwardBtn.setImageDrawable(mdiIcon(CommunityMaterial.Icon.cmd_arrow_right, 22, if (canGoForward) iconColor else disabledColor))
        forwardBtn.isEnabled = canGoForward
        forwardBtn.alpha = if (canGoForward) 1.0f else 0.38f
        forwardBtn.setOnClickListener {
            components.useCases.sessionUseCases.goForward(sessionId)
            popup.dismiss()
        }

        // Menu item icons
        menuView.findViewById<ImageView>(R.id.menuRefreshIcon)
            .setImageDrawable(mdiIcon(CommunityMaterial.Icon3.cmd_refresh, 24, iconColor))
        menuView.findViewById<ImageView>(R.id.menuShareIcon)
            .setImageDrawable(mdiIcon(CommunityMaterial.Icon3.cmd_share_variant, 24, iconColor))
        menuView.findViewById<ImageView>(R.id.menuDesktopIcon)
            .setImageDrawable(mdiIcon(CommunityMaterial.Icon3.cmd_monitor, 24, iconColor))
        menuView.findViewById<ImageView>(R.id.menuOpenInBrowserIcon)
            .setImageDrawable(mdiIcon(CommunityMaterial.Icon3.cmd_open_in_new, 24, iconColor))

        // Refresh
        menuView.findViewById<View>(R.id.menuRefresh).setOnClickListener {
            components.useCases.sessionUseCases.reload(sessionId)
            popup.dismiss()
        }

        // Share
        menuView.findViewById<View>(R.id.menuShare).setOnClickListener {
            shareCurrentUrl(sessionId)
            popup.dismiss()
        }

        // Desktop site toggle
        val isDesktop = customTab.content.desktopMode
        val desktopSwitch = menuView.findViewById<MaterialSwitch>(R.id.menuDesktopSwitch)
        desktopSwitch.isChecked = isDesktop
        val desktopRow = menuView.findViewById<View>(R.id.menuDesktopSite)
        desktopRow.setOnClickListener {
            val newState = !desktopSwitch.isChecked
            components.useCases.sessionUseCases.requestDesktopSite(newState, sessionId)
            popup.dismiss()
        }
        desktopSwitch.setOnCheckedChangeListener { _, isChecked ->
            components.useCases.sessionUseCases.requestDesktopSite(isChecked, sessionId)
            popup.dismiss()
        }

        // Open in browser
        menuView.findViewById<View>(R.id.menuOpenInBrowser).setOnClickListener {
            openInBrowser(sessionId)
            popup.dismiss()
        }

        popup.showAsDropDown(anchorView, 0, 0, Gravity.END)
    }

    private fun mdiIcon(icon: IIcon, sizeDp: Int, color: Int): IconicsDrawable {
        return IconicsDrawable(requireContext(), icon).apply {
            this.sizeDp = sizeDp
            this.colorInt = color
        }
    }

    private fun openInBrowser(sessionId: String) {
        val activity = requireActivity()

        sessionFeature?.get()?.release()
        components.useCases.customTabsUseCases.migrate(sessionId, select = true)

        val mainIntent = activity.packageManager.getLaunchIntentForPackage(activity.packageName)
        mainIntent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        mainIntent?.let { activity.startActivity(it) }

        activity.finishAndRemoveTask()
    }

    private fun shareCurrentUrl(sessionId: String) {
        val store = components.core.store
        store.state.findCustomTab(sessionId)?.let { tab ->
            val shareIntent = Intent(Intent.ACTION_SEND).apply {
                type = "text/plain"
                putExtra(Intent.EXTRA_TEXT, tab.content.url)
                putExtra(Intent.EXTRA_SUBJECT, tab.content.title)
            }
            startActivity(Intent.createChooser(shareIntent, null))
        }
    }

    private fun initializeCustomTabFeatures(view: View, sessionId: String) {
        val activity = requireActivity()
        val store = components.core.store
        val customTab = store.state.findCustomTab(sessionId) ?: return

        components.activeEngineView?.setDynamicToolbarMaxHeight(0)

        val manifest = webAppManifestUrl?.ifEmpty { null }?.let { url ->
            components.core.webAppManifestStorage.getManifestCache(url)
        }

        windowFeature.set(
            feature = CustomTabWindowFeature(activity, store, sessionId),
            owner = this,
            view = view,
        )

        val isPwaOrTwa = customTab.config.externalAppType == ExternalAppType.PROGRESSIVE_WEB_APP ||
            customTab.config.externalAppType == ExternalAppType.TRUSTED_WEB_ACTIVITY

        if (isPwaOrTwa) {
            hideToolbarFeature.set(
                feature = WebAppHideToolbarFeature(
                    store = store,
                    customTabsStore = components.core.customTabsStore,
                    tabId = sessionId,
                    manifest = manifest,
                ) { toolbarVisible ->
                    Logger.debug("Custom tab toolbar visibility: $toolbarVisible")
                },
                owner = this,
                view = view,
            )
        }

        if (manifest != null) {
            activity.lifecycle.addObservers(
                WebAppActivityFeature(
                    activity,
                    components.core.icons,
                    manifest,
                ),
                WebAppContentFeature(
                    store = store,
                    tabId = sessionId,
                    manifest,
                ),
                ManifestUpdateFeature(
                    activity.applicationContext,
                    store,
                    components.core.webAppShortcutManager,
                    components.core.webAppManifestStorage,
                    sessionId,
                    manifest,
                ),
            )
            viewLifecycleOwner.lifecycle.addObserver(
                WebAppSiteControlsFeature(
                    activity.applicationContext,
                    store,
                    components.useCases.sessionUseCases.reload,
                    sessionId,
                    manifest,
                    notificationsDelegate = components.notificationsDelegate,
                ),
            )
        }
    }

    @Deprecated("Deprecated in Java")
    @CallSuper
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super<BaseBrowserFragment>.onActivityResult(requestCode, data, resultCode)
    }

    override fun onBackPressed(): Boolean {
        return super.onBackPressed()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        activePopup?.dismiss()
        activePopup = null
        customTabToolbar = null
        components.externalAppEngineView = null
    }

    companion object {
        private const val CUSTOM_TAB_SESSION_ID_KEY = "custom_tab_session_id"
        private const val WEB_APP_MANIFEST_URL_KEY = "web_app_manifest_url"

        fun create(
            customTabSessionId: String,
            webAppManifestUrl: String? = null,
        ) = ExternalAppBrowserFragment().apply {
            arguments = Bundle().apply {
                putSessionId(customTabSessionId)
                putString(CUSTOM_TAB_SESSION_ID_KEY, customTabSessionId)
                putString(WEB_APP_MANIFEST_URL_KEY, webAppManifestUrl)
            }
        }
    }
}
