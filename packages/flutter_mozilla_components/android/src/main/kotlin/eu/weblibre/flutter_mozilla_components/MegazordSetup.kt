package eu.weblibre.flutter_mozilla_components

import android.content.Context
import android.content.pm.ApplicationInfo
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.async
import mozilla.components.concept.fetch.Client
import mozilla.components.support.AppServicesInitializer
import mozilla.components.support.AppServicesInitializer.Config as AppServicesConfig
import mozilla.components.support.rusthttp.RustHttpConfig

object MegazordSetup {
    fun setupEarlyMainProcess() {
        AppServicesInitializer.init(AppServicesConfig(null))
    }

    @DelicateCoroutinesApi
    fun setupMegazordNetwork(context: Context, client: Lazy<Client>): Deferred<Unit> =
        GlobalScope.async(Dispatchers.IO) {
            val isDebuggable =
                (context.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0

            if (isDebuggable) {
                RustHttpConfig.allowEmulatorLoopback()
            }

            RustHttpConfig.setClient(client)
        }
}
