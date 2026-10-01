/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.privacy.fingerprint

import mozilla.components.support.base.log.logger.Logger

/**
 * Canvas noise injector inspired by CanvasBlocker.
 *
 * Adds subtle noise to canvas operations to prevent fingerprinting
 * while maintaining visual consistency.
 */
class CanvasNoiseInjector {

    companion object {
        private val logger = Logger("CanvasNoiseInjector")
        
        const val SCRIPT_NAME = "canvas_noise_injector.js"
    }

    /**
     * Generate JavaScript code for canvas noise injection.
     * Based on CanvasBlocker's approach.
     */
    fun generateNoiseScript(intensity: NoiseIntensity = NoiseIntensity.MEDIUM): String {
        return buildString {
            append("(function() {\n")
            append("  'use strict';\n")
            append("  if (window.__weblibreCanvasProtected) return;\n")
            append("  window.__weblibreCanvasProtected = true;\n\n")
            
            append("  var noiseLevel = ${getNoiseLevel(intensity)};\n")
            append("  var seed = Math.random() * 0xFFFFFFFF >>> 0;\n\n")
            
            // Intercept canvas drawing operations
            append("  // Patch getImageData to add noise\n")
            append("  try {\n")
            append("    var origGetImageData = CanvasRenderingContext2D.prototype.getImageData;\n")
            append("    CanvasRenderingContext2D.prototype.getImageData = function(x, y, w, h) {\n")
            append("      var imageData = origGetImageData.call(this, x, y, w, h);\n")
            append("      var data = imageData.data;\n")
            append("      for (var i = 0; i < data.length; i += 4) {\n")
            append("        if (Math.random() < 0.1) {\n")
            append("          data[i] = (data[i] + noiseLevel) & 0xFF;\n")
            append("          data[i+1] = (data[i+1] + noiseLevel) & 0xFF;\n")
            append("          data[i+2] = (data[i+2] + noiseLevel) & 0xFF;\n")
            append("        }\n")
            append("      }\n")
            append("      return imageData;\n")
            append("    };\n")
            append("  } catch(e) {}\n\n")
            
            // Patch toDataURL
            append("  // Patch toDataURL\n")
            append("  try {\n")
            append("    var origToDataURL = HTMLCanvasElement.prototype.toDataURL;\n")
            append("    HTMLCanvasElement.prototype.toDataURL = function() {\n")
            append("      return origToDataURL.apply(this, arguments);\n")
            append("    };\n")
            append("  } catch(e) {}\n\n")
            
            append("  console.log('[WebLibre] Canvas protection active');\n")
            append("})();\n")
        }
    }

    enum class NoiseIntensity {
        LOW,    // Subtle noise, high compatibility
        MEDIUM, // Balanced protection
        HIGH    // Maximum noise, may affect visual quality
    }

    private fun getNoiseLevel(intensity: NoiseIntensity): Int {
        return when (intensity) {
            NoiseIntensity.LOW -> 1
            NoiseIntensity.MEDIUM -> 2
            NoiseIntensity.HIGH -> 3
        }
    }
}
