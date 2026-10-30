/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import android.content.Context
import androidx.core.content.edit
import eu.weblibre.flutter_mozilla_components.ProfileContext
import eu.weblibre.flutter_mozilla_components.PwaConstants
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

private const val PROFILE_ID = "0199a0b1-1111-7111-8111-111111111111"
private const val OTHER_PROFILE_ID = "0199a0b1-2222-7222-8222-222222222222"

/**
 * Launch tokens written into a profile's own copy of the PWA token index, where
 * neither `LaunchTrust` nor profile backups look, moving to the global index.
 */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class PwaLaunchTokenMigrationTest {
    private val application: Context = RuntimeEnvironment.getApplication()
    private val profile = ProfileContext(application, "weblibre_profiles/profile-$PROFILE_ID")

    private val global =
        application.getSharedPreferences(PwaConstants.PROFILE_MAPPING_PREFS, Context.MODE_PRIVATE)
    private val legacy =
        profile.getSharedPreferences(PwaConstants.PROFILE_MAPPING_PREFS, Context.MODE_PRIVATE)

    private fun key(url: String, profileId: String = PROFILE_ID) =
        "${PwaConstants.PROFILE_MAPPING_TOKEN_PREFIX}$url::$profileId::"

    @Test
    fun `tokens move to the global index`() {
        legacy.edit { putString(key("https://a.test/"), "token-a") }

        GeckoPwaApiImpl.migrateProfileScopedLaunchTokens(profile, global)

        assertEquals("token-a", global.getString(key("https://a.test/"), null))
        assertTrue(legacy.all.isEmpty())
    }

    @Test
    fun `the profile copy wins over an older global token`() {
        global.edit { putString(key("https://a.test/"), "old") }
        legacy.edit { putString(key("https://a.test/"), "current") }

        GeckoPwaApiImpl.migrateProfileScopedLaunchTokens(profile, global)

        assertEquals("current", global.getString(key("https://a.test/"), null))
    }

    @Test
    fun `other global tokens are left alone`() {
        global.edit { putString(key("https://other.test/"), "other") }
        legacy.edit { putString(key("https://a.test/"), "token-a") }

        GeckoPwaApiImpl.migrateProfileScopedLaunchTokens(profile, global)

        assertEquals("other", global.getString(key("https://other.test/"), null))
    }

    @Test
    fun `nothing to move leaves the global index untouched`() {
        global.edit { putString(key("https://a.test/"), "token-a") }

        GeckoPwaApiImpl.migrateProfileScopedLaunchTokens(profile, global)

        assertEquals(mapOf(key("https://a.test/") to "token-a"), global.all)
    }

    @Test
    fun `tokens naming another profile cannot overwrite its global tokens`() {
        val theirs = key("https://a.test/", OTHER_PROFILE_ID)
        global.edit { putString(theirs, "trusted") }
        // As a restored snapshot of this profile's file could have it.
        legacy.edit {
            putString(theirs, "forged")
            putString(key("https://b.test/", OTHER_PROFILE_ID), "forged")
            putString("token_https://c.test/", "forged")
            putString(key("https://own.test/"), "own")
        }

        GeckoPwaApiImpl.migrateProfileScopedLaunchTokens(profile, global)

        assertEquals(
            mapOf(theirs to "trusted", key("https://own.test/") to "own"),
            global.all,
        )
        assertTrue(legacy.all.isEmpty())
    }
}
