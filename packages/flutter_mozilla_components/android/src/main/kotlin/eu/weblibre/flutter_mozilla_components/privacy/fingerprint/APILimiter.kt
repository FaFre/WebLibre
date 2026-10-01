/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.privacy.fingerprint

import mozilla.components.support.base.log.logger.Logger

/**
 * JavaScript API limiter inspired by JShelter.
 *
 * Restricts access to fingerprinting APIs and returns
 * normalized/safe values.
 */
class APILimiter {

    companion object {
        private val logger = Logger("APILimiter")
        
        const val SCRIPT_NAME = "api_limiter.js"
    }

    /**
     * Generate JavaScript code to limit API access.
     */
    fun generateLimitScript(): String {
        return """
(function() {
  'use strict';
  if (window.__weblibreAPILimited) return;
  window.__weblibreAPILimited = true;

  // Limit Performance API precision
  try {
    var origNow = performance.now.bind(performance);
    performance.now = function() {
      return Math.round(origNow() * 100) / 100; // 10ms precision
    };
  } catch(e) {}

  // Limit Date timezone
  try {
    var origGetTimezoneOffset = Date.prototype.getTimezoneOffset;
    Date.prototype.getTimezoneOffset = function() {
      return 0; // UTC
    };
    
    var origResolved = Intl.DateTimeFormat.prototype.resolvedOptions;
    Intl.DateTimeFormat.prototype.resolvedOptions = function() {
      var opts = origResolved.call(this);
      opts.timeZone = 'UTC';
      return opts;
    };
  } catch(e) {}

  // Normalize navigator properties
  try {
    Object.defineProperty(navigator, 'hardwareConcurrency', {
      get: function() { return 4; },
      configurable: true
    });
    
    Object.defineProperty(navigator, 'deviceMemory', {
      get: function() { return 8; },
      configurable: true
    });
  } catch(e) {}

  // Restrict font enumeration
  try {
    if (document.fonts && document.fonts.check) {
      var origCheck = document.fonts.check.bind(document.fonts);
      document.fonts.check = function() {
        return false;
      };
    }
  } catch(e) {}

  console.log('[WebLibre] API limiting active');
})();
""".trimIndent()
    }
}
