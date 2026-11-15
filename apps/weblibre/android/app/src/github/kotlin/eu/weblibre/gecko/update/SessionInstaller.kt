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
package eu.weblibre.gecko.update

import android.annotation.SuppressLint
import android.app.Activity
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageInstaller
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import java.security.DigestInputStream
import java.security.MessageDigest
import java.util.UUID

/**
 * The system confirmation intent of a session waiting for the user. It can't
 * outlive the process (7.5), so it lives in memory only: after process death
 * "Continue" abandons the session and creates a new one from the staged file.
 */
object PendingConfirmation {
    @Volatile
    var sessionId: Int? = null

    @Volatile
    var intent: Intent? = null

    fun clear() {
        sessionId = null
        intent = null
    }
}

/** The activity in front, for starting the system confirmation. */
object ForegroundActivity {
    @Volatile
    var resumed: Activity? = null
}

/**
 * Commits a verified, authorized APK through [PackageInstaller] (plan 7.5) and
 * reconciles what Android is doing (7.6 stage 1).
 *
 * The journal is written ahead of every step, so nothing depends on code that
 * runs after `commit()`, and every status callback is correlated with the
 * journal's session ID and nonce before it changes anything.
 *
 * The monitor guards the journal and the reservation, and is only ever held
 * for short steps: [InstallStatusReceiver] takes it on the main thread, so
 * verifying an APK and copying it into a session happen outside it.
 */
