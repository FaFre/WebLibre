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
 */
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:secure_archive/secure_archive.dart';
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/core/design/window_size_class.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/maintenance/maintenance_journal_store.dart';
import 'package:weblibre/core/maintenance/maintenance_lease.dart';
import 'package:weblibre/core/maintenance/maintenance_outcome.dart';
import 'package:weblibre/core/maintenance/maintenance_runner.dart';
import 'package:weblibre/core/maintenance/saf_archive_target.dart';
import 'package:weblibre/core/startup/maintenance_evidence.dart';
import 'package:weblibre/core/startup/maintenance_scanner.dart';
import 'package:weblibre/core/startup/models/startup_config.dart';
import 'package:weblibre/core/startup/startup_bootstrap.dart';
import 'package:weblibre/core/startup/startup_config_store.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/utils/maintenance_outcome_l10n.dart';
import 'package:weblibre/presentation/widgets/obscurable_text_field.dart';

/// How often the screen proves it is still here.
///
/// A quarter of the native `MAINTENANCE_HEARTBEAT_TIMEOUT_MS`, so several
/// renewals have to be missed before the watchdog concludes this owner is gone.
///
/// Without it, the lease expired while the user was *reading the screen*.
/// `MaintenanceRunner.run` renews for as long as work is running, but the
/// longest wait here is the one before any work starts: the password prompt. A
/// user who switches to a password manager for ninety seconds came back to an
/// expired lease, which sets `restartRequiredForRecovery` and refuses every
/// later `beginStartup` in the process.
const _maintenanceHeartbeatInterval = Duration(seconds: 15);

/// Runs queued profile maintenance before the browser exists.
///
/// It builds no `ProviderScope` and opens no profile: the whole reason this
/// screen exists is that the profile it is working on must have no writers. The
/// password is asked for here rather than carried across the restart, because a
/// durable task record is exactly the wrong place to keep one.
class StartupMaintenanceScreen extends HookWidget {
  const StartupMaintenanceScreen({
    required this.phase,
    required this.onFinished,
    super.key,
  });

  final StartupMaintenanceRequired phase;

  /// Called once the queue is done and the lease should be released.
  final Future<void> Function() onFinished;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final store = useMemoized(
      () => StartupConfigStore(filesystem.startupPaths),
    );

    final password = useTextEditingController();
    final passwordFocus = useFocusNode();

    /// Whether the last attempt failed for a reason the password could explain.
    ///
    /// Kept apart from [outcome] because the two say different things in
    /// different places: the banner explains what happened, and this puts a mark
    /// on the one control that can change the answer. A banner alone left the
    /// field looking untouched by a failure it caused.
    final passwordRejected = useState(false);
    final busy = useState(false);
    final activity = useState<String?>(null);
    final outcome = useState<_Outcome?>(null);
    final tasks = useState<List<MaintenanceTask>>(const []);

    /// The task that just failed, if it can be put back on the queue.
    ///
    /// A failure takes the task out of `activeTasks`, which is right — a
    /// mistyped archive password must not hold the browser shut — but it also
    /// left the screen with nothing but "Open WebLibre". Retrying then meant
    /// booting, walking to Users → Backups, and going through the whole restart
    /// again for one wrong character. `failed → queued` is a legal transition,
    /// so the queue can simply take it back.
    final retryable = useState<MaintenanceTask?>(null);

    /// Task ids named by durable evidence on disk.
    ///
    /// Durable evidence is the *only* thing that says a destructive mutation is
    /// in flight, so it is also the only thing that may take the "cancel" option
    /// away — and it is all three of the things `MaintenanceScan.hasDurableEvidence`
    /// counts, not just the readable journals. An unreadable journal is evidence
    /// precisely because it cannot be parsed, and a half-cleared restore
    /// workspace is evidence with no journal at all; tracking only the readable
    /// ones offered to cancel operations whose record this screen could not
    /// read.
    final blockedTasks = useState<Set<String>>(const {});

