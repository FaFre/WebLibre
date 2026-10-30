/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.components

import mozilla.components.concept.engine.prompt.PromptRequest
import mozilla.components.support.base.log.logger.Logger
import java.io.File
import java.util.UUID

/**
 * Copies of chosen files that no page can send any more.
 *
 * Gecko uploads from a copy AC makes in `cacheDir/uploads`, which
 * `TabUploadsMiddleware` splits into one folder per tab. A tab's folder is
 * stale once the tab moves to another host or closes, and the whole directory
 * is stale in a new process. Deleting can take a while and a page may choose a
 * new file meanwhile, so this is two steps: [detach] and [detachTab] move the
 * folder aside at once, so new uploads get a fresh one, and [deleteDetached]
 * removes what was moved aside, off the main thread.
 */
internal object StaleUploads {
    // Also the name AC's own FileUploadsDirCleaner moves the directory to, so
    // its leftovers go too.
    private const val DETACHED_PREFIX = "uploads_to_be_deleted"

    private val logger = Logger("StaleUploads")

    fun uploadsDir(cacheDir: File) = File(cacheDir, PromptRequest.File.DEFAULT_UPLOADS_DIR_NAME)

    /**
     * Where [tabId]'s uploads go. Derived from the id rather than recorded, so a
     * custom tab handed to the next store after a rebuild still finds its own.
     */
    fun tabDir(cacheDir: File, tabId: String) =
        File(uploadsDir(cacheDir), UUID.nameUUIDFromBytes(tabId.toByteArray()).toString())

    /** Moves every upload aside. Only safe before any session can choose a file. */
    fun detach(cacheDir: File): Boolean = detach(cacheDir, uploadsDir(cacheDir))

    /** Moves [tabId]'s uploads aside. False when it had none. */
    fun detachTab(cacheDir: File, tabId: String): Boolean = detach(cacheDir, tabDir(cacheDir, tabId))

    /**
     * Never throws: it runs in background jobs nothing waits on, where an
     * exception would take the process down. What it leaves goes next time.
     */
    fun deleteDetached(cacheDir: File) {
        try {
            cacheDir.listFiles { file -> file.name.startsWith(DETACHED_PREFIX) }
                ?.forEach { it.deleteRecursively() }
        } catch (error: Exception) {
            logger.warn("Could not delete stale uploads", error)
        }
    }

    private fun detach(cacheDir: File, dir: File): Boolean {
        if (!dir.exists()) return false

        // A name of its own each time. Renaming onto a directory an interrupted
        // delete left behind fails, and the uploads would then stay in place.
        return dir.renameTo(File(cacheDir, "${DETACHED_PREFIX}_${UUID.randomUUID()}"))
    }
}
