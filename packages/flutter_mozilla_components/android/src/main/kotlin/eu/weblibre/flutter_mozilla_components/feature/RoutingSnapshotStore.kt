/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import android.content.Context
import androidx.core.content.edit
import eu.weblibre.flutter_mozilla_components.ProfilePrefs
import mozilla.components.support.base.log.logger.Logger
import org.json.JSONException
import org.json.JSONObject

private const val ROUTING_SNAPSHOT_PREF = "browser.weblibre.containerRoutingSnapshot"

/**
 * Where the routing snapshot survives a process restart.
 *
 * The proxy extension's store is memory-only and blocks every request until it
 * is told the routing, and the only thing that ever tells it is Dart. That
 * leaves the headless paths — a Custom Tab or PWA cold-started into
 * `ComponentsMode.EXTERNAL`, where no Flutter engine ever attaches — with an
 * extension nothing can ever configure, i.e. a browser that loads nothing at
 * all. Persisting the last acknowledged snapshot lets [ContainerProxyFeature]
 * seed the extension without Dart, the same way [HistoryExclusions] carries its
 * own replicated state across the same gap.
 *
 * The stored copy deliberately holds no proxy endpoints — see
 * `ContainerProxyFeature.toSeed`.
 */
internal object RoutingSnapshotStore {
    private val logger = Logger("container_proxy")

    /**
     * The context whose profile the snapshot belongs to, bound when components
     * are created. Null before that, in which case nothing is read or written:
     * a snapshot with no profile to key it to could only be filed under, or
     * restored into, the wrong one.
     */
    @Volatile
    private var context: Context? = null

    /**
     * The pref key [context]'s profile reads and writes under, resolved once at
     * [bind].
     *
     * It doubles as the profile's identity for everything that has to be able to
     * say *which* profile a snapshot belongs to — deliberately the key itself,
     * because the question that matters is only ever "would this be filed where
     * the snapshot came from". Resolved once rather than per call so a snapshot
     * cannot be written under a key that changed underneath it.
     */
    @Volatile
    private var boundKey: String? = null

    fun currentKey(): String? = boundKey

    /**
     * Points the store at [context]'s profile, and answers whether that is a
     * different profile than the one bound before — which is a signal to the
     * caller that everything it holds for the outgoing profile is now stale.
     */
    fun bind(context: Context): Boolean {
        val key = ProfilePrefs.key(context, ROUTING_SNAPSHOT_PREF)
        val previous = boundKey

        this.context = context
        boundKey = key

        return previous != null && previous != key
    }

    fun read(): JSONObject? {
        val context = this.context ?: return null
        val key = boundKey ?: return null
        val raw = ProfilePrefs.of(context).getString(key, null) ?: return null

        return try {
            JSONObject(raw)
        } catch (e: JSONException) {
            // Unreadable is the same as absent: the extension keeps blocking
            // until Dart pushes, which is the safe side of this decision.
            logger.error("Failed to parse persisted routing snapshot", e)
            null
        }
    }

    /**
     * Files [snapshot] under [key], which is the profile it was pushed for and
     * not whatever is bound now.
     *
     * The two can differ: the caller resolves and checks the key while holding
     * its own lock, but [bind] runs on the main thread and takes no lock, so a
     * profile switch can land in between. Writing to the bound key here would be
     * exactly the cross-profile file the caller's check exists to prevent.
     * Which profile is *current* does not enter into it — a snapshot belongs to
     * the profile that pushed it, and that profile should restore it next time
     * it runs.
     *
     * Every profile's state lives in the one app-wide preference file (see
     * [ProfilePrefs]), so the context in hand addresses [key]'s profile too.
     */
    fun write(snapshot: JSONObject, key: String) {
        val context = this.context ?: return
        ProfilePrefs.of(context).edit {
            putString(key, snapshot.toString())
        }
    }
}
