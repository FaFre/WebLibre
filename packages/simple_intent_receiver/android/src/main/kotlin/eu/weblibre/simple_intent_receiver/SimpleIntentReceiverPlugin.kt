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
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
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
    // Stable names that must match the notification replay path and shared-prefs schema.
    private const val PREFS_NAME = "weblibre_intent_gatekeeper"
    private const val KEY_NOTIFICATION_APPROVAL_TOKENS = "notification_approval_tokens"
    private const val KEY_NOTIFICATION_APPROVAL_PACKAGE_PREFIX = "notification_approval_package_"
    private const val EXTRA_NOTIFICATION_APPROVAL_TOKEN = "eu.weblibre.gatekeeper.notification_approval_token"
    private const val EXTRA_ALWAYS_ALLOW_PACKAGE = "eu.weblibre.gatekeeper.always_allow_package"
  }

  private data class NotificationApproval(val alwaysAllowPackage: String?)

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

    val notificationApproval = consumeNotificationApproval(intent)
    return convertToPigeonIntent(intent, notificationApproval)
  }

  private fun resolveCallerPackage(intent: Intent, notificationApproval: NotificationApproval?): String? {
    if (notificationApproval != null) {
      return null
    }

    val raw = resolveRawCallerPackage(intent) ?: return null
    // Treat system packages (launcher, shell, SystemUI, etc.) as internal — the
    // gatekeeper shouldn't prompt the user when the OS itself forwards an intent.
    if (isSystemPackage(raw)) return null
    return raw
  }

  private fun resolveRawCallerPackage(intent: Intent): String? {
    // 1. Try Activity.getReferrer() — handles EXTRA_REFERRER/_NAME and real caller.
    activity?.referrer?.let { uri ->
      if (uri.scheme == "android-app") {
        uri.host?.let { return it }
      }
    }

    // 2. Fallback to explicit referrer extras on the intent itself.
    @Suppress("DEPRECATION")
    val referrerUri: Uri? = intent.getParcelableExtra(Intent.EXTRA_REFERRER)
    if (referrerUri?.scheme == "android-app") {
      referrerUri.host?.let { return it }
    }

    intent.getStringExtra(Intent.EXTRA_REFERRER_NAME)?.let { name ->
      Uri.parse(name).takeIf { it.scheme == "android-app" }?.host?.let { return it }
    }

    // 3. Caller for startActivityForResult flows.
    return activity?.callingPackage
  }

  private fun isSystemPackage(packageName: String): Boolean {
    return try {
      val pm = context.packageManager
      val info = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        pm.getApplicationInfo(packageName, PackageManager.ApplicationInfoFlags.of(0))
      } else {
        @Suppress("DEPRECATION")
        pm.getApplicationInfo(packageName, 0)
      }
      val systemFlags = ApplicationInfo.FLAG_SYSTEM or ApplicationInfo.FLAG_UPDATED_SYSTEM_APP
      (info.flags and systemFlags) != 0
    } catch (_: PackageManager.NameNotFoundException) {
      false
    } catch (_: Exception) {
      false
    }
  }

  private fun consumeNotificationApproval(intent: Intent): NotificationApproval? {
    val token = intent.getStringExtra(EXTRA_NOTIFICATION_APPROVAL_TOKEN) ?: return null
    val prefs = context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    val tokens = prefs.getStringSet(KEY_NOTIFICATION_APPROVAL_TOKENS, emptySet())?.toMutableSet()
      ?: return null
    if (!tokens.remove(token)) {
      return null
    }

    val alwaysAllowPackage = prefs.getString("$KEY_NOTIFICATION_APPROVAL_PACKAGE_PREFIX$token", null)
    prefs.edit()
      .putStringSet(KEY_NOTIFICATION_APPROVAL_TOKENS, tokens)
      .remove("$KEY_NOTIFICATION_APPROVAL_PACKAGE_PREFIX$token")
      .apply()

    return NotificationApproval(alwaysAllowPackage)
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
