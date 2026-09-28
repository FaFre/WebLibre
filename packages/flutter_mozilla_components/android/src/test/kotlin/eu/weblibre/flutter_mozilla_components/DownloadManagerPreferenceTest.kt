/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import android.content.Context
import android.content.pm.ResolveInfo
import androidx.fragment.app.FragmentActivity
import eu.weblibre.flutter_mozilla_components.feature.DownloadAppChooser
import eu.weblibre.flutter_mozilla_components.feature.DownloadAppChooserDialog
import eu.weblibre.flutter_mozilla_components.maintenance.ProfilePreferencesParticipant
import eu.weblibre.flutter_mozilla_components.startup.StartupArbiter
import eu.weblibre.flutter_mozilla_components.startup.StartupPaths
import java.io.File
import java.nio.file.Files
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertSame
import kotlin.test.assertTrue
import mozilla.components.feature.downloads.NegativeActionCallback
import mozilla.components.feature.downloads.ThirdPartyDownloaderAppChosenCallback
import mozilla.components.feature.downloads.ThirdPartyDownloaderApps
import mozilla.components.feature.downloads.ui.DownloaderApp
import org.json.JSONObject
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

private const val PROFILE_A = "0199a0b1-1111-7111-8111-111111111111"
private const val PROFILE_B = "0199a0b1-2222-7222-8222-222222222222"

