/*
 * Copyright (c) 2024-2025 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
package eu.weblibre.gecko

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import eu.weblibre.flutter_mozilla_components.HomePressDispatcher
import eu.weblibre.flutter_mozilla_components.startup.LaunchTrust
import eu.weblibre.flutter_mozilla_components.startup.StartupIntentBroker
import eu.weblibre.flutter_mozilla_components.startup.StartupPaths
import eu.weblibre.simple_intent_receiver.IntentApprovals
import eu.weblibre.simple_intent_receiver.IntentCallerResolver
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.FlutterJNI
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    companion object {
        private const val TAG = "MainActivity"

        /** Marks the intent [checkAndExitPiP] sends to itself. */
        private const val EXTRA_EXIT_PIP = "eu.weblibre.gecko.EXIT_PIP"
    }

    private val TRIM_MEMORY_CHANNEL = "eu.weblibre.flutter_mozilla_components/trim_memory"
    private val ACTIVITY_CHANNEL = "eu.weblibre.gecko/activity"
    private val ENGINE_ID = "engine_id"
    private var trimMemoryChannel: MethodChannel? = null

    private fun engineTag(engine: FlutterEngine?): String {
        return engine?.let { "0x${System.identityHashCode(it).toString(16)}" } ?: "null"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        Log.d(TAG, "onCreate: savedInstanceState=${savedInstanceState != null}, " +
            "cachedEngine=${engineTag(FlutterEngineCache.getInstance().get(ENGINE_ID))}")

        super.onCreate(null)

        // Restored straight into a pinned task (e.g. the process was killed while in PiP).
        checkAndExitPiP()
    }

    override fun onNewIntent(intent: Intent) {
        if (intent.hasExtra(EXTRA_EXIT_PIP)) {
            // Our own intent from checkAndExitPiP, delivered back here because
            // FLAG_ACTIVITY_REORDER_TO_FRONT re-delivers to a singleTask activity. It carries
            // nothing for Flutter to handle, and acting on it again would recurse.
            return
        }

        // Before Flutter sees it. An intent that arrives while the picker is up,
        // while maintenance owns the process, or while a restart is tearing it
        // down reaches a Dart side with no listeners — the plugin sends it over
        // Pigeon and the message goes nowhere. The broker takes those and hands
        // them over once the app exists.
        //
        // Deliberately returning without `super`: once the broker owns delivery,
        // letting the plugin send it as well is how a silent drop becomes a
        // duplicate open.
        //
        // Guarded on `shouldTake()` rather than letting `takeIfUndeliverable`
        // decide, because everything below it has to happen *only* on the queueing
        // path: it redeems a one-shot token, which the plugin must still find on
        // the ordinary path a moment later.
        if (StartupIntentBroker.shouldTake() && queueLaunch(intent)) {
            Log.d(TAG, "Queued ${intent.action} until a profile is committed")
            checkAndExitPiP()
            return
        }

        super.onNewIntent(intent)

        checkAndExitPiP()
    }

    /**
     * Hands [intent] to the broker with everything the plugin would have resolved.
     *
     * Both halves have to be settled here, because a queued launch never reaches
     * the plugin and nothing downstream can work them out afterwards:
     *
     * - **Who sent it.** `getReferrer()` answers about the activity running when it
     *   is asked, so a queued launch that did not write down its caller comes back
     *   looking internal — and internal is precisely what the gatekeeper never
     *   prompts about.
     * - **Whether the user already approved it.** A "Allow once" relaunch carries a
     *   one-shot token that makes the caller count as internal. Left unredeemed,
     *   the replay arrives naming the sending package, meets that package's block
     *   policy, and is dropped — the one launch the user explicitly allowed.
     *
     * The token is redeemed before the queue write and put back if the broker
     * declines after all, so it is never spent on a launch nobody delivers.
     *
     * - **What kind of launch it is.** A queued entry's classification is the only
     *   channel by which a replayed launch can still name a profile: the Dart side
     *   is forbidden from deriving one from raw intent extras, precisely because
     *   `pwa_profile_uuid` is an extra any app on the device can forge. Queued with
     *   the default `UNKNOWN`, a pinned PWA that reached us during the picker or
     *   maintenance came back indistinguishable from an anonymous deep link, and
     *   nothing downstream could tell it had ever been trusted. [LaunchTrust] is
     *   the same validation `IntentReceiverActivity` runs, so a forged extra gets
     *   no more here than it does there.
     */
    private fun queueLaunch(intent: Intent): Boolean {
        val approval = IntentApprovals.consume(applicationContext, intent)

        // A copy: the original still goes to `super` when this declines, and it
        // has to reach the plugin with its extras untouched.
        val queueable = IntentApprovals.applyTo(Intent(intent), approval)

        // Classified from the intent as it will be queued, so the approval the
        // user just granted is part of what is being described.
        val descriptor = LaunchTrust.classify(applicationContext, queueable)

        val queued = StartupIntentBroker.takeIfUndeliverable(
            context = applicationContext,
            paths = StartupPaths(applicationContext),
            intent = queueable,
            classification = descriptor.classification,
            trustedProfileId = descriptor.trustedProfileId,
            callerPackage = {
                if (approval != null) {
                    null
                } else {
                    IntentCallerResolver.resolve(applicationContext, this, intent)
                }
            },
        )

        if (!queued) {
            approval?.let { IntentApprovals.restore(applicationContext, it) }
        }

        return queued
    }

    /**
     * A picture-in-picture window cannot show a newly opened page, so an intent arriving
     * while we are in PiP has to pull the task back to the foreground first.
     */
    private fun checkAndExitPiP() {
        if (isInPictureInPictureMode) {
            moveTaskToBack(false)
            startActivity(
                Intent(this, MainActivity::class.java)
                    .setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
                    .putExtra(EXTRA_EXIT_PIP, true)
            )
        }
    }

    override fun onUserLeaveHint() {
        if (HomePressDispatcher.onUserLeaveHint(this)) {
            return
        }

        super.onUserLeaveHint()
    }

    /**
     * Check whether the FlutterEngine's native JNI layer is still attached.
     * Note: binaryMessenger.send() does NOT throw when JNI is detached — it just
     * logs a warning. We must use reflection to access FlutterJNI.isAttachedToJni().
     */
    private fun isEngineNativeAlive(engine: FlutterEngine): Boolean {
        return try {
            val field = FlutterEngine::class.java.getDeclaredField("flutterJNI")
            field.isAccessible = true
            val jni = field.get(engine) as FlutterJNI
            jni.isAttached
        } catch (e: Exception) {
            Log.w(TAG, "Could not check JNI attachment state: ${e.message}")
            false
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        trimMemoryChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TRIM_MEMORY_CHANNEL)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ACTIVITY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "moveTaskToBack" -> {
                    moveTaskToBack(true)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onPause() {
        Log.d(TAG, "onPause")
        super.onPause()
    }

    override fun onDestroy() {
        Log.d(TAG, "onDestroy: isFinishing=$isFinishing, " +
            "cachedEngine=${engineTag(FlutterEngineCache.getInstance().get(ENGINE_ID))}")
        super.onDestroy()

        if (!isFinishing) {
            val cache = FlutterEngineCache.getInstance()
            val engine = cache.get(ENGINE_ID)
            if (engine != null) {
                Log.d(TAG, "onDestroy: system-initiated destroy, clearing stale engine")
                cache.remove(ENGINE_ID)
                try {
                    engine.destroy()
                } catch (e: Exception) {
                    Log.w(TAG, "Error destroying engine in onDestroy", e)
                }
            }
        }
    }

    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        trimMemoryChannel?.invokeMethod("onTrimMemory", level)
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine {
        val cache = FlutterEngineCache.getInstance()
        val cachedEngine = cache.get(ENGINE_ID)
        if (cachedEngine != null) {
            val isHealthy = try {
                cachedEngine.dartExecutor.isExecutingDart && isEngineNativeAlive(cachedEngine)
            } catch (e: Exception) {
                Log.w(TAG, "Cached engine health check failed", e)
                false
            }

            if (isHealthy) {
                Log.d(TAG, "provideFlutterEngine: reusing cached engine ${engineTag(cachedEngine)}")
                return cachedEngine
            }

            Log.w(TAG, "provideFlutterEngine: cached engine ${engineTag(cachedEngine)} is stale, creating fresh")
            cache.remove(ENGINE_ID)
            try {
                cachedEngine.destroy()
            } catch (e: Exception) {
                Log.w(TAG, "Error destroying stale engine", e)
            }
        }

        val flutterEngine = FlutterEngine(context.applicationContext)
        flutterEngine.navigationChannel.setInitialRoute("/")
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        cache.put(ENGINE_ID, flutterEngine)

        Log.d(TAG, "provideFlutterEngine: created new engine ${engineTag(flutterEngine)}")
        return flutterEngine
    }

    override fun shouldDestroyEngineWithHost(): Boolean {
        return false // Keep engine alive when activity is destroyed
    }
}
