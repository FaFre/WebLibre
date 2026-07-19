/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.push

import java.nio.file.Files
import kotlin.io.path.createTempDirectory
import kotlin.test.Test
import kotlin.test.assertContentEquals
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue

class PushMessageStoreTest {
    @Test
    fun persistsListsAndDeletesMessage() {
        val directory = createTempDirectory("push-store").toFile()
        try {
            val store = PushMessageStore(directory)
            store.persist("https://example.com", byteArrayOf(0, 1, 2, -1), "message-1")

            assertEquals(listOf("message-1"), store.ids())
            val stored = store.get("message-1")
            assertEquals("https://example.com", stored?.scope)
            assertContentEquals(byteArrayOf(0, 1, 2, -1), stored?.payload)
            assertTrue(store.complete("message-1"))
            assertNull(store.get("message-1"))
        } finally {
            directory.deleteRecursively()
        }
    }

    @Test
    fun replacingIdLeavesOneCompleteRecord() {
        val directory = createTempDirectory("push-store").toFile()
        try {
            val store = PushMessageStore(directory)
            store.persist("old", byteArrayOf(1), "same-id")
            store.persist("new", byteArrayOf(2, 3), "same-id")

            assertEquals(listOf("same-id"), store.ids())
            assertEquals("new", store.get("same-id")?.scope)
            assertContentEquals(byteArrayOf(2, 3), store.get("same-id")?.payload)
        } finally {
            directory.deleteRecursively()
        }
    }

    @Test
    fun rejectsPathTraversalIds() {
        val directory = Files.createTempDirectory("push-store").toFile()
        try {
            val store = PushMessageStore(directory)
            assertFailsWith<IllegalArgumentException> {
                store.persist("scope", byteArrayOf(1), "../outside")
            }
        } finally {
            directory.deleteRecursively()
        }
    }

    @Test
    fun completedMessageIsNotRecovered() {
        val directory = createTempDirectory("push-store").toFile()
        try {
            val store = PushMessageStore(directory)
            store.persist("scope", byteArrayOf(1), "completed")

            assertTrue(store.complete("completed"))

            assertTrue(store.ids().isEmpty())
            assertNull(store.get("completed"))
            assertFalse(directory.resolve("completed.push").exists())
            assertTrue(directory.resolve("completed.delivered").isFile)
        } finally {
            directory.deleteRecursively()
        }
    }

    @Test
    fun rejectsAndDiscardsCorruptMessage() {
        val directory = createTempDirectory("push-store").toFile()
        try {
            val store = PushMessageStore(directory)
            directory.resolve("corrupt.push").writeBytes(byteArrayOf(1, 2, 3))

            assertFailsWith<CorruptPushMessageException> {
                store.get("corrupt")
            }
            assertTrue(store.complete("corrupt"))
            assertTrue(store.ids().isEmpty())
        } finally {
            directory.deleteRecursively()
        }
    }

    @Test
    fun deliveredMarkerSuppressesStalePayload() {
        val directory = createTempDirectory("push-store").toFile()
        try {
            val store = PushMessageStore(directory)
            store.persist("scope", byteArrayOf(1), "stale")
            directory.resolve("stale.delivered").writeBytes(byteArrayOf(1))

            assertTrue(store.ids().isEmpty())
            assertNull(store.get("stale"))
        } finally {
            directory.deleteRecursively()
        }
    }

    @Test
    fun expiredDeliveredMarkerAllowsMessageIdReuse() {
        val directory = createTempDirectory("push-store").toFile()
        try {
            val store = PushMessageStore(directory)
            store.persist("old", byteArrayOf(1), "reused")
            assertTrue(store.complete("reused"))
            assertTrue(directory.resolve("reused.delivered").setLastModified(0))

            store.persist("new", byteArrayOf(2), "reused")

            assertEquals(listOf("reused"), store.ids())
            assertEquals("new", store.get("reused")?.scope)
        } finally {
            directory.deleteRecursively()
        }
    }
}
