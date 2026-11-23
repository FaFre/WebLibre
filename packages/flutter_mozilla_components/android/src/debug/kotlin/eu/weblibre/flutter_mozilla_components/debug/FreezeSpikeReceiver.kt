/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.debug

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.util.Log
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.lifecycle.RestrictedSessions
import eu.weblibre.flutter_mozilla_components.lifecycle.SessionContextCommands
import eu.weblibre.flutter_mozilla_components.rootApplicationContext
import eu.weblibre.flutter_mozilla_components.startup.AtomicJsonFile
import eu.weblibre.flutter_mozilla_components.startup.StartupArbiter
import java.io.File
import java.nio.file.Files
import java.nio.file.LinkOption
import java.nio.file.attribute.BasicFileAttributes
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import mozilla.components.browser.engine.gecko.await
import mozilla.components.browser.state.action.EngineAction
import org.json.JSONObject
import org.mozilla.geckoview.StorageController

/**
 * Debug builds only: runs the engine half of the container freeze spikes (S1,
 * S8, S11 in phase 0 of `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`) on a
 * device, driven over adb, with every result in logcat under [TAG]. Not part of
 * container freeze (C1); it calls the patched GeckoView API directly, with
 * command numbers from the shared [SessionContextCommands] and no registry record.
 *
 * Only a sender holding `android.permission.DUMP` reaches it (the manifest
 * says so), which on a normal device is adb's shell and not an app:
 *
 * ```
 * adb shell am broadcast -a eu.weblibre.debug.FREEZE_SPIKE -p <package> --es cmd tabs
 * adb shell am broadcast -a eu.weblibre.debug.FREEZE_SPIKE -p <package> --es cmd freeze --es contexts <id>[,<id>]
 * adb logcat -s WebLibreFreezeSpike
 * ```
 *
 * Commands (`contexts` are AC context ids as `tabs` lists them, comma-separated):
 * - `tabs`: every tab with its context, whether its page is loaded, and its host.
 * - `install`, `lift`: E5 install or lift for `contexts`, with a fresh command number.
 *   Install also marks them in [RestrictedSessions] (no state saved from a session
 *   linked meanwhile); lift unloads the tabs woken while restricted, which then
 *   restore their kept state when shown.
 * - `quiesce`: E5 quiescence wait for `contexts`, `timeout` ms (default 30000).
 * - `freeze`: install, then put every tab of `contexts` to sleep (media and POST
 *   results cut off), then the quiescence wait: barriers 3 to 5 without the
 *   registry. Lift afterwards; the tabs stay asleep until woken from the UI.
 * - `clear`: E9 acknowledged clear of `context`.
 * - `swcontexts`: E10, the contexts with service-worker registrations.
 * - `decode`: E7 on `suffix` (an origin or its `^…` suffix).
 * - `fsync`: S8, a strict write with directory fsync next to `tab_lifecycle.json`,
 *   read back, then `Files.notExists` against `File.isFile` on paths around it.
 */
class FreezeSpikeReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val cmd = intent.getStringExtra("cmd") ?: return log("No cmd given")
        val contexts = intent.getStringExtra("contexts")
            ?.split(',')?.map { it.trim() }?.filter { it.isNotEmpty() }
            .orEmpty()
        // Not goAsync: a quiescence wait outlasts a broadcast's time limit. The
        // app process is running (the spike is done with WebLibre open).
        scope.launch {
            runCatching { run(context, cmd, contexts, intent) }
                .onFailure { log("$cmd failed: $it") }
        }
    }

    private suspend fun run(context: Context, cmd: String, contexts: List<String>, intent: Intent) {
        when (cmd) {
            "tabs" -> tabs()
            "install" -> install(contexts)
            "lift" -> lift(contexts)
            "quiesce" -> quiesce(contexts, intent.getLongExtra("timeout", DEFAULT_QUIESCENCE_MILLIS))
            "freeze" -> freeze(contexts, intent.getLongExtra("timeout", DEFAULT_QUIESCENCE_MILLIS))
            "clear" -> clear(intent.getStringExtra("context") ?: return log("clear needs --es context <id>"))
            "swcontexts" -> log("Contexts with service workers: ${storage().listSessionContextsWithServiceWorkers().await()}")
            "decode" -> {
                val suffix = intent.getStringExtra("suffix") ?: return log("decode needs --es suffix <origin>")
                log("Context of '$suffix': ${StorageController.sessionContextIdFromOriginSuffix(suffix)}")
            }
            "fsync" -> fsync(context)
            else -> log("Unknown cmd '$cmd'")
        }
    }

    private fun tabs() {
        val state = GlobalComponents.components?.core?.store?.state ?: return log("No components")
        log("${state.tabs.size} tabs, selected ${state.selectedTabId}")
        state.tabs.forEach { tab ->
            log(
                "tab ${tab.id} context=${tab.contextId} loaded=${tab.engineState.engineSession != null} " +
                    "private=${tab.content.private} host=${android.net.Uri.parse(tab.content.url).host}",
            )
        }
    }

    private suspend fun install(contexts: List<String>) {
        if (contexts.isEmpty()) return log("install needs --es contexts <id>[,<id>]")
        val number = SessionContextCommands.next()
        val started = SystemClock.elapsedRealtime()
        // Before the engine: a session linked from now on must not save state.
        RestrictedSessions.restrict(contexts)
        val results = storage().installSessionContextRestriction(contexts, number).await().orEmpty()
        log("install cmd=$number in ${SystemClock.elapsedRealtime() - started} ms")
        results.forEach { log("  ${it.contextId}: status=${commandStatus(it.status)} restricted=${it.restricted}") }
    }

    private suspend fun lift(contexts: List<String>) {
        if (contexts.isEmpty()) return log("lift needs --es contexts <id>[,<id>]")
        val number = SessionContextCommands.next()
        val started = SystemClock.elapsedRealtime()
        val results = storage().liftSessionContextRestriction(contexts, number).await().orEmpty()
        log("lift cmd=$number in ${SystemClock.elapsedRealtime() - started} ms")
        results.forEach { log("  ${it.contextId}: status=${commandStatus(it.status)} restricted=${it.restricted}") }

        // Tabs woken while restricted hold an empty page, and their saved
        // state was kept: unload them, so they restore it when shown.
        val lifted = results.filter { !it.restricted }.map { it.contextId }
        val store = GlobalComponents.components?.core?.store ?: return
        RestrictedSessions.release(lifted).forEach { tabId ->
            log("  unloading $tabId (its session was created while restricted)")
            store.dispatch(EngineAction.SuspendEngineSessionAction(tabId))
        }
    }

    private suspend fun quiesce(contexts: List<String>, timeoutMillis: Long) {
        if (contexts.isEmpty()) return log("quiesce needs --es contexts <id>[,<id>]")
        val number = SessionContextCommands.next()
        val started = SystemClock.elapsedRealtime()
        val results = storage().awaitSessionContextQuiescence(contexts, number, timeoutMillis).await().orEmpty()
        log("quiesce cmd=$number in ${SystemClock.elapsedRealtime() - started} ms")
        results.forEach {
            log(
                "  ${it.contextId}: status=${quiescenceStatus(it.status)} restricted=${it.restricted} " +
                    "serviceWorkers=${it.serviceWorkers} topLevel=${it.topLevelContexts} processes=${it.processes} " +
                    "channels=${it.channels} connections=${it.connections} webSockets=${it.webSockets} " +
                    "sockets=${it.sockets}",
            )
        }
    }

    private suspend fun freeze(contexts: List<String>, timeoutMillis: Long) {
        if (contexts.isEmpty()) return log("freeze needs --es contexts <id>[,<id>]")
        val core = GlobalComponents.components?.core ?: return log("No components")
        val started = SystemClock.elapsedRealtime()
        install(contexts)

        val members = core.store.state.tabs
            .filter { it.contextId in contexts && it.engineState.engineSession != null }
            .map { it.id }
        log("Putting ${members.size} loaded tabs to sleep: $members")
        core.tabLifecycle.sleep(members, stopMedia = true, discardPostResult = true).forEach {
            log("  ${it.tabId}: asleep=${it.asleep} failure=${it.failure} blockers=${it.blockers}")
        }

        quiesce(contexts, timeoutMillis)
        log("freeze done in ${SystemClock.elapsedRealtime() - started} ms; lift with cmd=lift")
    }

    private suspend fun clear(contextId: String) {
        val started = SystemClock.elapsedRealtime()
        runCatching { storage().clearDataForSessionContextWithResult(contextId).await() }
            .onSuccess { log("clear $contextId done in ${SystemClock.elapsedRealtime() - started} ms") }
            .onFailure { log("clear $contextId failed after ${SystemClock.elapsedRealtime() - started} ms: $it") }
    }

    private fun fsync(context: Context) {
        val folder = StartupArbiter.boundProfileFolder() ?: return log("No profile committed")
        val dir = File(context.rootApplicationContext.filesDir, folder)
        val file = File(dir, "freeze_spike_fsync.json")
        val atomic = AtomicJsonFile(file, syncDirectory = true, strict = true)
        runCatching { atomic.write(JSONObject().put("at", System.currentTimeMillis())) }
            .onSuccess { log("Strict write with directory fsync in ${dir.path}: OK") }
            .onFailure { log("Strict write with directory fsync in ${dir.path} FAILED: $it") }
        log("Read back: ${atomic.read()}")
        file.delete()
        log("After delete: ${atomic.read()} (expect Absent)")

        val missing = File(dir, "does-not-exist/inner.json")
        log("Missing path: notExists=${Files.notExists(missing.toPath())} isFile=${missing.isFile}")
        // Paths whose stat fails instead of saying "missing". Another app's data
        // folder is simply absent (ENOENT) where app data isolation hides it, so
        // the probe that fails everywhere is pid 1's root, which needs ptrace access.
        for (denied in listOf(File("/proc/1/root/inner.json"), File("/data/data/android/inner.json"))) {
            val stat = runCatching {
                Files.readAttributes(denied.toPath(), BasicFileAttributes::class.java, LinkOption.NOFOLLOW_LINKS)
            }.exceptionOrNull()?.javaClass?.simpleName ?: "no error"
            log(
                "Path ${denied.path}: stat=$stat notExists=${Files.notExists(denied.toPath())} " +
                    "exists=${Files.exists(denied.toPath())} isFile=${denied.isFile} " +
                    "strict read=${AtomicJsonFile(denied, strict = true).read()}",
            )
        }
        log("Expect: stat=AccessDeniedException reads Corrupt, stat=NoSuchFileException reads Absent")
    }

    private fun storage(): StorageController {
        val core = GlobalComponents.components?.core ?: error("No components")
        return core.runtime.storageController
    }

    private fun commandStatus(status: Int) = when (status) {
        StorageController.SessionContextCommandResult.STATUS_APPLIED -> "APPLIED"
        StorageController.SessionContextCommandResult.STATUS_SUPERSEDED -> "SUPERSEDED"
        else -> status.toString()
    }

    private fun quiescenceStatus(status: Int) = when (status) {
        StorageController.SessionContextQuiescence.STATUS_QUIESCENT -> "QUIESCENT"
        StorageController.SessionContextQuiescence.STATUS_SUPERSEDED -> "SUPERSEDED"
        StorageController.SessionContextQuiescence.STATUS_NOT_RESTRICTED -> "NOT_RESTRICTED"
        StorageController.SessionContextQuiescence.STATUS_TIMED_OUT -> "TIMED_OUT"
        else -> status.toString()
    }

    companion object {
        const val TAG = "WebLibreFreezeSpike"
        private const val DEFAULT_QUIESCENCE_MILLIS = 30_000L

        private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

        private fun log(message: String) {
            Log.i(TAG, message)
        }
    }
}
