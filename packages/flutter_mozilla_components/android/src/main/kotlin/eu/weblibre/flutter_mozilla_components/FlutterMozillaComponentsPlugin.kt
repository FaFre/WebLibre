/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import eu.weblibre.flutter_mozilla_components.api.GeckoBrowserApiImpl
import eu.weblibre.flutter_mozilla_components.api.GeckoEngineSettingsApiImpl
import eu.weblibre.flutter_mozilla_components.feature.SandboxCaptureFeature
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoBrowserApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoEngineSettingsApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoPushApi

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding


/** FlutterMozillaComponentsPlugin */
class FlutterMozillaComponentsPlugin: FlutterPlugin, ActivityAware {
  private val browserApi = GeckoBrowserApiImpl()

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    browserApi.attachBinding(flutterPluginBinding)
    GeckoBrowserApi.setUp(flutterPluginBinding.binaryMessenger, browserApi)
    SandboxCaptureFeature.wireFlutterEvents(flutterPluginBinding.binaryMessenger)

    // Register the engine-settings API at attach time (before GeckoBrowserService
    // .initialize) so Dart can push the history-exclusion contextId set to native
    // *before* the engine starts recording restored-tab visits, closing the
    // startup window where an excluded container could leak to Places.
    // setExcludedHistoryContextIds only writes GlobalComponents state and needs
    // no initialized components; the remaining settings methods resolve
    // components lazily and are not invoked until after initialize. The same
    // instance is reused by GeckoBrowserApiImpl.initialize.
    val engineSettingsApiImpl = GeckoEngineSettingsApiImpl(
      flutterPluginBinding.applicationContext,
    )
    GeckoEngineSettingsApi.setUp(flutterPluginBinding.binaryMessenger, engineSettingsApiImpl)
    GlobalComponents.engineSettingsApi = engineSettingsApiImpl
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    SandboxCaptureFeature.detachFlutterEvents(binding.binaryMessenger)
    GeckoPushApi.setUp(binding.binaryMessenger, null)
    browserApi.disposePushApi()
    GlobalComponents.historyEvents = null
    // The UnifiedPush receiver outlives the Flutter engine; without this it would keep dispatching
    // onto a dead messenger. Failures are still retained on Push.lastError.
    GlobalComponents.pushEvents = null
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    browserApi.attachActivity(binding.activity)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivity() {
    browserApi.detachActivity()
  }
}
