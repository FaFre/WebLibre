/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.addons

import android.os.Bundle
import android.os.Environment
import android.view.View
import androidx.fragment.app.Fragment
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.services.DownloadService
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.action.CustomTabListAction
import mozilla.components.browser.state.state.CustomTabSessionState
import mozilla.components.browser.state.state.EngineState
import mozilla.components.browser.state.state.SessionState
import mozilla.components.browser.state.state.content.DownloadState
import mozilla.components.browser.state.state.createCustomTab
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.prompt.PromptRequest
import mozilla.components.concept.engine.window.WindowRequest
import mozilla.components.concept.fetch.Response
import mozilla.components.feature.downloads.DownloadsFeature
import mozilla.components.feature.downloads.manager.FetchDownloadManager
import mozilla.components.feature.prompts.PromptFeature
import mozilla.components.support.base.feature.UserInteractionHandler
import mozilla.components.support.base.feature.ViewBoundFeatureWrapper

/**
 * Provides shared functionality to fragments for add-on popups and settings.
 *
 * Manages the engine session lifecycle by wrapping it in a custom tab registered in the
 * BrowserStore, enabling PromptFeature and DownloadsFeature to interact with the session.
 */
abstract class AddonPopupBaseFragment : Fragment(), EngineSession.Observer, UserInteractionHandler {
    private val promptsFeature = ViewBoundFeatureWrapper<PromptFeature>()
    private val downloadsFeature = ViewBoundFeatureWrapper<DownloadsFeature>()

    protected val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    protected var session: SessionState? = null
    protected var engineSession: EngineSession? = null
    private var canGoBack: Boolean = false

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        session?.let {
            promptsFeature.set(
                feature = PromptFeature(
                    fragment = this,
                    store = components.core.store,
                    customTabId = it.id,
                    fragmentManager = parentFragmentManager,
                    fileUploadsDirCleaner = components.core.fileUploadsDirCleaner,
                    tabsUseCases = components.useCases.tabsUseCases,
                    onNeedToRequestPermissions = { permissions ->
                        @Suppress("DEPRECATION")
                        requestPermissions(permissions, REQUEST_CODE_PROMPT_PERMISSIONS)
                    },
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
                    tabId = it.id,
                    downloadManager = FetchDownloadManager(
                        requireContext().applicationContext,
                        components.core.store,
                        DownloadService::class,
                        notificationsDelegate = components.notificationsDelegate,
                    ),
                    onNeedToRequestPermissions = { permissions ->
                        @Suppress("DEPRECATION")
                        requestPermissions(permissions, REQUEST_CODE_DOWNLOAD_PERMISSIONS)
                    },
                ),
                owner = this,
                view = view,
            )
        }
    }

    override fun onStart() {
        super.onStart()
        engineSession?.register(this)
    }

    override fun onStop() {
        super.onStop()
        engineSession?.unregister(this)
    }

    override fun onDestroyView() {
        engineSession?.close()
        session?.let {
            components.core.store.dispatch(CustomTabListAction.RemoveCustomTabAction(it.id))
        }
        super.onDestroyView()
    }

    override fun onPromptRequest(promptRequest: PromptRequest) {
        session?.let { session ->
            components.core.store.dispatch(
                ContentAction.UpdatePromptRequestAction(session.id, promptRequest),
            )
        }
    }

    override fun onExternalResource(
        url: String,
        fileName: String?,
        contentLength: Long?,
        contentType: String?,
        cookie: String?,
        userAgent: String?,
        isPrivate: Boolean,
        skipConfirmation: Boolean,
        openInApp: Boolean,
        response: Response?,
    ) {
        session?.let { session ->
            val fileSize = if (contentLength != null && contentLength < 0) null else contentLength
            val download = DownloadState(
                url,
                fileName,
                contentType,
                fileSize,
                0,
                DownloadState.Status.INITIATED,
                userAgent,
                Environment.DIRECTORY_DOWNLOADS,
                private = isPrivate,
                skipConfirmation = skipConfirmation,
                openInApp = openInApp,
                response = response,
            )
            components.core.store.dispatch(
                ContentAction.UpdateDownloadAction(session.id, download),
            )
        }
    }

    override fun onWindowRequest(windowRequest: WindowRequest) {
        if (windowRequest.type == WindowRequest.Type.CLOSE) {
            activity?.onBackPressedDispatcher?.onBackPressed()
        } else {
            engineSession?.loadUrl(windowRequest.url)
        }
    }

    override fun onNavigationStateChange(canGoBack: Boolean?, canGoForward: Boolean?) {
        canGoBack?.let { this.canGoBack = it }
    }

    override fun onBackPressed(): Boolean {
        return if (canGoBack) {
            engineSession?.goBack()
            true
        } else {
            false
        }
    }

    protected fun initializeSession(fromEngineSession: EngineSession? = null) {
        engineSession = fromEngineSession ?: components.core.engine.createSession()
        session = createCustomTab(
            url = "",
            source = SessionState.Source.Internal.CustomTab,
        ).copy(engineState = EngineState(engineSession))
        components.core.store.dispatch(
            CustomTabListAction.AddCustomTabAction(session as CustomTabSessionState)
        )
    }

    @Suppress("OVERRIDE_DEPRECATION")
    final override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray,
    ) {
        when (requestCode) {
            REQUEST_CODE_PROMPT_PERMISSIONS -> promptsFeature.get()?.onPermissionsResult(permissions, grantResults)
            REQUEST_CODE_DOWNLOAD_PERMISSIONS -> downloadsFeature.get()?.onPermissionsResult(permissions, grantResults)
        }
    }

    companion object {
        private const val REQUEST_CODE_PROMPT_PERMISSIONS = 1
        private const val REQUEST_CODE_DOWNLOAD_PERMISSIONS = 2
    }
}
