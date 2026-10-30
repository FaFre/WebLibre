/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.middleware

import android.content.Context
import android.content.ContextWrapper
import android.net.Uri
import androidx.core.net.toUri
import eu.weblibre.flutter_mozilla_components.components.StaleUploads
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.action.CustomTabListAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.selector.findTabOrCustomTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.concept.engine.prompt.PromptRequest
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.Store
import java.io.File
import java.util.UUID

/**
 * Keeps each tab's uploads to itself, and deletes them once that tab can no
 * longer send them.
 *
 * Gecko uploads from a copy: AC copies each chosen file into `uploads/` under
 * the cache directory of the context the picker hands back, named after the
 * original. AC's `FileUploadsDirCleanerMiddleware` keeps one list of those names
 * for the whole browser and deletes all of them when *any* tab moves to another
 * host, so a document chosen in one tab was gone before that tab sent its form.
 * The single folder also let two files of the same name overwrite each other,
 * and copies from the photo picker were never listed at all.
 *
 * Here each file prompt's callbacks get a context whose cache directory is a
 * new folder inside the tab's own ([StaleUploads.tabDir]), so every pick lands
 * apart, and the tab's folder goes when that tab moves to another host or
 * closes. A page reads the file when its form is sent, before the navigation
 * that follows. Anything still there when the process ends goes at the next
 * start.
 *
 * This relies on AC copying through the cache directory of the context it is
 * given (`Uri.toFileUri`); check that on every AC upgrade.
 */
class TabUploadsMiddleware(
    private val cacheDir: () -> File,
    private val scope: CoroutineScope = CoroutineScope(Dispatchers.IO + SupervisorJob()),
) : Middleware<BrowserState, BrowserAction> {

    override fun invoke(
        store: Store<BrowserState, BrowserAction>,
        next: (BrowserAction) -> Unit,
        action: BrowserAction,
    ) {
        when (action) {
            is ContentAction.UpdatePromptRequestAction -> {
                val request = action.promptRequest
                if (request is PromptRequest.File) {
                    // Before the reducer, so the store only ever holds the wrapped
                    // request: the picker answers whatever it finds there.
                    next(action.copy(promptRequest = request.inTabFolder(action.sessionId)))
                    return
                }
            }

            is ContentAction.UpdateUrlAction -> {
                val tab = store.state.findTabOrCustomTab(action.sessionId)
                if (tab != null && tab.content.url.host() != action.url.host()) {
                    release(action.sessionId)
                }
            }

            is TabListAction.RemoveTabAction,
            is TabListAction.RemoveTabsAction,
            is TabListAction.RemoveAllTabsAction,
            is TabListAction.RemoveAllNormalTabsAction,
            is TabListAction.RemoveAllPrivateTabsAction,
            is CustomTabListAction.RemoveCustomTabAction,
            is CustomTabListAction.RemoveAllCustomTabsAction,
            -> {
                // Bulk closes keep some tabs (pinned, the other mode), so ask the
                // reducer rather than mirroring its rules here.
                val before = store.state.tabIds()
                next(action)
                (before - store.state.tabIds()).forEach(::release)
                return
            }

            else -> Unit
        }

        next(action)
    }

    private fun PromptRequest.File.inTabFolder(tabId: String): PromptRequest.File {
        val onSingle = onSingleFileSelected
        val onMultiple = onMultipleFilesSelected
        return copy(
            onSingleFileSelected = { context, uri: Uri -> onSingle(pickContext(context, tabId), uri) },
            onMultipleFilesSelected = { context, uris -> onMultiple(pickContext(context, tabId), uris) },
        )
    }

    private fun pickContext(context: Context, tabId: String): Context {
        val folder = File(StaleUploads.tabDir(cacheDir(), tabId), UUID.randomUUID().toString())
        folder.mkdirs()
        return PickContext(context, folder)
    }

    /**
     * Moves the folder aside before the action goes on, so a file the tab's next
     * page chooses lands in a fresh folder the delete never reaches.
     */
    private fun release(tabId: String) {
        val cacheDir = cacheDir()
        if (StaleUploads.detachTab(cacheDir, tabId)) {
            scope.launch { StaleUploads.deleteDetached(cacheDir) }
        }
    }

    private fun BrowserState.tabIds(): Set<String> =
        tabs.mapTo(mutableSetOf()) { it.id } + customTabs.map { it.id }

    private fun String.host(): String? = toUri().host
}

/** A picker's context whose cache directory is the folder its copy goes in. */
private class PickContext(base: Context, private val folder: File) : ContextWrapper(base) {
    override fun getCacheDir(): File = folder
}
