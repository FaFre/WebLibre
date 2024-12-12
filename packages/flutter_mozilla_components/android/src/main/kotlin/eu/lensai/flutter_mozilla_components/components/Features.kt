package eu.lensai.flutter_mozilla_components.components

import eu.lensai.flutter_mozilla_components.feature.ReadabilityExtractFeature
import eu.lensai.flutter_mozilla_components.feature.WebExtensionToolbarFeature
import eu.lensai.flutter_mozilla_components.pigeons.GeckoAddonEvents
import eu.lensai.flutter_mozilla_components.pigeons.GeckoTabContentEvents
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.Engine

class Features(
    private val engine: Engine,
    private val store: BrowserStore,
    private val addonEvents: GeckoAddonEvents,
    private var tabContentEvents: GeckoTabContentEvents
) {
    val webExtensionToolbarFeature by lazy {
        WebExtensionToolbarFeature(
            store,
            addonEvents
        )
    }

    val readabilityExtractFeature by lazy {
        ReadabilityExtractFeature(
            engine,
            store,
            tabContentEvents
        )
    }
}