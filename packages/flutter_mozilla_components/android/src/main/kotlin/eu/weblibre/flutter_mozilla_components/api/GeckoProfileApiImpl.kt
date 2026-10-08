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
package eu.weblibre.flutter_mozilla_components.api

import android.content.Context
import android.os.StatFs
import android.util.Log
import eu.weblibre.flutter_mozilla_components.maintenance.MaintenanceParticipantHandler
import eu.weblibre.flutter_mozilla_components.maintenance.ProfileExternalStorageParticipant
import eu.weblibre.flutter_mozilla_components.maintenance.ProfileJobsParticipant
import eu.weblibre.flutter_mozilla_components.maintenance.PushOwnershipParticipant
import eu.weblibre.flutter_mozilla_components.maintenance.ProfilePreferencesParticipant
import eu.weblibre.flutter_mozilla_components.maintenance.PwaShortcutParticipant
import eu.weblibre.flutter_mozilla_components.pigeons.ParticipantStep
import android.net.Uri
import android.os.ParcelFileDescriptor
import android.system.Os
import android.system.OsConstants
import java.io.File
import java.io.FileNotFoundException
import java.io.FileOutputStream
import java.io.InputStream
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import eu.weblibre.flutter_mozilla_components.lock.AutoLockMode
import eu.weblibre.flutter_mozilla_components.lock.ProfileUnlockRegistry
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoProfileApi
import eu.weblibre.flutter_mozilla_components.pigeons.SharedProfileUnlock
import eu.weblibre.flutter_mozilla_components.pigeons.SharedUnlockMode
import eu.weblibre.flutter_mozilla_components.pigeons.ProfileStartupDirective
import eu.weblibre.flutter_mozilla_components.pigeons.ProfileStartupDirectiveKind
import eu.weblibre.flutter_mozilla_components.pigeons.ProfileStartupOwnerType
import eu.weblibre.flutter_mozilla_components.pigeons.ProfileStartupPromptMode
import eu.weblibre.flutter_mozilla_components.pigeons.StartupIntentRecord
import eu.weblibre.flutter_mozilla_components.startup.BootstrapStage
import eu.weblibre.flutter_mozilla_components.startup.DartAccessOwner
import eu.weblibre.flutter_mozilla_components.startup.DartStartupProgress
import eu.weblibre.flutter_mozilla_components.startup.DartProfileAccess
import eu.weblibre.flutter_mozilla_components.startup.ProfilePromptMode
import eu.weblibre.flutter_mozilla_components.startup.RestartCoordinator
import eu.weblibre.flutter_mozilla_components.startup.StartupArbiter
import eu.weblibre.flutter_mozilla_components.startup.StartupPaths
import eu.weblibre.flutter_mozilla_components.startup.StartupIntentBroker
import eu.weblibre.flutter_mozilla_components.startup.StartupDirectiveKind
import eu.weblibre.flutter_mozilla_components.startup.StartupOwner
import eu.weblibre.flutter_mozilla_components.startup.StartupOwnerType

/**
 * Thin adapter from the arbitration Pigeon API to [StartupArbiter].
 *
 * The arbiter is process-global and outlives every Flutter engine, which is the
 * entire point: a replacement engine in the same process must not be able to
 * re-decide the profile.
 *
 * The one piece of state it does keep is [grantedAccess] — see
 * [onEngineDetached].
 *
 * Registered in `FlutterMozillaComponentsPlugin.onAttachedToEngine`, so it is
 * reachable from the first line of Dart `main()` — before any database is opened
 * and long before Gecko exists.
 */
class GeckoProfileApiImpl(private val applicationContext: Context) : GeckoProfileApi {

    private val TAG = "GeckoProfileApi"

    /** Large enough that an 80 MB archive is not thousands of tiny reads. */
    private val COPY_BUFFER_BYTES = 1 shl 16

