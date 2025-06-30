const FEED_MIME_TYPES = [
  "application/atom",
  "application/rss"
];

// Listen for any webRequest that might be a feed
browser.webRequest.onHeadersReceived.addListener(
  function (details) {
    let isFeed = false;

    for (let header of details.responseHeaders) {
      if (header.name.toLowerCase() === "content-type") {
        const contentType = header.value.toLowerCase();

        for (const mimeType of FEED_MIME_TYPES) {
          if (contentType.includes(mimeType)) {
            isFeed = true;
            break;
          }
        }

        if (isFeed) break;
      }
    }

    if (isFeed) {
      port.postMessage({
        "type": "feedRequest",
        "url": details.url
      });

      return { cancel: true };
    }

    // Not a feed, let the browser handle it normally
    return { responseHeaders: details.responseHeaders };
  },
  { urls: ["<all_urls>"] },
  ["blocking", "responseHeaders"]
);