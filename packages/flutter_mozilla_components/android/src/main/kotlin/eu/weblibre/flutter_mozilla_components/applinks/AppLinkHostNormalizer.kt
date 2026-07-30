/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import java.net.IDN
import java.net.InetAddress
import java.util.Locale

/**
 * Native-owned host normalisation (see APP_LINKS_OWN_IMPLEMENTATION_PLAN.md §2.5).
 *
 * The resolver returns the canonical scope key used by prompts and rules; Dart persists
 * it opaquely and never reconstructs it. The same helper normalises hosts when matching
 * `protectedTargetPatterns`.
 */
object AppLinkHostNormalizer {
    const val HOST_SCOPE_PREFIX = "host:"
    const val PACKAGE_SCOPE_PREFIX = "pkg:"

    /**
     * Canonicalise a host:
     * - [Locale.ROOT] lowercase,
     * - strip a single trailing dot,
     * - `IDN.toASCII` for non-ASCII hosts,
     * - reject empty/invalid hosts and IPv6 zone IDs,
     * - canonicalise IP literals.
     *
     * @return the canonical host, or `null` if the host is empty or invalid.
     */
    fun normalizeHost(rawHost: String?): String? {
        if (rawHost.isNullOrEmpty()) return null

        // Reject IPv6 zone identifiers (e.g. fe80::1%eth0) — the zone is host-local
        // and must never participate in a cross-navigation scope key.
        if (rawHost.contains('%')) return null

        var host = rawHost.trim()
        if (host.isEmpty()) return null

        // Strip a single trailing dot (fully-qualified form).
        if (host.endsWith(".")) {
            host = host.dropLast(1)
        }
        if (host.isEmpty()) return null

        // IPv6 literal in brackets: canonicalise the address inside.
        if (host.startsWith("[") && host.endsWith("]")) {
            val inner = host.substring(1, host.length - 1)
            if (inner.contains('%')) return null
            return canonicalizeIpLiteral(inner)?.let { "[$it]" } ?: return null
        }

        // Try to canonicalise as an IP literal first (IPv4 / bare IPv6).
        canonicalizeIpLiteral(host)?.let { return it }

        val lowered = host.lowercase(Locale.ROOT)

        return try {
            val ascii = IDN.toASCII(lowered, IDN.ALLOW_UNASSIGNED)
            if (ascii.isEmpty()) null else ascii.lowercase(Locale.ROOT)
        } catch (e: IllegalArgumentException) {
            null
        }
    }

    /**
     * Canonicalise an IP literal (numeric address only). Returns `null` when [value] is not a
     * numeric IP literal, so callers can fall through to hostname handling.
     */
    private fun canonicalizeIpLiteral(value: String): String? {
        if (value.isEmpty()) return null
        // Only treat clearly-numeric forms as IP literals; a real hostname must go through IDN.
        val looksNumeric = value.all { it.isDigit() || it == '.' } ||
            (value.contains(':') && value.all { it.isDigit() || it == ':' || it in 'a'..'f' || it in 'A'..'F' })
        if (!looksNumeric) return null

        return try {
            val address = InetAddress.getByName(value)
            address.hostAddress?.lowercase(Locale.ROOT)
        } catch (e: Exception) {
            null
        }
    }

    /** Build the canonical scope key for a host (`host:youtube.com`). */
    fun hostScopeKey(rawHost: String?): String? {
        val host = normalizeHost(rawHost) ?: return null
        return HOST_SCOPE_PREFIX + host
    }

    /** Build the canonical scope key for a package (`pkg:us.zoom.videomeetings`). */
    fun packageScopeKey(packageName: String?): String? {
        if (packageName.isNullOrEmpty()) return null
        return PACKAGE_SCOPE_PREFIX + packageName
    }
}
