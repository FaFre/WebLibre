/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.activity.result.ActivityResult
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.annotation.CallSuper
import androidx.annotation.VisibleForTesting
import androidx.fragment.app.Fragment
import eu.weblibre.flutter_mozilla_components.addons.WebExtensionPromptFeature
import eu.weblibre.flutter_mozilla_components.databinding.FragmentBrowserBinding
import eu.weblibre.flutter_mozilla_components.ext.getPreferenceKey
import eu.weblibre.flutter_mozilla_components.services.DownloadService
import io.flutter.Log
import mozilla.components.browser.state.selector.findCustomTabOrSelectedTab
import mozilla.components.browser.state.selector.selectedTab
import mozilla.components.browser.state.state.SessionState
import mozilla.components.concept.engine.EngineView
import mozilla.components.feature.app.links.AppLinksFeature
import mozilla.components.feature.downloads.DownloadsFeature
import mozilla.components.feature.downloads.manager.FetchDownloadManager
import mozilla.components.feature.downloads.temporary.ShareResourceFeature
import mozilla.components.feature.intent.ext.EXTRA_SESSION_ID
import mozilla.components.feature.media.fullscreen.MediaSessionFullscreenFeature
import mozilla.components.feature.privatemode.feature.SecureWindowFeature
import mozilla.components.feature.prompts.PromptFeature
import mozilla.components.feature.prompts.file.AndroidPhotoPicker
import mozilla.components.feature.session.FullScreenFeature
import mozilla.components.feature.session.PictureInPictureFeature
import mozilla.components.feature.session.SessionFeature
import mozilla.components.feature.session.SwipeRefreshFeature
import mozilla.components.feature.sitepermissions.SitePermissionsFeature
import mozilla.components.feature.sitepermissions.SitePermissionsRules
import mozilla.components.feature.sitepermissions.SitePermissionsRules.AutoplayAction
import mozilla.components.feature.webauthn.WebAuthnFeature
import mozilla.components.support.base.feature.ActivityResultHandler
import mozilla.components.support.base.feature.PermissionsFeature
import mozilla.components.support.base.feature.UserInteractionHandler
import mozilla.components.support.base.feature.ViewBoundFeatureWrapper
import mozilla.components.support.base.log.logger.Logger
import mozilla.components.support.ktx.android.view.enterImmersiveMode
import mozilla.components.support.ktx.android.view.exitImmersiveMode
import mozilla.components.support.locale.ActivityContextWrapper

/**
 * Base fragment extended by [BrowserFragment] and [ExternalAppBrowserFragment].
 * This class only contains shared code focused on the main browsing content.
 * UI code specific to the app or to custom tabs can be found in the subclasses.
 */
@SuppressWarnings("LargeClass")
abstract class BaseBrowserFragment : Fragment(), UserInteractionHandler, ActivityResultHandler {
    var customTabSessionId: String? = null

    @VisibleForTesting
    internal var browserInitialized: Boolean = false

    private val sessionFeature = ViewBoundFeatureWrapper<SessionFeature>()
    private val shareResourceFeature = ViewBoundFeatureWrapper<ShareResourceFeature>()
    private val downloadsFeature = ViewBoundFeatureWrapper<DownloadsFeature>()
    private val appLinksFeature = ViewBoundFeatureWrapper<AppLinksFeature>()
    private val promptFeature = ViewBoundFeatureWrapper<PromptFeature>()
    private val webExtensionPromptFeature = ViewBoundFeatureWrapper<WebExtensionPromptFeature>()
    private val sitePermissionsFeature = ViewBoundFeatureWrapper<SitePermissionsFeature>()
    private val swipeRefreshFeature = ViewBoundFeatureWrapper<SwipeRefreshFeature>()
    private val secureWindowFeature = ViewBoundFeatureWrapper<SecureWindowFeature>()
    private val fullScreenFeature = ViewBoundFeatureWrapper<FullScreenFeature>()
    private val mediaSessionFullscreenFeature =
        ViewBoundFeatureWrapper<MediaSessionFullscreenFeature>()

