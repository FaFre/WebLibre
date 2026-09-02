/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import android.content.Context
import android.util.Log
import androidx.annotation.MainThread
import eu.weblibre.flutter_mozilla_components.feature.ContainerProxyFeature
import eu.weblibre.flutter_mozilla_components.startup.DartStartupProgress
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.FlutterJNI
import io.flutter.embedding.engine.dart.DartExecutor
import java.util.concurrent.atomic.AtomicInteger

/**
 * The one Flutter engine this process runs, and the one place that decides when
 * it exists.
 *
 * There has always been exactly one — `MainActivity` caches it so a destroyed
 * activity does not take the app's whole state with it — but the activity was
 * also the only thing that could create it, which made "is the app running?" and
 * "is an activity showing?" the same question. They are not: a Custom Tab or PWA
 * cold start runs in a process with no activity of ours at all, and a launch
 * into a proxied container needs the app half (routing, sing-box, Tor) without
 * needing the app's window.
 *
 * So the engine is started here, from either side, and whichever comes second
 * finds it: [obtain] is the activity's path and [ensureStarted] the headless
 * one, and an activity that starts later attaches to the very engine a headless
 * bootstrap created.
 *
 * If a plugin ever turns out to need an `Activity` during startup, this is the
 * seam to change — the bootstrap would start a transparent activity that hosts
 * the same cached engine, and nothing outside this object would know the
 * difference.
 */
object FlutterEngineCoordinator {
    private const val TAG = "FlutterEngineCoordinator"

    /** Cache id. Shared with `MainActivity`, which hosts whatever is cached here. */
    const val ENGINE_ID = "engine_id"

    private fun engineTag(engine: FlutterEngine?): String =
        engine?.let { "0x${System.identityHashCode(it).toString(16)}" } ?: "null"

    /**
     * Whether [engine]'s native side is still attached.
     *
     * `binaryMessenger.send()` does not throw once JNI is detached — it logs and
     * drops the message — so a dead engine is indistinguishable from a silent
     * one unless this is checked. There is no public accessor, hence reflection.
     */
    private fun isNativeAlive(engine: FlutterEngine): Boolean {
        return try {
            val field = FlutterEngine::class.java.getDeclaredField("flutterJNI")
            field.isAccessible = true
            (field.get(engine) as FlutterJNI).isAttached
        } catch (e: Exception) {
            Log.w(TAG, "Could not check JNI attachment state: ${e.message}")
            false
        }
    }

    private fun isHealthy(engine: FlutterEngine): Boolean {
        return try {
            engine.dartExecutor.isExecutingDart && isNativeAlive(engine)
        } catch (e: Exception) {
            Log.w(TAG, "Engine health check failed", e)
            false
        }
    }

    /** The cached engine if it is still usable; otherwise it is discarded. */
    private fun healthyCachedEngine(): FlutterEngine? {
        val cache = FlutterEngineCache.getInstance()
        val cached = cache.get(ENGINE_ID) ?: return null

        if (isHealthy(cached)) return cached

        Log.w(TAG, "Cached engine ${engineTag(cached)} is stale, discarding")
        DartStartupProgress.reset()
        // Same reasoning as [discard]: the isolate that installed this process's
        // routing is gone, and the backends its endpoints name went with it.
        ContainerProxyFeature.onAppHalfStopped()
        cache.remove(ENGINE_ID)
        runCatching { cached.destroy() }
            .onFailure { Log.w(TAG, "Error destroying stale engine", it) }

        return null
    }

    /** Whether a running engine exists, i.e. whether the app half is up. */
    fun isRunning(): Boolean = FlutterEngineCache.getInstance().get(ENGINE_ID)?.let(::isHealthy)
        ?: false

    /**
     * The engine to host, creating it if there is none. The activity's path.
     */
    @MainThread
    fun obtain(context: Context): FlutterEngine {
        healthyCachedEngine()?.let {
            Log.d(TAG, "obtain: reusing cached engine ${engineTag(it)}")
            return it
        }

        return create(context)
    }