    /**
     * Profile-access owners this engine was granted, so they can be released
     * when it goes away.
     *
     * [DartProfileAccess] is process-global and keyed on an id the Dart isolate
     * generates for itself, so a new engine is always a new owner. An engine
     * that dies without releasing therefore locks every future engine out for
     * the life of the *process* — and `MainActivity.onDestroy` destroys the
     * cached engine on any non-finishing destroy, which is an ordinary Android
     * event, not a crash. The result was an app that refused to open until it
     * was force-stopped.
     *
     * One instance of this class exists per engine attachment, so "what this
     * engine holds" is exactly what this set records.
     */
    private val grantedAccess = mutableSetOf<DartAccessOwner>()

    /**
     * Engine ids this instance asked the arbiter to arbitrate for.
     *
     * Same problem as [grantedAccess], one level up: a selection or maintenance
     * lease is keyed on the engine id, so an engine destroyed while holding one
     * leaves the arbiter naming an owner that no longer exists. Every later
     * `beginStartup` from the replacement engine is then answered "owned by
     * someone else" for the life of the process.
     */
    private val startupEngines = mutableSetOf<String>()

    /**
     * What the isolate a hot restart replaced was holding, still held in its
     * name until its replacement asks for it. See [onEngineRestarting].
     */
    private class SupersededLeases {
        val access = mutableSetOf<DartAccessOwner>()
        val engines = mutableSetOf<String>()
    }

    private val superseded = SupersededLeases()

    override fun beginStartup(
        ownerType: ProfileStartupOwnerType,
        engineId: String,
        promptMode: ProfileStartupPromptMode,
    ): ProfileStartupDirective {
        val owner = StartupOwner(
            type = when (ownerType) {
                ProfileStartupOwnerType.UI -> StartupOwnerType.UI
                ProfileStartupOwnerType.HEADLESS -> StartupOwnerType.HEADLESS
            },
            engineId = engineId,
        )

        // The lease a replaced isolate was granted is handed back here rather
        // than when it died, for the reason [onEngineRestarting] gives — and
        // here rather than in `claimProfileAccess` because this is the call it
        // would otherwise be refused by.
        abandonSupersededEngines(except = engineId)

        synchronized(startupEngines) { startupEngines += engineId }

        // Noted, not required: a launch waiting for this app half needs to know
        // it got this far. See [DartStartupProgress].
        DartStartupProgress.record(BootstrapStage.ARBITRATING)

        val directive = StartupArbiter.beginStartup(
            owner,
            when (promptMode) {
                ProfileStartupPromptMode.OFF -> ProfilePromptMode.OFF
                ProfileStartupPromptMode.BROWSER_ONLY -> ProfilePromptMode.BROWSER_ONLY
            },
        )

        return ProfileStartupDirective(
            kind = when (directive.kind) {
                StartupDirectiveKind.COMMITTED -> ProfileStartupDirectiveKind.COMMITTED
                StartupDirectiveKind.SELECT -> ProfileStartupDirectiveKind.SELECT
                StartupDirectiveKind.MAINTENANCE -> ProfileStartupDirectiveKind.MAINTENANCE
                StartupDirectiveKind.UNAVAILABLE -> ProfileStartupDirectiveKind.UNAVAILABLE
            },
            profileId = directive.profileId,
            candidateProfileId = directive.candidateProfileId,
            leaseId = directive.leaseId,
            showPicker = directive.showPicker,
            maintenanceTaskId = directive.maintenanceTaskId,
            recoveryRequired = directive.recoveryRequired,
            reason = directive.reason,
        )
    }

    override fun commitSelection(leaseId: String, profileId: String): Boolean =
        StartupArbiter.commitSelection(leaseId, profileId.lowercase())

    override fun heartbeatSelection(leaseId: String): Boolean =
        StartupArbiter.heartbeatSelection(leaseId)

    override fun releaseSelection(leaseId: String, reason: String): Boolean =
        StartupArbiter.releaseSelection(leaseId, reason)

