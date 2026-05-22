package eu.weblibre.flutter_singbox_proxy

import kotlin.test.Test
import kotlin.test.assertEquals

/**
 * Tag format is part of the Dart↔Kotlin contract: the Dart DNS resolver in
 * `dns_config_resolver.dart` emits `out-`/`in-` tags that must match what the
 * config builder writes. The mirrored Dart test lives in
 * `apps/weblibre/test/features/proxy/domain/services/singbox_tag_format_test.dart`
 * — both must update together if this format ever changes.
 */
internal class SingboxTagFormatTest {
    @Test
    fun outboundTag_isPrefixedAndSanitized() {
        assertEquals("out-singbox_foo-bar", SingboxTagFormat.outboundTag("singbox:foo-bar"))
    }

    @Test
    fun inboundTag_isPrefixedAndSanitized() {
        assertEquals("in-singbox_foo-bar", SingboxTagFormat.inboundTag("singbox:foo-bar"))
    }

    @Test
    fun sanitizeTag_preservesAlphanumericDotsDashesUnderscores() {
        assertEquals(
            "Abc_123.x-Y",
            SingboxTagFormat.sanitizeTag("Abc_123.x-Y")
        )
    }

    @Test
    fun sanitizeTag_replacesSpacesSlashesAndColons() {
        assertEquals(
            "a_b_c_d_e",
            SingboxTagFormat.sanitizeTag("a:b c/d\\e")
        )
    }
}
