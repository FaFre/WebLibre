package eu.lensai.flutter_mozilla_components

import eu.lensai.flutter_mozilla_components.api.GeckoBrowserApiImpl
import eu.lensai.flutter_mozilla_components.pigeons.GeckoBrowserApi

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding


/** FlutterMozillaComponentsPlugin */
class FlutterMozillaComponentsPlugin: FlutterPlugin, ActivityAware {
  private val browserApi = GeckoBrowserApiImpl()

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    browserApi.attachBinding(flutterPluginBinding)
    GeckoBrowserApi.setUp(flutterPluginBinding.binaryMessenger, browserApi)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {

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
