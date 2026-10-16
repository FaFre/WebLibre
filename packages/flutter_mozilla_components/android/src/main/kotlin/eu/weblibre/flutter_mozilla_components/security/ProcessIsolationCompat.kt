/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.security

import android.os.Build
import mozilla.components.support.base.log.logger.Logger
import mozilla.components.concept.engine.Engine

/**
 * Compatibility layer for Android process isolation features (isolatedProcess,
 * appZygote) that are known to break Cloudflare Turnstile verification and
 * Widevine DRM video playback.
 *
 * Root cause: Android's isolated process mode applies additional seccomp-bpf
 * filters and SELinux policies that block system calls required by:
 * - Cloudflare's challenge computation engine (shared memory, memfd_create)
 * - Widevine CDM initialization (binder IPC to mediaserver)
 *
 * This is a documented GeckoView limitation, not a WebLibre bug.
 * Reference: https://bugzilla.mozilla.org/show_bug.cgi?id=1752594
 *
 * Strategy: Apply runtime preference compensations that relax Gecko-internal
 * restrictions which compound with Android's OS-level isolation. These prefs
 * cannot undo seccomp filtering, but they prevent Gecko from adding its own
 * additional sandboxing on top, which is often the tipping point that breaks
 * Cloudflare/DRM even when the OS alone would still allow them.
 */
object ProcessIsolationCompat {
    private val logger = Logger("ProcessIsolationCompat")

    fun hasKnownIsolationIssues(): Boolean {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE
    }

    /**
     * Apply runtime preference compensations when process isolation is active.
     * Called after GeckoRuntime creation in EngineProvider.getOrCreateRuntime().
     */
    fun applyCompensations(
        engine: Engine,
        isolatedProcessEnabled: Boolean,
        appZygoteProcessEnabled: Boolean,
    ) {
        if (!isolatedProcessEnabled && !appZygoteProcessEnabled) {
            return
        }

        val prefs = GeckoPrefs(engine)

        // Disable Gecko's internal content process sandbox level escalation
        // that stacks on top of Android's isolated process seccomp filter.
        prefs.setInt("security.sandbox.content.level", 0)

        // Allow shared memory usage in content processes.
        // Cloudflare Turnstile uses SharedArrayBuffer for parallel challenge
        // computation; Widevine CDM uses it for secure video frame transfer.
        prefs.setBoolean("dom.ipc.sharedUseProcessMemoryScheduling", true)

        // Ensure media pipeline components remain functional under isolation.
        prefs.setBoolean("media.widevine.cdm.enabled", true)
        prefs.setBoolean("media.gmp-widevinecdm.enabled", true)

        // Relax GPU process restrictions for video decode surface sharing.
        prefs.setBoolean("layers.gpu-process.enabled", true)

        // Ensure WebAssembly threads are available for CF challenge crypto.
        prefs.setBoolean("javascript.options.wasm_threads", true)

        // Allow JIT compilation in content processes.
        prefs.setBoolean("javascript.options.jit_trustedprincipals", false)

        // Enable cross-origin isolation headers support so sites using
        // SharedArrayBuffer (including CF Turnstile) work correctly.
        prefs.setBoolean("dom.postMessage.sharedArrayBuffer.bypassCOOP_COEP.insecure.enabled", true)

        logger.info(
            "Applied process isolation compensations: " +
                "isolatedProcess=$isolatedProcessEnabled, " +
                "appZygote=$appZygoteProcessEnabled, " +
                "api=${Build.VERSION.SDK_INT}"
        )
    }
}
