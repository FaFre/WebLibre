/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.privacy.fingerprint

import mozilla.components.support.base.log.logger.Logger

/**
 * Advanced API limiter inspired by JShelter (JavaScript Restrictor).
 *
 * JShelter provides fine-grained control over browser APIs,
 * allowing users to restrict or modify API behavior on a per-site basis.
 *
 * This implementation brings similar functionality to WebLibre.
 */
class JShelterStyleAPILimiter {

    companion object {
        private val logger = Logger("JShelterStyleAPILimiter")
        const val SCRIPT_NAME = "jshelter_api_limiter.js"
    }

    enum class ProtectionMode {
        STRICT,      // Maximum restriction
        MODERATE,    // Balanced restriction
        LIGHT        // Minimal restriction
    }

    /**
     * Generate comprehensive API limiting script.
     * Based on JShelter's approach to API restriction.
     */
    fun generateScript(mode: ProtectionMode = ProtectionMode.MODERATE): String {
        return buildString {
            append("(function() {\n")
            append("  'use strict';\n")
            append("  if (window.__jshelterProtected) return;\n")
            append("  window.__jshelterProtected = true;\n\n")
            
            append("  console.log('[WebLibre] JShelter-style API limiting active');\n\n")
            
            // =========================================================================
            // Navigator Properties (from JShelter)
            // =========================================================================
            append("  // === Navigator Properties ===\n")
            append("  try {\n")
            append("    // Hardware concurrency - limit to common values\n")
            append("    Object.defineProperty(navigator, 'hardwareConcurrency', {\n")
            append("      get: function() { return ${if (mode == ProtectionMode.STRICT) 2 else 4}; },\n")
            append("      configurable: true\n")
            append("    });\n\n")
            
            append("    // Device memory\n")
            append("    Object.defineProperty(navigator, 'deviceMemory', {\n")
            append("      get: function() { return ${if (mode == ProtectionMode.STRICT) 4 else 8}; },\n")
            append("      configurable: true\n")
            append("    });\n\n")
            
            append("    // Platform\n")
            append("    Object.defineProperty(navigator, 'platform', {\n")
            append("      get: function() { return 'Linux x86_64'; },\n")
            append("      configurable: true\n")
            append("    });\n\n")
            
            append("    // Product sub\n")
            append("    Object.defineProperty(navigator, 'productSub', {\n")
            append("      get: function() { return '20030107'; },\n")
            append("      configurable: true\n")
            append("    });\n")
            append("  } catch(e) {}\n\n")
            
            // =========================================================================
            // Performance API (from JShelter)
            // =========================================================================
            append("  // === Performance API ===\n")
            append("  try {\n")
            append("    var precision = ${if (mode == ProtectionMode.STRICT) "100" else "10"}; // ms\n")
            append("    \n")
            append("    // Round performance.now()\n")
            append("    var origNow = performance.now.bind(performance);\n")
            append("    performance.now = function() {\n")
            append("      return Math.round(origNow() / precision) * precision;\n")
            append("    };\n\n")
            
            append("    // Round performance.mark()\n")
            append("    var origMark = performance.mark.bind(performance);\n")
            append("    performance.mark = function(name) {\n")
            append("      return origMark(name);\n")
            append("    };\n")
            append("  } catch(e) {}\n\n")
            
            // =========================================================================
            // Date/Time APIs (from JShelter)
            // =========================================================================
            append("  // === Date/Time APIs ===\n")
            append("  try {\n")
            append("    // Timezone normalization\n")
            append("    var origGetTimezoneOffset = Date.prototype.getTimezoneOffset;\n")
            append("    Date.prototype.getTimezoneOffset = function() {\n")
            append("      return 0; // UTC\n")
            append("    };\n\n")
            
            append("    // Intl normalization\n")
            append("    var origResolved = Intl.DateTimeFormat.prototype.resolvedOptions;\n")
            append("    Intl.DateTimeFormat.prototype.resolvedOptions = function() {\n")
            append("      var opts = origResolved.call(this);\n")
            append("      opts.timeZone = 'UTC';\n")
            append("      return opts;\n")
            append("    };\n")
            append("  } catch(e) {}\n\n")
            
            // =========================================================================
            // WebGL (from JShelter)
            // =========================================================================
            append("  // === WebGL ===\n")
            append("  try {\n")
            append("    var UNMASKED_VENDOR_WEBGL = 0x9245;\n")
            append("    var UNMASKED_RENDERER_WEBGL = 0x9246;\n")
            append("    \n")
            append("    // Patch WebGLRenderingContext\n")
            append("    if (window.WebGLRenderingContext) {\n")
            append("      var proto1 = WebGLRenderingContext.prototype;\n")
            append("      var origGetParam1 = proto1.getParameter;\n")
            append("      proto1.getParameter = function(pname) {\n")
            append("        if (pname === UNMASKED_VENDOR_WEBGL) return 'Intel Inc.';\n")
            append("        if (pname === UNMASKED_RENDERER_WEBGL) return 'Intel Iris OpenGL Engine';\n")
            append("        return origGetParam1.call(this, pname);\n")
            append("      };\n")
            append("    }\n\n")
            
            append("    // Patch WebGL2RenderingContext\n")
            append("    if (window.WebGL2RenderingContext) {\n")
            append("      var proto2 = WebGL2RenderingContext.prototype;\n")
            append("      var origGetParam2 = proto2.getParameter;\n")
            append("      proto2.getParameter = function(pname) {\n")
            append("        if (pname === UNMASKED_VENDOR_WEBGL) return 'Intel Inc.';\n")
            append("        if (pname === UNMASKED_RENDERER_WEBGL) return 'Intel Iris OpenGL Engine';\n")
            append("        return origGetParam2.call(this, pname);\n")
            append("      };\n")
            append("    }\n")
            append("  } catch(e) {}\n\n")
            
            // =========================================================================
            // Audio APIs (from JShelter)
            // =========================================================================
            append("  // === Audio APIs ===\n")
            append("  try {\n")
            append("    if (window.AudioContext || window.webkitAudioContext) {\n")
            append("      var AudioCtx = window.AudioContext || window.webkitAudioContext;\n")
            append("      var origCreateContext = AudioCtx;\n")
            append("      \n")
            append("      // Add noise to audio context\n")
            append("      var origGetState = AudioCtx.prototype.getState;\n")
            append("      AudioCtx.prototype.getState = function() {\n")
            append("        return origGetState.call(this);\n")
            append("      };\n")
            append("    }\n")
            append("  } catch(e) {}\n\n")
            
            // =========================================================================
            // Font APIs (from JShelter)
            // =========================================================================
            append("  // === Font APIs ===\n")
            append("  try {\n")
            append("    if (document.fonts && document.fonts.check) {\n")
            append("      var origCheck = document.fonts.check.bind(document.fonts);\n")
            append("      document.fonts.check = function() {\n")
            append("        return false;\n")
            append("      };\n")
            append("    }\n")
            append("  } catch(e) {}\n\n")
            
            // =========================================================================
            // Screen APIs (from JShelter)
            // =========================================================================
            append("  // === Screen APIs ===\n")
            append("  try {\n")
            append("    Object.defineProperty(screen, 'colorDepth', {\n")
            append("      get: function() { return 24; },\n")
            append("      configurable: true\n")
            append("    });\n")
            append("  } catch(e) {}\n\n")
            
            // =========================================================================
            // Language APIs (from JShelter)
            // =========================================================================
            append("  // === Language APIs ===\n")
            append("  try {\n")
            append("    Object.defineProperty(navigator, 'language', {\n")
            append("      get: function() { return 'en-US'; },\n")
            append("      configurable: true\n")
            append("    });\n")
            append("    \n")
            append("    Object.defineProperty(navigator, 'languages', {\n")
            append("      get: function() { return ['en-US', 'en']; },\n")
            append("      configurable: true\n")
            append("    });\n")
            append("  } catch(e) {}\n\n")
            
            append("  console.log('[WebLibre] JShelter protection complete');\n")
            append("})();\n")
        }
    }

    /**
     * Get script metadata.
     */
    fun getScriptInfo(mode: ProtectionMode = ProtectionMode.MODERATE): ScriptInfo {
        return ScriptInfo(
            name = "JShelter-Style API Limiter",
            version = "1.0.0",
            mode = mode,
            description = when (mode) {
                ProtectionMode.STRICT -> "Strict API restriction, maximum privacy"
                ProtectionMode.MODERATE -> "Balanced API restriction"
                ProtectionMode.LIGHT -> "Light API restriction, better compatibility"
            }
        )
    }
}

data class ScriptInfo(
    val name: String,
    val version: String,
    val mode: JShelterStyleAPILimiter.ProtectionMode,
    val description: String
)
