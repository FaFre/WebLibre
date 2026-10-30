/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.addons

import android.content.Context
import androidx.core.app.NotificationManagerCompat
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequest
import androidx.work.Operation
import androidx.work.PeriodicWorkRequest
import androidx.work.WorkManager
import com.google.common.util.concurrent.ListenableFuture
import eu.weblibre.flutter_mozilla_components.ProfileContext
import eu.weblibre.flutter_mozilla_components.ProfileWorkTags
import eu.weblibre.flutter_mozilla_components.pigeons.AddonUpdateStatus
import eu.weblibre.flutter_mozilla_components.startup.StartupPaths
import java.util.concurrent.ExecutionException
import java.util.concurrent.Executor
import java.util.concurrent.TimeUnit
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking
import mozilla.components.concept.engine.webextension.WebExtension
import mozilla.components.feature.addons.update.AddonUpdater
import mozilla.components.support.base.android.NotificationsDelegate
import mozilla.components.support.base.worker.Frequency
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.ArgumentMatchers.anyString
import org.mockito.Mockito.mock
import org.mockito.Mockito.mockingDetails
import org.mockito.Mockito.`when`
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

private const val PROFILE_A = "0199a0b1-1111-7111-8111-111111111111"
private const val PROFILE_B = "0199a0b1-2222-7222-8222-222222222222"
private const val ADDON = "addon@example.org"
private val FREQUENCY = Frequency(12, TimeUnit.HOURS)

/** What [ProfileAddonUpdater] leaves to AC's updater. */
private class FakeUpdater : AddonUpdater {
    val unregistered = mutableListOf<String>()

    override fun registerForFutureUpdates(addonId: String) = error("AC's jobs are not scheduled any more")

    override fun unregisterForFutureUpdates(addonId: String) {
        unregistered += addonId
    }

    override fun update(addonId: String) = error("AC's update worker is not queued any more")

    override fun onUpdatePermissionRequest(
        extension: WebExtension,
        newPermissions: List<String>,
        newOrigins: List<String>,
        newDataCollectionPermissions: List<String>,
        onPermissionsGranted: (Boolean) -> Unit,
    ) = error("Answered by ProfileAddonUpdater")
}

/** A WorkManager operation that already ended, failing with [failure] if given. */
private fun finishedOperation(failure: Throwable? = null): Operation = object : Operation {
    override fun getState(): LiveData<Operation.State> =
        MutableLiveData(failure?.let(Operation.State::FAILURE) ?: Operation.SUCCESS)

    override fun getResult(): ListenableFuture<Operation.State.SUCCESS> =
        object : ListenableFuture<Operation.State.SUCCESS> {
            override fun get(): Operation.State.SUCCESS = failure?.let { throw ExecutionException(it) } ?: Operation.SUCCESS
            override fun get(timeout: Long, unit: TimeUnit) = get()
            override fun isDone() = true
            override fun isCancelled() = false
            override fun cancel(mayInterruptIfRunning: Boolean) = false
            override fun addListener(listener: Runnable, executor: Executor) = executor.execute(listener)
        }
}

