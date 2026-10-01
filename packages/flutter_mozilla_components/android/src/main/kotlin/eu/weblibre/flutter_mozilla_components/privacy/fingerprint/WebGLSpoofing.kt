/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.privacy.fingerprint

import mozilla.components.support.base.log.logger.Logger

/**
 * WebGL renderer spoofing inspired by Chameleon.
 *
 * Masks the real GPU information to prevent fingerprinting
 * through WebGL renderer detection.
 */
class WebGLSpoofing {

    companion object {
        private val logger = Logger("WebGLSpoofing")
        
        const val SCRIPT_NAME = "webgl_spoofing.js"
        
        // Common spoofed values
        private val SPOOFED_VENDOR = "Intel Inc."
        private val SPOOFED_RENDERER = "Intel Iris OpenGL Engine"
    }

    /**
     * Generate JavaScript code for WebGL spoofing.
     */
    fun generateSpoofScript(): String {
        return """
(function() {
  'use strict';
  if (window.__weblibreWebGLProtected) return;
  window.__weblibreWebGLProtected = true;

  var UNMASKED_VENDOR_WEBGL = 0x9245;
  var UNMASKED_RENDERER_WEBGL = 0x9246;

  // Patch WebGLRenderingContext
  try {
    var proto = window.WebGLRenderingContext && window.WebGLRenderingContext.prototype;
    if (proto && proto.getParameter) {
      var origGetParameter = proto.getParameter;
      proto.getParameter = function(pname) {
        if (pname === UNMASKED_VENDOR_WEBGL) return '$SPOOFED_VENDOR';
        if (pname === UNMASKED_RENDERER_WEBGL) return '$SPOOFED_RENDERER';
        return origGetParameter.call(this, pname);
      };
    }
  } catch(e) {}

  // Patch WebGL2RenderingContext
  try {
    var proto2 = window.WebGL2RenderingContext && window.WebGL2RenderingContext.prototype;
    if (proto2 && proto2.getParameter) {
      var origGetParameter2 = proto2.getParameter;
      proto2.getParameter = function(pname) {
        if (pname === UNMASKED_VENDOR_WEBGL) return '$SPOOFED_VENDOR';
        if (pname === UNMASKED_RENDERER_WEBGL) return '$SPOOFED_RENDERER';
        return origGetParameter2.call(this, pname);
      };
    }
  } catch(e) {}

  console.log('[WebLibre] WebGL protection active');
})();
""".trimIndent()
    }
}
