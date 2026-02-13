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
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "eu.weblibre.flutter_mozilla_components/trim_memory"
    private val ENGINE_ID = "engine_id"
    private var channel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
    }

    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        channel?.invokeMethod("onTrimMemory", level)
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine {
        val cache = FlutterEngineCache.getInstance()
        val cachedEngine = cache.get(ENGINE_ID)
        if (cachedEngine != null && cachedEngine.dartExecutor.isExecutingDart) {
            return cachedEngine
        }

        if (cachedEngine != null) {
            cache.remove(ENGINE_ID)
            cachedEngine.destroy()
        }

        val flutterEngine = FlutterEngine(context.applicationContext)
        flutterEngine.navigationChannel.setInitialRoute("/")
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        cache.put(ENGINE_ID, flutterEngine)

        return flutterEngine
    }

    override fun shouldDestroyEngineWithHost(): Boolean {
        return false // Keep engine alive when activity is destroyed
    }
}