    /// Tasks whose blocking evidence is a journal this build *can* read.
    ///
    /// The third state, and the one that was missing. [blockedTasks] says the
    /// task may not start over; [unresolved] says nothing automatic can help. A
    /// readable journal whose recovery threw is in neither camp — recovery owns
    /// it and can be asked again — so with only the other two the screen showed a
    /// dead button, no panel, and copy claiming the record was unreadable.
    final recoverableTasks = useState<Set<String>>(const {});

    /// Evidence that remains after recovery and that this screen cannot act on.
    ///
    /// Kept separate from [blockedTasks] because it has no task to attach to:
    /// this is what makes the difference between "nothing left to do" and
    /// "nothing *I* can do", and conflating them left the finish button
    /// re-arbitrating into the same reservation over and over.
    final unresolved = useState<List<String>>(const []);

    // Deliberately unlike the picker's heartbeat, which simply stops when the app
    // is not resumed: an unanswered picker costs nothing to abandon, because the
    // watchdog just commits the candidate. Abandoning *this* lease is destructive.
    // Expiry sets `restartRequiredForRecovery`, which refuses every later
    // maintenance boundary in the process and leaves the queue stuck behind a
    // recovery the user never asked for — and the single most likely reason to
    // leave this screen is the one it asks for: fetching the archive password from
    // a password manager.
    //
    // So leaving is *declared* rather than ridden out. Simply continuing to beat
    // in the background is not enough: Android freezes cached processes, a frozen
    // isolate fires no timers, and the deadline would then be measuring how long
    // the platform declined to run us. `holdMaintenanceHeartbeat` says so up front,
    // while the isolate is still running and can be heard.
    //
    // Held and alive are separate facts on the native side, so the hold has to be
    // released as explicitly as it was taken — a heartbeat will not do it. That is
    // deliberate: `MaintenanceLease.keepAlive` beats for as long as a task runs,
    // and if beating cleared the hold, a backup running behind a backgrounded app
    // would undo its own protection every fifteen seconds.
    final lifecycle = useAppLifecycleState();
    final resumed = lifecycle == null || lifecycle == AppLifecycleState.resumed;

    useEffect(() {
      final service = GeckoProfileService();

      Future<void> hold(bool held) async {
        await service
            .holdMaintenanceHeartbeat(phase.leaseId, held)
            .catchError((_) => false);
      }

      if (!resumed) {
        unawaited(hold(true));
        return null;
      }

      // Releases *and* renews, so it doubles as the first beat.
      unawaited(hold(false));

      Future<void> beat() async {
        // A single missed renewal decides nothing; the boundary asserts are what
        // fail closed. A *late* one is honoured — native matches the lease before
        // it evaluates the deadline — so returning to the screen recovers even
        // when the hold never got through.
        await service
            .heartbeatMaintenance(phase.leaseId)
            .catchError((_) => false);
      }

      final timer = Timer.periodic(
        _maintenanceHeartbeatInterval,
        (_) => unawaited(beat()),
      );
      return timer.cancel;
    }, [phase.leaseId, resumed]);

    Future<void> reload() async {
      final config = await store.read(useCache: false);
      final scan = await MaintenanceScanner(filesystem.startupPaths).scan();

      tasks.value = config.activeTasks;
      blockedTasks.value = scan.evidenceTaskIds;
      unresolved.value = scan.unresolvedEvidence;
      recoverableTasks.value = {
        for (final journal in scan.incompleteJournals) journal.taskId,
      };
    }

    final pending = tasks.value;
    final next = pending.firstOrNull;
    final needsPassword = next != null && _needsPassword(next);