    override fun heartbeatMaintenance(leaseId: String): Boolean =
        StartupArbiter.heartbeatMaintenance(leaseId)

    override fun holdMaintenanceHeartbeat(leaseId: String, held: Boolean): Boolean =
        StartupArbiter.holdMaintenanceHeartbeat(leaseId, held)

    override fun assertMaintenanceLease(
        leaseId: String,
        taskId: String?,
        boundary: String,
    ): Boolean = StartupArbiter.assertMaintenanceLease(leaseId, taskId, boundary)

    override fun suspendMaintenance(leaseId: String, taskId: String?): Boolean =
        StartupArbiter.suspendMaintenance(leaseId, taskId)

    override fun finishMaintenance(leaseId: String): Boolean =
        StartupArbiter.finishMaintenance(leaseId)

    /**
     * Arms a restart, trampoline included.
     *
     * `arm` starts the trampoline itself, while a window is still visible — the
     * only state in which Android permits the activity start, and the only
     * reliable relaunch path once the process dies. A refusal therefore aborts
     * the whole arming and returns false, so the caller reports it and keeps
     * running instead of exiting into a restart that will never arrive.
     */
    override fun armProfileRestart(
        targetProfileId: String?,
        reason: String,
        showPicker: Boolean,
    ): Boolean =
        RestartCoordinator.arm(
            context = applicationContext,
            targetProfileId = targetProfileId?.lowercase(),
            reason = reason,
            showPicker = showPicker,
        ) != null

    override fun completeProfileRestart() {
        // Dart has finished its own teardown by the time this arrives; there is
        // nothing left for the native side to unwind that surviving the exit would
        // help with. The trampoline is already up, waiting for this process to die.
        RestartCoordinator.terminate {}
    }

    /**
     * The participants this build knows how to run.
     *
     * Constructed per call rather than held: they read the live preference stores,
     * and a cached instance would outlive the profile commitment they depend on.
     */
    private fun participant(id: String): MaintenanceParticipantHandler? = when (id) {
        ProfilePreferencesParticipant.ID ->
            ProfilePreferencesParticipant(applicationContext)
        ProfileExternalStorageParticipant.ID ->
            ProfileExternalStorageParticipant(applicationContext)
        PwaShortcutParticipant.ID ->
            PwaShortcutParticipant(applicationContext)
        ProfileJobsParticipant.ID ->
            ProfileJobsParticipant(applicationContext)
        PushOwnershipParticipant.ID ->
            PushOwnershipParticipant(applicationContext)
        else -> null
    }

    override fun listMaintenanceParticipants(): List<String> = listOf(
        ProfilePreferencesParticipant.ID,
        ProfileExternalStorageParticipant.ID,
        PwaShortcutParticipant.ID,
        ProfileJobsParticipant.ID,
        PushOwnershipParticipant.ID,
    )

    override fun runMaintenanceParticipantStep(
        participantId: String,
        step: ParticipantStep,
        taskId: String,
        profileId: String,
        journalKind: String,
        workDirPath: String,
    ): Boolean {
        val participant = participant(participantId) ?: return false

        val workDir = File(workDirPath)
        if (!workDir.isDirectory && !workDir.mkdirs()) return false

        return when (step) {
            // Nothing to enumerate ahead of time: the preference stores are read
            // in `prepare`, which is also where the rollback snapshot is taken, so
            // a separate discovery pass would only read them twice.
            ParticipantStep.DISCOVER -> true
            ParticipantStep.PREPARE -> participant.prepare(workDir, profileId, journalKind)
            ParticipantStep.APPLY -> participant.apply(workDir, profileId, journalKind)
            ParticipantStep.VERIFY -> participant.verify(workDir, profileId, journalKind)
            ParticipantStep.FINALIZE -> participant.finalizeWork(workDir)
            ParticipantStep.ROLLBACK -> participant.rollback(workDir, profileId)
        }
    }

