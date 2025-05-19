package eu.weblibre.flutter_mozilla_components


import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.annotation.CallSuper
import androidx.fragment.app.Fragment
import eu.weblibre.flutter_mozilla_components.addons.WebExtensionPromptFeature
import eu.weblibre.flutter_mozilla_components.databinding.FragmentBrowserBinding
import eu.weblibre.flutter_mozilla_components.ext.getPreferenceKey
import eu.weblibre.flutter_mozilla_components.pip.PictureInPictureIntegration
import eu.weblibre.flutter_mozilla_components.services.DownloadService
import io.flutter.Log
import mozilla.components.browser.state.selector.selectedTab
import mozilla.components.concept.engine.EngineView
import mozilla.components.feature.app.links.AppLinksFeature
import mozilla.components.feature.downloads.DownloadsFeature
import mozilla.components.feature.downloads.manager.FetchDownloadManager
import mozilla.components.feature.downloads.temporary.ShareResourceFeature
import mozilla.components.feature.media.fullscreen.MediaSessionFullscreenFeature
import mozilla.components.feature.privatemode.feature.SecureWindowFeature
import mozilla.components.feature.prompts.PromptFeature
import mozilla.components.feature.session.FullScreenFeature
import mozilla.components.feature.session.SessionFeature
import mozilla.components.feature.session.SwipeRefreshFeature
import mozilla.components.feature.sitepermissions.SitePermissionsFeature
import mozilla.components.feature.sitepermissions.SitePermissionsRules
import mozilla.components.feature.sitepermissions.SitePermissionsRules.AutoplayAction
import mozilla.components.support.base.feature.ActivityResultHandler
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
    private val sessionFeature = ViewBoundFeatureWrapper<SessionFeature>()
    private val shareResourceFeature = ViewBoundFeatureWrapper<ShareResourceFeature>()
    private val downloadsFeature = ViewBoundFeatureWrapper<DownloadsFeature>()
    private val appLinksFeature = ViewBoundFeatureWrapper<AppLinksFeature>()
    private val promptFeature = ViewBoundFeatureWrapper<PromptFeature>()
    private val webExtensionPromptFeature = ViewBoundFeatureWrapper<WebExtensionPromptFeature>()
    private val pictureInPictureIntegration = ViewBoundFeatureWrapper<PictureInPictureIntegration>()
    private val sitePermissionsFeature = ViewBoundFeatureWrapper<SitePermissionsFeature>()
    private val swipeRefreshFeature = ViewBoundFeatureWrapper<SwipeRefreshFeature>()
    private val secureWindowFeature = ViewBoundFeatureWrapper<SecureWindowFeature>()
    private val fullScreenFeature = ViewBoundFeatureWrapper<FullScreenFeature>()
    private val mediaSessionFullscreenFeature =
        ViewBoundFeatureWrapper<MediaSessionFullscreenFeature>()

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
    )

    protected abstract fun createEngine(components: Components) : EngineView

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

        pictureInPictureIntegration.set(
            feature = PictureInPictureIntegration(
                components.core.store,
                requireActivity(),
                sessionId,
            ),
            owner = this,
            view = view,
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

    @CallSuper
    override fun onBackPressed(): Boolean {
        return backButtonHandler.any { it.onBackPressed() }
    }

    final override fun onPause() {
        pictureInPictureIntegration.get()?.onHomePressed() ?: false
        super.onPause()
    }

    final override fun onPictureInPictureModeChanged(enabled: Boolean) {
        val session = components.core.store.state.selectedTab
        val fullScreenMode = session?.content?.fullScreen ?: false
        // If we're exiting PIP mode and we're in fullscreen mode, then we should exit fullscreen mode as well.
        if (!enabled && fullScreenMode) {
            onBackPressed()
            fullScreenChanged(false)
        }
    }

    @CallSuper
    override fun onActivityResult(requestCode: Int, data: Intent?, resultCode: Int): Boolean {
        return activityResultHandler.any { it.onActivityResult(requestCode, data, resultCode) }
    }

    companion object {
        private const val SESSION_ID_KEY = "session_id"

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
