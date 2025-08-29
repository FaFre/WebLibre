package eu.weblibre.pluggable_transports_proxy

import IPtProxy.Controller
import eu.weblibre.pluggable_transports_proxy.pigeons.IPtProxyController
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
import java.io.File

/** PluggableTransportsProxyPlugin */
class PluggableTransportsProxyPlugin : FlutterPlugin {
    private lateinit var channel: MethodChannel

    companion object {
        @Volatile
        private var INSTANCE: Controller? = null

        fun getController(ptDirPath: String): Controller {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: Controller(ptDirPath, true, false, "INFO", null).also { INSTANCE = it }
            }
        }
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val ptDir = File(flutterPluginBinding.applicationContext.cacheDir, "pt_state")
        val ptc = getController(ptDir.path)

        IPtProxyController.setUp(flutterPluginBinding.binaryMessenger, ProxyImpl(controller = ptc))
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Controller instance remains alive for reuse
    }
}
