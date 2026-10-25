// WebLibre Fingerprint Shield — shared profile/seed logic.
//
// Loaded first by both the content script and the background script so that
// the JS-visible identity and the outgoing User-Agent header are derived from
// the exact same seed. Keeping the header and the JS surface coherent is what
// stops a site from flagging the mismatch as a unique signal.

var WEBLIBRE_FP = (function () {
  'use strict';

  // FNV-1a 32-bit. Synchronous and dependency-free so it can run before any
  // page script; crypto.subtle would be async and therefore too late.
  function fnv1a(str) {
    var h = 0x811c9dc5;
    for (var i = 0; i < str.length; i++) {
      h ^= str.charCodeAt(i);
      h = (h + ((h << 1) + (h << 4) + (h << 7) + (h << 8) + (h << 24))) >>> 0;
    }
    return h >>> 0;
  }

  // Each profile is internally consistent: the UA's device string matches the
  // screen metrics, pixel ratio and GPU. Adding a profile widens the anonymity
  // set without any other change.
  var PROFILES = [
    {
      ua: 'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      appVersion: '5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      platform: 'Linux armv8l',
      vendor: 'Google Inc.',
      screen: { width: 412, height: 915, availWidth: 412, availHeight: 915, colorDepth: 24, pixelDepth: 24 },
      dpr: 2.625,
      hardwareConcurrency: 9,
      deviceMemory: 8,
      maxTouchPoints: 5,
      webgl: { vendor: 'Qualcomm', renderer: 'Adreno (TM) 740' },
      audio: { sampleRate: 48000, maxChannelCount: 2 }
    },
    {
      ua: 'Mozilla/5.0 (Linux; Android 13; SM-S908B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Mobile Safari/537.36',
      appVersion: '5.0 (Linux; Android 13; SM-S908B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Mobile Safari/537.36',
      platform: 'Linux armv8l',
      vendor: 'Google Inc.',
      screen: { width: 360, height: 780, availWidth: 360, availHeight: 780, colorDepth: 24, pixelDepth: 24 },
      dpr: 3,
      hardwareConcurrency: 8,
      deviceMemory: 8,
      maxTouchPoints: 10,
      webgl: { vendor: 'ARM', renderer: 'Mali-G710' },
      audio: { sampleRate: 48000, maxChannelCount: 2 }
    },
    {
      ua: 'Mozilla/5.0 (Linux; Android 14; ASUS_AI2401) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Mobile Safari/537.36',
      appVersion: '5.0 (Linux; Android 14; ASUS_AI2401) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Mobile Safari/537.36',
      platform: 'Linux armv8l',
      vendor: 'Google Inc.',
      screen: { width: 393, height: 873, availWidth: 393, availHeight: 873, colorDepth: 24, pixelDepth: 24 },
      dpr: 2.75,
      hardwareConcurrency: 8,
      deviceMemory: 12,
      maxTouchPoints: 10,
      webgl: { vendor: 'Qualcomm', renderer: 'Adreno (TM) 730' },
      audio: { sampleRate: 48000, maxChannelCount: 2 }
    },
    {
      ua: 'Mozilla/5.0 (Linux; Android 13; V2254A) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Mobile Safari/537.36',
      appVersion: '5.0 (Linux; Android 13; V2254A) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Mobile Safari/537.36',
      platform: 'Linux armv8l',
      vendor: 'Google Inc.',
      screen: { width: 360, height: 800, availWidth: 360, availHeight: 800, colorDepth: 24, pixelDepth: 24 },
      dpr: 3,
      hardwareConcurrency: 8,
      deviceMemory: 8,
      maxTouchPoints: 10,
      webgl: { vendor: 'ARM', renderer: 'Mali-G715-Immortalis' },
      audio: { sampleRate: 48000, maxChannelCount: 2 }
    }
  ];

  function seedForOrigin(origin) {
    return fnv1a('weblibre-fp-shield-v1|' + (origin || 'null'));
  }

  function profileForOrigin(origin) {
    return PROFILES[seedForOrigin(origin) % PROFILES.length];
  }

  function originOf(url) {
    try {
      return new URL(url).origin;
    } catch (e) {
      return null;
    }
  }

  return {
    fnv1a: fnv1a,
    PROFILES: PROFILES,
    seedForOrigin: seedForOrigin,
    profileForOrigin: profileForOrigin,
    originOf: originOf
  };
})();