    /**
     * Starts the app half without an activity, and reports whether one is now
     * running.
     *
     * Idempotent: a healthy engine is left exactly as it is, so a launch that
     * arrives while the browser is already running costs nothing.
     */
    @MainThread
    fun ensureStarted(context: Context): Boolean {
        healthyCachedEngine()?.let {
            Log.d(TAG, "ensureStarted: engine ${engineTag(it)} already running")
            return true
        }

        return try {
            create(context)
            true
        } catch (e: Exception) {
            // The caller has somewhere to fall back to (the ordinary browser,
            // which creates its own engine the usual way), so this must not take
            // the launch down with it.
            Log.e(TAG, "Failed to start the Flutter engine headlessly", e)
            false
        }
    }

    @MainThread
    private fun create(context: Context): FlutterEngine {
        // A new isolate starts its own cold start; the old one's progress says
        // nothing about it and would make a launch patient with a stage nothing
        // has reached.
        DartStartupProgress.reset()

        val engine = FlutterEngine(context.applicationContext)
        engine.navigationChannel.setInitialRoute("/")
        engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
        FlutterEngineCache.getInstance().put(ENGINE_ID, engine)

        Log.d(TAG, "Created engine ${engineTag(engine)}")
        return engine
    }

    /**
     * How many things that are not an activity hosting the engine currently
     * depend on it running.
     *
     * The app half is not only a window: sing-box and Tor run inside the Flutter
     * isolate, and a Custom Tab or PWA whose container routes through either of
     * them keeps needing that isolate long after — and quite independently of —
     * any activity of ours being on screen. Destroying the engine detaches the
     * proxy plugins and stops the backends, which leaves such a task pointed at
     * loopback ports nothing is listening on any more.
     *
     * A count rather than a flag because the holders nest: a bootstrap waiting
     * for routing and the external activity that bootstrap was run for are both
     * holders, and their lifetimes overlap without either owning the other.
     */
    private val externalTaskHolders = AtomicInteger(0)

    /**
     * Declares that something outside the activity hosting the engine is relying
     * on it. Must be paired with [releaseForExternalTask].
     */
    fun retainForExternalTask() {
        val held = externalTaskHolders.incrementAndGet()
        Log.d(TAG, "Engine retained by an external task ($held held)")
    }

    fun releaseForExternalTask() {
        val held = externalTaskHolders.updateAndGet { if (it > 0) it - 1 else 0 }
        Log.d(TAG, "Engine released by an external task ($held held)")
    }

    /**
     * Drops the cached engine, if any and if nothing else is relying on it.
     *
     * For a host being torn down by the system rather than by the user: the
     * engine it leaves behind has lost the activity it was attached to, and the
     * leases the plugin hands back on detach are process-global.
     *
     * A refused discard is not retried when the last holder goes away. The
     * engine is then exactly where a user-initiated `MainActivity` finish leaves
     * it — cached, unhosted and healthy — and [healthyCachedEngine] drops it if
     * it ever stops being that.
     */
    @MainThread
    fun discard() {
        val held = externalTaskHolders.get()
        if (held > 0) {
            Log.d(TAG, "Not discarding the engine: $held external task(s) need it")
            return
        }

        val cache = FlutterEngineCache.getInstance()
        val engine = cache.get(ENGINE_ID) ?: return

        Log.d(TAG, "Discarding engine ${engineTag(engine)}")
        DartStartupProgress.reset()
        // Destroying the engine stops sing-box and Tor with it, so the routing
        // this process installed stops describing anything the moment the call
        // below returns. It has to go too: the Gecko runtime and the extension
        // outlive the engine, and a launch arriving afterwards would read that
        // stale routing as live and be served headlessly into ports nothing is
        // listening on.
        ContainerProxyFeature.onAppHalfStopped()
        cache.remove(ENGINE_ID)
        runCatching { engine.destroy() }
            .onFailure { Log.w(TAG, "Error destroying engine", it) }
    }
}