    override fun getAvailableBytes(path: String): Long? = runCatching {
        // StatFs answers for the filesystem the path lives on, which is what the
        // preflight needs: the staged copy and the archive both land there.
        val stat = StatFs(path)
        stat.availableBlocksLong * stat.blockSizeLong
    }.getOrNull()

    /**
     * Opens the directory read-only and syncs its descriptor.
     *
     * A rename is recorded in the parent *directory*, not in either file, so a
     * journal phase that was written and flushed can still be lost if the machine
     * dies before that directory entry reaches the platter. Dart has no way to
     * reach a directory's descriptor; the platform does, through `Os.open`
     * read-only and `Os.fsync`. (`FileInputStream` cannot be used: libcore's
     * `IoBridge` refuses to open a directory with `EISDIR`, so the earlier
     * version of this never synced anything.)
     *
     * False means the window is still open, never that the operation failed —
     * recovery is written to survive exactly this, and refusing to continue
     * because a durability hint could not be taken would be worse than the gap it
     * is narrowing.
     */
    override fun syncDirectory(path: String): Boolean = runCatching {
        val directory = File(path)
        if (!directory.isDirectory) return@runCatching false

        val fd = Os.open(path, OsConstants.O_RDONLY, 0)
        try {
            Os.fsync(fd)
        } finally {
            Os.close(fd)
        }
        true
    }.getOrElse { error ->
        Log.w(TAG, "Could not sync directory $path", error)
        false
    }

    /**
     * Streams a SAF document into a local file, off the main thread.
     *
     * Replaces `saf_stream`'s `copyToLocalFile`, which reported every failure as
     * `PluginError` with the exception's message — null for several of them —
     * so a restore that could not read its archive failed without a reason.
     * Here the exception propagates, and pigeon hands Dart its class and text.
     */
    override suspend fun copyDocumentToFile(sourceUri: String, destPath: String) {
        withContext(Dispatchers.IO) {
            try {
                openDocumentForRead(Uri.parse(sourceUri)).use { source ->
                    FileOutputStream(destPath).use { sink ->
                        source.copyTo(sink, COPY_BUFFER_BYTES)
                        sink.fd.sync()
                    }
                }
            } catch (error: Throwable) {
                Log.e(TAG, "Could not copy $sourceUri to $destPath", error)
                throw error
            }
        }
    }

    /**
     * Opens a SAF document for reading, falling back to a read-write descriptor.
     *
     * For a file in shared storage, `FileSystemProvider.openDocument` routes a
     * read-only open through MediaProvider (`openFileForRead`, so media can be
     * redacted), and MediaProvider resolves the *caller's* package first. Some
     * Android builds — seen on Waydroid, Android 13 — resolve it to null and
     * fail inside `AppOpsManager.checkPackage` with a bare
     * `NullPointerException`, so no backup in shared storage could be read. A
     * read-write open takes the provider's direct path instead and never
     * reaches MediaProvider. It needs the write grant the backup folder already
     * has, and "rw" neither truncates nor writes anything.
     *
     * Only for failures that say nothing about the file: a missing document or
     * a refused grant is the real answer and is reported as it is.
     */
    private fun openDocumentForRead(uri: Uri): InputStream {
        val resolver = applicationContext.contentResolver
        return try {
            resolver.openInputStream(uri)
                ?: throw FileNotFoundException("The provider returned no stream for $uri")
        } catch (error: FileNotFoundException) {
            throw error
        } catch (error: SecurityException) {
            throw error
        } catch (error: Exception) {
            Log.w(TAG, "Read-only open of $uri failed; retrying read-write", error)
            try {
                val descriptor = resolver.openFileDescriptor(uri, "rw") ?: throw error
                ParcelFileDescriptor.AutoCloseInputStream(descriptor)
            } catch (retry: Exception) {
                error.addSuppressed(retry)
                throw error
            }
        }
    }

