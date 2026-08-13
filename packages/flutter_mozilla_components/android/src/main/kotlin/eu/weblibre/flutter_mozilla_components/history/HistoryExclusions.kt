/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.history

import android.content.Context
import android.content.SharedPreferences
import androidx.core.content.edit
import androidx.preference.PreferenceManager
import eu.weblibre.flutter_mozilla_components.ActiveProfile
import eu.weblibre.flutter_mozilla_components.ProfileContext
import java.util.concurrent.ConcurrentHashMap

private const val EXCLUDED_TAB_IDS_PREF = "browser.weblibre.excludedHistoryTabIds"
private const val EXCLUDED_CONTEXT_IDS_PREF = "browser.weblibre.excludedHistoryContextIds"

/**
 * Which sessions must not record browsing history ("Exclude from History" /
 * incognito container).
 *
 * WebLibre's container membership lives in Dart, so the decision is replicated
 * here as a snapshot of tab ids and consulted by [TabScopedHistoryDelegate] —
 * the delegate each engine session runs — at record time. Keying on the tab is
 * what makes the feature work for containers *without* cookie isolation: those
 * share the default Gecko context, so a contextId can't tell their visits apart,
 * while the session that produced the visit always can.
 *
 * Resolution, in order:
 *  1. [excludedTabIds] — the replicated answer for a tab WebLibre knows about.
 *  2. [excludedContextIds] — the container's Gecko contextual identity. Covers
 *     cookie-isolated containers before the first snapshot lands (cold start,
 *     and the headless external path where no Flutter engine ever attaches).
 *  3. A provisional mark ([markProvisional]) — a tab that exists natively before
 *     WebLibre has a row for it: one just created in an excluded container, or
 *     one an excluded session opened via `window.open`. Honored only while the
 *     tab is missing from [knownTabIds], i.e. until the snapshot that covers it
 *     arrives and answers authoritatively.
 *
 * Ambiguity resolves to "excluded": a dropped visit is recoverable by revisiting
 * the page, a leaked one is not.
 */
object HistoryExclusions {
    @Volatile
    private var excludedTabIds: Set<String> = emptySet()

    @Volatile
    private var knownTabIds: Set<String> = emptySet()

    @Volatile
    private var excludedContextIds: Set<String> = emptySet()

    private val provisionalTabIds: MutableSet<String> = ConcurrentHashMap.newKeySet()

    /**
     * Whether anything is excluded at all. Read by [FallbackHistoryDelegate],
     * which has no session to ask about and therefore records only while this is
     * false.
     */
    val anyExclusionActive: Boolean
        get() = excludedTabIds.isNotEmpty() ||
            excludedContextIds.isNotEmpty() ||
            provisionalTabIds.isNotEmpty()

    /** Whether [tabId] (running under [contextId]) must skip history recording. */
    fun isExcluded(tabId: String?, contextId: String?): Boolean {
        if (contextId != null && contextId in excludedContextIds) {
            return true
        }

        if (tabId == null) {
            return false
        }

        if (tabId in excludedTabIds) {
            return true
        }

        return tabId !in knownTabIds && tabId in provisionalTabIds
    }

    /**
     * Whether WebLibre holds a row for [tabId], i.e. whether the replicated
     * snapshot is authoritative about it. False for a session that only exists
     * natively so far, and for one WebLibre never tracks (a custom tab).
     */
    fun isTracked(tabId: String): Boolean = tabId in knownTabIds

    /**
     * Exclude a tab WebLibre has no row for yet. Superseded by the next snapshot
     * that lists [tabId], which may well say the tab is not excluded after all —
     * this only has to hold the line until then.
     */
    fun markProvisional(tabId: String) {
        provisionalTabIds.add(tabId)
    }

    /** Drop a closed tab's provisional mark so the set can't grow unbounded. */
    fun forget(tabId: String) {
        provisionalTabIds.remove(tabId)
    }

    fun forgetAll() {
        provisionalTabIds.clear()
    }

