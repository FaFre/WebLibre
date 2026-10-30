/*
 * Copyright (c) 2024-2026 Fabian Freund.
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
package eu.weblibre.flutter_mozilla_components

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import eu.weblibre.flutter_mozilla_components.startup.StartupPaths
import java.io.File
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import org.junit.After
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

private const val PROFILE_A = "0199a0b1-1111-7111-8111-111111111111"
private const val PROFILE_B = "0199a0b1-2222-7222-8222-222222222222"

// One of the databases Android 8.0 kept global, and one it never moves.
private const val DOWNLOADS = "mozac_downloads_database"
private const val OTHER = "some_other_database"

/**
 * Room databases opened through a profile's context, which on Android 8.0 used
 * to land in the app's global folder for every profile.
 */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [26, 28])
class ProfileContextDatabaseTest {
    private val application: Context = RuntimeEnvironment.getApplication()
    private val opened = mutableListOf<SQLiteOpenHelper>()

    @After
    fun tearDown() {
        opened.forEach { it.close() }
        application.databaseList().forEach { application.deleteDatabase(it) }
        File(application.filesDir, PwaConstants.PROFILES_DIR_NAME).deleteRecursively()
    }

    private fun profile(id: String) =
        ProfileContext(application, StartupPaths.relativeProfilePath(id))

    /** Opens [name] the way Room does on every API level. */
    private fun open(context: Context, name: String): SQLiteDatabase {
        val helper = object : SQLiteOpenHelper(context, name, null, 1) {
            override fun onCreate(db: SQLiteDatabase) {
                db.execSQL("CREATE TABLE rows (value TEXT)")
            }

            override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) = Unit
        }
        opened += helper
        return helper.writableDatabase
    }

    private fun SQLiteDatabase.values(): List<String> =
        rawQuery("SELECT value FROM rows", null).use { cursor ->
            buildList { while (cursor.moveToNext()) add(cursor.getString(0)) }
        }

    private fun closeAll() {
        opened.forEach { it.close() }
        opened.clear()
    }

    @Test
    fun `a profile's database opens in that profile`() {
        val path = open(profile(PROFILE_A), DOWNLOADS).path

        assertEquals(profile(PROFILE_A).getDatabasePath(DOWNLOADS).path, path)
        assertFalse(application.getDatabasePath(DOWNLOADS).exists())
    }

    @Test
    fun `two profiles keep their own rows`() {
        open(profile(PROFILE_A), OTHER).execSQL("INSERT INTO rows VALUES ('a')")

        assertEquals(emptyList(), open(profile(PROFILE_B), OTHER).values())
    }

    @Test
    fun `deleting a profile's database leaves the global one`() {
        open(application, OTHER)
        open(profile(PROFILE_A), OTHER)
        closeAll()

        assertTrue(profile(PROFILE_A).deleteDatabase(OTHER))

        assertFalse(profile(PROFILE_A).getDatabasePath(OTHER).exists())
        assertTrue(application.getDatabasePath(OTHER).exists())
    }

    @Test
    fun `the database list is the profile's`() {
        open(application, OTHER)
        open(profile(PROFILE_A), DOWNLOADS)

        assertTrue(DOWNLOADS in profile(PROFILE_A).databaseList())
        assertFalse(OTHER in profile(PROFILE_A).databaseList())
    }

    @Test
    @Config(sdk = [26])
    fun `on Android 8_0 the first profile opened takes over the shared file`() {
        open(application, DOWNLOADS).execSQL("INSERT INTO rows VALUES ('shared')")
        closeAll()

        assertEquals(listOf("shared"), open(profile(PROFILE_A), DOWNLOADS).values())
        assertFalse(application.getDatabasePath(DOWNLOADS).exists())

        assertEquals(emptyList(), open(profile(PROFILE_B), DOWNLOADS).values())
    }

    @Test
    @Config(sdk = [26])
    fun `on Android 8_0 other global databases stay where they are`() {
        open(application, OTHER).execSQL("INSERT INTO rows VALUES ('global')")
        closeAll()

        assertEquals(emptyList(), open(profile(PROFILE_A), OTHER).values())
        assertTrue(application.getDatabasePath(OTHER).exists())
    }

    @Test
    @Config(sdk = [28])
    fun `a device updated past Android 8_0 still takes over the shared file`() {
        // Left by 8.0; later versions never put these there.
        open(application, DOWNLOADS).execSQL("INSERT INTO rows VALUES ('shared')")
        closeAll()

        assertEquals(listOf("shared"), open(profile(PROFILE_A), DOWNLOADS).values())
        assertFalse(application.getDatabasePath(DOWNLOADS).exists())
    }

    @Test
    fun `deleting a profile's database leaves the shared file for the profile that opens it`() {
        open(application, DOWNLOADS).execSQL("INSERT INTO rows VALUES ('shared')")
        closeAll()

        profile(PROFILE_A).deleteDatabase(DOWNLOADS)

        assertTrue(application.getDatabasePath(DOWNLOADS).exists())
        assertEquals(listOf("shared"), open(profile(PROFILE_B), DOWNLOADS).values())
    }
}