    override fun claimStartupIntents(engineId: String): List<StartupIntentRecord> =
        runCatching {
            StartupIntentBroker.claim(StartupPaths(applicationContext), engineId)
                .map { entry ->
                    StartupIntentRecord(
                        id = entry.id,
                        sequence = entry.sequence,
                        action = entry.action,
                        dataUri = entry.dataUri,
                        mimeType = entry.mimeType,
                        categories = entry.categories,
                        extras = entry.extras,
                        trustedProfileId = entry.effectiveTrustedProfileId,
                        callerPackage = entry.callerPackage,
                    )
                }
        }.getOrElse { error ->
            Log.w(TAG, "Could not claim queued launches", error)
            emptyList()
        }

    override fun acknowledgeStartupIntent(entryId: String, engineId: String): Boolean =
        runCatching {
            StartupIntentBroker.acknowledge(StartupPaths(applicationContext), entryId, engineId)
        }.getOrDefault(false)

    override fun releaseStartupIntent(entryId: String, engineId: String): Boolean =
        runCatching {
            StartupIntentBroker.release(StartupPaths(applicationContext), entryId, engineId)
        }.getOrDefault(false)

    override fun claimProfileAccess(
        ownerType: ProfileStartupOwnerType,
        engineId: String,
        taskId: String?,
    ): Boolean {
        val owner = accessOwner(ownerType, engineId, taskId)

        // Everything a replaced isolate of *this* engine held. The arbiter
        // refuses every other candidate, so the lease never stands open.
        val replaced = synchronized(superseded) { superseded.access.toSet() }
        if (!DartProfileAccess.tryClaim(owner, replaced)) return false

        if (replaced.isNotEmpty()) {
            synchronized(superseded) { superseded.access -= replaced }
            synchronized(grantedAccess) { grantedAccess -= replaced }
        }
        synchronized(grantedAccess) { grantedAccess += owner }

        // The earliest call Dart's startup makes, and so the first moment a
        // waiting launch can tell a running isolate from a started one.
        DartStartupProgress.record(BootstrapStage.ARBITRATING)
        return true
    }

    override fun releaseProfileAccess(
        ownerType: ProfileStartupOwnerType,
        engineId: String,
        taskId: String?,
    ): Boolean {
        val owner = accessOwner(ownerType, engineId, taskId)
        synchronized(grantedAccess) { grantedAccess -= owner }
        return DartProfileAccess.release(owner)
    }

    /**
     * Releases whatever this engine still held.
     *
     * Called from `onDetachedFromEngine`, which is the last moment a dying
     * engine is observable — see [onEngineRestarting] for the other way an
     * isolate stops existing. Dart cannot do this for itself: the isolate is gone
     * by the time anyone notices, and `release` checks owner identity, so no
     * later engine can drop the lease on its behalf either.
     *
     * Releasing here is safe precisely because [DartProfileAccess] keys on the
     * isolate: an engine that detached has no isolate left to be holding a
     * `ProviderContainer` open, which is the only thing the lease protects.
     */
    fun onEngineDetached() {
        synchronized(superseded) {
            superseded.access.clear()
            superseded.engines.clear()
        }

        val held = synchronized(grantedAccess) {
            grantedAccess.toList().also { grantedAccess.clear() }
        }

        for (owner in held) {
            if (DartProfileAccess.release(owner)) {
                Log.i(TAG, "Released profile access held by a detached engine: $owner")
            }
        }

        val engines = synchronized(startupEngines) {
            startupEngines.toList().also { startupEngines.clear() }
        }

        for (engineId in engines) {
            if (StartupArbiter.abandonEngine(engineId)) {
                Log.i(TAG, "Handed back a startup lease held by a detached engine: $engineId")
            }
        }
    }

