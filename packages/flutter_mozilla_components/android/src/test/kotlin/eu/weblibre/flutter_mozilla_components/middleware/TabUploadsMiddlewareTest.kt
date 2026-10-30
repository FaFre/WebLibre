/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.middleware

import android.content.Context
import android.net.Uri
import java.io.File
import java.nio.file.Files
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotEquals
import kotlin.test.assertTrue
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.selector.findTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.createTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.prompt.PromptRequest
import mozilla.components.support.ktx.android.net.toFileUri
import org.junit.After
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

/**
 * Picks go through AC's own `Uri.toFileUri`, as `GeckoPromptDelegate` does, so
 * these also catch AC no longer copying into the context's cache directory.
 */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class TabUploadsMiddlewareTest {
    private val context: Context = RuntimeEnvironment.getApplication()
    private val cacheDir = Files.createTempDirectory("weblibre_tab_uploads").toFile()
    private val sources = Files.createTempDirectory("weblibre_tab_upload_sources").toFile()

    private val store = BrowserStore(
        initialState = BrowserState(
            tabs = listOf(
                createTab("https://a.example/form", id = TAB_A),
                createTab("https://b.example", id = TAB_B),
            ),
            selectedTabId = TAB_A,
        ),
        middleware = listOf(
            TabUploadsMiddleware(
                cacheDir = { cacheDir },
                scope = CoroutineScope(Dispatchers.Unconfined),
            ),
        ),
    )

    @After
    fun tearDown() {
        cacheDir.deleteRecursively()
        sources.deleteRecursively()
    }

    /** Chooses a file named [name] in [tabId]; returns the copy Gecko would send. */
    private fun choose(tabId: String, name: String, content: String = name): File {
        val source = File(Files.createTempDirectory(sources.toPath(), "pick").toFile(), name)
        source.writeText(content)

        var copy: File? = null
        val request = PromptRequest.File(
            mimeTypes = emptyArray(),
            onSingleFileSelected = { context, uri ->
                copy = File(requireNotNull(uri.toFileUri(context, PromptRequest.File.DEFAULT_UPLOADS_DIR_NAME).path))
            },
            onMultipleFilesSelected = { _, _ -> },
            onDismiss = {},
        )
        store.dispatch(ContentAction.UpdatePromptRequestAction(tabId, request))

        val stored = store.state.findTab(tabId)!!.content.promptRequests.last() as PromptRequest.File
        stored.onSingleFileSelected(context, Uri.fromFile(source))
        store.dispatch(ContentAction.ConsumePromptRequestAction(tabId, stored))

        return requireNotNull(copy).also { assertEquals(content, it.readText()) }
    }

    private fun navigate(tabId: String, url: String) {
        store.dispatch(ContentAction.UpdateUrlAction(tabId, url))
    }

    @Test
    fun `a file chosen in one tab survives another tab moving to another host`() {
        val upload = choose(TAB_A, "letter.pdf")

        navigate(TAB_B, "https://elsewhere.example")

        assertTrue(upload.exists())
    }

    @Test
    fun `a tab's files go once it moves to another host`() {
        val upload = choose(TAB_A, "letter.pdf")

        navigate(TAB_A, "https://a.example/sent")
        assertTrue(upload.exists())

        navigate(TAB_A, "https://elsewhere.example")
        assertFalse(upload.exists())
    }

    @Test
    fun `a file chosen after the tab moved on is kept`() {
        choose(TAB_A, "first.pdf")
        navigate(TAB_A, "https://elsewhere.example")

        val upload = choose(TAB_A, "second.pdf")

        assertTrue(upload.exists())
    }

    @Test
    fun `closing a tab deletes its files and no one else's`() {
        val inA = choose(TAB_A, "a.pdf")
        val inB = choose(TAB_B, "b.pdf")

        store.dispatch(TabListAction.RemoveTabAction(TAB_A))
        assertFalse(inA.exists())
        assertTrue(inB.exists())

        store.dispatch(TabListAction.RemoveAllTabsAction())
        assertFalse(inB.exists())
    }

    @Test
    fun `files of the same name stay apart`() {
        val first = choose(TAB_A, "scan.pdf", content = "first")
        val second = choose(TAB_A, "scan.pdf", content = "second")
        val elsewhere = choose(TAB_B, "scan.pdf", content = "third")

        assertNotEquals(first, second)
        assertEquals("first", first.readText())
        assertEquals("second", second.readText())
        assertEquals("third", elsewhere.readText())
    }

    private companion object {
        const val TAB_A = "tab-a"
        const val TAB_B = "tab-b"
    }
}
