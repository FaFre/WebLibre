package eu.weblibre.flutter_singbox_proxy

import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyApi
import io.flutter.embedding.engine.plugins.FlutterPlugin

/** Flutter plugin entry point for the sing-box proxy runtime. */
class FlutterSingboxProxyPlugin : FlutterPlugin {
    private var runtimeManager: SingboxRuntimeManager? = null
    private var eventStreams: SingboxEventStreams? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val events = SingboxEventStreams().also { it.register(binding.binaryMessenger) }
        eventStreams = events
        val manager = SingboxRuntimeManager(
            context = binding.applicationContext,
            onStateChanged = events::emitState,
            onLogMessage = events::emitLog
        )
        runtimeManager = manager
        SingboxProxyApi.setUp(binding.binaryMessenger, manager)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        SingboxProxyApi.setUp(binding.binaryMessenger, null)
        runtimeManager?.close()
        runtimeManager = null
        eventStreams?.detach()
        eventStreams = null
    }
}
