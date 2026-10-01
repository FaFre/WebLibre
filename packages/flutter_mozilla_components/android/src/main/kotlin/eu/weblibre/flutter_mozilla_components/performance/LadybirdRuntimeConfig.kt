/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.performance

import mozilla.components.ExperimentalAndroidComponentsApi
import mozilla.components.concept.engine.Engine
import mozilla.components.concept.engine.preferences.Branch

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
    @OptIn(ExperimentalAndroidComponentsApi::class)
    fun applyPerformancePrefs(engine: Engine) {
        // GeckoRuntimeSettings has no generic pref setter, so these go through
        // the engine's browser-pref API. The writes are asynchronous, which is
        // fine for runtime prefs Gecko reads on the next navigation.
        fun setBoolean(name: String, value: Boolean) =
            engine.setBrowserPref(name, value, Branch.USER, onSuccess = {}, onError = {})

        fun setInt(name: String, value: Int) =
            engine.setBrowserPref(name, value, Branch.USER, onSuccess = {}, onError = {})

        fun setString(name: String, value: String) =
            engine.setBrowserPref(name, value, Branch.USER, onSuccess = {}, onError = {})

        // =========================================================================
        // Memory reduction — inspired by Lightpanda's 16x memory advantage
        // =========================================================================

        // Limit content process memory ceiling. Gecko defaults are tuned for
        // desktop with abundant RAM; mobile devices benefit from tighter limits
        // that trigger earlier GC and prevent OOM kills under memory pressure.
        setInt("browser.cache.memory.capacity", 65536) // 64MB cache cap
        setInt("javascript.options.mem.high_water_mark", 96) // MB, trigger GC earlier
        setInt("javascript.options.mem.max", 512) // MB, hard ceiling per tab

        // Reduce image decoding memory. Mobile screens don't need full-resolution
        // decode for off-screen images; downscale-on-decode saves significant RAM.
        setBoolean("image.downscale-during-decode.enabled", true)
        setInt("image.mem.animated.discardable", 1)

        // Limit DOM storage. Most sites don't need the default 10MB localStorage.
        setInt("dom.storage.default_quota", 5120) // 5MB in KB

        // =========================================================================
        // Power reduction — inspired by Ladybird's zero-main-thread-blocking design
        // =========================================================================

        // Disable background tab animations and timers. When a tab is not visible,
        // there is no reason to run CSS animations or requestAnimationFrame callbacks.
        setBoolean("dom.animations.offscreen-throttling", true)
        setInt("dom.animations.throttle-min-duration-ms", 100)

        // Suspend media in background tabs immediately rather than waiting.
        setBoolean("media.suspend-bkgnd-video.enabled", true)
        setInt("media.suspend-bkgnd-video.delay-ms", 0)

        // Disable speculative connections and prefetching. On mobile with metered
        // connections, the battery/bandwidth cost outweighs the latency benefit.
        setInt("network.http.speculative-parallel-limit", 0)
        setBoolean("network.dns.disablePrefetch", true)
        setBoolean("browser.urlbar.speculativeConnect.enabled", false)
        setBoolean("network.predictor.enabled", false)
        setBoolean("network.prefetch-next", false)

        // =========================================================================
        // Startup acceleration — inspired by Lightpanda's V8 snapshot approach
        // =========================================================================

        // Enable bytecode caching for JavaScript. Subsequent loads skip parsing
        // and go straight to execution, similar to Lightpanda's pre-compiled snapshot.
        setBoolean("javascript.options.bytecode_cache", true)
        setInt("javascript.options.bytecode_cache_size", 32768)

        // Parallelize CSS parsing and style computation across multiple cores.
        setBoolean("layout.css.stylo-threads.enabled", true)
        setInt("layout.css.stylo-threads.count", 4)

        // Enable HTTP/3 (QUIC). Reduces connection setup from 2-3 RTTs to 0-1 RTT.
        setBoolean("network.http.http3.enable", true)

        // Enable early hints (103) processing for parallel critical resource fetching.
        setBoolean("network.early-hints.enabled", true)

        // =========================================================================
        // Rendering optimization — inspired by Ladybird's GPU compositor
        // =========================================================================

        // Force GPU-accelerated compositing. Ladybird's entire pipeline is GPU-first;
        // Gecko sometimes falls back to software compositing on Android causing jank.
        setBoolean("layers.acceleration.force-enabled", true)
        setBoolean("gfx.webrender.all", true)
        setBoolean("gfx.webrender.compositor", true)

        // Enable async scrolling (APZ). Decouples scroll handling from the main
        // thread so scrolling remains smooth even during heavy JS execution.
        setBoolean("apz.asyncscroll.throttle", true)
        setInt("apz.asyncscroll.timeout", 0)

        // Match paint frequency to display refresh rate, never faster.
        setInt("layout.frame_rate", -1)
    }
}
