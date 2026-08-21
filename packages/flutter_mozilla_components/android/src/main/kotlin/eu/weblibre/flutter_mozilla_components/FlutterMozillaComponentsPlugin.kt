/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import eu.weblibre.flutter_mozilla_components.api.GeckoBrowserApiImpl
import eu.weblibre.flutter_mozilla_components.api.GeckoEngineSettingsApiImpl
import eu.weblibre.flutter_mozilla_components.api.GeckoProfileApiImpl
import eu.weblibre.flutter_mozilla_components.feature.SandboxCaptureFeature
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoBrowserApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoEngineSettingsApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoProfileApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoPushApi

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding


/** FlutterMozillaComponentsPlugin */
class FlutterMozillaComponentsPlugin: FlutterPlugin, ActivityAware {
  private val browserApi = GeckoBrowserApiImpl()

  /**
   * Held so the leases this engine took — profile access, and whatever the
   * arbiter granted it — can be handed back when the engine goes away. See
   * [GeckoProfileApiImpl.onEngineDetached].
   */
  private var profileApi: GeckoProfileApiImpl? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    // Registered first, and unconditionally: this is the arbitration API Dart
    // `main()` calls before it opens a database, creates a profile, or asks for
    // anything else. Everything below it is profile-bound and therefore only
    // legal after a commitment this API hands out.
    val profileApiImpl = GeckoProfileApiImpl(flutterPluginBinding.applicationContext)
    profileApi = profileApiImpl
    GeckoProfileApi.setUp(flutterPluginBinding.binaryMessenger, profileApiImpl)

    browserApi.attachBinding(flutterPluginBinding)
    GeckoBrowserApi.setUp(flutterPluginBinding.binaryMessenger, browserApi)
    SandboxCaptureFeature.wireFlutterEvents(flutterPluginBinding.binaryMessenger)

    // Register the engine-settings API at attach time (before GeckoBrowserService
    // .initialize) so Dart can push the history-exclusion snapshot to native
    // *before* the engine starts recording restored-tab visits, closing the
    // startup window where an excluded container could leak to Places.
    // setHistoryExclusions only writes HistoryExclusions state and needs
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
    GeckoProfileApi.setUp(binding.binaryMessenger, null)
    // Before anything else: the profile-access lease and the arbiter's selection
    // and maintenance leases are all process-global and keyed on the isolate, so
    // an engine that detaches without handing them back locks every later engine
    // out until the process dies. MainActivity destroys the cached engine on any
    // non-finishing destroy, so that is a routine event.
    profileApi?.onEngineDetached()
    profileApi = null
    SandboxCaptureFeature.detachFlutterEvents(binding.binaryMessenger)
    GeckoPushApi.setUp(binding.binaryMessenger, null)
    browserApi.disposePushApi()
    GlobalComponents.historyEvents = null
    // The availability event is optimisation-only; once Flutter detaches, the surface
    // re-queries pending prompts on its next attach/resume, so dropping the sink is safe.
    GlobalComponents.appLinkEvents = null
    // The UnifiedPush receiver outlives the Flutter engine; without this it would keep dispatching
    // onto a dead messenger. Failures are still retained on Push.lastError.
    GlobalComponents.pushEvents = null
    // An import in flight keeps reporting after detach, and would otherwise hold
    // the old messenger across an engine restart. Progress is advisory, so
    // dropping the sink only costs the percentage, never the import itself.
    GlobalComponents.bookmarksEvents = null
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
