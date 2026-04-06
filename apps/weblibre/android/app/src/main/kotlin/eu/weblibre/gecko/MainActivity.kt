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
package eu.weblibre.gecko

import android.content.Context
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.FlutterJNI
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    companion object {
        private const val TAG = "MainActivity"
    }

    private val TRIM_MEMORY_CHANNEL = "eu.weblibre.flutter_mozilla_components/trim_memory"
    private val ACTIVITY_CHANNEL = "eu.weblibre.gecko/activity"
    private val ENGINE_ID = "engine_id"
    private var trimMemoryChannel: MethodChannel? = null

    private fun engineTag(engine: FlutterEngine?): String {
        return engine?.let { "0x${System.identityHashCode(it).toString(16)}" } ?: "null"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        Log.d(TAG, "onCreate: savedInstanceState=${savedInstanceState != null}, " +
            "cachedEngine=${engineTag(FlutterEngineCache.getInstance().get(ENGINE_ID))}")

        super.onCreate(null)
    }

    /**
     * Check whether the FlutterEngine's native JNI layer is still attached.
     * Note: binaryMessenger.send() does NOT throw when JNI is detached — it just
     * logs a warning. We must use reflection to access FlutterJNI.isAttachedToJni().
     */
    private fun isEngineNativeAlive(engine: FlutterEngine): Boolean {
        return try {
            val field = FlutterEngine::class.java.getDeclaredField("flutterJNI")
            field.isAccessible = true
            val jni = field.get(engine) as FlutterJNI
            jni.isAttached
        } catch (e: Exception) {
            Log.w(TAG, "Could not check JNI attachment state: ${e.message}")
            false
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        trimMemoryChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TRIM_MEMORY_CHANNEL)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ACTIVITY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "moveTaskToBack" -> {
                    moveTaskToBack(true)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onPause() {
        Log.d(TAG, "onPause")
        super.onPause()
    }

    override fun onDestroy() {
        Log.d(TAG, "onDestroy: isFinishing=$isFinishing, " +
            "cachedEngine=${engineTag(FlutterEngineCache.getInstance().get(ENGINE_ID))}")
        super.onDestroy()

        if (!isFinishing) {
            val cache = FlutterEngineCache.getInstance()
            val engine = cache.get(ENGINE_ID)
            if (engine != null) {
                Log.d(TAG, "onDestroy: system-initiated destroy, clearing stale engine")
                cache.remove(ENGINE_ID)
                try {
                    engine.destroy()
                } catch (e: Exception) {
                    Log.w(TAG, "Error destroying engine in onDestroy", e)
                }
            }
        }
    }

    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        trimMemoryChannel?.invokeMethod("onTrimMemory", level)
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine {
        val cache = FlutterEngineCache.getInstance()
        val cachedEngine = cache.get(ENGINE_ID)
        if (cachedEngine != null) {
            val isHealthy = try {
                cachedEngine.dartExecutor.isExecutingDart && isEngineNativeAlive(cachedEngine)
            } catch (e: Exception) {
                Log.w(TAG, "Cached engine health check failed", e)
                false
            }

            if (isHealthy) {
                Log.d(TAG, "provideFlutterEngine: reusing cached engine ${engineTag(cachedEngine)}")
                return cachedEngine
            }

            Log.w(TAG, "provideFlutterEngine: cached engine ${engineTag(cachedEngine)} is stale, creating fresh")
            cache.remove(ENGINE_ID)
            try {
                cachedEngine.destroy()
            } catch (e: Exception) {
                Log.w(TAG, "Error destroying stale engine", e)
            }
        }

        val flutterEngine = FlutterEngine(context.applicationContext)
        flutterEngine.navigationChannel.setInitialRoute("/")
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        cache.put(ENGINE_ID, flutterEngine)

        Log.d(TAG, "provideFlutterEngine: created new engine ${engineTag(flutterEngine)}")
        return flutterEngine
    }

    override fun shouldDestroyEngineWithHost(): Boolean {
        return false // Keep engine alive when activity is destroyed
    }
}
