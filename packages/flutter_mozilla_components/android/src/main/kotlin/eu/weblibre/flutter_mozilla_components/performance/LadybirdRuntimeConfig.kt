/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.performance

import org.mozilla.geckoview.GeckoRuntime

/**
 * Performance-oriented runtime configuration inspired by Ladybird and Lightpanda.
 *
 * Ladybird achieves low power and fast rendering through a zero-bloat architecture:
 * no legacy code paths, GPU-accelerated compositor, multi-process isolation with
 * minimal IPC overhead. Lightpanda achieves 16x lower memory and 9x faster execution
 * by stripping all non-essential components and using system-level resource control.
 *
 * WebLibre cannot replace GeckoView, but we can apply the same philosophy at the
 * runtime preference level: disable every subsystem that is not actively needed,
 * reduce memory ceilings, and tune scheduling for mobile-first workloads.
 *
 * These prefs are applied once at runtime creation and persist for the process
 * lifetime. They complement (not replace) TitaniumHardeningConfig's security prefs.
 *
 * Reference:
 * - Ladybird: https://github.com/LadybirdBrowser/ladybird
 * - Lightpanda: https://github.com/lightpanda-io/browser
 */
object LadybirdRuntimeConfig {

    /**
     * Apply performance-oriented preferences to the GeckoRuntime.
     * Called after TitaniumHardeningConfig in EngineProvider.getOrCreateRuntime().
     */
    fun applyPerformancePrefs(runtime: GeckoRuntime) {
        val prefs = runtime.settings

        // =========================================================================
        // Memory reduction — inspired by Lightpanda's 16x memory advantage
        // =========================================================================

        // Limit content process memory ceiling. Gecko defaults are tuned for
        // desktop with abundant RAM; mobile devices benefit from tighter limits
        // that trigger earlier GC and prevent OOM kills under memory pressure.
        prefs.setInt("browser.cache.memory.capacity", 65536) // 64MB cache cap
        prefs.setInt("javascript.options.mem.high_water_mark", 96) // MB, trigger GC earlier
        prefs.setInt("javascript.options.mem.max", 512) // MB, hard ceiling per tab

        // Reduce image decoding memory. Mobile screens don't need full-resolution
        // decode for off-screen images; downscale-on-decode saves significant RAM.
        prefs.setBoolean("image.downscale-during-decode.enabled", true)
        prefs.setInt("image.mem.animated.discardable", 1)

        // Limit DOM storage. Most sites don't need the default 10MB localStorage.
        prefs.setInt("dom.storage.default_quota", 5120) // 5MB in KB

        // =========================================================================
        // Power reduction — inspired by Ladybird's zero-main-thread-blocking design
        // =========================================================================

        // Disable background tab animations and timers. When a tab is not visible,
        // there is no reason to run CSS animations or requestAnimationFrame callbacks.
        prefs.setBoolean("dom.animations.offscreen-throttling", true)
        prefs.setInt("dom.animations.throttle-min-duration-ms", 100)

        // Suspend media in background tabs immediately rather than waiting.
        prefs.setBoolean("media.suspend-bkgnd-video.enabled", true)
        prefs.setInt("media.suspend-bkgnd-video.delay-ms", 0)

        // Disable speculative connections and prefetching. On mobile with metered
        // connections, the battery/bandwidth cost outweighs the latency benefit.
        prefs.setInt("network.http.speculative-parallel-limit", 0)
        prefs.setBoolean("network.dns.disablePrefetch", true)
        prefs.setBoolean("browser.urlbar.speculativeConnect.enabled", false)
        prefs.setBoolean("network.predictor.enabled", false)
        prefs.setBoolean("network.prefetch-next", false)

        // =========================================================================
        // Startup acceleration — inspired by Lightpanda's V8 snapshot approach
        // =========================================================================

        // Enable bytecode caching for JavaScript. Subsequent loads skip parsing
        // and go straight to execution, similar to Lightpanda's pre-compiled snapshot.
        prefs.setBoolean("javascript.options.bytecode_cache", true)
        prefs.setInt("javascript.options.bytecode_cache_size", 32768)

        // Parallelize CSS parsing and style computation across multiple cores.
        prefs.setBoolean("layout.css.stylo-threads.enabled", true)
        prefs.setInt("layout.css.stylo-threads.count", 4)

        // Enable HTTP/3 (QUIC). Reduces connection setup from 2-3 RTTs to 0-1 RTT.
        prefs.setBoolean("network.http.http3.enable", true)

        // Enable early hints (103) processing for parallel critical resource fetching.
        prefs.setBoolean("network.early-hints.enabled", true)

        // =========================================================================
        // Rendering optimization — inspired by Ladybird's GPU compositor
        // =========================================================================

        // Force GPU-accelerated compositing. Ladybird's entire pipeline is GPU-first;
        // Gecko sometimes falls back to software compositing on Android causing jank.
        prefs.setBoolean("layers.acceleration.force-enabled", true)
        prefs.setBoolean("gfx.webrender.all", true)
        prefs.setBoolean("gfx.webrender.compositor", true)

        // Enable async scrolling (APZ). Decouples scroll handling from the main
        // thread so scrolling remains smooth even during heavy JS execution.
        prefs.setBoolean("apz.asyncscroll.throttle", true)
        prefs.setInt("apz.asyncscroll.timeout", 0)

        // Match paint frequency to display refresh rate, never faster.
        prefs.setInt("layout.frame_rate", -1)
    }
}
