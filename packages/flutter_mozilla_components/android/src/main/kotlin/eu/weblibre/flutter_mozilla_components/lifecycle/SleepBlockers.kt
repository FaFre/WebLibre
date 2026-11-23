/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.lifecycle

import android.os.SystemClock
import android.util.JsonWriter
import eu.weblibre.flutter_mozilla_components.components.StaleUploads
import eu.weblibre.flutter_mozilla_components.pigeons.ProtectedActivity
import java.io.File
import java.io.StringWriter
import java.lang.ref.WeakReference
import java.util.WeakHashMap
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.CustomTabListAction
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.selector.findTabOrCustomTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.SessionState
import mozilla.components.browser.state.state.TabSessionState
import mozilla.components.browser.state.state.content.DownloadState
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.EngineSessionState
import mozilla.components.concept.engine.mediasession.MediaSession
import mozilla.components.concept.engine.media.RecordingDevice
import org.json.JSONObject

/**
 * These blockers with the form input as GeckoView reported it just now, in
 * place of the store's cached flag; unchanged when [answer] is null.
 */
internal fun List<ProtectedActivity>.withFormData(answer: Boolean?): List<ProtectedActivity> {
    if (answer == null) return this
    val present = toMutableSet()
    if (answer) present += ProtectedActivity.FORM_DATA else present -= ProtectedActivity.FORM_DATA
    return ProtectedActivity.values().filter { it in present }
}

/**
 * The tabs printing or saving a PDF right now. Fed by `SaveToPDFMiddleware`,
 * which sees each request and its end; read on the main thread.
 *
 * Only a request the tab's session can take is counted. A tab without a
 * session gets the request again as the follow-up of its session's creation,
 * so counting the first sight would count it twice; and a sleeping tab gets no
 * session at all, so that request never runs and would never end.
 *
 * A job belongs to the session that took it: once the tab's session is closed
 * or replaced, its jobs are over. AC also reports no end for a print the user
 * cancelled or a PDF that produced nothing, so a job counts for at most
 * [maxJobMillis].
 *
 * Nothing here keeps a session alive: a job holds its session weakly, and is
 * dropped when the tab's session is unlinked or the tab removed, and once
 * expired whenever a job starts, not only when someone asks [isBusy] (with
 * automatic sleep off nothing may ever ask).
 */
class PageOutputTracker(
    private val maxJobMillis: Long = MAX_JOB_MILLIS,
    private val now: () -> Long = SystemClock::elapsedRealtime,
) {
    private class Job(session: EngineSession, val startedAt: Long) {
        private val session = WeakReference(session)

        fun belongsTo(current: EngineSession?): Boolean = current != null && session.get() === current

        val isCollected: Boolean get() = session.get() == null
    }

    private val jobs = mutableMapOf<String, MutableList<Job>>()

    /** Call with the state the action meets, before it goes on. */
    fun onAction(state: BrowserState, action: BrowserAction) {
        when (action) {
            is EngineAction.SaveToPdfAction -> begin(state, action.tabId)
            is EngineAction.PrintContentAction -> begin(state, action.tabId)
            is EngineAction.SaveToPdfCompleteAction -> end(action.tabId)
            is EngineAction.SaveToPdfExceptionAction -> end(action.tabId)
            is EngineAction.PrintContentCompletedAction -> end(action.tabId)
            is EngineAction.PrintContentExceptionAction -> end(action.tabId)
            is EngineAction.UnlinkEngineSessionAction -> forget(listOf(action.tabId))
            is TabListAction.RemoveTabAction -> forget(listOf(action.tabId))
            is TabListAction.RemoveTabsAction -> forget(action.tabIds)
            is CustomTabListAction.RemoveCustomTabAction -> forget(listOf(action.tabId))
            else -> Unit
        }
    }

    @Synchronized
    private fun begin(state: BrowserState, tabId: String) {
        dropExpired()
        val session = state.findTabOrCustomTab(tabId)?.engineState?.engineSession ?: return
        jobs.getOrPut(tabId) { mutableListOf() } += Job(session, now())
    }

    /** The jobs of [tabIds] are over: their sessions went. */
    @Synchronized
    private fun forget(tabIds: Collection<String>) {
        if (jobs.isEmpty()) return
        tabIds.forEach { jobs.remove(it) }
    }

    @Synchronized
    private fun end(tabId: String) {
        val running = jobs[tabId] ?: return
        running.removeAt(0)
        if (running.isEmpty()) jobs.remove(tabId)
    }

    /** Whether [tab] has a job running in its current session. */
    @Synchronized
    fun isBusy(tab: SessionState): Boolean {
        dropExpired()
        val running = jobs[tab.id] ?: return false
        val session = tab.engineState.engineSession
        running.removeAll { !it.belongsTo(session) }
        if (running.isEmpty()) jobs.remove(tab.id)
        return running.isNotEmpty()
    }

    /** Every tab's expired jobs, and those whose session is gone. */
    private fun dropExpired() {
        if (jobs.isEmpty()) return
        val time = now()
        val tabs = jobs.values.iterator()
        while (tabs.hasNext()) {
            val running = tabs.next()
            running.removeAll { time - it.startedAt > maxJobMillis || it.isCollected }
            if (running.isEmpty()) tabs.remove()
        }
    }

    /** How many jobs are kept, for tests. */
    @Synchronized
    internal fun jobCount(): Int = jobs.values.sumOf { it.size }

    companion object {
        /**
         * Long enough for a large page's PDF to be generated. A print hands its
         * PDF to Android's print dialog, which covers the browser until the
         * user is done with it.
         */
        const val MAX_JOB_MILLIS = 2 * 60 * 1000L
    }
}

