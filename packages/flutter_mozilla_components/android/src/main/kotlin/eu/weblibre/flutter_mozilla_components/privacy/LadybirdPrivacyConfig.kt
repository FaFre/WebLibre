/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.privacy

import java.security.MessageDigest

/**
 * Privacy configuration inspired by Ladybird's LibPrivacy module.
 *
 * Provides per-origin deterministic fingerprinting countermeasures:
 * - Per-origin User-Agent spoofing with SHA-256 deterministic selection
 * - Per-origin deterministic noise seed generation for canvas/audio randomization
 * - WebGL blocking toggle
 * - Cookie isolation toggle
 *
 * Reference: qwerzxcva/ladybird Libraries/LibPrivacy
 */
object LadybirdPrivacyConfig {

    enum class ProtectionLevel { Off, Standard, Strict }

    private var fingerprintLevel: ProtectionLevel = ProtectionLevel.Strict
    private var spoofUserAgent: Boolean = true
    private var isolateCookies: Boolean = true
    private var blockWebGL: Boolean = false

    // Cached per-origin results to avoid redundant SHA-256 computation
    private val uaCache = mutableMapOf<String, String>()
    private val noiseSeedCache = mutableMapOf<String, Int>()

    private val userAgentPool = arrayOf(
        "Mozilla/5.0 (Android 14; Pixel 8) AppleWebKit/537.36 Chrome/120.0.0.0 Mobile Safari/537.36",
        "Mozilla/5.0 (Android 13; SM-S908B) AppleWebKit/537.36 Chrome/119.0.0.0 Mobile Safari/537.36",
        "Mozilla/5.0 (Android 14; ASUS_AI2401) AppleWebKit/537.36 Chrome/121.0.0.0 Mobile Safari/537.36",
        "Mozilla/5.0 (Android 13; OnePlus CPH2581) AppleWebKit/537.36 Chrome/118.0.0.0 Mobile Safari/537.36"
    )

    fun protectionLevel(): ProtectionLevel = fingerprintLevel
    fun setProtectionLevel(level: ProtectionLevel) { fingerprintLevel = level }

    fun shouldSpoofUserAgent(): Boolean = spoofUserAgent
    fun setSpoofUserAgent(value: Boolean) { spoofUserAgent = value }

    fun shouldIsolateCookies(): Boolean = isolateCookies
    fun setIsolateCookies(value: Boolean) { isolateCookies = value }

    fun shouldBlockWebGL(): Boolean = blockWebGL
    fun setBlockWebGL(value: Boolean) { blockWebGL = value }

    /**
     * Returns a per-origin stable but unique User-Agent string.
     *
     * Uses SHA-256(origin + salt) to deterministically pick from a pool
     * of realistic Android Chrome UAs. Same origin always gets same UA,
     * different origins get different (but realistic) UAs.
     *
     * This prevents cross-origin user agent correlation while maintaining
     * compatibility with sites that check UA strings.
     */
    fun getIsolatedUserAgent(origin: String): String {
        if (!spoofUserAgent || fingerprintLevel == ProtectionLevel.Off) {
            return userAgentPool[0]
        }

        uaCache[origin]?.let { return it }

        val digest = MessageDigest.getInstance("SHA-256")
        digest.update(origin.toByteArray())
        digest.update("ladybird-privacy-salt-v1".toByteArray())
        val hash = digest.digest()

        // Use first 4 bytes as selector (matching C++ implementation)
        val selector = ((hash[0].toInt() and 0xFF) shl 24) or
                       ((hash[1].toInt() and 0xFF) shl 16) or
                       ((hash[2].toInt() and 0xFF) shl 8) or
                       (hash[3].toInt() and 0xFF)

        val selected = userAgentPool[selector % userAgentPool.size]
        uaCache[origin] = selected
        return selected
    }

    /**
     * Returns a per-origin deterministic noise seed for fingerprint randomization.
     *
     * Used to add consistent-but-random noise to:
     * - Canvas2D pixel hashing (every origin sees slightly different pixels)
     * - AudioContext fingerprinting (shifted frequency response curves)
     * - WebGL renderer strings
     *
     * Same origin always gets the same seed (deterministic),
     * different origins get different seeds (isolated).
     * ProtectionLevel.Off returns 0 (no noise).
     */
    fun getNoiseSeedForOrigin(origin: String): Int {
        if (fingerprintLevel == ProtectionLevel.Off) return 0

        noiseSeedCache[origin]?.let { return it }

        val digest = MessageDigest.getInstance("SHA-256")
        digest.update(origin.toByteArray())
        digest.update("noise-seed-salt-v1".toByteArray())
        val hash = digest.digest()

        val seed = ((hash[0].toInt() and 0xFF) shl 24) or
                   ((hash[1].toInt() and 0xFF) shl 16) or
                   ((hash[2].toInt() and 0xFF) shl 8) or
                   (hash[3].toInt() and 0xFF)

        noiseSeedCache[origin] = seed
        return seed
    }
}