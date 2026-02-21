package eu.weblibre.flutter_mozilla_components.components

import mozilla.components.concept.sync.FxAEntryPoint

enum class WebLibreFxAEntryPoint(override val entryName: String) : FxAEntryPoint {
    Settings("settings"),
}
