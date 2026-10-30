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

import android.app.Application
import android.content.Context
import android.database.DatabaseErrorHandler
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import eu.weblibre.flutter_mozilla_components.startup.StartupArbiter
import eu.weblibre.flutter_mozilla_components.startup.StartupPaths
import java.io.File
import java.nio.file.Files
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue
import org.json.JSONObject
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

private const val PROFILE_A = "0199a0b1-1111-7111-8111-111111111111"
private const val PROFILE_B = "0199a0b1-2222-7222-8222-222222222222"
private const val UPDATE_ATTEMPTS = "addons_updater_attempts_database"

/** What `MyApplication` does with databases; that class lives in the app module. */
class DatabaseRoutingApplication : Application() {
    override fun getDatabasePath(name: String): File =
        ActiveProfile.profileDatabasePath(this, name) ?: super.getDatabasePath(name)

    override fun openOrCreateDatabase(
        name: String,
        mode: Int,
        factory: SQLiteDatabase.CursorFactory?,
    ): SQLiteDatabase =
        ActiveProfile.openProfileDatabase(this, name, mode, factory, null)
            ?: super.openOrCreateDatabase(name, mode, factory)

    override fun openOrCreateDatabase(
        name: String,
        mode: Int,
        factory: SQLiteDatabase.CursorFactory?,
        errorHandler: DatabaseErrorHandler?,
    ): SQLiteDatabase =
        ActiveProfile.openProfileDatabase(this, name, mode, factory, errorHandler)
            ?: super.openOrCreateDatabase(name, mode, factory, errorHandler)
}

/**
 * Databases AC's workers open through the application context, which
 * `MyApplication` routes here. Add-on update results are keyed by add-on id
 * alone, so one shared file shows a profile another profile's results for the
 * same add-on.
 *
 * Android 8.0 matters on its own: its `SQLiteOpenHelper` opens through
 * `openOrCreateDatabase` rather than `getDatabasePath`.
 */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [26, 28], application = DatabaseRoutingApplication::class)
class ProfileDatabasePathTest {
    private val application: Context = RuntimeEnvironment.getApplication()
    private val tempDirs = mutableListOf<File>()

    @Before
    fun setUp() {
        reset()
    }

    @After
    fun tearDown() {
        reset()
        tempDirs.forEach { it.deleteRecursively() }
    }

    private fun reset() {
        StartupArbiter.resetForTest()
        ActiveProfile.resetForTest()
    }

    /** Commits [profileId] as this process's profile, as a headless start does. */
    private fun commitProfile(profileId: String) {
        reset()

        val filesDir = Files.createTempDirectory("weblibre_profile_databases").toFile()
        tempDirs += filesDir
        val paths = StartupPaths(filesDir)
        val profileDir = File(paths.profilesDir, "profile-$profileId")
        profileDir.mkdirs()
        File(profileDir, StartupPaths.PROFILE_METADATA_FILE_NAME).writeText(
            JSONObject().put("id", profileId).put("name", "Profile").toString(),
        )

        StartupArbiter.initialize(paths, { })
        StartupArbiter.tryCommitExternal(null, trusted = false)
    }

    private fun profileFile(profileId: String, name: String) =
        File(application.filesDir, "${StartupPaths.relativeProfilePath(profileId)}/databases/$name")

    @Test
    fun `update results live in the committed profile`() {
        commitProfile(PROFILE_A)

        assertEquals(
            profileFile(PROFILE_A, UPDATE_ATTEMPTS),
            ActiveProfile.profileDatabasePath(application, UPDATE_ATTEMPTS),
        )
    }

    @Test
    fun `update results are opened in the committed profile`() {
        commitProfile(PROFILE_A)
        // What Room ends up in, and the class that differs on Android 8.0.
        val helper = object : SQLiteOpenHelper(application, UPDATE_ATTEMPTS, null, 1) {
            override fun onCreate(db: SQLiteDatabase) = Unit

            override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) = Unit
        }

        val opened = try {
            helper.writableDatabase.path
        } finally {
            helper.close()
        }

        assertEquals(profileFile(PROFILE_A, UPDATE_ATTEMPTS).path, opened)
    }

    @Test
    fun `each profile gets its own file`() {
        commitProfile(PROFILE_A)
        val first = ActiveProfile.profileDatabasePath(application, UPDATE_ATTEMPTS)
        commitProfile(PROFILE_B)
        val second = ActiveProfile.profileDatabasePath(application, UPDATE_ATTEMPTS)

        assertNotEquals(first, second)
    }

    @Test
    fun `nothing is routed before commitment`() {
        assertNull(ActiveProfile.profileDatabasePath(application, UPDATE_ATTEMPTS))
    }

    @Test
    fun `other databases are left alone`() {
        commitProfile(PROFILE_A)

        assertNull(ActiveProfile.profileDatabasePath(application, "androidx.work.workdb"))
    }

    @Test
    fun `update results kept from before the routing are deleted`() {
        val unrouted = (application as DatabaseRoutingApplication).baseContext
        unrouted.openOrCreateDatabase(UPDATE_ATTEMPTS, Context.MODE_PRIVATE, null).close()
        commitProfile(PROFILE_A)
        val routed = ActiveProfile.openProfileDatabase(
            application,
            UPDATE_ATTEMPTS,
            Context.MODE_PRIVATE,
            null,
            null,
        )
        routed?.close()

        ActiveProfile.deleteUnscopedDatabases(unrouted)

        assertFalse(unrouted.getDatabasePath(UPDATE_ATTEMPTS).exists())
        assertTrue(profileFile(PROFILE_A, UPDATE_ATTEMPTS).exists())
    }
}