/**
 * What putting a tab to sleep would cut off (D13 in
 * `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`), read from the store and
 * from what the store does not hold: running PDF and print jobs, and files
 * chosen for upload.
 *
 * Form detection is GeckoView's: it sees changed form fields, not rich editors
 * or a page's own script state.
 */
class SleepBlockerProbe(
    private val outputs: PageOutputTracker,
    private val hasChosenUploads: (tabId: String) -> Boolean,
    private val isPostResult: (EngineSessionState?) -> Boolean = Companion::isPostResult,
) {
    constructor(outputs: PageOutputTracker, uploadsCacheDir: () -> File) : this(
        outputs,
        hasChosenUploads = { tabId ->
            // A folder per pick under the tab's own; it goes when the tab moves to
            // another host or closes (TabUploadsMiddleware).
            StaleUploads.tabDir(uploadsCacheDir(), tabId).walkTopDown().any { it.isFile }
        },
    )

    /**
     * [isPostResult] by state object, which only changes with the tab's saved
     * state: a blocked tab is asked again at every evaluation. Weak, so a
     * closed tab's state goes with it; `GeckoEngineSessionState` compares by
     * identity.
     */
    private val postResults = WeakHashMap<EngineSessionState, Boolean>()

    fun blockersOf(state: BrowserState, tab: TabSessionState): List<ProtectedActivity> = blockers(state, tab).toList()

    /**
     * Whether [tab] has any blocker other than form input; stops at the
     * first. For the schedulers' picks: the store's form flag is refreshed
     * only when a tab is deselected, so a background page that cleared its
     * form or navigated away keeps it set, and the tab would never be picked.
     * The sleep or freeze a pick starts asks GeckoView instead, and refuses
     * (and backs off) on real form input.
     */
    fun isBlockedBesidesFormData(state: BrowserState, tab: TabSessionState): Boolean =
        blockers(state, tab, formData = false).any()

    private fun blockers(state: BrowserState, tab: TabSessionState, formData: Boolean = true) = sequence {
        if (tab.mediaSessionState?.playbackState == MediaSession.PlaybackState.PLAYING) {
            yield(ProtectedActivity.MEDIA)
        }
        if (tab.content.recordingDevices.any { it.status == RecordingDevice.Status.RECORDING }) {
            yield(ProtectedActivity.RECORDING)
        }
        if (formData && tab.content.hasFormData) yield(ProtectedActivity.FORM_DATA)
        if (hasChosenUploads(tab.id)) yield(ProtectedActivity.UPLOAD)
        if (outputs.isBusy(tab)) yield(ProtectedActivity.PRINT_OR_PDF)
        if (state.downloads.values.any { it.sessionId == tab.id && it.status in RUNNING_DOWNLOADS }) {
            yield(ProtectedActivity.DOWNLOAD)
        }
        if (postResultOf(tab.engineState.engineSessionState)) yield(ProtectedActivity.POST_RESULT)
    }

    private fun postResultOf(state: EngineSessionState?): Boolean {
        if (state == null) return isPostResult(null)
        return synchronized(postResults) { postResults.getOrPut(state) { isPostResult(state) } }
    }

    companion object {
        private val RUNNING_DOWNLOADS = setOf(
            DownloadState.Status.INITIATED,
            DownloadState.Status.DOWNLOADING,
        )

        /** What GeckoView's AC wrapper names its serialized state. */
        private const val GECKO_STATE_KEY = "GECKO_STATE"

        /**
         * Whether the current entry of [state] is the result of a form submission:
         * the `hasPostData` marker `gecko-weblibre-session-post-marker.patch` puts
         * on saved history entries. False when the state is missing or unreadable,
         * and with a GeckoView that does not write the marker.
         */
        fun isPostResult(state: EngineSessionState?): Boolean {
            if (state == null) return false
            return runCatching {
                val buffer = StringWriter()
                JsonWriter(buffer).use { state.writeTo(it) }
                val gecko = JSONObject(buffer.toString()).optString(GECKO_STATE_KEY)
                if (gecko.isEmpty() || gecko == "null") return false
                isPostResultJson(JSONObject(gecko))
            }.getOrDefault(false)
        }

        /** [isPostResult] on GeckoView's session state JSON. */
        internal fun isPostResultJson(geckoState: JSONObject): Boolean {
            val history = geckoState.optJSONObject("history") ?: return false
            val entries = history.optJSONArray("entries") ?: return false
            // GeckoView's history index is 1-based.
            val index = history.optInt("index", entries.length()) - 1
            val entry = entries.optJSONObject(index) ?: return false
            return entry.optBoolean("hasPostData", false)
        }
    }
}
