// Titanium Privacy Shield - Background Tracker Blocker
// Ported from Titanium Browser's host-based tracker blocking architecture

const TRACKER_PATTERNS = [
    "*://*.doubleclick.net/*",
    "*://*.googlesyndication.com/*",
    "*://*.google-analytics.com/*",
    "*://*.analytics.google.com/*",
    "*://*.facebook.com/tr*",
    "*://*.fbcdn.net/*/tracking*",
    "*://*.hotjar.com/*",
    "*://*.mixpanel.com/*",
    "*://*.amplitude.com/*",
    "*://*.segment.io/*",
    "*://*.branch.io/*",
    "*://*.adjust.com/*",
    "*://*.appsflyer.com/*",
    "*://*.kochava.com/*",
    "*://*.singular.net/*"
];

// Subresource types only. A tracker host is blocked when a page pulls it in,
// but not when the user deliberately navigates to it: cancelling main_frame
// would turn a mistyped or intentional visit into a blank error page, and the
// tracker cannot run in that context anyway without the page that embeds it.
const SUBRESOURCE_TYPES = [
    "sub_frame",
    "stylesheet",
    "script",
    "image",
    "object",
    "xmlhttprequest",
    "media",
    "font",
    "websocket",
    "csp_report",
    "imageset",
    "web_manifest",
    "speculative",
    "other"
];

browser.webRequest.onBeforeRequest.addListener(
    function(details) { return { cancel: true }; },
    { urls: TRACKER_PATTERNS, types: SUBRESOURCE_TYPES },
    ["blocking"]
);
