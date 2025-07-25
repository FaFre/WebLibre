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

import android.app.ActivityManager
import android.app.Application
import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

class MyApplication : Application() {
    private fun getProcessNameCompat(): String {
        // Try to get process name from ActivityManager
        val pid = android.os.Process.myPid()
        val manager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager

        for (processInfo in manager.runningAppProcesses) {
            if (processInfo.pid == pid) {
                return processInfo.processName
            }
        }

        // Fallback to package name if process name cannot be determined
        return packageName
    }

    override fun onCreate() {
        super.onCreate()

        val processName = getProcessNameCompat()
        // Only initialize Flutter engine in the main process
        if (processName == packageName) {
            // Initialize the Flutter engine
            val flutterEngine = FlutterEngine(this)

            // Pre-warm the Flutter engine with your initial route
            flutterEngine.navigationChannel.setInitialRoute("/")
            flutterEngine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )

            // Cache the Flutter engine
            FlutterEngineCache.getInstance().put("engine_id", flutterEngine)
        }
    }
}