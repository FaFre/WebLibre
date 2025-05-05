package me.movenext.simple_intent_receiver

import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry
import me.movenext.simple_intent_receiver.pigeons.Intent as PigeonIntent

class SimpleIntentReceiverPlugin: FlutterPlugin, ActivityAware, PluginRegistry.NewIntentListener {
  private lateinit var context: Context
  private var intentReceiver: IntentReceiver? = null
  private var handledInitialIntent = false

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext

    intentReceiver = IntentReceiver(flutterPluginBinding.binaryMessenger)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    intentReceiver = null
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    binding.addOnNewIntentListener(this)

    // Process the initial intent if available
    binding.activity.intent?.let { intent ->
      if (!handledInitialIntent) {
        handleIntent(intent)
        handledInitialIntent = true
      }
    }
  }

  override fun onDetachedFromActivityForConfigChanges() {
    // No implementation needed
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    binding.addOnNewIntentListener(this)
  }

  override fun onDetachedFromActivity() {
    // No implementation needed
  }

  override fun onNewIntent(intent: Intent): Boolean {
    return handleIntent(intent)
  }

  private fun handleIntent(intent: Intent): Boolean {
    val pigeonIntent = convertToPigeonIntent(intent)
    intentReceiver?.sendIntent(System.currentTimeMillis(), pigeonIntent)
    return true
  }

  private fun convertToPigeonIntent(intent: Intent): PigeonIntent {
    val action = intent.action
    val data = intent.dataString
    val fromPackageName = intent.getPackage()

    // Extract categories
    val categories = ArrayList<String>()
    intent.categories?.let {
      categories.addAll(it)
    }

    // Extract extras
    val extras = HashMap<String, Any?>()
    intent.extras?.keySet()?.forEach { key ->
      extras[key] = intent.extras?.get(key)
    }

    return PigeonIntent(
      fromPackageName = fromPackageName,
      action = action,
      data = data,
      categories = categories,
      extra = extras
    )
  }
}
