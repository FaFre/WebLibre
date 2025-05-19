package eu.weblibre.browser

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