    private val webAuthnFeature = ViewBoundFeatureWrapper<WebAuthnFeature>()

    private var pictureInPictureFeature: PictureInPictureFeature? = null

    // Registers a photo picker activity launcher in single-select mode.
    private val singleMediaPicker =
        AndroidPhotoPicker.singleMediaPicker(
            { this },
            { promptFeature.get() },
        )

    // Registers a photo picker activity launcher in multi-select mode.
    private val multipleMediaPicker =
        AndroidPhotoPicker.multipleMediaPicker(
            { this },
            { promptFeature.get() },
        )

    private val sessionId: String?
        get() = arguments?.getString(SESSION_ID_KEY)

    private var _binding: FragmentBrowserBinding? = null
    val binding get() = _binding!!

    protected val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    private val backButtonHandler: List<ViewBoundFeatureWrapper<*>> = listOf(
        fullScreenFeature,
        sessionFeature,
    )

    private val activityResultHandler: List<ViewBoundFeatureWrapper<*>> = listOf(
        promptFeature,
        webAuthnFeature
    )

    protected abstract fun createEngine(components: Components) : EngineView

    protected abstract fun initializeUI(view: View, tab: SessionState)

    @VisibleForTesting
    internal fun getCurrentTab(): SessionState? {
        return components.core.store.state.findCustomTabOrSelectedTab(customTabSessionId)
    }

    private fun initializeUI(view: View) {
        val tab = getCurrentTab()
        browserInitialized = if (tab != null) {
            initializeUI(view, tab)
            true
        } else {
            false
        }
    }

