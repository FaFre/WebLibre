package eu.lensai.flutter_mozilla_components.api

import eu.lensai.flutter_mozilla_components.feature.ContainerProxyFeature
import eu.lensai.flutter_mozilla_components.pigeons.GeckoContainerProxyApi

class GeckoContainerProxyApiImpl : GeckoContainerProxyApi {
    override fun setProxyPort(port: Long) {
        ContainerProxyFeature.scheduleRequest("setProxyPort", port.toInt())
    }

    override fun addContainerProxy(contextId: String) {
        ContainerProxyFeature.scheduleRequest("addContainerProxy", contextId)
    }

    override fun removeContainerProxy(contextId: String) {
        ContainerProxyFeature.scheduleRequest("removeContainerProxy", contextId)
    }
}