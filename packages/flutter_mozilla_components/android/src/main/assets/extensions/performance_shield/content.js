// WebLibre Performance Shield — content script.
//
// Lightpanda's headline win comes from never doing work for what is not being
// looked at. GeckoView already suspends media for a *hidden tab*, but a
// decorative muted video that has merely scrolled out of view keeps decoding
// frames and compositing on the main thread while the user reads the rest of
// the page.
//
// This script pauses those videos and resumes them when they scroll back. It is
// deliberately narrow:
//   - only <video> elements, never audio-only playback (music must keep going)
//   - only muted videos (an unmuted video is something the user chose to hear)
//   - never a video with controls (the user is driving it)
//   - never a video in picture-in-picture
// A video we paused is remembered, so returning to the tab does not resume
// something the user had paused themselves.

(function () {
  'use strict';

  if (window.__weblibrePerformanceShield) return;
  window.__weblibrePerformanceShield = true;

  var tracked = new WeakSet();
  var observer = null;

  function isManaged(video) {
    return (
      video &&
      video.tagName === 'VIDEO' &&
      video.muted &&
      !video.controls &&
      document.pictureInPictureElement !== video
    );
  }

  function observe(video) {
    if (!video || video.tagName !== 'VIDEO') return;
    if (tracked.has(video)) return;
    // Videos the user controls are out of scope entirely.
    if (video.controls) return;
    tracked.add(video);
    observer.observe(video);
  }

  function scan(root) {
    if (!root || !root.querySelectorAll) return;
    var videos = root.querySelectorAll('video');
    for (var i = 0; i < videos.length; i++) observe(videos[i]);
  }

  observer = new IntersectionObserver(function (entries) {
    for (var i = 0; i < entries.length; i++) {
      var entry = entries[i];
      var video = entry.target;

      // Re-check on every transition: a video can be unmuted or given controls
      // after we started watching it, and we must back off when it is.
      if (!isManaged(video)) {
        if (video.__wlPausedByShield) {
          video.__wlPausedByShield = false;
          video.play().catch(function () {});
        }
        continue;
      }

      if (entry.isIntersecting) {
        if (video.__wlPausedByShield) {
          video.__wlPausedByShield = false;
          video.play().catch(function () {});
        }
      } else if (!video.paused) {
        video.__wlPausedByShield = true;
        video.pause();
      }
    }
  }, { threshold: 0 });

  function start() {
    scan(document);
    if (!document.documentElement) return;
    new MutationObserver(function (mutations) {
      for (var i = 0; i < mutations.length; i++) {
        var added = mutations[i].addedNodes;
        for (var j = 0; j < added.length; j++) {
          var node = added[j];
          if (node.nodeType !== 1) continue;
          if (node.tagName === 'VIDEO') observe(node);
          else scan(node);
        }
      }
    }).observe(document.documentElement, { childList: true, subtree: true });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', start, { once: true });
  } else {
    start();
  }
})();