    Future<MaintenanceRunner> buildRunner(String taskId) async {
      final temp = await getTemporaryDirectory();
      return MaintenanceRunner(
        store: store,
        lease: MaintenanceLease(leaseId: phase.leaseId, taskId: taskId),
        profilesDir: filesystem.profilesDir,
        workRoot: temp,
        paths: filesystem.startupPaths,
        availableBytes: () =>
            GeckoProfileService().getAvailableBytes(temp.path),
        syncDirectory: GeckoProfileService().syncDirectory,
        packer: (source, output, secret, {required integrityCheck}) async {
          await SecureArchivePack(
            outputFile: output,
            sourceDirectory: source,
            argon2Params: Argon2Params.memoryConstrained(),
          ).pack(secret, integrityCheck: integrityCheck);
        },
        verifyTarget: safTargetIsWritable,
        publisher: (archive, targetTree, fileName) async {
          await publishArchiveToSaf(
            archive: archive,
            targetTree: targetTree,
            fileName: fileName,
          );
        },
        unpacker: (sourceFile, staging, secret) async {
          await withArchiveFromSaf(
            sourceUri: sourceFile,
            local: File(p.join(staging.parent.path, 'incoming.weblibre')),
            use: (archive) => SecureArchiveUnpack(
              inputFile: archive,
              outputDirectory: staging,
              argon2Params: Argon2Params.memoryConstrained(),
            ).unpack(secret),
          );
        },
      );
    }

    /// Finishes whatever a previous process left in flight, before any queued
    /// task runs. A journal is durable evidence that a mutation was interrupted;
    /// starting new work on top of one would layer a second incomplete operation
    /// over the first.
    Future<MaintenanceRecoveryOutcome?> recoverJournals() async {
      final scan = await MaintenanceScanner(filesystem.startupPaths).scan();
      if (!scan.hasDurableEvidence) return null;

      final journals = MaintenanceJournalStore(
        filesystem.startupPaths,
        syncDirectory: GeckoProfileService().syncDirectory,
      );

      MaintenanceRecoveryOutcome? outcome;
      for (final entry in scan.incompleteJournals) {
        final journal = await journals.read(entry.taskId);
        if (journal == null) continue;

        activity.value = l10n.startup_maintenanceFinishingInterrupted;
        final runner = await buildRunner(journal.taskId);
        outcome = await runner.recoverJournal(journal);
      }

      await sweepHarmlessArtifacts(filesystem.startupPaths, scan);
      return outcome;
    }

    Future<void> runTask(MaintenanceTask task) async {
      busy.value = true;
      outcome.value = null;
      retryable.value = null;
      passwordRejected.value = false;
      final copy = _copyFor(l10n, task);
      activity.value = copy.activity;

      try {
        final runner = await buildRunner(task.id);
        final result = await runner.run(task, password: password.text);

        final done = result.effectiveState == MaintenanceTaskState.completed;
        outcome.value = _Outcome(
          done
              ? copy.describeDone
              : (result.describeFailure(l10n) ??
                    result.error ??
                    l10n.startup_maintenanceTaskDidNotFinish),
          failed: !done,
        );
        if (done) {
          password.clear();
        } else {
          // The persisted kind, not the message. A sentence is what the banner
          // shows; the kind is what survives the process and can be branched on
          // without two files agreeing on punctuation.
          passwordRejected.value =
              _needsPassword(task) &&
              (result.failureKind?.blamesPassword ?? false);
        }

        if (!done &&
            result.effectiveState == MaintenanceTaskState.failed &&
            _isRunnable(result)) {
          // Only `failed`. `recoveryRequired` means the work got far enough to
          // need reconciling, and that is recovery's to finish, not something to
          // offer as a retry — and an action this build cannot run would fail
          // again the moment the button was pressed.
          retryable.value = result;
        }
      } on MaintenanceLeaseLost {
        // The reservation moved on while this screen held it. Nothing was
        // damaged — the boundary check is what stopped the work — but this
        // process can no longer act, and only a restart clears that.
        outcome.value = _Outcome(
          l10n.startup_maintenanceLeaseLost(
            l10n.profileCopy_nothingChanged,
            l10n.profileCopy_reopenToContinue,
          ),
          failed: true,
        );
      } catch (error) {
        outcome.value = _Outcome(
          describeMaintenanceFailure(l10n, error),
          failed: true,
        );
      } finally {
        busy.value = false;
        activity.value = null;
        await reload();
      }
    }

