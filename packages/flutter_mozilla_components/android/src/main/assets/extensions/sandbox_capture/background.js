// WebLibre sandbox capture subresource firewall.
//
// Cancels any request issued from a document served by the local capture
// server (http://127.0.0.1:*/captures/* or /loader*) unless the request
// also targets the same loopback server. This is the second line of
// defence behind AppRequestInterceptor — SingleFile captures are already
// fully-inlined, so this firewall should rarely have anything to block
// in practice, but it guarantees the privacy contract.

const LOOPBACK_PATTERN = /^http:\/\/127\.0\.0\.1:\d+\/(captures|loader)(\/|\?|$)/;

browser.webRequest.onBeforeRequest.addListener(
  (details) => {
    const doc = details.documentUrl || details.originUrl;
    if (!doc || !LOOPBACK_PATTERN.test(doc)) {
      return {};
    }
    if (LOOPBACK_PATTERN.test(details.url)) {
      return {};
    }
    if (details.url.startsWith("data:") || details.url.startsWith("blob:")) {
      return {};
    }
    return { cancel: true };
  },
  { urls: ["<all_urls>"] },
  ["blocking"]
);