/**
 * The remembered download manager: stored per profile, and only ever used for a
 * download it is offered for.
 */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class DownloadManagerPreferenceTest {
    private val context: Context = RuntimeEnvironment.getApplication()
    private val tempDirs = mutableListOf<File>()

    private val adm = app("com.dv.adm", "com.dv.adm.AEditor")
    private val admOtherActivity = app("com.dv.adm", "com.dv.adm.ShareActivity")
    private val oneDm = app("idm.internet.download.manager", "idm.internet.download.manager.Downloader")
    private val thisApp get() = app(context.packageName, "eu.weblibre.IntentReceiverActivity")

    @Before
    fun setUp() {
        StartupArbiter.resetForTest()
    }

    @After
    fun tearDown() {
        StartupArbiter.resetForTest()
        tempDirs.forEach { it.deleteRecursively() }
    }

    /** Commits [profileId] as this process's profile, as a headless start does. */
    private fun commitProfile(profileId: String) {
        StartupArbiter.resetForTest()

        val filesDir = Files.createTempDirectory("weblibre_download_manager").toFile()
        tempDirs += filesDir
        val paths = StartupPaths(filesDir)
        val profileDir = File(paths.profilesDir, "profile-$profileId")
        profileDir.mkdirs()
        File(profileDir, StartupPaths.PROFILE_METADATA_FILE_NAME).writeText(
            JSONObject().put("id", profileId).put("name", "Profile").toString(),
        )

        StartupArbiter.initialize(paths, { })
        StartupArbiter.tryCommitExternal(null, trusted = false)
        assertEquals("profile-$profileId", ActiveProfile.prefix)
    }

    private fun app(
        packageName: String,
        activityName: String,
        url: String = "https://example.com/file.zip",
    ) = DownloaderApp(
        name = packageName,
        resolver = ResolveInfo(),
        packageName = packageName,
        activityName = activityName,
        url = url,
        contentType = "application/zip",
    )

    // --- persistence ------------------------------------------------------------

    @Test
    fun `nothing is remembered by default`() {
        commitProfile(PROFILE_A)

        assertNull(DownloadManagerPreference.read(context))
    }

    @Test
    fun `a remembered app reads back by package and activity`() {
        commitProfile(PROFILE_A)

        DownloadManagerPreference.write(context, DownloadManagerPreference.Choice.of(adm))

        assertEquals(
            DownloadManagerPreference.Choice("com.dv.adm", "com.dv.adm.AEditor"),
            DownloadManagerPreference.read(context),
        )
    }

    @Test
    fun `clearing goes back to asking`() {
        commitProfile(PROFILE_A)
        DownloadManagerPreference.write(context, DownloadManagerPreference.Choice.of(adm))

        DownloadManagerPreference.clear(context)

        assertNull(DownloadManagerPreference.read(context))
    }

    @Test
    fun `each profile remembers its own app`() {
        commitProfile(PROFILE_A)
        DownloadManagerPreference.write(context, DownloadManagerPreference.Choice.of(adm))

        commitProfile(PROFILE_B)
        assertNull(DownloadManagerPreference.read(context))
        DownloadManagerPreference.write(context, DownloadManagerPreference.Choice.of(oneDm))

        commitProfile(PROFILE_A)
        assertEquals(DownloadManagerPreference.Choice.of(adm), DownloadManagerPreference.read(context))
    }

    @Test
    fun `without a committed profile nothing is written or read`() {
        DownloadManagerPreference.write(context, DownloadManagerPreference.Choice.of(adm))

        assertNull(DownloadManagerPreference.read(context))
        assertTrue(
            ProfilePrefs.of(context).all.keys.none { it.startsWith("browser.weblibre.preferredDownloadManager") },
        )
    }

    @Test
    fun `the choice travels with the profile through backup and restore`() {
        commitProfile(PROFILE_A)
        DownloadManagerPreference.write(context, DownloadManagerPreference.Choice.of(adm))

        val snapshot = ProfilePreferencesParticipant(context)
            .capture(ProfilePreferencesParticipant.prefixFor(PROFILE_A))

        assertTrue(snapshot.defaultKeys.containsKey("browser.weblibre.preferredDownloadManager"))
    }

    // --- resolution against the offered apps --------------------------------------

    @Test
    fun `the remembered app is used when it is offered`() {
        val offered = listOf(oneDm, adm, thisApp)

        assertSame(
            adm,
            DownloadManagerPreference.resolve(DownloadManagerPreference.Choice.of(adm), offered),
        )
    }

    @Test
    fun `another activity of the same app is not the remembered one`() {
        val offered = listOf(admOtherActivity, thisApp)

        assertNull(DownloadManagerPreference.resolve(DownloadManagerPreference.Choice.of(adm), offered))
    }

    @Test
    fun `an app not offered for this download is not used`() {
        // Uninstalled, or unable to take this URL or MIME type: either way it is
        // missing from what DownloadsFeature offers.
        val offered = listOf(oneDm, thisApp)

        assertNull(DownloadManagerPreference.resolve(DownloadManagerPreference.Choice.of(adm), offered))
    }

    @Test
    fun `nothing remembered resolves to nothing`() {
        assertNull(DownloadManagerPreference.resolve(null, listOf(adm, thisApp)))
    }

    // --- forwarding ------------------------------------------------------------------

    @Test
    fun `the external manager switch stays the gate`() {
        val remembered = DownloadManagerPreference.Choice.of(adm)

        assertFalse(DownloadManagerPreference.shouldForwardToThirdParties(context, false, remembered))
        assertFalse(DownloadManagerPreference.shouldForwardToThirdParties(context, false, null))
    }

    @Test
    fun `an external app or no choice forwards to the chooser`() {
        assertTrue(DownloadManagerPreference.shouldForwardToThirdParties(context, true, null))
        assertTrue(
            DownloadManagerPreference.shouldForwardToThirdParties(
                context,
                true,
                DownloadManagerPreference.Choice.of(adm),
            ),
        )
    }

    @Test
    fun `remembering WebLibre takes the first-party path`() {
        // Not forwarding is what reaches WebLibre's own confirmation; selecting
        // WebLibre in the chooser would start the download without one.
        assertFalse(
            DownloadManagerPreference.shouldForwardToThirdParties(
                context,
                true,
                DownloadManagerPreference.Choice.of(thisApp),
            ),
        )
    }

    // --- the chooser delegate ------------------------------------------------------

    @Test
    fun `an offered remembered app is chosen without a dialog`() {
        commitProfile(PROFILE_A)
        DownloadManagerPreference.write(context, DownloadManagerPreference.Choice.of(adm))
        val activity = Robolectric.buildActivity(FragmentActivity::class.java).setup().get()
        val chooser = DownloadAppChooser(context, activity.supportFragmentManager)
        val chosen = mutableListOf<DownloaderApp>()
        var cancelled = 0

        chooser.show(
            ThirdPartyDownloaderApps(listOf(oneDm, adm, thisApp)),
            ThirdPartyDownloaderAppChosenCallback { chosen += it },
            NegativeActionCallback { cancelled++ },
        )

        assertEquals(listOf(adm), chosen)
        assertEquals(0, cancelled)
        assertNull(activity.supportFragmentManager.findFragmentByTag(DownloadAppChooserDialog.FRAGMENT_TAG))
    }

    @Test
    fun `nothing is answered while the host cannot show the chooser`() {
        commitProfile(PROFILE_A)
        val controller = Robolectric.buildActivity(FragmentActivity::class.java).setup()
        controller.pause().stop()
        val fragmentManager = controller.get().supportFragmentManager
        assertTrue(fragmentManager.isStateSaved)
        val chooser = DownloadAppChooser(context, fragmentManager)
        var answers = 0

        chooser.show(
            ThirdPartyDownloaderApps(listOf(oneDm, adm, thisApp)),
            ThirdPartyDownloaderAppChosenCallback { answers++ },
            NegativeActionCallback { answers++ },
        )

        // Left pending on the tab for DownloadsFeature to offer again on restart.
        assertEquals(0, answers)
        assertNull(fragmentManager.findFragmentByTag(DownloadAppChooserDialog.FRAGMENT_TAG))
    }
}
