package eu.lensai.flutter_mozilla_components


import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import eu.lensai.flutter_mozilla_components.feature.DefaultSelectionActionDelegate
import eu.lensai.flutter_mozilla_components.integration.ReaderViewIntegration
import mozilla.components.browser.thumbnails.BrowserThumbnails
import mozilla.components.concept.engine.EngineView
import mozilla.components.feature.media.fullscreen.MediaSessionFullscreenFeature
import mozilla.components.feature.session.FullScreenFeature
import mozilla.components.feature.tabs.WindowFeature
import mozilla.components.support.base.feature.UserInteractionHandler
import mozilla.components.support.base.feature.ViewBoundFeatureWrapper
import mozilla.components.support.ktx.android.view.enterImmersiveMode
import mozilla.components.support.ktx.android.view.exitImmersiveMode

/**
 * Fragment used for browsing the web within the main app.
 */
class BrowserFragment(private val context: Context) : BaseBrowserFragment(), UserInteractionHandler {
    private val thumbnailsFeature = ViewBoundFeatureWrapper<BrowserThumbnails>()
    private val readerViewFeature = ViewBoundFeatureWrapper<ReaderViewIntegration>()
    private val fullScreenFeature = ViewBoundFeatureWrapper<FullScreenFeature>()
    private val mediaSessionFullscreenFeature =
        ViewBoundFeatureWrapper<MediaSessionFullscreenFeature>()

    override fun createEngine(components: Components): EngineView {
        return components.engine.createView(context).apply {
           selectionActionDelegate = components.selectionAction
        }
    }

    @Suppress("LongMethod")
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?,
    ): View {
        super.onCreateView(inflater, container, savedInstanceState)

        val binding = super.binding

        readerViewFeature.set(
            feature = ReaderViewIntegration(
                requireContext(),
                components.engine,
                components.store,
                binding.readerViewBar,
                components.readerViewEvents,
                components.readerViewController,
            ),
            owner = this,
            view = binding.root,
        )

        fullScreenFeature.set(
            feature = FullScreenFeature(
                components.store,
                components.sessionUseCases,
                sessionId,
            ) { inFullScreen ->
                if (inFullScreen) {
                    activity?.enterImmersiveMode()
                } else {
                    activity?.exitImmersiveMode()
                }
            },
            owner = this,
            view = binding.root,
        )

        mediaSessionFullscreenFeature.set(
            feature = MediaSessionFullscreenFeature(
                requireActivity(),
                components.store,
                sessionId,
            ),
            owner = this,
            view = binding.root,
        )

        thumbnailsFeature.set(
            feature = BrowserThumbnails(requireContext(), engineView, components.store),
            owner = this,
            view = binding.root,
        )

        val windowFeature = WindowFeature(components.store, components.tabsUseCases)
        lifecycle.addObserver(windowFeature)

        return binding.root
    }


    override fun onBackPressed(): Boolean {
        return when {
            fullScreenFeature.onBackPressed() -> true
            else -> super.onBackPressed()
        }
    }

    companion object {
        fun create(context: Context, sessionId: String? = null) = BrowserFragment(context).apply {
            arguments = Bundle().apply {
                putSessionId(sessionId)
            }
        }
    }
}