class SessionInstaller(
    private val context: Context,
    private val paths: UpdatePaths,
    private val journal: InstallerJournal = InstallerJournal(paths.journalFile),
    private val inspector: ApkInspector = ApkInspector({ installedIdentity(context) }),
) {
    private val installer: PackageInstaller get() = context.packageManager.packageInstaller

    /** The session [commit] is filling outside the monitor. Guarded by `this`. */
    private var filling: Int? = null

    fun canRequestPackageInstalls(): Boolean = context.packageManager.canRequestPackageInstalls()

    fun verifyAndPromote(expected: ExpectedArtifact): ApkVerificationResult {
        val part = paths.partFile(expected.sha256)
        val result = inspector.inspect(part, expected)
        if (!result.verified) {
            part.delete()
            return result
        }
        val apk = paths.apkFile(expected.sha256)
        if (!part.renameTo(apk)) {
            return ApkVerificationResult(verified = false, failure = NativeFailure.INSTALL_STORAGE, detail = "rename failed")
        }
        return result
    }

    /** Stage 1 of recovery, applied: abandons what it says and writes the journal. */
    @Synchronized
    fun reconcile(): InstallerReconciliation = applyReconciled().reconciliation

    /**
     * A decision that replays an interrupted abandonment is decided once more
     * on the session list as it is after abandoning: only Android's list
     * proves the session gone (`abandoned`), and one that survived is still
     * an installation in progress.
     */
    private fun applyReconciled(): ReconcileDecision {
        val decision = applyDecision(decide())
        return if (decision.confirmAbandoned) applyDecision(decide()) else decision
    }

    private fun decide(): ReconcileDecision {
        val journalRead = journal.read()
        val sessions = runCatching { installer.mySessions }.getOrDefault(emptyList())
            .map { SessionView(it.sessionId, committedness(it)) }
        return InstallerReconciler.decide(
            ReconcileInput(
                journal = journalRead,
                installedVersionCode = InstalledBuildInfoReader.installedVersionCode(context),
                installedByUs = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    InstalledBuildInfoReader.installerOfRecord(context) == context.packageName
                } else {
                    null
                },
                sessions = sessions,
                fillingSessionId = filling,
            ),
        )
    }

    private fun applyDecision(decision: ReconcileDecision): ReconcileDecision {
        for (id in decision.abandon) {
            runCatching { installer.abandonSession(id) }
                .onFailure { Log.w(TAG, "Could not abandon session $id", it) }
            if (PendingConfirmation.sessionId == id) PendingConfirmation.clear()
        }
        decision.journal?.let(journal::write)
        return decision
    }

    private sealed interface Begun {
        data class Refused(val result: InstallCommitResult) : Begun
        data class Created(val sessionId: Int, val nonce: String) : Begun
    }

    /**
     * Three steps, so the monitor is never held while an APK of 100+ MB is
     * verified and copied: reserve (locked), fill (unlocked, the session
     * counts as a reservation meanwhile), then commit (locked).
     */
    fun commit(expected: ExpectedArtifact): InstallCommitResult {
        val (sessionId, nonce) = when (val begun = synchronized(this) { begin(expected) }) {
            is Begun.Refused -> return begun.result
            is Begun.Created -> begun.sessionId to begun.nonce
        }
        return try {
            val filled = installer.openSession(sessionId).use { session -> fillAndCommit(session, sessionId, nonce, expected) }
            if (filled.committed) committedOutcome(sessionId, nonce) else filled
        } catch (e: Exception) {
            Log.e(TAG, "Install session $sessionId failed before commit", e)
            synchronized(this) {
                runCatching { installer.abandonSession(sessionId) }
                retireOwn(sessionId, nonce, expected, failure = NativeFailure.INSTALL_UNKNOWN, detail = e.toString())
            }
            InstallCommitResult(committed = false, failure = NativeFailure.INSTALL_UNKNOWN, detail = e.toString())
        } finally {
            synchronized(this) { if (filling == sessionId) filling = null }
        }
    }

    /** Under the monitor: the reservation, the cheap checks, and the session. */
    private fun begin(expected: ExpectedArtifact): Begun {
        fun refused(failure: NativeFailure, detail: String? = null) =
            Begun.Refused(InstallCommitResult(committed = false, failure = failure, detail = detail))

        // A live reservation blocks a second session, whatever Dart thinks.
        val decision = applyReconciled()
        if (InstallerReconciler.holdsReservation(decision)) return refused(NativeFailure.RESERVATION_ACTIVE)
        if (journal.read() is JournalRead.Corrupt) {
            // Reconciliation found no session of ours; an unreadable journal
            // is replaced by the new session's entry below.
            Log.w(TAG, "Replacing an unreadable installer journal")
        }

        if (authorizationLapsed(expected)) return refused(NativeFailure.AUTHORIZATION_STALE)
        if (!canRequestPackageInstalls()) return refused(NativeFailure.INSTALL_PERMISSION_DENIED)

        val params = PackageInstaller.SessionParams(PackageInstaller.SessionParams.MODE_FULL_INSTALL).apply {
            setAppPackageName(context.packageName)
            setSize(expected.byteLength)
            setInstallReason(PackageManager.INSTALL_REASON_USER)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                setRequireUserAction(PackageInstaller.SessionParams.USER_ACTION_NOT_REQUIRED)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                setPackageSource(PackageInstaller.PACKAGE_SOURCE_OTHER)
            }
        }

        val sessionId = try {
            installer.createSession(params)
        } catch (e: Exception) {
            return refused(NativeFailure.INSTALL_STORAGE, e.toString())
        }
        val nonce = UUID.randomUUID().toString()
        try {
            journal.write(JournalState(phase = InstallerPhase.SESSION_CREATED, sessionId = sessionId, nonce = nonce, expected = expected))
        } catch (e: Exception) {
            runCatching { installer.abandonSession(sessionId) }
            return refused(NativeFailure.INSTALL_UNKNOWN, e.toString())
        }
        filling = sessionId
        return Begun.Created(sessionId, nonce)
    }

    /** Outside the monitor, except for its last step. */
    private fun fillAndCommit(
        session: PackageInstaller.Session,
        sessionId: Int,
        nonce: String,
        expected: ExpectedArtifact,
    ): InstallCommitResult {
        val apk = paths.apkFile(expected.sha256)
        // The digest is checked once, on the bytes copied into the session
        // below; the rest of 7.4 runs again here against the installed build
        // as it is now.
        val verification = inspector.inspect(apk, expected, checkDigest = false)
        if (!verification.verified) {
            apk.delete()
            return synchronized(this) { giveUp(session, sessionId, nonce, expected, verification.failure, verification.detail) }
        }

        // Opened once and hashed while copied: what the session holds is byte
        // for byte what was verified.
        val md = MessageDigest.getInstance("SHA-256")
        DigestInputStream(apk.inputStream(), md).use { input ->
            session.openWrite("base.apk", 0, expected.byteLength).use { out ->
                input.copyTo(out, 1 shl 16)
                session.fsync(out)
            }
        }
        if (md.digest().toHexString() != expected.sha256) {
            apk.delete()
            return synchronized(this) { giveUp(session, sessionId, nonce, expected, NativeFailure.DOWNLOAD_MISMATCH, null) }
        }

        synchronized(this) {
            if (ownEntry(sessionId, nonce) == null) {
                // Abandoned while it was being filled (7.5): nothing to commit.
                runCatching { session.abandon() }
                return InstallCommitResult(committed = false, failure = NativeFailure.INSTALL_CANCELLED)
            }
            // Verifying and copying take long enough for the bound to pass:
            // authorization holds at commit, not at the start of it. The
            // staged APK stays for a new authorization.
            if (authorizationLapsed(expected)) {
                return giveUp(session, sessionId, nonce, expected, NativeFailure.AUTHORIZATION_STALE, null)
            }
            journal.write(JournalState(phase = InstallerPhase.COMMIT_REQUESTED, sessionId = sessionId, nonce = nonce, expected = expected))
            session.commit(statusReceiver(sessionId, nonce).intentSender)
        }
        return InstallCommitResult(committed = true)
    }

    /**
     * What the journal says about a session just committed: a status callback
     * may have arrived before commit returned, and its event may already have
     * been reduced, so the answer has to agree with it, terminal outcomes
     * included.
     */
    private fun committedOutcome(sessionId: Int, nonce: String): InstallCommitResult = synchronized(this) {
        val state = journal.state()
        when {
            state != null && state.sessionId == sessionId && state.nonce == nonce -> InstallCommitResult(
                committed = true,
                phase = state.phase,
                failure = state.failure,
                detail = state.lastMessage,
                // Shown from this answer, so Dart acknowledges it: its event
                // may never reach a listener.
                sessionId = sessionId.toLong().takeIf { state.phase == InstallerPhase.FAILED },
                nonce = nonce.takeIf { state.phase == InstallerPhase.FAILED },
            )
            // Retired by a reconciliation in between: commit replaced the
            // journal, so the retired outcome is this session's.
            state?.phase == InstallerPhase.NONE -> InstallCommitResult(
                committed = true,
                phase = state.lastOutcome,
                failure = state.lastOutcomeFailure,
            )
            else -> InstallCommitResult(committed = true, phase = InstallerPhase.COMMIT_REQUESTED)
        }
    }

    private fun authorizationLapsed(expected: ExpectedArtifact) =
        System.currentTimeMillis() > expected.authorizedUntilEpochMs

    /**
     * The journal's entry while it still names this session and nothing has
     * happened to it since [commit] wrote it: no abandon, no status.
     */
    private fun ownEntry(sessionId: Int, nonce: String): JournalState? =
        journal.state()?.takeIf {
            it.sessionId == sessionId && it.nonce == nonce &&
                (it.phase == InstallerPhase.SESSION_CREATED || it.phase == InstallerPhase.COMMIT_REQUESTED)
        }

    /** Under the monitor: abandons a session that will not be committed. */
    private fun giveUp(
        session: PackageInstaller.Session,
        sessionId: Int,
        nonce: String,
        expected: ExpectedArtifact,
        failure: NativeFailure?,
        detail: String?,
    ): InstallCommitResult {
        runCatching { session.abandon() }
        retireOwn(sessionId, nonce, expected, failure, detail)
        return InstallCommitResult(committed = false, failure = failure, detail = detail)
    }

    /**
     * Under the monitor. The caller reports the outcome itself, so it is
     * history at once; an entry that no longer names the session (abandoned
     * meanwhile) is left as it is.
     */
    private fun retireOwn(sessionId: Int, nonce: String, expected: ExpectedArtifact, failure: NativeFailure?, detail: String?) {
        if (ownEntry(sessionId, nonce) == null) return
        journal.write(
            JournalState(
                phase = InstallerPhase.FAILED,
                sessionId = sessionId,
                nonce = nonce,
                expected = expected,
                failure = failure,
                lastMessage = detail,
            ).retired(),
        )
    }

    @SuppressLint("UnspecifiedImmutableFlag")
    private fun statusReceiver(sessionId: Int, nonce: String): PendingIntent {
        val intent = Intent(context, InstallStatusReceiver::class.java)
            .setAction(InstallStatusReceiver.ACTION)
            .putExtra(InstallStatusReceiver.EXTRA_NONCE, nonce)
        // Mutable: the installer fills in the status extras.
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) PendingIntent.FLAG_MUTABLE else 0
        return PendingIntent.getBroadcast(context, sessionId, intent, flags)
    }

    /**
     * Reopens the confirmation of the waiting session, only within the bound
     * Dart's authorization just returned (7.5): the same raw-clock check as
     * [commit], so a delay after authorizing never hands an expired
     * authorization to the installer.
     */
    fun continuePendingUserAction(activity: Activity?, authorizedUntilEpochMs: Long): Boolean {
        val state = journal.state() ?: return false
        val intent = PendingConfirmation.intent
        if (state.phase != InstallerPhase.PENDING_USER_ACTION || intent == null ||
            PendingConfirmation.sessionId != state.sessionId || activity == null ||
            System.currentTimeMillis() > authorizedUntilEpochMs
        ) {
            return false
        }
        return runCatching { activity.startActivity(intent) }.isSuccess
    }

    /**
     * `abandonRequested`, then `abandonSession`, and `abandoned` only once
     * Android's list no longer holds the session.
     */
    @Synchronized
    fun abandon() {
        val state = journal.state()
        if (state?.sessionId != null && !state.phase.terminal) {
            journal.write(state.copy(phase = InstallerPhase.ABANDON_REQUESTED))
        }
        for (session in runCatching { installer.mySessions }.getOrDefault(emptyList())) {
            runCatching { installer.abandonSession(session.sessionId) }
        }
        PendingConfirmation.clear()
        val remaining = runCatching { installer.mySessions }.getOrDefault(emptyList())
        if (remaining.isEmpty() && state?.sessionId != null && !state.phase.terminal) {
            journal.write(state.copy(phase = InstallerPhase.ABANDONED).retired())
        }
    }

    /**
     * Applied from [InstallStatusReceiver]. Ignores anything not correlated.
     *
     * A failure stays in the journal after its event is sent: a send proves
     * nothing (no listener, an engine already gone, a Dart state that dropped
     * it). Dart retires it with [acknowledgeFailure] once its state shows it;
     * until then reconciliation reports it.
     */
    fun onStatus(sessionId: Int, nonce: String?, status: Int, message: String?, confirmation: Intent?) {
        val event = synchronized(this) {
            val state = journal.state()
            if (state == null || state.sessionId != sessionId || state.nonce != nonce || nonce == null) {
                Log.w(TAG, "Ignoring status $status for uncorrelated session $sessionId")
                return
            }
            when (status) {
                PackageInstaller.STATUS_PENDING_USER_ACTION -> {
                    // The user cancelled and the abandonment hasn't taken yet:
                    // never reopen the confirmation over that, nor overwrite
                    // the request that reconciliation replays.
                    if (state.phase == InstallerPhase.ABANDON_REQUESTED) {
                        Log.w(TAG, "Ignoring a confirmation for session $sessionId, whose abandonment was requested")
                        return
                    }
                    journal.write(state.copy(phase = InstallerPhase.PENDING_USER_ACTION, lastMessage = message))
                    PendingConfirmation.sessionId = sessionId
                    PendingConfirmation.intent = confirmation?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    ForegroundActivity.resumed?.let { activity ->
                        confirmation?.let { runCatching { activity.startActivity(it) } }
                    }
                    InstallerStatusEvent(sessionId.toLong(), nonce, InstallerPhase.PENDING_USER_ACTION, message = message)
                }

                PackageInstaller.STATUS_SUCCESS -> {
                    journal.write(state.copy(phase = InstallerPhase.SUCCEEDED, lastMessage = message))
                    PendingConfirmation.clear()
                    InstallerStatusEvent(sessionId.toLong(), nonce, InstallerPhase.SUCCEEDED, message = message)
                }

                else -> {
                    val failure = failureKind(status)
                    journal.write(state.copy(phase = InstallerPhase.FAILED, failure = failure, lastMessage = message))
                    PendingConfirmation.clear()
                    InstallerStatusEvent(sessionId.toLong(), nonce, InstallerPhase.FAILED, failure = failure, message = message)
                }
            }
        }
        UpdateEventStreams.sendInstaller(event)
    }

    /**
     * Dart shows this session's failure; a later reconciliation must not
     * report it again. Only while the journal still holds that failure: a
     * reconciliation may have retired it already, or a new session replaced
     * it.
     */
    @Synchronized
    fun acknowledgeFailure(sessionId: Int, nonce: String) {
        val state = journal.state() ?: return
        if (state.sessionId != sessionId || state.nonce != nonce || state.phase != InstallerPhase.FAILED) return
        journal.write(state.retired())
    }

    companion object {
        private const val TAG = "SessionInstaller"

        @Volatile
        private var shared: SessionInstaller? = null

        /**
         * One per process: the bridge and the status receiver must serialize
         * on the same instance and the same journal lock.
         */
        fun shared(context: Context): SessionInstaller = shared ?: synchronized(this) {
            shared ?: SessionInstaller(context.applicationContext, UpdatePaths(context.applicationContext))
                .also { shared = it }
        }

        fun failureKind(status: Int): NativeFailure = when (status) {
            PackageInstaller.STATUS_FAILURE_ABORTED -> NativeFailure.INSTALL_CANCELLED
            PackageInstaller.STATUS_FAILURE_BLOCKED -> NativeFailure.INSTALL_BLOCKED
            PackageInstaller.STATUS_FAILURE_CONFLICT -> NativeFailure.INSTALL_CONFLICT
            PackageInstaller.STATUS_FAILURE_INCOMPATIBLE -> NativeFailure.INSTALL_INCOMPATIBLE
            PackageInstaller.STATUS_FAILURE_INVALID -> NativeFailure.APK_INVALID
            PackageInstaller.STATUS_FAILURE_STORAGE -> NativeFailure.INSTALL_STORAGE
            else -> NativeFailure.INSTALL_UNKNOWN
        }

        /**
         * Unknown, including a call that fails, is never read as uncommitted.
         *
         * Sealed counts as committed on every API level: `commit()` seals the
         * session at once, while Android 10+ sets `isCommitted` only after its
         * asynchronous validation. A session in between is an installation in
         * progress, never a leftover to abandon. We never seal a session any
         * other way. (`isSealed` is API 26, the app's minimum.)
         */
        fun committedness(info: PackageInstaller.SessionInfo): Committedness = try {
            val committed = info.isSealed ||
                (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && info.isCommitted)
            if (committed) Committedness.COMMITTED else Committedness.UNCOMMITTED
        } catch (e: Throwable) {
            Committedness.UNKNOWN
        }

        fun installedIdentity(context: Context): InstalledIdentity {
            val manifest = InstalledBuildInfoReader.readManifest(context)
            val versionCode = InstalledBuildInfoReader.installedVersionCode(context)
            return InstalledIdentity(
                packageName = context.packageName,
                versionCode = versionCode,
                signers = ProductionSigner.installedSigners(context),
                distribution = CompiledBuild.distribution,
                track = CompiledBuild.track,
                renderer = CompiledBuild.renderer,
                logicalReleaseSequence = eu.weblibre.gecko.BuildConfig.LOGICAL_RELEASE_SEQUENCE,
                abi = manifest?.abiFor(versionCode),
                sdkInt = Build.VERSION.SDK_INT,
            )
        }
    }
}
