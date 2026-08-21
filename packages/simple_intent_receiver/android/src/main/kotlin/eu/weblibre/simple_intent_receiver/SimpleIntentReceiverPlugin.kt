/*
 * Copyright (c) 2024-2025 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
package eu.weblibre.simple_intent_receiver

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry
import eu.weblibre.simple_intent_receiver.pigeons.IntentHost
import eu.weblibre.simple_intent_receiver.pigeons.Intent as PigeonIntent
import eu.weblibre.simple_intent_receiver.pigeons.IntentGatekeeperHostApi

class SimpleIntentReceiverPlugin: FlutterPlugin, ActivityAware, PluginRegistry.NewIntentListener, IntentHost {
  companion object {
    private val EXTRA_NOTIFICATION_APPROVAL_TOKEN =
      IntentApprovals.EXTRA_NOTIFICATION_APPROVAL_TOKEN
    private val EXTRA_ALWAYS_ALLOW_PACKAGE = IntentApprovals.EXTRA_ALWAYS_ALLOW_PACKAGE
  }

  private lateinit var context: Context
  private var intentReceiver: IntentReceiver? = null
  private var lastHandledIntent: String? = null
  private var activity: Activity? = null
  private var binaryMessenger: io.flutter.plugin.common.BinaryMessenger? = null

  /**
   * Caches the launch intent so Dart can retrieve it after setUp().
   * On cold start, onAttachedToActivity fires before Dart registers its
   * Pigeon handler, so the initial sendIntent message is lost. This field
   * lets Dart call getInitialIntent() to recover it.
   *
   * On Android configuration change (rotation, theme switch) the activity
   * is recreated and onAttachedToActivity fires again with the same
   * launching intent. The `lastHandledIntent` guard below prevents
   * re-caching that identical intent. If a NEW deep link arrives via the
   * launcher between two Dart-side reads of getInitialIntent(),
   * pendingInitialIntent is overwritten — only the latest intent is
   * delivered. This is intentional: dropping the stale one keeps the
   * "initial" intent meaning "what should the app open into right now".
   */
  private var pendingInitialIntent: PigeonIntent? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    intentReceiver = IntentReceiver(flutterPluginBinding.binaryMessenger)
    binaryMessenger = flutterPluginBinding.binaryMessenger
    IntentHost.setUp(flutterPluginBinding.binaryMessenger, this)
    IntentGatekeeperHostApi.setUp(
      flutterPluginBinding.binaryMessenger,
      IntentGatekeeperHostApiImpl(flutterPluginBinding.applicationContext),
    )
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    intentReceiver = null
    binaryMessenger?.let {
      IntentHost.setUp(it, null)
      IntentGatekeeperHostApi.setUp(it, null)
    }
    binaryMessenger = null
  }

  override fun getInitialIntent(): PigeonIntent? {
    val intent = pendingInitialIntent
    pendingInitialIntent = null
    return intent
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addOnNewIntentListener(this)

    binding.activity.intent?.let { intent ->
      val uri = intent.toUri(0)
      if (lastHandledIntent != uri) {
        // Cache the launch intent for Dart to retrieve via getInitialIntent().
        // Don't send via Pigeon here — the Dart handler isn't registered yet
        // during cold start so the message would be lost.
        pendingInitialIntent = prepareIntentForDelivery(intent)
        lastHandledIntent = uri
      }
    }
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addOnNewIntentListener(this)
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onNewIntent(intent: Intent): Boolean {
    activity?.setIntent(intent)
    return handleIntent(intent)
  }

  private fun grantUriPermissions(intent: Intent) {
    intent.data?.let { uri ->
      if (uri.scheme == "content") {
        try {
          activity?.grantUriPermission(
            context.packageName,
            uri,
            Intent.FLAG_GRANT_READ_URI_PERMISSION
          )
        } catch (e: Exception) {
          Log.w("SimpleIntentReceiver", "Could not grant URI permission for: $uri", e)
        }
      }
    }

    intent.getStringExtra(Intent.EXTRA_STREAM)?.let { streamUri ->
      try {
        val uri = Uri.parse(streamUri)
        if (uri.scheme == "content") {
          activity?.grantUriPermission(
            context.packageName,
            uri,
            Intent.FLAG_GRANT_READ_URI_PERMISSION
          )
        }
      } catch (e: Exception) {
        Log.w("SimpleIntentReceiver", "Could not grant URI permission for stream: $streamUri", e)
      }
    }
  }

  private fun handleIntent(intent: Intent): Boolean {
    val pigeonIntent = prepareIntentForDelivery(intent)
    intentReceiver?.sendIntent(pigeonIntent)
    return true
  }

  private fun prepareIntentForDelivery(intent: Intent): PigeonIntent {
    grantUriPermissions(intent)

    if (intent.flags and Intent.FLAG_ACTIVITY_NEW_TASK != 0) {
      intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
    }

    // Shared with the startup broker, which has to redeem the same token when it
    // queues a launch the plugin will never see.
    val notificationApproval = IntentApprovals.consume(context, intent)
    return convertToPigeonIntent(intent, notificationApproval)
  }

  /**
   * Delegates to [IntentCallerResolver] rather than resolving here, because the
   * native startup broker has to record the same answer for a launch it replays
   * later. Two copies of this would agree only until one was edited.
   */
  private fun resolveCallerPackage(intent: Intent, notificationApproval: NotificationApproval?): String? {
    if (notificationApproval != null) {
      return null
    }

    return IntentCallerResolver.resolve(context, activity, intent)
  }

  private fun convertToPigeonIntent(intent: Intent, notificationApproval: NotificationApproval?): PigeonIntent {
    val action = intent.action
    val data = intent.dataString
    val fromPackageName = resolveCallerPackage(intent, notificationApproval)

    val categories = ArrayList<String>()
    intent.categories?.let {
      categories.addAll(it)
    }

    val extras = HashMap<String, Any?>()
    intent.extras?.let { bundle ->
      for (key in bundle.keySet()) {
        try {
          if (key == EXTRA_NOTIFICATION_APPROVAL_TOKEN) {
            continue
          }
          if (key == EXTRA_ALWAYS_ALLOW_PACKAGE) {
            continue
          }

          when (val value = bundle.get(key)) {
            is Bundle -> {
              val bundleMap = HashMap<String, Any?>()
              for (bundleKey in value.keySet()) {
                val bundleValue = value.get(bundleKey)
                if (bundleValue == null || bundleValue is String ||
                  bundleValue is Boolean || bundleValue is Int ||
                  bundleValue is Long || bundleValue is Double ||
                  bundleValue is Float) {
                  bundleMap[bundleKey] = bundleValue
                } else {
                  bundleMap[bundleKey] = bundleValue.toString()
                }
              }
              extras[key] = bundleMap
            }
            null, is String, is Boolean, is Int, is Long, is Double, is Float,
            is ByteArray, is IntArray, is LongArray, is DoubleArray, is FloatArray -> {
              extras[key] = value
            }
            else -> {
              extras[key] = value.toString()
            }
          }
        } catch (e: Exception) {
          Log.w("SimpleIntentReceiver", "Could not extract extra with key: $key", e)
          extras["${key}_error"] = e.message ?: "Unknown error"
        }
      }
    }

    notificationApproval?.alwaysAllowPackage?.let {
      extras[EXTRA_ALWAYS_ALLOW_PACKAGE] = it
    }

    return PigeonIntent(
      fromPackageName = fromPackageName,
      action = action,
      data = data,
      categories = categories,
      mimeType = intent.type,
      extra = extras
    )
  }
}
