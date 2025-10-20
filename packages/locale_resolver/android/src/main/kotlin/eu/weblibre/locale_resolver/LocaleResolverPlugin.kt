package eu.weblibre.locale_resolver

import eu.weblibre.locale_resolver.pigeons.LocaleResolver
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** LocaleResolverPlugin */
class LocaleResolverPlugin : FlutterPlugin {
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        LocaleResolver.setUp(flutterPluginBinding.binaryMessenger, LocaleResolverImpl())
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {

    }
}
