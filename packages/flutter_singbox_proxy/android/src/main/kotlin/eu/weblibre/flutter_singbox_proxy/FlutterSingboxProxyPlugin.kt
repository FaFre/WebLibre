package eu.weblibre.flutter_singbox_proxy

import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyApi
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyEventsApi
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyLogMessage
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyRuntimeState
import io.flutter.embedding.engine.plugins.FlutterPlugin

/** Flutter plugin entry point for the sing-box proxy runtime. */
class FlutterSingboxProxyPlugin : FlutterPlugin {
    private var runtimeManager: SingboxRuntimeManager? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val eventsApi = SingboxProxyEventsApi(binding.binaryMessenger)
        val manager = SingboxRuntimeManager(
            context = binding.applicationContext,
            onStateChanged = { state: SingboxProxyRuntimeState ->
                eventsApi.onStateChanged(state) { }
            },
            onLogMessage = { message: SingboxProxyLogMessage ->
                eventsApi.onLogMessage(message) { }
            }
        )
        runtimeManager = manager
        SingboxProxyApi.setUp(binding.binaryMessenger, manager)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        SingboxProxyApi.setUp(binding.binaryMessenger, null)
        runtimeManager?.close()
        runtimeManager = null
    }
}