    /// Runs recovery and reports what it did.
    ///
    /// Shared by the automatic pass below and the button a failed pass offers, so
    /// asking again is provably the same operation rather than a second
    /// implementation of it. Safe to repeat: every recovery path reads the
    /// directories rather than trusting the recorded phase, precisely so it can
    /// resume from wherever the last attempt stopped.
    Future<void> runRecovery() async {
      busy.value = true;
      outcome.value = null;
      try {
        final recovered = await recoverJournals();
        if (recovered != null) {
          outcome.value = _Outcome(recovered.describe(l10n));
        }
      } catch (error) {
        outcome.value = _Outcome(
          describeMaintenanceFailure(l10n, error),
          failed: true,
        );
      } finally {
        busy.value = false;
        activity.value = null;
        await reload();
      }
    }

    /// Recovery on mount, then whatever can start without asking.
    ///
    /// Recovery is not optional and never was: an incomplete journal means a
    /// destructive operation stopped half-way, and nothing may open a profile
    /// until it is reconciled. Running it behind a button would make it look
    /// like something the user chose not to do — the button below is offered only
    /// once this pass has already run and failed.
    useEffect(() {
      unawaited(() async {
        await runRecovery();

        // A deletion was already confirmed, by name, before the restart that
        // brought us here — and it needs nothing else from the user. Asking a
        // second time across a process restart reads as the app not having
        // heard the first answer.
        //
        // Gated on the same evidence the button is: recovery has just run, and
        // anything it left behind means starting this task over would write on
        // top of a record nothing could read. That must never happen without
        // being asked, least of all unattended.
        final head = tasks.value.firstOrNull;
        if (head != null &&
            !_needsInput(head) &&
            _isRunnable(head) &&
            !blockedTasks.value.contains(head.id)) {
          await runTask(head);
        }
      }());
      return null;
    }, const []);

    /// Drops a task that has not started. Only offered when there is no journal
    /// for it, which is exactly the condition under which nothing was changed.
    Future<void> abandon(MaintenanceTask task) async {
      busy.value = true;
      try {
        await store.removeTask(task.id);
        outcome.value = _Outcome(
          l10n.startup_maintenanceTaskCancelled(_copyFor(l10n, task).describe),
        );
      } finally {
        busy.value = false;
        await reload();
      }
    }

    /// The last resort, offered wherever unresolved evidence is shown.
    ///
    /// One closure rather than two copies of the same button body: it is reached
    /// both from the no-tasks branch and from a head task whose own evidence
    /// blocks it, and those two used to be able to drift apart.
    Future<void> discardEvidence(BuildContext context) async {
      final confirmed = await _confirmDiscardEvidence(context);
      if (confirmed != true) return;

      busy.value = true;
      try {
        final parked = await discardUnresolvedEvidence(filesystem.startupPaths);
        outcome.value = _Outcome(
          parked == 0
              ? l10n.startup_maintenanceEvidenceDiscarded
              : l10n.startup_maintenanceEvidenceDiscardedKept,
        );
      } catch (error) {
        outcome.value = _Outcome(
          describeMaintenanceFailure(l10n, error),
          failed: true,
        );
      } finally {
        busy.value = false;
        await reload();
      }
    }

    final canAbandon = next != null && !blockedTasks.value.contains(next.id);

    /// Whether the head task may be *started*, as opposed to merely named.
    ///
    /// Durable evidence for the very task the button would run means a previous
    /// attempt got far enough to leave a record, and recovery has already had its
    /// turn — it runs on mount, before anything here is offered. What is left is
    /// evidence recovery could not resolve, and starting over on top of it is not
    /// a retry: `RestoreOperation.run` writes a fresh journal over the one that
    /// could not be read, and its `oldMoved` phase deletes an existing `old` tree
    /// — which is the user's previous profile, moved aside by the interrupted
    /// attempt and the only copy of it left.
    ///
    /// So the same evidence that takes "cancel" away takes "run" away too, and
    /// the discard-or-recover path below is the only way forward. Blocking both
    /// is the point: the two of them were the whole choice.
    final canRun =
        next != null &&
        _isRunnable(next) &&
        !blockedTasks.value.contains(next.id);

    // Watched rather than read: the button's enabled state has to follow the
    // field, and a plain `controller.text` read only samples it at build time.
    final passwordText = useValueListenable(password).text;