    /**
     * Marks what this engine holds as the previous isolate's, for a hot restart.
     *
     * A restart replaces the isolate without touching the engine, so
     * `onDetachedFromEngine` never runs — and yet the isolate that took these
     * leases is exactly as gone as a detached one. The replacement introduces
     * itself with a freshly generated engine id, which the arbiter can only read
     * as a second owner arriving, so every debug hot restart used to land on
     * "profile is in use" naming an owner that no longer existed, with nothing
     * left alive to release it and no retry that could ever succeed.
     *
     * Marked rather than released, because the embedder is not finished yet:
     * `onPreEngineRestart` runs before the old isolate is destroyed, so handing
     * the lease back to *nobody* here would open it — briefly, but genuinely —
     * to a headless engine starting elsewhere in the process, while the isolate
     * that held it is still being torn down. Instead the lease stays taken and
     * passes to the first claim from this same engine: one engine runs one
     * isolate, so a claim arriving under a new id is the replacement, and by the
     * time it runs the embedder has destroyed its predecessor. If none ever
     * comes, [onEngineDetached] hands everything back the ordinary way.
     */
    fun onEngineRestarting() {
        val held = synchronized(grantedAccess) { grantedAccess.toList() }
        val engines = synchronized(startupEngines) { startupEngines.toList() }
        if (held.isEmpty() && engines.isEmpty()) return

        synchronized(superseded) {
            superseded.access += held
            superseded.engines += engines
        }

        Log.i(TAG, "A restarted engine's isolate held $held and arbitrated as $engines")
    }

    private fun abandonSupersededEngines(except: String) {
        val engines = synchronized(superseded) {
            (superseded.engines - except).also { superseded.engines -= it }
        }
        if (engines.isEmpty()) return

        synchronized(startupEngines) { startupEngines -= engines }

        for (engineId in engines) {
            if (StartupArbiter.abandonEngine(engineId)) {
                Log.i(TAG, "Handed back a startup lease held by a restarted engine: $engineId")
            }
        }
    }

    /**
     * A headless owner without a task id is still a headless owner.
     *
     * The empty fallback keeps the identity total rather than silently promoting
     * it to a UI owner, which would let a background isolate hold the lease the
     * UI is waiting on and never be recognised as the holder to release it.
     */
    private fun accessOwner(
        ownerType: ProfileStartupOwnerType,
        engineId: String,
        taskId: String?,
    ): DartAccessOwner = when (ownerType) {
        ProfileStartupOwnerType.UI -> DartAccessOwner.Ui(engineId)
        ProfileStartupOwnerType.HEADLESS ->
            DartAccessOwner.Headless(engineId, taskId.orEmpty())
    }

    override fun getCommittedProfileId(): String? = StartupArbiter.committedProfileId()

    override fun getBoundProfileFolder(): String? = StartupArbiter.boundProfileFolder()

    /**
     * Only the committed profile's unlock is kept: no window of this process
     * can show any other, and the browser also remembers unlocks of other
     * profiles it authorized an action on.
     */
    override fun recordSharedProfileUnlock(
        profileId: String,
        mode: SharedUnlockMode,
        timeoutMs: Long,
        ageMs: Long,
    ) {
        if (profileId != StartupArbiter.committedProfileId()) return

        ProfileUnlockRegistry.recordShared(
            profileId,
            when (mode) {
                SharedUnlockMode.TIMEOUT -> AutoLockMode.TIMEOUT
                SharedUnlockMode.STARTUP -> AutoLockMode.STARTUP
            },
            timeoutMs,
            ageMs,
        )
    }

    override fun clearSharedProfileUnlock(profileId: String) {
        ProfileUnlockRegistry.forgetShared(profileId)
    }

    override fun getSharedProfileUnlock(profileId: String): SharedProfileUnlock? {
        if (profileId != StartupArbiter.committedProfileId()) return null

        val shared = ProfileUnlockRegistry.shared(profileId) ?: return null
        return SharedProfileUnlock(
            mode = when (shared.mode) {
                AutoLockMode.STARTUP -> SharedUnlockMode.STARTUP
                else -> SharedUnlockMode.TIMEOUT
            },
            timeoutMs = shared.timeoutMs,
            ageMs = shared.ageMs,
        )
    }
}
