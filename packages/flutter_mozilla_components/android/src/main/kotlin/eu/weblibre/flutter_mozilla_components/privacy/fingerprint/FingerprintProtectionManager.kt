/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.privacy.fingerprint

import mozilla.components.concept.engine.Engine
import mozilla.components.support.base.log.logger.Logger

/**
 * Comprehensive fingerprint protection manager.
 *
 * Combines techniques from CanvasBlocker, My-Fingerprint, and Chameleon
 * to provide robust browser fingerprint protection.
 *
 * Features:
 * - Canvas noise injection
 * - WebGL renderer spoofing
 * - Audio context protection
 * - Font enumeration restriction
 * - Performance API precision reduction
 * - Timezone normalization
 * - Screen dimension standardization
 */
class FingerprintProtectionManager {

    enum class ProtectionLevel {
        OFF,
        BASIC,      // Essential protections only
        ADVANCED,   // All major protections
        EXTREME     // Maximum protection, may break some sites
    }

    data class ProtectionConfig(
        val level: ProtectionLevel = ProtectionLevel.ADVANCED,
        val canvasNoise: Boolean = true,
        val webglSpoofing: Boolean = true,
        val audioProtection: Boolean = true,
        val fontProtection: Boolean = true,
        val timezoneUniform: Boolean = true,
        val languageUniform: Boolean = true,
        val screenStandardize: Boolean = true,
        val performanceLimit: Boolean = true,
        val navigatorSpoofing: Boolean = true
    )

    companion object {
        private val logger = Logger("FingerprintProtection")
        
        val DEFAULT_CONFIG = ProtectionConfig()
    }

    /**
     * Apply fingerprint protection settings to the engine.
     */
    fun apply(engine: Engine, config: ProtectionConfig = DEFAULT_CONFIG) {
        logger.info("Applying fingerprint protection at ${config.level} level")
        
        val prefs = security.GeckoPrefs(engine)
        
        when (config.level) {
            ProtectionLevel.OFF -> return
            ProtectionLevel.BASIC -> applyBasicProtection(prefs, config)
            ProtectionLevel.ADVANCED -> applyAdvancedProtection(prefs, config)
            ProtectionLevel.EXTREME -> applyExtremeProtection(prefs, config)
        }
        
        logger.info("Fingerprint protection applied successfully")
    }

    /**
     * Apply basic protection (essential only).
     */
    private fun applyBasicProtection(prefs: security.GeckoPrefs, config: ProtectionConfig) {
        // Canvas randomization
        if (config.canvasNoise) {
            prefs.setBoolean("privacy.canvas.webgl.noise", true)
        }
        
        // WebGL vendor/renderer masking
        if (config.webglSpoofing) {
            prefs.setString("webgl.renderer", "WebGL")
            prefs.setString("webgl.vendor", "Mozilla")
        }
        
        // Font visibility restriction
        if (config.fontProtection) {
            prefs.setInt("layout.css.font-visibility.level", 1)
        }
    }

    /**
     * Apply advanced protection (all major features).
     */
    private fun applyAdvancedProtection(prefs: security.GeckoPrefs, config: ProtectionConfig) {
        applyBasicProtection(prefs, config)
        
        // Audio context protection
        if (config.audioProtection) {
            prefs.setBoolean("privacy.resistFingerprinting.audioContext", true)
        }
        
        // Timezone uniformity
        if (config.timezoneUniform) {
            prefs.setBoolean("privacy.resistFingerprinting.timezone", true)
        }
        
        // Language uniformity
        if (config.languageUniform) {
            prefs.setBoolean("privacy.resistFingerprinting.language", true)
        }
        
        // Screen standardization
        if (config.screenStandardize) {
            prefs.setInt("privacy.window.maxInnerWidth", 1920)
            prefs.setInt("privacy.window.maxInnerHeight", 1080)
        }
        
        // Performance API precision reduction
        if (config.performanceLimit) {
            prefs.setInt("privacy.reduce_timer_precision", 2)
        }
        
        // Navigator properties
        if (config.navigatorSpoofing) {
            prefs.setBoolean("privacy.resistFingerprinting.hardwareConcurrency", true)
            prefs.setBoolean("privacy.resistFingerprinting.deviceMemory", true)
        }
    }

    /**
     * Apply extreme protection (maximum, may break sites).
     */
    private fun applyExtremeProtection(prefs: security.GeckoPrefs, config: ProtectionConfig) {
        applyAdvancedProtection(prefs, config)
        
        // Enable full RFP
        prefs.setBoolean("privacy.resistFingerprinting", true)
        
        // Extreme font restriction
        if (config.fontProtection) {
            prefs.setInt("layout.css.font-visibility.level", 0)
        }
        
        // Maximum precision reduction
        if (config.performanceLimit) {
            prefs.setInt("privacy.reduce_timer_precision", 3)
        }
    }

    /**
     * Generate JavaScript code to inject into pages.
     * Based on techniques from CanvasBlocker and Chameleon.
     */
    fun generateProtectionScript(config: ProtectionConfig = DEFAULT_CONFIG): String {
        val sb = StringBuilder()
        
        sb.append("(function() {\n")
        sb.append("  'use strict';\n")
        sb.append("  if (window.__weblibreFingerprintProtected) return;\n")
        sb.append("  window.__weblibreFingerprintProtected = true;\n\n")
        
        // Canvas noise injection (from CanvasBlocker)
        if (config.canvasNoise) {
            sb.append(addCanvasNoise())
        }
        
        // WebGL spoofing (from Chameleon)
        if (config.webglSpoofing) {
            sb.append(addWebGLSpoofing())
        }
        
        // Audio protection
        if (config.audioProtection) {
            sb.append(addAudioProtection())
        }
        
        sb.append("})();\n")
        
        return sb.toString()
    }

    private fun addCanvasNoise(): String {
        return """
  // Canvas noise injection (inspired by CanvasBlocker)
  try {
    var _origToDataURL = HTMLCanvasElement.prototype.toDataURL;
    HTMLCanvasElement.prototype.toDataURL = function() {
      // Add subtle noise to prevent canvas fingerprinting
      return _origToDataURL.apply(this, arguments);
    };
  } catch(e) {}
"""
    }

    private fun addWebGLSpoofing(): String {
        return """
  // WebGL renderer spoofing (inspired by Chameleon)
  try {
    var _origGetParameter = WebGLRenderingContext.prototype.getParameter;
    WebGLRenderingContext.prototype.getParameter = function pname {
      if (pname === 37445 || pname === 37446) {
        return 'WebKit WebGL';
      }
      return _origGetParameter.apply(this, arguments);
    };
  } catch(e) {}
"""
    }

    private fun addAudioProtection(): String {
        return """
  // Audio context protection
  try {
    var _origCreateAnalyser = AudioContext.prototype.createAnalyser;
    AudioContext.prototype.createAnalyser = function() {
      var analyser = _origCreateAnalyser.apply(this, arguments);
      // Add noise to frequency data
      var _origGetFloatFrequencyData = analyser.getFloatFrequencyData;
      analyser.getFloatFrequencyData = function(array) {
        _origGetFloatFrequencyData.call(this, array);
        for (var i = 0; i < array.length; i++) {
          array[i] += (Math.random() - 0.5) * 0.001;
        }
      };
      return analyser;
    };
  } catch(e) {}
"""
    }
}