    /// Whether the field still has to be filled in before the task can start.
    ///
    /// An empty password is a legal archive password, which is exactly the
    /// problem: a backup made with one is a file anybody who finds it can open,
    /// created by a screen that told the user to choose a strong one. Restores
    /// are held to the same rule, where it only costs a round trip through a
    /// failure that says "wrong password".
    final passwordMissing = needsPassword && passwordText.isEmpty;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: ContentWidth.form),
        child: SingleChildScrollView(
          // Room for the keyboard: the password field sits low on the screen and
          // this used to be a centered column that simply overflowed.
          padding: EdgeInsets.fromLTRB(
            24,
            32,
            24,
            32 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.settings_backup_restore,
                size: 40,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.startup_maintenanceHeadline,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                switch ((next, unresolved.value.isEmpty)) {
                  (final MaintenanceTask _, _) =>
                    l10n.startup_maintenanceMustFinish,
                  (null, true) => l10n.startup_maintenanceNothingLeft,
                  (null, false) => l10n.startup_maintenanceCannotReadRecord,
                },
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              if (next != null) ...[
                _TaskCard(task: next, busy: busy.value),
                if (needsPassword) ...[
                  const SizedBox(height: 16),
                  ObscurableTextField(
                    controller: password,
                    focusNode: passwordFocus,
                    enabled: !busy.value,
                    autofocus: true,
                    // Clears the moment the user starts fixing it, so the mark
                    // describes the text that failed rather than the text now in
                    // the field.
                    onChanged: (_) => passwordRejected.value = false,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (!busy.value && canRun && !passwordMissing) {
                        unawaited(runTask(next));
                      }
                    },
                    decoration: InputDecoration(
                      labelText: l10n.startup_maintenancePasswordLabel,
                      errorText: passwordRejected.value
                          ? l10n.startup_maintenancePasswordRejected
                          : null,
                      // Says why the button is dark rather than leaving the
                      // user to work it out from a control that does nothing.
                      helperText: passwordMissing
                          ? (next.action == MaintenanceAction.backup
                                ? l10n.startup_maintenancePasswordHelperRequiredBackup
                                : l10n.startup_maintenancePasswordHelperRequiredRestore)
                          : (next.action == MaintenanceAction.backup
                                ? l10n.startup_maintenancePasswordHelperBackup
                                : l10n.startup_maintenancePasswordHelperRestore),
                      helperMaxLines: 3,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: busy.value || !canRun || passwordMissing
                      ? null
                      : () => runTask(next),
                  icon: Icon(_actionIcon(next)),
                  label: Text(_copyFor(l10n, next).verb),
                ),
                // Whatever is blocking the task, shown *with* the task rather
                // than only on the no-tasks branch. Disabling the button and
                // saying nothing left a screen with one dead control and no
                // account of why.
                if (!canRun) ...[
                  // Recovery ran on mount and did not finish. It owns this
                  // record and can be asked again — the automatic pass is the
                  // only thing that failed, not the operation — so this is the
                  // way forward rather than the last resort below.
                  if (recoverableTasks.value.contains(next.id)) ...[
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: busy.value ? null : () => runRecovery(),
                      icon: const Icon(Icons.restart_alt),
                      label: Text(l10n.startup_maintenanceTryFinishingAgain),
                    ),
                  ],
                  if (unresolved.value.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _UnresolvedEvidencePanel(items: unresolved.value),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: busy.value
                          ? null
                          : () => discardEvidence(context),
                      icon: const Icon(Icons.report_problem_outlined),
                      label: Text(
                        l10n.startup_maintenanceDiscardAndContinueBlocked,
                      ),
                    ),
                  ],
                ],
              ] else if (unresolved.value.isEmpty) ...[
                if (retryable.value case final failed?) ...[
                  FilledButton.icon(
                    onPressed: busy.value
                        ? null
                        : () async {
                            busy.value = true;
                            try {
                              await store.transitionTask(
                                failed.id,
                                MaintenanceTaskState.queued,
                              );
                              retryable.value = null;
                              outcome.value = null;
                            } finally {
                              busy.value = false;
                              await reload();
                              // After the rebuild that brings the field back.
                              // Selected rather than cleared: most retries are a
                              // one-character typo, and a wiped field makes the
                              // user retype a long password from scratch.
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                password.selection = TextSelection(
                                  baseOffset: 0,
                                  extentOffset: password.text.length,
                                );
                                passwordFocus.requestFocus();
                              });
                            }
                          },
                    icon: const Icon(Icons.refresh),
                    label: Text(_copyFor(l10n, failed).retry),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: busy.value ? null : onFinished,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(l10n.startup_maintenanceOpenWebLibreRetry),
                  ),
                ] else
                  FilledButton.icon(
                    onPressed: busy.value ? null : onFinished,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(l10n.startup_maintenanceOpenWebLibre),
                  ),
              ] else ...[
                // Nothing queued, but evidence remains — so `onFinished` would
                // release the lease, native would hand it straight back, and the
                // same screen would render again. Offering it as an ordinary
                // "continue" made a button that could only ever loop.
                _UnresolvedEvidencePanel(items: unresolved.value),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: busy.value ? null : () => discardEvidence(context),
                  icon: const Icon(Icons.report_problem_outlined),
                  label: Text(
                    l10n.startup_maintenanceDiscardAndContinueNoTasks,
                  ),
                ),
              ],

              if (busy.value) ...[
                const SizedBox(height: 20),
                const LinearProgressIndicator(),
                if (activity.value != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    activity.value!,
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.startup_maintenanceTakesSeveralMinutes,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],

              if (outcome.value case final result?) ...[
                const SizedBox(height: 20),
                _OutcomeBanner(outcome: result),
              ],

              if (pending.length > 1) ...[
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.startup_maintenanceThenAfterThisOne,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                const SizedBox(height: 4),
                for (final task in pending.skip(1))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          _actionIcon(task),
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _copyFor(l10n, task).describe,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],

              if (next != null) ...[
                const SizedBox(height: 16),
                if (canAbandon)
                  TextButton(
                    onPressed: busy.value ? null : () => abandon(next),
                    child: Text(_copyFor(l10n, next).cancel),
                  )
                else if (!phase.blocking)
                  TextButton(
                    onPressed: busy.value ? null : onFinished,
                    child: Text(l10n.startup_maintenanceSkipForNow),
                  ),
                if (!canAbandon)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      // Three states, not two. Saying "cannot read what it was
                      // doing" over a journal this build reads perfectly well —
                      // whose recovery simply did not finish — described the
                      // wrong problem and pointed at the wrong way out.
                      switch ((
                        canRun,
                        recoverableTasks.value.contains(next.id),
                      )) {
                        (true, _) =>
                          l10n.startup_maintenanceInterruptedMustFinish,
                        (false, true) =>
                          l10n.startup_maintenanceInterruptedFinishFailed,
                        (false, false) =>
                          l10n.startup_maintenanceInterruptedUnreadable,
                      },
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Lists evidence the screen cannot resolve, so the state is legible rather than
/// just a browser that will not open.
class _UnresolvedEvidencePanel extends StatelessWidget {
  const _UnresolvedEvidencePanel({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: SelectableText(
                item,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The last resort, and stated as one.
///
/// The record exists precisely because losing it is how an optimistic boot
/// destroys data, so it is never discarded on a timer, at startup, or as a side
/// effect of anything else. But a browser that can never be opened again is not
/// an acceptable resting state either, and the user is the only one who can weigh
/// those against each other — so they are told exactly what is unknown.
Future<bool?> _confirmDiscardEvidence(BuildContext context) => showDialog<bool>(
  context: context,
  anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
  builder: (context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      icon: const Icon(Icons.report_problem_outlined),
      title: Text(l10n.startup_maintenanceDiscardDialogTitle),
      content: Text(l10n.startup_maintenanceDiscardDialogContent),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.common_cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.startup_maintenanceDiscardIt),
        ),
      ],
    );
  },
);

/// What the operation is, stated so the user can check it before it runs.
class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.busy});

  final MaintenanceTask task;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final copy = _copyFor(AppLocalizations.of(context), task);
    final destructive = task.action?.isDestructive ?? false;

    return Card(
      margin: EdgeInsets.zero,
      color: destructive
          ? theme.colorScheme.errorContainer
          : theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _actionIcon(task),
              color: destructive
                  ? theme.colorScheme.onErrorContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    copy.describe,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: destructive
                          ? theme.colorScheme.onErrorContainer
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    copy.consequence,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: destructive
                          ? theme.colorScheme.onErrorContainer
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Outcome {
  const _Outcome(this.message, {this.failed = false});

  final String message;
  final bool failed;
}

class _OutcomeBanner extends StatelessWidget {
  const _OutcomeBanner({required this.outcome});

  final _Outcome outcome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: outcome.failed
            ? scheme.errorContainer
            : scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            outcome.failed ? Icons.error_outline : Icons.check_circle_outline,
            size: 20,
            color: outcome.failed
                ? scheme.onErrorContainer
                : scheme.onSecondaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SelectableText(
              outcome.message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: outcome.failed
                    ? scheme.onErrorContainer
                    : scheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The non-text facts about one queued action, chosen by one exhaustive
/// switch. This used to be ten parallel switches over [MaintenanceAction],
/// which meant adding an action was ten edits — and `needsPassword`, written
/// as a boolean expression rather than a switch, would not even have failed
/// to compile.
///
/// Kept apart from [_ActionText]: these are read from a `useEffect` callback
/// that runs after an `await` with no widget guaranteed still mounted, so
/// they must never need an [AppLocalizations]/[BuildContext] the way the text
/// fields do.
class _ActionFlags {
  const _ActionFlags({
    required this.needsInput,
    required this.needsPassword,
    required this.isRunnable,
    required this.icon,
  });

  /// Whether the task cannot start until the user gives it something.
  ///
  /// Only the password qualifies. A deletion was confirmed by name before the
  /// restart, so stopping to confirm it again is asking the same question twice
  /// across a process boundary.
  final bool needsInput;

  /// Whether the task cannot start until the user supplies the archive password.
  final bool needsPassword;

  /// Whether this build can execute the task at all.
  ///
  /// `restoreClone` is a queue entry only a newer build writes: restoring into a
  /// new profile is not destructive and stays in the normal app, so the runner
  /// has nothing to do with it.
  final bool isRunnable;

  final IconData icon;
}

_ActionFlags _flagsFor(MaintenanceTask task) => switch (task.action) {
  MaintenanceAction.backup => const _ActionFlags(
    needsInput: true,
    needsPassword: true,
    isRunnable: true,
    icon: Icons.lock_outline,
  ),
  MaintenanceAction.restoreOver => const _ActionFlags(
    needsInput: true,
    needsPassword: true,
    isRunnable: true,
    icon: Icons.settings_backup_restore,
  ),
  MaintenanceAction.delete => const _ActionFlags(
    needsInput: false,
    needsPassword: false,
    isRunnable: true,
    icon: Icons.delete_outline,
  ),
  MaintenanceAction.restoreClone => const _ActionFlags(
    // Not "needs a password" but "must not start on its own":
    // `MaintenanceRunner` refuses this action, so running it unattended only
    // produces a failure the user did not ask for and cannot act on.
    needsInput: true,
    needsPassword: false,
    isRunnable: false,
    icon: Icons.restore_page_outlined,
  ),
  null => const _ActionFlags(
    needsInput: true,
    needsPassword: false,
    isRunnable: false,
    icon: Icons.help_outline,
  ),
};

bool _needsInput(MaintenanceTask task) => _flagsFor(task).needsInput;

bool _needsPassword(MaintenanceTask task) => _flagsFor(task).needsPassword;

bool _isRunnable(MaintenanceTask task) => _flagsFor(task).isRunnable;

IconData _actionIcon(MaintenanceTask task) => _flagsFor(task).icon;

/// Everything this screen *says* about one queued action. See [_ActionFlags]
/// for why this is a separate switch rather than one combined class.
class _ActionText {
  const _ActionText({
    required this.verb,
    required this.retry,
    required this.cancel,
    required this.describe,
    required this.consequence,
    required this.activity,
    required this.describeDone,
  });

  /// The verb for the primary button, so it never says "Continue" while the
  /// thing it actually does is delete a profile.
  final String verb;

  /// Whole button labels rather than one noun slotted into a shared sentence:
  /// the article and adjective around the noun agree with its gender, which
  /// differs per task in most languages.
  final String retry;
  final String cancel;
  final String describe;
  final String consequence;
  final String activity;
  final String describeDone;
}

_ActionText _copyFor(
  AppLocalizations l10n,
  MaintenanceTask task,
) => switch (task.action) {
  MaintenanceAction.backup => _ActionText(
    verb: l10n.startup_maintenanceBackupVerb,
    retry: l10n.startup_maintenanceBackupRetry,
    cancel: l10n.startup_maintenanceBackupCancel,
    describe: l10n.startup_maintenanceBackupDescribe(task.profileName),
    consequence: l10n.startup_maintenanceBackupConsequence(
      l10n.profileCopy_secretDataDescription,
    ),
    activity: l10n.startup_maintenanceBackupActivity(task.profileName),
    describeDone: l10n.startup_maintenanceBackupDescribeDone(task.profileName),
  ),
  MaintenanceAction.restoreOver => _ActionText(
    verb: l10n.startup_maintenanceRestoreOverVerb,
    retry: l10n.startup_maintenanceRestoreOverRetry,
    cancel: l10n.startup_maintenanceRestoreOverCancel,
    describe: l10n.startup_maintenanceRestoreOverDescribe(task.profileName),
    consequence: task.adoptArchiveName
        ? l10n.startup_maintenanceRestoreOverConsequenceWithRename(
            l10n.profileCopy_signedInFromBackup,
            l10n.profileCopy_olderBackupKeepsCredentials,
            l10n.profileCopy_cannotBeUndone,
          )
        : l10n.startup_maintenanceRestoreOverConsequencePlain(
            l10n.profileCopy_signedInFromBackup,
            l10n.profileCopy_olderBackupKeepsCredentials,
            l10n.profileCopy_cannotBeUndone,
          ),
    activity: l10n.startup_maintenanceRestoreOverActivity(task.profileName),
    describeDone: l10n.startup_maintenanceRestoreOverDescribeDone(
      task.profileName,
    ),
  ),
  MaintenanceAction.delete => _ActionText(
    verb: l10n.startup_maintenanceDeleteVerb,
    retry: l10n.startup_maintenanceDeleteRetry,
    cancel: l10n.startup_maintenanceDeleteCancel,
    describe: l10n.startup_maintenanceDeleteDescribe(task.profileName),
    consequence: l10n.startup_maintenanceDeleteConsequence(
      l10n.profileCopy_dataDescription,
      l10n.profileCopy_cannotBeUndone,
    ),
    activity: l10n.startup_maintenanceDeleteActivity(task.profileName),
    describeDone: l10n.startup_maintenanceDeleteDescribeDone(task.profileName),
  ),
  MaintenanceAction.restoreClone => _ActionText(
    verb: l10n.startup_maintenanceRestoreCloneVerb,
    retry: l10n.startup_maintenanceRestoreCloneRetry,
    cancel: l10n.startup_maintenanceRestoreCloneCancel,
    describe: l10n.startup_maintenanceRestoreCloneDescribe(task.profileName),
    consequence: l10n.startup_maintenanceRestoreCloneConsequence,
    activity: l10n.startup_maintenanceRestoreCloneActivity(task.profileName),
    describeDone: l10n.startup_maintenanceRestoreCloneDescribeDone(
      task.profileName,
    ),
  ),
  null => _ActionText(
    verb: l10n.startup_maintenanceUnknownVerb,
    retry: l10n.startup_maintenanceUnknownRetry,
    cancel: l10n.startup_maintenanceUnknownCancel,
    describe: l10n.startup_maintenanceUnknownDescribe(task.id),
    consequence: l10n.startup_maintenanceUnknownConsequence,
    activity: l10n.startup_maintenanceUnknownActivity,
    describeDone: l10n.startup_maintenanceUnknownDescribeDone,
  ),
};
