package eu.weblibre.flutter_mozilla_components.components

import android.content.Context
import mozilla.appservices.fxaclient.FxaServer as AppServicesFxaServer
import mozilla.components.service.fxa.ServerConfig

object FxaServer {
    private const val CLIENT_ID = "a2270f727f45f648"
    const val REDIRECT_URL = "urn:ietf:wg:oauth:2.0:oob:oauth-redirect-webchannel"

    fun config(
        context: Context,
        serverOverride: String?,
        tokenServerOverride: String?
    ): ServerConfig {
        val effectiveServerOverride = serverOverride?.trim().orEmpty()
        val effectiveTokenOverride = tokenServerOverride?.trim().takeUnless { it.isNullOrEmpty() }

        return if (effectiveServerOverride.isEmpty()) {
            ServerConfig(AppServicesFxaServer.Release, CLIENT_ID, REDIRECT_URL, effectiveTokenOverride)
        } else {
            ServerConfig(
                AppServicesFxaServer.Custom(effectiveServerOverride),
                CLIENT_ID,
                REDIRECT_URL,
                effectiveTokenOverride,
            )
        }
    }
}
