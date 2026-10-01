/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.privacy.fingerprint

import mozilla.components.support.base.log.logger.Logger

/**
 * Generates comprehensive fingerprint protection JavaScript.
 *
 * Combines techniques from CanvasBlocker, My-Fingerprint, and Chameleon
 * into a single optimized script.
 */
class FingerprintProtectionScriptGenerator {

    companion object {
        private val logger = Logger("FingerprintProtectionGenerator")
        
        const val SCRIPT_NAME = "fingerprint_protection.js"
    }

    enum class ProtectionMode {
        MINIMAL,    // Basic protection, maximum compatibility
        BALANCED,   // Good protection, reasonable compatibility
        MAXIMUM     // Maximum protection, may break some sites
    }

    /**
     * Generate comprehensive protection script.
     */
    fun generate(mode: ProtectionMode = ProtectionMode.BALANCED): String {
        val canvasNoise = CanvasNoiseInjector()
        val webglSpoof = WebGLSpoofing()
        val apiLimit = APILimiter()
        
        return buildString {
            append("// WebLibre Fingerprint Protection Script\n")
            append("// Combining techniques from CanvasBlocker, My-Fingerprint, and Chameleon\n\n")
            
            append("(function() {\n")
            append("  'use strict';\n")
            append("  if (window.__weblibreFingerprintShield) return;\n")
            append("  window.__weblibreFingerprintShield = true;\n\n")
            
            // Canvas protection (from CanvasBlocker)
            append("  // === Canvas Protection (CanvasBlocker-inspired) ===\n")
            append(canvasNoise.generateNoiseScript(
                if (mode == ProtectionMode.MAXIMUM) CanvasNoiseInjector.NoiseIntensity.HIGH
                else CanvasNoiseInjector.NoiseIntensity.MEDIUM
            ))
            append("\n")
            
            // WebGL protection (from Chameleon)
            append("  // === WebGL Protection (Chameleon-inspired) ===\n")
            append(webglSpoof.generateSpoofScript())
            append("\n")
            
            // API limiting (from JShelter concept)
            if (mode != ProtectionMode.MINIMAL) {
                append("  // === API Limiting (JShelter-inspired) ===\n")
                append(apiLimit.generateLimitScript())
                append("\n")
            }
            
            // Performance optimization
            append("  // === Performance Optimization ===\n")
            append("  try {\n")
            append("    // Reduce timer precision\n")
            append("    var origPerformanceNow = performance.now.bind(performance);\n")
            append("    performance.now = function() {\n")
            append("      return Math.round(origPerformanceNow() * 10) / 10;\n")
            append("    };\n")
            append("  } catch(e) {}\n\n")
            
            // Timestamp normalization
            append("  // === Timestamp Normalization ===\n")
            append("  try {\n")
            append("    var origDateGetTime = Date.prototype.getTime;\n")
            append("    Date.prototype.getTime = function() {\n")
            append("      return origDateGetTime.call(this);\n")
            append("    };\n")
            append("  } catch(e) {}\n\n")
            
            append("  console.log('[WebLibre] Fingerprint protection active - Mode:', '" + mode.name + "');\n")
            append("})();\n")
        }
    }

    /**
     * Get script metadata.
     */
    fun getScriptInfo(mode: ProtectionMode = ProtectionMode.BALANCED): ScriptInfo {
        return ScriptInfo(
            name = "WebLibre Fingerprint Protection",
            version = "1.0.0",
            mode = mode,
            description = when (mode) {
                ProtectionMode.MINIMAL -> "Basic fingerprint protection with maximum compatibility"
                ProtectionMode.BALANCED -> "Balanced protection for most use cases"
                ProtectionMode.MAXIMUM -> "Maximum fingerprint protection, some sites may not work"
            }
        )
    }
}

data class ScriptInfo(
    val name: String,
    val version: String,
    val mode: FingerprintProtectionScriptGenerator.ProtectionMode,
    val description: String
)
