package eu.weblibre.flutter_mozilla_components_example

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "eu.weblibre.flutter_mozilla_components/trim_memory"
    private lateinit var channel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
    }

    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        channel.invokeMethod("onTrimMemory", level)
    }
}
