/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

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
import eu.weblibre.flutter_mozilla_components.pigeons.ContentBlocking
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
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoHistoryApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoIconsApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoLogging
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoMlApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoPrefApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSelectionActionController
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSelectionActionEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSessionApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoStateEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSuggestionApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSuggestionEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoTabContentEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoTabsApi
import eu.weblibre.flutter_mozilla_components.pigeons.LogLevel
import eu.weblibre.flutter_mozilla_components.pigeons.ReaderViewController
import eu.weblibre.flutter_mozilla_components.pigeons.ReaderViewEvents
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import mozilla.components.browser.state.action.SystemAction
import mozilla.components.feature.addons.logger
import mozilla.components.support.base.ext.getStacktraceAsString
import mozilla.components.support.base.log.Log
import mozilla.components.support.base.log.sink.AndroidLogSink
import mozilla.components.support.base.log.sink.LogSink
import org.mozilla.gecko.util.ThreadUtils.runOnUiThread
import org.mozilla.geckoview.BuildConfig as GeckoViewBuildConfig

class PriorityAwareLogSink(
    private val minLogPriority: Log.Priority,
    private val geckoLogging: GeckoLogging
) : LogSink {

    override fun log(
        priority: Log.Priority,
        tag: String?,
        throwable: Throwable?,
        message: String,
    ) {
        if (priority < minLogPriority) {
            return
        }

        val level = when(priority) {
            Log.Priority.DEBUG -> LogLevel.DEBUG
            Log.Priority.INFO -> LogLevel.INFO
            Log.Priority.WARN -> LogLevel.WARN
            Log.Priority.ERROR -> LogLevel.ERROR
        };

        val logMessage: String = if (throwable != null) {
            "$message\n${throwable.getStacktraceAsString()}"
        } else {
            message
        }

        runOnUiThread {
            geckoLogging.onLog(level, logMessage) { _ -> }
        }
    }
}

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

    override fun getGeckoVersion(): String {
        return GeckoViewBuildConfig.MOZ_APP_VERSION + "-" + GeckoViewBuildConfig.MOZ_APP_BUILDID
    }

    override fun initialize(logLevel: LogLevel, contentBlocking: ContentBlocking) {
        synchronized(this) {
            if(!isGeckoInitialized) {
                val geckoLogging = GeckoLogging(_flutterPluginBinding.binaryMessenger)

                val level = when(logLevel) {
                    LogLevel.DEBUG -> Log.Priority.DEBUG
                    LogLevel.INFO -> Log.Priority.INFO
                    LogLevel.WARN -> Log.Priority.WARN
                    LogLevel.ERROR -> Log.Priority.ERROR
                };

                Log.addSink(PriorityAwareLogSink(level, geckoLogging))

                setupGeckoEngine(level, contentBlocking)
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

    private fun setupGeckoEngine(logLevel: Log.Priority, contentBlocking: ContentBlocking) {
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
            extensionEvents,
            logLevel,
            contentBlocking
        )

        GeckoEngineSettingsApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoEngineSettingsApiImpl())
        GeckoAddonsApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoAddonsApiImpl(_flutterPluginBinding.applicationContext))
        GeckoSessionApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoSessionApiImpl())
        GeckoTabsApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoTabsApiImpl())
        GeckoIconsApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoIconsApiImpl())
        GeckoCookieApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoCookieApiImpl())
        GeckoMlApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoMlApiImpl())
        GeckoPrefApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoPrefApiImpl())
        GeckoContainerProxyApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoContainerProxyApiImpl())
        GeckoFindApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoFindApiImpl())
        GeckoSelectionActionController.setUp(_flutterPluginBinding.binaryMessenger, GeckoSelectionActionControllerImpl(
            selectionActionDelegate
        ))
        GeckoDeleteBrowsingDataController.setUp(_flutterPluginBinding.binaryMessenger, GeckoDeleteBrowsingDataControllerImpl())
        GeckoDownloadsApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoDownloadsApiImpl())
        GeckoBrowserExtensionApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoBrowserExtensionApiImpl())
        GeckoHistoryApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoHistoryApiImpl())

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

        val fragmentActivity = activity as? FragmentActivity ?: return false

        if (fragmentActivity.isFinishing || fragmentActivity.isDestroyed) {
            return false
        }

        fragmentActivity.findViewById<View>(FRAGMENT_CONTAINER_ID) ?: return false

        val fm = fragmentActivity.supportFragmentManager

        if (fm.isStateSaved) {
            return false
        }

        val existingFragment = fm.findFragmentById(FRAGMENT_CONTAINER_ID)
        if (existingFragment is BrowserFragment) {
            // Check if fragment needs engine refresh instead of full replacement
            if (!isFragmentCorrupted(existingFragment)) {
                return true
            }
        }

        val nativeFragment = BrowserFragment.create()
        fm.beginTransaction()
            .replace(FRAGMENT_CONTAINER_ID, nativeFragment)
            .commitNow()

        return true
    }

    private fun isFragmentCorrupted(fragment: BrowserFragment): Boolean {
        if (!fragment.isAdded || fragment.isDetached || fragment.isRemoving) {
            return true
        }

        val view = fragment.view ?: return true
        if (view.visibility != View.VISIBLE || view.width == 0 || view.height == 0) {
            return true
        }

        if(!view.isAttachedToWindow) {
            return true
        }

        return false
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