    /**
     * Replace the replicated snapshot. Persisted (except [knownTabIds], which is
     * only meaningful while Dart is live) so a cold start on the headless path
     * still knows which sessions to keep out of Places.
     */
    fun update(
        context: Context?,
        excludedTabIds: Collection<String>,
        knownTabIds: Collection<String>,
        excludedContextIds: Collection<String>,
    ) {
        val excludedTabIdSet = excludedTabIds.toSet()
        val excludedContextIdSet = excludedContextIds.toSet()
        val knownTabIdSet = knownTabIds.toSet()

        this.excludedTabIds = excludedTabIdSet
        this.knownTabIds = knownTabIdSet
        this.excludedContextIds = excludedContextIdSet

        // A provisional mark the snapshot now answers for is dead weight, and
        // [anyExclusionActive] counts it — a single stale mark would keep
        // [FallbackHistoryDelegate] refusing to record long after the last
        // container was un-excluded.
        provisionalTabIds.removeAll(knownTabIdSet)

        if (context != null) {
            prefs(context).edit {
                putStringSet(profileKey(context, EXCLUDED_TAB_IDS_PREF), excludedTabIdSet)
                putStringSet(profileKey(context, EXCLUDED_CONTEXT_IDS_PREF), excludedContextIdSet)
                // This profile now has its own value, so the pre-scoping one is
                // obsolete — and it is profile-independent, so leaving it would
                // let it resurface as *another* profile's fallback below.
                remove(EXCLUDED_TAB_IDS_PREF)
                remove(EXCLUDED_CONTEXT_IDS_PREF)
            }
        }
    }

    /**
     * Restore the last persisted snapshot, discarding whatever the process held
     * before — used on a cold headless start and when components are rebuilt for
     * another profile.
     *
     * [knownTabIds] deliberately stays empty: without Dart there is nothing
     * authoritative to say a tab is *not* excluded, so provisional marks keep
     * applying until a real snapshot arrives. That is exactly why the provisional
     * set has to be dropped here too — its ids belong to the previous profile's
     * tabs, which will never appear in the next [update]'s [knownTabIds] and so
     * could never be cleared, leaving [anyExclusionActive] pinned true (and
     * [FallbackHistoryDelegate] silent) for the rest of the process.
     */
    fun loadPersisted(context: Context) {
        val prefs = prefs(context)
        excludedTabIds = prefs.readExclusions(context, EXCLUDED_TAB_IDS_PREF)
        excludedContextIds = prefs.readExclusions(context, EXCLUDED_CONTEXT_IDS_PREF)
        knownTabIds = emptySet()
        provisionalTabIds.clear()
    }

    /**
     * The profile-scoped value, falling back to the unscoped key that predates
     * [profileKey]. Only a device carrying a build from before the keys were
     * scoped can still hold one, and the next [update] drops it — but until then
     * ignoring it would mean a cold headless start with no exclusions at all,
     * which leaks rather than merely dropping a visit.
     */
    private fun SharedPreferences.readExclusions(context: Context, base: String): Set<String> {
        getStringSet(profileKey(context, base), null)?.let { return it.toSet() }
        return getStringSet(base, emptySet()).orEmpty().toSet()
    }

    /**
     * Always the app-wide default preferences, whichever context a caller hands
     * in. The snapshot is pushed from Dart before any [ProfileContext] exists, so
     * the writer can only ever hold the raw application context — while callers on
     * the profile-switch path naturally hold a [ProfileContext], which renames the
     * underlying prefs file and would otherwise read a different store than the
     * one written. The profile is carried by [profileKey] instead.
     */
    private fun prefs(context: Context): SharedPreferences =
        PreferenceManager.getDefaultSharedPreferences(
            (context as? ProfileContext)?.rootApplicationContext ?: context.applicationContext,
        )

    /**
     * Scope a pref key to the active profile, so a headless start under profile B
     * does not restore profile A's excluded ids.
     */
    private fun profileKey(context: Context, base: String): String {
        if (ActiveProfile.prefix == null) {
            ActiveProfile.resolveFromDisk(context.applicationContext)
        }
        return ActiveProfile.prefix?.let { "$base.$it" } ?: base
    }
}
