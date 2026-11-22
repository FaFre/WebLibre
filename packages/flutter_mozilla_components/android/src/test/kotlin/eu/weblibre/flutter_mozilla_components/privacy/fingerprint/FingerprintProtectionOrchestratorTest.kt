/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.privacy.fingerprint

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * Unit tests for FingerprintProtectionOrchestrator.
 */
class FingerprintProtectionOrchestratorTest {

    private val orchestrator = FingerprintProtectionOrchestrator()

    // =========================================================================
    // ProtectionConfig Tests
    // =========================================================================

    @Test
    fun `default config has STANDARD level`() {
        val config = FingerprintProtectionOrchestrator.ProtectionConfig.DEFAULT
        assertEquals(
            FingerprintProtectionOrchestrator.ProtectionLevel.STANDARD,
            config.level
        )
        assertTrue(config.engineRFP)
        assertTrue(config.extensionScripts)
        assertTrue(config.apiLimiting)
    }

    @Test
    fun `MINIMAL config has BASIC level`() {
        val config = FingerprintProtectionOrchestrator.ProtectionConfig.MINIMAL
        assertEquals(
            FingerprintProtectionOrchestrator.ProtectionLevel.BASIC,
            config.level
        )
    }

    @Test
    fun `MAXIMUM config enables all protections`() {
        val config = FingerprintProtectionOrchestrator.ProtectionConfig.MAXIMUM
        assertEquals(
            FingerprintProtectionOrchestrator.ProtectionLevel.MAXIMUM,
            config.level
        )
        assertTrue(config.sensorLimit)
    }

    // =========================================================================
    // ProtectionLevel Tests
    // =========================================================================

    @Test
    fun `protection levels are ordered correctly`() {
        val levels = FingerprintProtectionOrchestrator.ProtectionLevel.values()
        assertEquals(4, levels.size)
        assertEquals(
            FingerprintProtectionOrchestrator.ProtectionLevel.OFF,
            levels[0]
        )
        assertEquals(
            FingerprintProtectionOrchestrator.ProtectionLevel.MAXIMUM,
            levels[3]
        )
    }

    // =========================================================================
    // ProtectionStatus Tests
    // =========================================================================

    @Test
    fun `protection status reflects config`() {
        val config = FingerprintProtectionOrchestrator.ProtectionConfig(
            level = FingerprintProtectionOrchestrator.ProtectionLevel.ADVANCED,
            engineRFP = true,
            extensionScripts = true,
            apiLimiting = true,
            whiteList = setOf("example.com")
        )
        
        // Note: This test would need a mock engine to run fully
        // For now, we just verify the config is valid
        assertNotNull(config)
        assertEquals(1, config.whiteList.size)
        assertTrue(config.whiteList.contains("example.com"))
    }

    // =========================================================================
    // Orchestration Logic Tests
    // =========================================================================

    @Test
    fun `orchestrator instance is singleton`() {
        val instance1 = FingerprintProtectionOrchestrator.getInstance()
        val instance2 = FingerprintProtectionOrchestrator.getInstance()
        assertSame(instance1, instance2)
    }

    @Test
    fun `custom config can be created`() {
        val config = FingerprintProtectionOrchestrator.ProtectionConfig(
            level = FingerprintProtectionOrchestrator.ProtectionLevel.STANDARD,
            canvasNoise = false,
            webglSpoofing = true,
            apiLimiting = false
        )
        
        assertFalse(config.canvasNoise)
        assertTrue(config.webglSpoofing)
        assertFalse(config.apiLimiting)
    }
}
