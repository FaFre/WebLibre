package eu.weblibre.flutter_mozilla_components.api

import android.app.Activity
import android.content.Intent
import android.view.View
import androidx.fragment.app.FragmentActivity
import eu.weblibre.flutter_mozilla_components.BrowserFragment
import eu.weblibre.flutter_mozilla_components.GeckoViewFactory
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.activities.NotificationActivity
import eu.weblibre.flutter_mozilla_components.feature.DefaultSelectionActionDelegate
import eu.weblibre.flutter_mozilla_components.pigeons.BrowserExtensionEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoAddonEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoAddonsApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoBrowserApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoBrowserExtensionApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoContainerProxyApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoCookieApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoDeleteBrowsingDataController
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoDownloadsApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoEngineSettingsApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoFindApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoIconsApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoPrefApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSelectionActionController
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSelectionActionEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSessionApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoStateEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSuggestionApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSuggestionEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoTabContentEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoTabsApi
import eu.weblibre.flutter_mozilla_components.pigeons.ReaderViewController
import eu.weblibre.flutter_mozilla_components.pigeons.ReaderViewEvents
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import mozilla.components.browser.state.action.SystemAction
import mozilla.components.feature.addons.logger
import mozilla.components.support.base.log.Log
import mozilla.components.support.base.log.sink.AndroidLogSink

/**
 * Implementation of GeckoBrowserApi that handles browser-related operations
 * @param showFragmentCallback Callback function to show native fragment
 */
class GeckoBrowserApiImpl : GeckoBrowserApi {
    companion object {
        private const val TAG = "GeckoBrowserApiImpl"
        private const val FRAGMENT_CONTAINER_ID = 0xBEEF

        private var isGeckoInitialized = false
    }

    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    private var activity: Activity? = null
    private var isPlatformViewRegistered = false

    private lateinit var _flutterPluginBinding: FlutterPlugin.FlutterPluginBinding
    private lateinit var _flutterEvents : GeckoStateEvents

    fun attachBinding(flutterPluginBinding: FlutterPluginBinding) {
        _flutterPluginBinding = flutterPluginBinding
        _flutterEvents = GeckoStateEvents(_flutterPluginBinding.binaryMessenger)

        isGeckoInitialized = false
    }

    fun attachActivity(activity: Activity) {
        this.activity = activity

        _flutterPluginBinding.platformViewRegistry.registerViewFactory(
            "eu.weblibre/gecko", GeckoViewFactory(
                activity,
                FRAGMENT_CONTAINER_ID,
                _flutterEvents
            )
        )

        isPlatformViewRegistered = true
    }

    fun detachActivity() {
        this.activity = null
        isPlatformViewRegistered = false
    }

    override fun initialize() {
        synchronized(this) {
            if(!isGeckoInitialized) {
                Log.addSink(AndroidLogSink())

                setupGeckoEngine()
                isGeckoInitialized = true
            }
        }
    }

    override fun showNativeFragment(): Boolean {
        try {
            return showFragmentCallback()
        } catch (e: Exception) {
            logger.error("Failed to show native fragment", e)
        }

        return false
    }

    private fun setupGeckoEngine() {
        val selectionActionEvents = GeckoSelectionActionEvents(_flutterPluginBinding.binaryMessenger)

        val selectionActionDelegate = DefaultSelectionActionDelegate(selectionActionEvents) { actions ->
            val processTextAction = "android.intent.action.PROCESS_TEXT"
            val withoutProcessText = actions.filter { it != processTextAction }.toTypedArray()
            val processTextActions = actions.filter { it == processTextAction }.toTypedArray()

            withoutProcessText + processTextActions
        }

        val readerViewController =
            ReaderViewController(_flutterPluginBinding.binaryMessenger)

        val extensionEvents = BrowserExtensionEvents(_flutterPluginBinding.binaryMessenger)

        val addonEvents = GeckoAddonEvents(_flutterPluginBinding.binaryMessenger)
        val tabContentEvents = GeckoTabContentEvents(_flutterPluginBinding.binaryMessenger)

        val suggestionEvents = GeckoSuggestionEvents(_flutterPluginBinding.binaryMessenger)
        GeckoSuggestionApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoSuggestionApiImpl(suggestionEvents))

        GlobalComponents.setUp(
            _flutterPluginBinding.applicationContext,
            _flutterEvents,
            readerViewController,
            selectionActionDelegate,
            addonEvents,
            tabContentEvents,
            extensionEvents
        )

        GeckoEngineSettingsApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoEngineSettingsApiImpl())
        GeckoAddonsApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoAddonsApiImpl(_flutterPluginBinding.applicationContext))
        GeckoSessionApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoSessionApiImpl())
        GeckoTabsApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoTabsApiImpl())
        GeckoIconsApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoIconsApiImpl())
        GeckoCookieApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoCookieApiImpl())
        GeckoPrefApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoPrefApiImpl())
        GeckoContainerProxyApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoContainerProxyApiImpl())
        GeckoFindApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoFindApiImpl())
        GeckoSelectionActionController.setUp(_flutterPluginBinding.binaryMessenger, GeckoSelectionActionControllerImpl(
            selectionActionDelegate
        ))
        GeckoDeleteBrowsingDataController.setUp(_flutterPluginBinding.binaryMessenger, GeckoDeleteBrowsingDataControllerImpl())
        GeckoDownloadsApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoDownloadsApiImpl())
        GeckoBrowserExtensionApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoBrowserExtensionApiImpl())

        ReaderViewEvents.setUp(
            _flutterPluginBinding.binaryMessenger,
            components.events.readerViewEvents
        )

        val intent = Intent(_flutterPluginBinding.applicationContext, NotificationActivity::class.java)
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        _flutterPluginBinding.applicationContext.startActivity(intent)
    }

    private fun showFragmentCallback(): Boolean {
        if (!isPlatformViewRegistered) {
            return false
        }

        if (activity == null || activity !is FragmentActivity) {
            return false
        }

        val fragmentActivity = activity as FragmentActivity

        // Check if the container view exists in the view hierarchy
        val container = fragmentActivity.findViewById<View>(FRAGMENT_CONTAINER_ID)
        if (container == null) {
            // Container doesn't exist yet, retry later
            return false
        }

        val nativeFragment = BrowserFragment.create()
        val fm = fragmentActivity.supportFragmentManager
        fm.beginTransaction()
            .replace(FRAGMENT_CONTAINER_ID, nativeFragment)
            .commitAllowingStateLoss()

        return true
    }

    override fun onTrimMemory(level: Long) {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }

        logger.debug("$TAG: onTrimMemory called with level: $level")

        with(GlobalComponents.components!!) {
            try {
                core.store.dispatch(SystemAction.LowMemoryAction(level.toInt()))
                core.icons.onTrimMemory(level.toInt())
            } catch (e: Exception) {
                logger.error("$TAG: Failed to handle memory trim", e)
            }
        }
    }
}
