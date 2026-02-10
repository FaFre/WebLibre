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
import eu.weblibre.simple_intent_receiver.pigeons.Intent as PigeonIntent

class SimpleIntentReceiverPlugin: FlutterPlugin, ActivityAware, PluginRegistry.NewIntentListener {
  private lateinit var context: Context
  private var intentReceiver: IntentReceiver? = null
  private var lastHandledIntent: String? = null
  private var activity: Activity? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    intentReceiver = IntentReceiver(flutterPluginBinding.binaryMessenger)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    intentReceiver = null
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addOnNewIntentListener(this)

    binding.activity.intent?.let { intent ->
      val uri = intent.toUri(0)
      if (lastHandledIntent != uri) {
        handleIntent(intent)
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

  private fun handleIntent(intent: Intent): Boolean {
    // Grant URI permissions for content URIs
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

    // Handle SEND action with STREAM extra
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

    if (intent.flags and Intent.FLAG_ACTIVITY_NEW_TASK != 0) {
      intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
    }

    val pigeonIntent = convertToPigeonIntent(intent)
    intentReceiver?.sendIntent(pigeonIntent)
    return true
  }

  private fun convertToPigeonIntent(intent: Intent): PigeonIntent {
    val action = intent.action
    val data = intent.dataString
    val fromPackageName = intent.getPackage()

    val categories = ArrayList<String>()
    intent.categories?.let {
      categories.addAll(it)
    }

    val extras = HashMap<String, Any?>()
    intent.extras?.let { bundle ->
      for (key in bundle.keySet()) {
        try {
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
