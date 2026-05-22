package eu.weblibre.flutter_singbox_proxy

/**
 * Inbound/outbound tag format shared between the Kotlin config builder and
 * the Dart DNS resolver. Changing this contract requires updating
 * `dns_config_resolver.dart` in lockstep — the Dart side emits matching tags
 * so DNS detours bind to the outbound this builder actually creates.
 */
internal object SingboxTagFormat {
    fun inboundTag(profileId: String): String = "in-${sanitizeTag(profileId)}"

    fun outboundTag(profileId: String): String = "out-${sanitizeTag(profileId)}"

    fun sanitizeTag(value: String): String {
        return value.replace(Regex("[^A-Za-z0-9_.-]"), "_")
    }
}
