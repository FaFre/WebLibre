package eu.lensai.flutter_mozilla_components

import android.app.Activity
import android.content.Intent
import android.view.View
import androidx.fragment.app.FragmentActivity
import eu.lensai.flutter_mozilla_components.activities.NotificationActivity
import eu.lensai.flutter_mozilla_components.api.GeckoAddonsApiImpl
import eu.lensai.flutter_mozilla_components.api.GeckoBrowserApiImpl
import eu.lensai.flutter_mozilla_components.api.GeckoContainerProxyApiImpl
import eu.lensai.flutter_mozilla_components.api.GeckoCookieApiImpl
import eu.lensai.flutter_mozilla_components.api.GeckoDeleteBrowsingDataControllerImpl
import eu.lensai.flutter_mozilla_components.api.GeckoDownloadsApiImpl
import eu.lensai.flutter_mozilla_components.api.GeckoEngineSettingsApiImpl
import eu.lensai.flutter_mozilla_components.api.GeckoFindApiImpl
import eu.lensai.flutter_mozilla_components.api.GeckoIconsApiImpl
import eu.lensai.flutter_mozilla_components.api.GeckoPrefApiImpl
import eu.lensai.flutter_mozilla_components.api.GeckoSelectionActionControllerImpl
import eu.lensai.flutter_mozilla_components.api.GeckoSessionApiImpl
import eu.lensai.flutter_mozilla_components.api.GeckoSuggestionApiImpl
import eu.lensai.flutter_mozilla_components.api.GeckoTabsApiImpl
import eu.lensai.flutter_mozilla_components.api.GeckoBrowserExtensionApiImpl
import eu.lensai.flutter_mozilla_components.feature.DefaultSelectionActionDelegate
import eu.lensai.flutter_mozilla_components.pigeons.BrowserExtensionEvents
import eu.lensai.flutter_mozilla_components.pigeons.GeckoAddonEvents
import eu.lensai.flutter_mozilla_components.pigeons.GeckoAddonsApi
import eu.lensai.flutter_mozilla_components.pigeons.GeckoBrowserApi
import eu.lensai.flutter_mozilla_components.pigeons.GeckoBrowserExtensionApi
import eu.lensai.flutter_mozilla_components.pigeons.GeckoContainerProxyApi
import eu.lensai.flutter_mozilla_components.pigeons.GeckoCookieApi
import eu.lensai.flutter_mozilla_components.pigeons.GeckoDeleteBrowsingDataController
import eu.lensai.flutter_mozilla_components.pigeons.GeckoDownloadsApi
import eu.lensai.flutter_mozilla_components.pigeons.GeckoEngineSettingsApi
import eu.lensai.flutter_mozilla_components.pigeons.GeckoFindApi
import eu.lensai.flutter_mozilla_components.pigeons.GeckoIconsApi
import eu.lensai.flutter_mozilla_components.pigeons.GeckoPrefApi
import eu.lensai.flutter_mozilla_components.pigeons.GeckoSelectionActionController
import eu.lensai.flutter_mozilla_components.pigeons.GeckoSelectionActionEvents
import eu.lensai.flutter_mozilla_components.pigeons.GeckoSessionApi
import eu.lensai.flutter_mozilla_components.pigeons.GeckoStateEvents
import eu.lensai.flutter_mozilla_components.pigeons.GeckoSuggestionApi
import eu.lensai.flutter_mozilla_components.pigeons.GeckoSuggestionEvents
import eu.lensai.flutter_mozilla_components.pigeons.GeckoTabContentEvents
import eu.lensai.flutter_mozilla_components.pigeons.GeckoTabsApi
import eu.lensai.flutter_mozilla_components.pigeons.ReaderViewController
import eu.lensai.flutter_mozilla_components.pigeons.ReaderViewEvents

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import mozilla.components.support.base.log.Log
import mozilla.components.support.base.log.sink.AndroidLogSink


/** FlutterMozillaComponentsPlugin */
class FlutterMozillaComponentsPlugin: FlutterPlugin, ActivityAware {
  companion object {
    private const val FRAGMENT_CONTAINER_ID = 0xBEEF

    private var isGeckoInitialized = false
  }

  private val components by lazy {
    requireNotNull(GlobalComponents.components) { "Components not initialized" }
  }

  private var activity: Activity? = null

  private lateinit var _flutterPluginBinding: FlutterPlugin.FlutterPluginBinding;
  private lateinit var _flutterEvents : GeckoStateEvents

  private var isPlatformViewRegistered = false

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    synchronized(this) {
      if(!isGeckoInitialized) {
        Log.addSink(AndroidLogSink())

        setupGeckoEngine(flutterPluginBinding)
        isGeckoInitialized = true
      }
    }
  }

  private fun setupGeckoEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    _flutterPluginBinding = flutterPluginBinding

    _flutterEvents = GeckoStateEvents(_flutterPluginBinding.binaryMessenger)
    val selectionActionEvents = GeckoSelectionActionEvents(_flutterPluginBinding.binaryMessenger)

    val selectionActionDelegate = DefaultSelectionActionDelegate(selectionActionEvents)

    val readerViewController =
      ReaderViewController(_flutterPluginBinding.binaryMessenger)

    val extensionEvents = BrowserExtensionEvents(_flutterPluginBinding.binaryMessenger)

    val addonEvents = GeckoAddonEvents(_flutterPluginBinding.binaryMessenger)
    val tabContentEvents = GeckoTabContentEvents(_flutterPluginBinding.binaryMessenger)

    val suggestionEvents = GeckoSuggestionEvents(_flutterPluginBinding.binaryMessenger)
    GeckoSuggestionApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoSuggestionApiImpl(suggestionEvents))

    GlobalComponents.setUp(
      flutterPluginBinding.applicationContext,
      _flutterEvents,
      readerViewController,
      selectionActionDelegate,
      addonEvents,
      tabContentEvents,
      extensionEvents
    )

    GeckoBrowserApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoBrowserApiImpl {
      showNativeFragment()
    })

    GeckoEngineSettingsApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoEngineSettingsApiImpl())
    GeckoAddonsApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoAddonsApiImpl(flutterPluginBinding.applicationContext))
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

    val intent = Intent(flutterPluginBinding.applicationContext, NotificationActivity::class.java)
    intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    flutterPluginBinding.applicationContext.startActivity(intent)
  }

  private fun showNativeFragment(): Boolean {
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

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {

  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.activity = binding.activity

    _flutterPluginBinding.platformViewRegistry.registerViewFactory(
      "eu.lensai/gecko", GeckoViewFactory(
        binding.activity,
        FRAGMENT_CONTAINER_ID,
        _flutterEvents
      )
    )

    isPlatformViewRegistered = true
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivity() {
    this.activity = null
    isPlatformViewRegistered = false
  }
}
