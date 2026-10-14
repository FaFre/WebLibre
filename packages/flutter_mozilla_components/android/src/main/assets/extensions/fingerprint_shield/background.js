// WebLibre Fingerprint Shield — background script.
//
// Pins the outgoing User-Agent header to the same per-origin profile the
// content script exposes to JavaScript. Without this, a site could compare the
// header (which it sees first) against navigator.userAgent and flag the
// mismatch as an anti-fingerprinting tell.
//
// It also clamps Accept-Language to match the navigator.languages the content
// script reports, for the same reason.

(function () {
  'use strict';

  function rewriteHeader(headers, name, value) {
    var lower = name.toLowerCase();
    for (var i = 0; i < headers.length; i++) {
      if (headers[i].name.toLowerCase() === lower) {
        headers[i].value = value;
        return;
      }
    }
    headers.push({ name: name, value: value });
  }

  browser.webRequest.onBeforeSendHeaders.addListener(
    function (details) {
      var origin = WEBLIBRE_FP.originOf(details.originUrl || details.documentUrl || details.url);
      if (!origin) return {};

      var profile = WEBLIBRE_FP.profileForOrigin(origin);
      var headers = details.requestHeaders || [];

      rewriteHeader(headers, 'User-Agent', profile.ua);
      rewriteHeader(headers, 'Accept-Language', 'en-US,en;q=0.5');

      return { requestHeaders: headers };
    },
    { urls: ['<all_urls>'] },
    ['blocking', 'requestHeaders']
  );
})();