@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class ProfileAddonUpdaterTest {
    private val application: Context = RuntimeEnvironment.getApplication()
    private val workManager = mock(WorkManager::class.java).also {
        `when`(it.cancelAllWorkByTag(anyString())).thenReturn(finishedOperation())
    }
    private val ac = FakeUpdater()

    /** Add-ons the engine was asked to update. */
    private val updated = mutableListOf<String>()

    /** How the engine's next update ends. */
    private var engineUpdate: (addonId: String) -> AddonUpdater.Status = {
        AddonUpdater.Status.SuccessfullyUpdated
    }

    private fun profile(id: String) = ProfileContext(application, StartupPaths.relativeProfilePath(id))

    private fun updater(
        profileId: String = PROFILE_A,
        lastCheckedAt: (String) -> Long? = { null },
    ) = ProfileAddonUpdater(
        profileContext = profile(profileId),
        updater = ac,
        updateAddon = { addonId, onFinish ->
            updated += addonId
            onFinish(engineUpdate(addonId))
        },
        notificationsDelegate = NotificationsDelegate(NotificationManagerCompat.from(application)),
        frequency = FREQUENCY,
        workManager = { workManager },
        lastCheckedAt = lastCheckedAt,
        scope = CoroutineScope(Dispatchers.Unconfined),
    )

    private fun extension(id: String): WebExtension =
        mock(WebExtension::class.java).also { `when`(it.id).thenReturn(id) }

    // Read off the mock rather than verified with matchers: those hand Kotlin's
    // non-null parameters a null.
    private fun calls(method: String): List<Array<Any?>> =
        mockingDetails(workManager).invocations
            .filter { it.method.name == method }
            .map { it.arguments }

    private fun scheduledChecks(): List<Pair<String, PeriodicWorkRequest>> =
        calls("enqueueUniquePeriodicWork").map { (name, policy, request) ->
            assertEquals(ExistingPeriodicWorkPolicy.KEEP, policy)
            name as String to request as PeriodicWorkRequest
        }

    private fun immediateChecks(): List<Pair<String, OneTimeWorkRequest>> =
        calls("enqueueUniqueWork").map { (name, policy, request) ->
            assertEquals(ExistingWorkPolicy.KEEP, policy)
            name as String to request as OneTimeWorkRequest
        }

    @Test
    fun `scheduled checks carry their profile`() {
        updater(PROFILE_A).registerForFutureUpdates(ADDON)
        updater(PROFILE_B).registerForFutureUpdates(ADDON)

        val (first, second) = scheduledChecks()
        assertNotEquals(first.first, second.first)
        assertTrue(ProfileWorkTags.forProfile(PROFILE_A) in first.second.tags)
        assertTrue(ProfileWorkTags.forProfile(PROFILE_B) in second.second.tags)
    }

    @Test
    fun `an update runs as the profile's own job, never as AC's`() = runBlocking {
        val updater = updater()

        updater.update(ADDON)
        val (name, request) = immediateChecks().single()
        assertEquals(AddonUpdateCheckWorker.immediateWorkName(StartupPaths.relativeProfilePath(PROFILE_A), ADDON), name)
        assertTrue(ProfileWorkTags.forProfile(PROFILE_A) in request.tags)
        assertEquals(emptyList(), updated)

        // Asked for, so it runs with automatic updates off as well. FakeUpdater
        // fails the test if this queues AC's worker.
        updater.updateNow(ADDON, automatic = false)
        assertEquals(listOf(ADDON), updated)
        assertEquals(
            AddonUpdateStatus.SUCCESSFULLY_UPDATED,
            AddonUpdateAttempts.get(profile(PROFILE_A), ADDON)?.status,
        )
    }

    @Test
    fun `an update stopped for new permissions is recorded as that`() = runBlocking {
        val updater = updater()
        engineUpdate = { addonId ->
            updater.onUpdatePermissionRequest(extension(addonId), listOf("tabs"), emptyList(), emptyList()) {}
            AddonUpdater.Status.Error(addonId, IllegalStateException("cancelled"))
        }

        updater.updateNow(ADDON, automatic = false)

        assertEquals(
            AddonUpdateStatus.NEEDS_PERMISSIONS,
            AddonUpdateAttempts.get(profile(PROFILE_A), ADDON)?.status,
        )
    }

    @Test
    fun `a failed update is a failure while an earlier request still waits`() = runBlocking {
        val context = profile(PROFILE_A)
        AddonUpdatePermissionRequests.record(
            context,
            ADDON,
            listOf("tabs"),
            emptyList(),
            installedVersion = "1.0",
            now = System.currentTimeMillis() - TimeUnit.HOURS.toMillis(1),
        )
        // Offline, say.
        engineUpdate = { addonId -> AddonUpdater.Status.Error(addonId, IllegalStateException("offline")) }

        updater().updateNow(ADDON, automatic = false)

        assertEquals(AddonUpdateStatus.ERROR, AddonUpdateAttempts.get(context, ADDON)?.status)
    }

    @Test
    fun `unregistering cancels the profile's checks and AC's`() {
        val updater = updater()

        updater.unregisterForFutureUpdates(ADDON)

        val path = StartupPaths.relativeProfilePath(PROFILE_A)
        assertEquals(
            listOf(
                AddonUpdateCheckWorker.periodicWorkName(path, ADDON),
                AddonUpdateCheckWorker.catchUpWorkName(path, ADDON),
            ),
            calls("cancelUniqueWork").map { it.single() },
        )
        assertEquals(listOf(ADDON), ac.unregistered)
    }

    @Test
    fun `turning automatic updates off cancels a queued catch-up but not an update asked for`() {
        val path = StartupPaths.relativeProfilePath(PROFILE_A)
        val updater = updater()
        // Started offline: the catch-up check waits for the connection.
        updater.registerForFutureUpdates(listOf(extension(ADDON)))
        updater.update(ADDON)
        assertEquals(
            listOf(
                AddonUpdateCheckWorker.catchUpWorkName(path, ADDON),
                AddonUpdateCheckWorker.immediateWorkName(path, ADDON),
            ),
            immediateChecks().map { it.first },
        )

        updater.unregisterForFutureUpdates(ADDON)

        val cancelled = calls("cancelUniqueWork").map { it.single() }
        assertTrue(AddonUpdateCheckWorker.catchUpWorkName(path, ADDON) in cancelled)
        assertFalse(AddonUpdateCheckWorker.immediateWorkName(path, ADDON) in cancelled)
    }

    @Test
    fun `an automatic check already running once automatic updates are off does not update`() = runBlocking {
        val updater = updater()
        updater.registerForFutureUpdates(ADDON)
        updater.unregisterForFutureUpdates(ADDON)

        updater.updateNow(ADDON, automatic = true)

        assertEquals(emptyList(), updated)
        assertNull(AddonUpdateAttempts.get(profile(PROFILE_A), ADDON))
    }

    @Test
    fun `a catch-up found due after automatic updates were turned off is not queued`() {
        lateinit var updater: ProfileAddonUpdater
        updater = updater(
            lastCheckedAt = { addonId ->
                // Turned off while the last check's time was being read.
                updater.unregisterForFutureUpdates(addonId)
                null
            },
        )

        updater.registerForFutureUpdates(listOf(extension(ADDON)))

        assertEquals(emptyList(), immediateChecks())
    }

    @Test
    fun `add-ons not checked for a while are checked once extensions load`() {
        val now = System.currentTimeMillis()
        val lastChecked = mapOf(
            "fresh@example.org" to now - TimeUnit.HOURS.toMillis(1),
            "stale@example.org" to now - TimeUnit.HOURS.toMillis(13),
        )

        updater(lastCheckedAt = lastChecked::get).registerForFutureUpdates(
            listOf("fresh@example.org", "stale@example.org", "never@example.org").map(::extension),
        )

        assertEquals(3, scheduledChecks().size)
        val checkedNow = immediateChecks().map { it.first }
        assertEquals(2, checkedNow.size)
        assertTrue(checkedNow.none { "fresh@example.org" in it })
    }

    @Test
    fun `AC's own jobs are cancelled the first time extensions load`() {
        updater().onExtensionsLoaded(emptyList())
        updater(PROFILE_B).onExtensionsLoaded(emptyList())

        assertEquals(
            listOf(AddonUpdateCheckWorker.LEGACY_PERIODIC_TAG, AddonUpdateCheckWorker.LEGACY_IMMEDIATE_TAG),
            calls("cancelAllWorkByTag").map { it.single() },
        )
    }

    @Test
    fun `AC's jobs are cancelled again while WorkManager has not confirmed it`() {
        `when`(workManager.cancelAllWorkByTag(AddonUpdateCheckWorker.LEGACY_IMMEDIATE_TAG))
            .thenReturn(finishedOperation(IllegalStateException("database locked")))
        updater().onExtensionsLoaded(emptyList())

        `when`(workManager.cancelAllWorkByTag(AddonUpdateCheckWorker.LEGACY_IMMEDIATE_TAG))
            .thenReturn(finishedOperation())
        updater().onExtensionsLoaded(emptyList())
        updater().onExtensionsLoaded(emptyList())

        val legacy = listOf(AddonUpdateCheckWorker.LEGACY_PERIODIC_TAG, AddonUpdateCheckWorker.LEGACY_IMMEDIATE_TAG)
        assertEquals(legacy + legacy, calls("cancelAllWorkByTag").map { it.single() })
    }

    @Test
    fun `a failed cleanup still applies accepted updates`() {
        `when`(workManager.cancelAllWorkByTag(anyString()))
            .thenReturn(finishedOperation(IllegalStateException("database locked")))
        AddonUpdateGrants.grant(profile(PROFILE_A), ADDON, listOf("tabs"), emptyList())

        updater().onExtensionsLoaded(listOf(ADDON))

        assertEquals(1, immediateChecks().size)
    }

    @Test
    fun `asking for new permissions keeps the request for the add-on's page`() {
        val updater = updater()
        var granted: Boolean? = null

        updater.onUpdatePermissionRequest(extension(ADDON), listOf("tabs"), emptyList(), emptyList()) {
            granted = it
        }

        assertEquals(false, granted)
        assertEquals(
            listOf("tabs"),
            AddonUpdatePermissionRequests.get(profile(PROFILE_A), ADDON, installedVersion = null)?.permissions,
        )

        AddonUpdateGrants.grant(profile(PROFILE_A), ADDON, listOf("tabs"), emptyList())
        updater.onUpdatePermissionRequest(extension(ADDON), listOf("tabs"), emptyList(), emptyList()) {
            granted = it
        }

        assertEquals(true, granted)
        assertNull(AddonUpdatePermissionRequests.get(profile(PROFILE_A), ADDON, installedVersion = null))
    }

    @Test
    fun `a grant the update no longer asks for is dropped`() {
        val context = profile(PROFILE_A)
        val updater = updater()
        // Accepted for one version; the next check finds a newer one asking more.
        AddonUpdateGrants.grant(context, ADDON, listOf("tabs"), emptyList())

        var granted: Boolean? = null
        updater.onUpdatePermissionRequest(extension(ADDON), listOf("tabs", "history"), emptyList(), emptyList()) {
            granted = it
        }
        assertEquals(false, granted)
        assertEquals(emptySet(), AddonUpdateGrants.pendingAddonIds(context))

        // "Not now" stays an answer: the next start does not ask again.
        val request = AddonUpdatePermissionRequests.get(context, ADDON, installedVersion = null)!!
        assertTrue(AddonUpdatePermissionRequests.decline(context, ADDON, request.id))
        updater.onExtensionsLoaded(listOf(ADDON))
        assertEquals(emptyList(), immediateChecks())
    }

    @Test
    fun `a request asked for with repeated permissions is the one the notification answers`() {
        val context = profile(PROFILE_A)
        val posted = AddonUpdatePermissionRequests.Request(listOf("tabs", "tabs"), emptyList()).id

        updater().onUpdatePermissionRequest(extension(ADDON), listOf("tabs"), listOf("tabs"), emptyList()) {}

        assertEquals(posted, AddonUpdatePermissionRequests.get(context, ADDON, installedVersion = null)?.id)
        assertTrue(AddonUpdatePermissionRequests.accept(context, ADDON, posted))
    }

    @Test
    fun `a request is dropped once another version is installed`() {
        val context = profile(PROFILE_A)
        AddonUpdatePermissionRequests.record(context, ADDON, listOf("tabs"), emptyList(), installedVersion = "1.0")

        // Not known yet: kept.
        assertEquals(listOf("tabs"), AddonUpdatePermissionRequests.get(context, ADDON, installedVersion = null)?.permissions)
        assertEquals(listOf("tabs"), AddonUpdatePermissionRequests.get(context, ADDON, installedVersion = "1.0")?.permissions)

        assertNull(AddonUpdatePermissionRequests.get(context, ADDON, installedVersion = "2.0"))
        assertNull(AddonUpdatePermissionRequests.get(context, ADDON, installedVersion = "1.0"))
    }

    @Test
    fun `requests of removed add-ons are dropped once extensions load`() {
        val context = profile(PROFILE_A)
        AddonUpdatePermissionRequests.record(context, ADDON, listOf("tabs"), emptyList(), installedVersion = "1.0")
        AddonUpdatePermissionRequests.record(context, "kept@example.org", listOf("tabs"), emptyList(), "1.0")

        updater().onExtensionsLoaded(listOf("kept@example.org"))

        assertEquals(setOf("kept@example.org"), AddonUpdatePermissionRequests.pendingAddonIds(context))
        // A request is not an answer: nothing is updated for it.
        assertEquals(emptyList(), immediateChecks())
    }

    @Test
    fun `accepting grants the request that was shown, and only that`() {
        val context = profile(PROFILE_A)
        AddonUpdatePermissionRequests.record(context, ADDON, listOf("tabs"), emptyList(), installedVersion = "1.0")
        val shown = AddonUpdatePermissionRequests.get(context, ADDON, installedVersion = "1.0")!!.id

        assertTrue(AddonUpdatePermissionRequests.accept(context, ADDON, shown))

        assertNull(AddonUpdatePermissionRequests.get(context, ADDON, installedVersion = null))
        assertFalse(AddonUpdateGrants.consume(context, ADDON, listOf("tabs", "history"), emptyList()))
        assertTrue(AddonUpdateGrants.consume(context, ADDON, listOf("tabs"), emptyList()))
    }

    @Test
    fun `a request replaced after it was shown is not accepted`() {
        val context = profile(PROFILE_A)
        AddonUpdatePermissionRequests.record(context, ADDON, listOf("tabs"), emptyList(), installedVersion = "1.0")
        val shown = AddonUpdatePermissionRequests.get(context, ADDON, installedVersion = "1.0")!!.id
        // A background check asks for more while the page still shows the first.
        AddonUpdatePermissionRequests.record(
            context,
            ADDON,
            listOf("tabs", "history"),
            listOf("locationInfo"),
            installedVersion = "1.0",
        )

        assertFalse(AddonUpdatePermissionRequests.accept(context, ADDON, shown))

        assertFalse(AddonUpdateGrants.consume(context, ADDON, listOf("tabs"), emptyList()))
        assertEquals(
            listOf("history", "tabs"),
            AddonUpdatePermissionRequests.get(context, ADDON, installedVersion = null)?.permissions,
        )
    }

    @Test
    fun `asking again for the same permissions keeps the request's id`() {
        val context = profile(PROFILE_A)
        AddonUpdatePermissionRequests.record(context, ADDON, listOf("tabs", "history"), emptyList(), "1.0")
        val first = AddonUpdatePermissionRequests.get(context, ADDON, installedVersion = null)!!.id

        AddonUpdatePermissionRequests.record(context, ADDON, listOf("history", "tabs"), emptyList(), "1.0")
        assertEquals(first, AddonUpdatePermissionRequests.get(context, ADDON, installedVersion = null)!!.id)

        AddonUpdatePermissionRequests.record(context, ADDON, listOf("tabs"), listOf("history"), "1.0")
        assertNotEquals(first, AddonUpdatePermissionRequests.get(context, ADDON, installedVersion = null)!!.id)
    }
}
