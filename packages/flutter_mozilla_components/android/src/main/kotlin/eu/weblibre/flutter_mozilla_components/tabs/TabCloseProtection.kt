/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.tabs

import android.content.Context
import eu.weblibre.flutter_mozilla_components.ProfilePrefs
import java.io.IOException

private const val LOCKED_TAB_IDS_PREF = "browser.weblibre.lockedTabIds"

/**
 * The tabs the user locked ("Lock tab"), as native enforces it.
 *
 * Dart keeps what the user asked for in `tab.is_locked`. Native needs its own
 * copy because tabs are also closed where Dart never gets a say: a page's
 * `window.close()`, an add-on's `tabs.remove`, the `RemoveAll*` actions of the
 * browsing-data deletion. [eu.weblibre.flutter_mozilla_components.middleware.TabCloseGuardMiddleware]
 * consults this set for every removal, before anything else in the store sees it.
 *
 * Process-wide and profile-scoped, like
 * [eu.weblibre.flutter_mozilla_components.history.HistoryExclusions], and for the
 * same reason: Dart pushes its startup snapshot ([bootstrap]) before the engine
 * and `Core` exist. A process never changes its profile, so the set is read once,
 * on first use after the profile is committed.
 *
 * The protocol keeps **this set a superset of the database's** (D3 in
 * `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`): Dart locks here first and in
 * the database second, and unlocks the other way round. Every write here is
 * therefore durable before it is answered (`commit()`, never `apply()`), and a
 * write that fails leaves the previous set in force, so an interrupted step can
 * only leave a tab *more* locked than the database says. [bootstrap] and
 * [replace] repair that from the database.
 */
object TabCloseProtection {
    /** Where the set is kept. Swapped in tests to make a write fail. */
    internal interface Storage {
        /** The persisted set, or `null` while no profile is committed. */
        fun read(): Set<String>?

        /** Persists [tabIds] before returning; false when that failed. */
        fun write(tabIds: Set<String>): Boolean
    }

    private class ProfilePrefsStorage(private val context: Context) : Storage {
        override fun read(): Set<String>? {
            val key = ProfilePrefs.key(LOCKED_TAB_IDS_PREF) ?: return null
            return ProfilePrefs.of(context).getStringSet(key, null).orEmpty().toSet()
        }

        override fun write(tabIds: Set<String>): Boolean {
            // No committed profile means no addressable key, and an unscoped key
            // would hand these locks to whichever profile starts next.
            val key = ProfilePrefs.key(LOCKED_TAB_IDS_PREF) ?: return false
            return ProfilePrefs.of(context).edit().putStringSet(key, tabIds).commit()
        }
    }

    private val lock = Any()

    @Volatile
    private var storage: Storage? = null

    /** The set in force, or `null` until it could be read. */
    @Volatile
    private var lockedTabIds: Set<String>? = null

    /**
     * Gives the store the context it persists through. Called wherever a process
     * can start enforcing (plugin attach, components setup); later calls do
     * nothing.
     */
    fun attach(context: Context) {
        if (storage != null) return
        synchronized(lock) {
            if (storage == null) storage = ProfilePrefsStorage(context.applicationContext)
        }
    }

    /**
     * The set in force. Read from disk on first use; until the profile is
     * committed nothing is readable, and the read is tried again next time.
     */
    private fun current(): Set<String> {
        lockedTabIds?.let { return it }
        return synchronized(lock) {
            lockedTabIds ?: storage?.read()?.also { lockedTabIds = it } ?: emptySet()
        }
    }

    fun isLocked(tabId: String): Boolean = tabId in current()

    /** Which of [tabIds] are locked right now, in their order. */
    fun lockedAmong(tabIds: Collection<String>): List<String> {
        val locked = current()
        return tabIds.filter { it in locked }
    }

    /** Every locked tab id. */
    fun lockedTabIds(): Set<String> = current()

    /**
     * Replaces the set with Dart's startup snapshot of `tab.is_locked`, trusted as
     * it is: the tabs are not restored yet, so there is nothing live to check them
     * against. The database is the record of what the user asked for, and a lock
     * native held without it was never acknowledged.
     *
     * @throws IOException when the snapshot could not be persisted; the previous
     * set, a superset of the database's by the protocol, then stays in force.
     */
    fun bootstrap(tabIds: Collection<String>) {
        synchronized(lock) {
            val next = tabIds.toSet()
            // Usually what is on disk already, so most starts write nothing. An
            // unreadable set is written, so a missing profile still throws.
            if ((lockedTabIds ?: storage?.read()) != next) persist(next)
            lockedTabIds = next
        }
    }

    /**
     * Locks or unlocks [tabId] and returns whether it was locked before.
     *
     * A lock is in force before it is written, so a removal running meanwhile is
     * already refused, and is taken back if the write fails. An unlock takes effect
     * only once it is written. Either way a failed write leaves the previous
     * value in force.
     *
     * @throws IOException when the change could not be persisted.
     */
    fun set(tabId: String, locked: Boolean): Boolean {
        synchronized(lock) {
            val before = current()
            // What is cached, which is null while the set could not be read:
            // a failed write puts this back, not the empty fallback [current]
            // returned, which would hide the persisted set for good.
            val cachedBefore = lockedTabIds
            val previouslyLocked = tabId in before
            if (previouslyLocked == locked) return previouslyLocked

            val next = if (locked) before + tabId else before - tabId
            if (locked) lockedTabIds = next
            try {
                persist(next)
            } catch (e: IOException) {
                lockedTabIds = cachedBefore
                throw e
            }
            lockedTabIds = next
            return previouslyLocked
        }
    }

    /**
     * Replaces the set with [tabIds] and returns the ids that were dropped. Only
     * for the reconciliation after the session restore, where [tabIds] is the
     * database's set limited to the live tabs.
     *
     * @throws IOException when the new set could not be persisted; the old one
     * then stays in force.
     */
    fun replace(tabIds: Collection<String>): Set<String> {
        synchronized(lock) {
            val before = current()
            val next = tabIds.toSet()
            if (next != before) {
                persist(next)
                lockedTabIds = next
            }
            return before - next
        }
    }

    private fun persist(tabIds: Set<String>) {
        val storage = storage ?: throw IOException("Tab locks have no storage attached")
        if (!storage.write(tabIds)) {
            throw IOException("Writing the locked tabs failed")
        }
    }

    internal fun setStorageForTest(storage: Storage?) {
        synchronized(lock) {
            this.storage = storage
            lockedTabIds = null
        }
    }

    internal fun resetForTest() = setStorageForTest(null)
}