    private lateinit var requestDownloadPermissionsLauncher: ActivityResultLauncher<Array<String>>
    private lateinit var requestSitePermissionsLauncher: ActivityResultLauncher<Array<String>>
    private lateinit var requestPromptsPermissionsLauncher: ActivityResultLauncher<Array<String>>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        requestDownloadPermissionsLauncher =
            registerForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) { results ->
                val permissions = results.keys.toTypedArray()
                val grantResults =
                    results.values.map {
                        if (it) PackageManager.PERMISSION_GRANTED else PackageManager.PERMISSION_DENIED
                    }.toIntArray()
                downloadsFeature.withFeature {
                    it.onPermissionsResult(permissions, grantResults)
                }
            }

        requestSitePermissionsLauncher =
            registerForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) { results ->
                val permissions = results.keys.toTypedArray()
                val grantResults =
                    results.values.map {
                        if (it) PackageManager.PERMISSION_GRANTED else PackageManager.PERMISSION_DENIED
                    }.toIntArray()
                sitePermissionsFeature.withFeature {
                    it.onPermissionsResult(permissions, grantResults)
                }
            }

        requestPromptsPermissionsLauncher =
            registerForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) { results ->
                val permissions = results.keys.toTypedArray()
                val grantResults =
                    results.values.map {
                        if (it) PackageManager.PERMISSION_GRANTED else PackageManager.PERMISSION_DENIED
                    }.toIntArray()
                promptFeature.withFeature {
                    it.onPermissionsResult(permissions, grantResults)
                }
            }
    }

    @CallSuper
    @Suppress("LongMethod")
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        initializeUI(view)

        sessionFeature.set(
            feature = SessionFeature(
                components.core.store,
                components.useCases.sessionUseCases.goBack,
                components.useCases.sessionUseCases.goForward,
                components.engineView!!,
                sessionId,
            ),
            owner = this,
            view = view,
        )

        swipeRefreshFeature.set(
            feature = SwipeRefreshFeature(
                components.core.store,
                components.useCases.sessionUseCases.reload,
                binding.swipeToRefresh,
            ),
            owner = this,
            view = view,
        )

        shareResourceFeature.set(
            ShareResourceFeature(
                context = requireContext().applicationContext,
                httpClient = components.core.client,
                store = components.core.store,
                tabId = sessionId,
            ),
            owner = this,
            view = view,
        )

        downloadsFeature.set(
            feature = DownloadsFeature(
                requireContext().applicationContext,
                store = components.core.store,
                useCases = components.useCases.downloadsUseCases,
                fragmentManager = childFragmentManager,
                onDownloadStopped = { download, id, status ->
                    Logger.debug("Download done. ID#$id $download with status $status")
                },
                downloadManager = FetchDownloadManager(
                    requireContext().applicationContext,
                    components.core.store,
                    DownloadService::class,
                    notificationsDelegate = components.notificationsDelegate,
                ),
                tabId = sessionId,
                onNeedToRequestPermissions = { permissions ->
                    requestDownloadPermissionsLauncher.launch(permissions)
                },
            ),
            owner = this,
            view = view,
        )

        appLinksFeature.set(
            feature = AppLinksFeature(
                context = requireContext(),
                store = components.core.store,
                sessionId = sessionId,
                fragmentManager = parentFragmentManager,
                launchInApp = { components.core.prefs.getBoolean(context?.getPreferenceKey(R.string.pref_key_launch_external_app), false) },
                loadUrlUseCase = components.useCases.sessionUseCases.loadUrl,
            ),
            owner = this,
            view = view,
        )

        promptFeature.set(
            feature = PromptFeature(
                fragment = this,
                store = components.core.store,
                customTabId = sessionId,
                tabsUseCases = components.useCases.tabsUseCases,
                fragmentManager = parentFragmentManager,
                fileUploadsDirCleaner = components.core.fileUploadsDirCleaner,
                onNeedToRequestPermissions = { permissions ->
                    requestPromptsPermissionsLauncher.launch(permissions)
                },
                androidPhotoPicker = AndroidPhotoPicker(
                    requireContext(),
                    singleMediaPicker,
                    multipleMediaPicker,
                ),
            ),
            owner = this,
            view = view,
        )

        sitePermissionsFeature.set(
            feature = SitePermissionsFeature(
                context = requireContext(),
                sessionId = sessionId,
                storage = components.core.geckoSitePermissionsStorage,
                fragmentManager = parentFragmentManager,
                sitePermissionsRules = SitePermissionsRules(
                    autoplayAudible = AutoplayAction.BLOCKED,
                    autoplayInaudible = AutoplayAction.BLOCKED,
                    camera = SitePermissionsRules.Action.ASK_TO_ALLOW,
                    location = SitePermissionsRules.Action.ASK_TO_ALLOW,
                    notification = SitePermissionsRules.Action.ASK_TO_ALLOW,
                    microphone = SitePermissionsRules.Action.ASK_TO_ALLOW,
                    persistentStorage = SitePermissionsRules.Action.ASK_TO_ALLOW,
                    mediaKeySystemAccess = SitePermissionsRules.Action.ASK_TO_ALLOW,
                    crossOriginStorageAccess = SitePermissionsRules.Action.ASK_TO_ALLOW,
                    localDeviceAccess = SitePermissionsRules.Action.ASK_TO_ALLOW,
                    localNetworkAccess = SitePermissionsRules.Action.ASK_TO_ALLOW,
                ),
                onNeedToRequestPermissions = { permissions ->
                    requestSitePermissionsLauncher.launch(permissions)
                },
                onShouldShowRequestPermissionRationale = { shouldShowRequestPermissionRationale(it) },
                store = components.core.store,
            ),
            owner = this,
            view = view,
        )

        webExtensionPromptFeature.set(
            feature = WebExtensionPromptFeature(
                store = components.core.store,
                context = requireContext(),
                fragmentManager = parentFragmentManager,
            ),
            owner = this,
            view = view
        )

        fullScreenFeature.set(
            feature = FullScreenFeature(
                store = components.core.store,
                sessionUseCases = components.useCases.sessionUseCases,
                tabId = sessionId,
                fullScreenChanged = ::fullScreenChanged,
                viewportFitChanged = ::viewportFitChanged
            ),
            owner = this,
            view = binding.root,
        )

        mediaSessionFullscreenFeature.set(
            feature = MediaSessionFullscreenFeature(
                requireActivity(),
                components.core.store,
                sessionId,
            ),
            owner = this,
            view = binding.root,
        )

        pictureInPictureFeature = PictureInPictureFeature(
            store = components.core.store,
            activity = requireActivity(),
            tabId = sessionId,
        )

        secureWindowFeature.set(
            feature = SecureWindowFeature(
                window = requireActivity().window,
                store = components.core.store,
                customTabId = sessionId,
            ),
            owner = this,
            view = binding.root,
        )

        webAuthnFeature.set(
            feature = WebAuthnFeature(
                engine = components.core.engine,
                activity = requireActivity(),
                exitFullScreen = components.useCases.sessionUseCases.exitFullscreen::invoke,
                currentTab = { components.core.store.state.selectedTabId },
            ),
            owner = this,
            view = view
        )
    }

    private fun restartApp(context: Context) {
        val packageManager = context.packageManager
        val intent = packageManager.getLaunchIntentForPackage(context.packageName)
        intent?.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        intent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)

        if (context is Activity) {
            context.finish()
        }

        Runtime.getRuntime().exit(0)
    }

    private fun createAndSetupEngine() {
        try {
            // Set layout parameters
            val layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )

            val engineView = createEngine(components)
            val originalContext = ActivityContextWrapper.getOriginalContext(requireActivity())
            val engineNativeView = engineView.asView()
            engineNativeView.layoutParams = layoutParams

            engineView.setActivityContext(originalContext)

            binding.swipeToRefresh.addView(engineNativeView)

            components.engineView = engineView
        } catch (e: Exception) {
            Log.e("EngineCreation", "Failed to create engine: ${e.message}", e)
            context?.let { restartApp(it) }
        }
    }

    @CallSuper
    @Suppress("LongMethod")
    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = FragmentBrowserBinding.inflate(inflater, container, false)

        customTabSessionId = requireArguments().getString(EXTRA_SESSION_ID)

        createAndSetupEngine()

        return binding.root
    }

    private fun fullScreenChanged(enabled: Boolean) {
        if (enabled) {
            activity?.enterImmersiveMode()
        } else {
            activity?.exitImmersiveMode()
        }
    }

    private fun viewportFitChanged(viewportFit: Int) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            activity?.window?.attributes?.layoutInDisplayCutoutMode = viewportFit
        }
    }

    @CallSuper
    override fun onBackPressed(): Boolean {
        return backButtonHandler.any { it.onBackPressed() }
    }

    final override fun onHomePressed(): Boolean =pictureInPictureFeature?.onHomePressed() ?: false

    override fun onPictureInPictureModeChanged(enabled: Boolean) {
        pictureInPictureFeature?.onPictureInPictureModeChanged(enabled)
        if (lifecycle.currentState == androidx.lifecycle.Lifecycle.State.CREATED) {
            onBackPressed()
        }
    }

    @Suppress("OVERRIDE_DEPRECATION")
    final override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray,
    ) {
        val feature: PermissionsFeature? = when (requestCode) {
            REQUEST_CODE_DOWNLOAD_PERMISSIONS -> downloadsFeature.get()
            REQUEST_CODE_PROMPT_PERMISSIONS -> promptFeature.get()
            REQUEST_CODE_APP_PERMISSIONS -> sitePermissionsFeature.get()
            else -> null
        }
        feature?.onPermissionsResult(permissions, grantResults)
    }

    @CallSuper
    override fun onActivityResult(requestCode: Int, data: Intent?, resultCode: Int): Boolean {
        return activityResultHandler.any { it.onActivityResult(requestCode, data, resultCode) }
    }

    companion object {
        private const val SESSION_ID_KEY = "session_id"

        private const val REQUEST_CODE_DOWNLOAD_PERMISSIONS = 1
        private const val REQUEST_CODE_PROMPT_PERMISSIONS = 2
        private const val REQUEST_CODE_APP_PERMISSIONS = 3

        @JvmStatic
        protected fun Bundle.putSessionId(sessionId: String?) {
            putString(SESSION_ID_KEY, sessionId)
        }
    }
    override fun onDestroyView() {
        super.onDestroyView()

        components.engineView?.setActivityContext(null)
        _binding = null
    }
}
