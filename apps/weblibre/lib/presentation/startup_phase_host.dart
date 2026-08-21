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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:weblibre/core/copy/profile_copy.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/startup/startup_bootstrap.dart';
import 'package:weblibre/presentation/startup_maintenance_screen.dart';
import 'package:weblibre/presentation/startup_profile_picker.dart';

/// How often the picker proves it is still asking.
///
/// A fifth of the native `SELECTION_TIMEOUT_MS`, so several renewals have to be
/// missed before the watchdog concludes this owner is gone.
const _selectionHeartbeatInterval = Duration(seconds: 60);

/// The single root of the process, before the app itself exists.
///
/// It is one widget rather than a sequence of `runApp()` calls so the arbitration
/// future is owned by the element tree: a rebuild cannot restart the decision,
/// and there is never a moment where two roots are alive at once.
///
/// It deliberately creates no `ProviderScope`. Everything the app's providers
/// reach for — databases, settings, the Gecko engine — is profile-bound, and no
/// profile exists until [resolveStartupPhase] returns [StartupActivated].
class StartupPhaseHost extends HookWidget {
  const StartupPhaseHost({
    required this.appBuilder,
    this.onActivated,
    super.key,
  });

  /// Builds the real app. Called only after the profile is activated.
  final WidgetBuilder appBuilder;

  /// Profile-bound bootstrap that must run before the app builds — anything that
  /// would otherwise open profile state from a second isolate.
  final Future<void> Function()? onActivated;

  Future<StartupPhase> _settle(StartupPhase phase) async {
    if (phase is StartupActivated) {
      await onActivated?.call();
    } else if (phase is StartupHalted) {
      logger.w('Startup halted: $phase');
    }
    return phase;
  }

  @override
  Widget build(BuildContext context) {
    // The picker's answer replaces the resolved phase rather than restarting the
    // future: the lease was granted to this owner once, and re-running startup to
    // apply a choice would ask native for it a second time.
    final answered = useState<StartupPhase?>(null);
    final committing = useState(false);
    final resolved = useFuture(useMemoized(() => _run()));

    final phase = answered.value ?? resolved.data;

    // Hooks run before the error branch below, so that an error build cannot skip
    // one and desynchronise the hook order.
    final lifecycle = useAppLifecycleState();
    final selectionLeaseId = phase is StartupSelectionRequired
        ? phase.leaseId
        : null;

    // Without this the native selection watchdog commits the candidate profile
    // after `SELECTION_TIMEOUT_MS`, binding the process to a profile nobody chose
    // and refusing the user's eventual tap. Renewing while the picker is on screen
    // is what makes "not answered yet" different from "this owner is gone" — and
    // it deliberately stops while the app is not resumed, because a picker the
    // user cannot see is not a reason to hold the decision indefinitely.
    useEffect(() {
      if (selectionLeaseId == null) return null;
      if (lifecycle != null && lifecycle != AppLifecycleState.resumed) {
        return null;
      }

      final timer = Timer.periodic(_selectionHeartbeatInterval, (_) {
        unawaited(heartbeatSelectionLease(leaseId: selectionLeaseId));
      });
      return timer.cancel;
    }, [selectionLeaseId, lifecycle]);

    /// Arbitrates again, from the top.
    ///
    /// Only ever reached from a halt, which is precisely the state in which
    /// nothing was opened and no lease is held — so asking again is a fresh
    /// question rather than a second answer to one already given. That is what
    /// makes "try again in a moment" something the user can actually do: the
    /// competing owner was another isolate in this process, and it finishes.
    Future<void> retry() async {
      if (committing.value) return;
      committing.value = true;
      try {
        answered.value = await _settle(await resolveStartupPhase());
      } finally {
        committing.value = false;
      }
    }

    // Guarded on there being no answer to show, not on the future alone: the
    // future is memoized, so once it rejects it stays rejected for the life of
    // this element — and checking it ahead of `phase` would pin the screen to
    // that first error even after a retry has answered successfully.
    if (phase == null && resolved.hasError) {
      return _StartupShell(
        child: StartupHaltScreen(
          halted: StartupHalted(
            kind: StartupHaltKind.arbitrationFailed,
            reason: '${resolved.error}',
          ),
          onRetry: retry,
          busy: committing.value,
        ),
      );
    }

    return switch (phase) {
      final StartupActivated _ => appBuilder(context),
      final StartupHalted halted => _StartupShell(
        child: StartupHaltScreen(
          halted: halted,
          onRetry: retry,
          busy: committing.value,
        ),
      ),
      final StartupMaintenanceRequired maintenance => _StartupShell(
        child: StartupMaintenanceScreen(
          phase: maintenance,
          onFinished: () async {
            if (committing.value) return;
            committing.value = true;
            answered.value = await _settle(
              await finishMaintenanceAndResolve(leaseId: maintenance.leaseId),
            );
            committing.value = false;
          },
        ),
      ),
      final StartupSelectionRequired selection => _StartupShell(
        child: StartupProfilePicker(
          profiles: selection.profiles,
          candidateProfileId: selection.candidateProfileId,
          busy: committing.value,
          onSelected: (profileId) async {
            if (committing.value) return;
            committing.value = true;
            try {
              answered.value = await _settle(
                await commitChosenProfile(
                  leaseId: selection.leaseId,
                  profileId: profileId,
                ),
              );
            } finally {
              // Reset even on the paths that do not activate: a re-arbitrated
              // selection renders the picker again, and leaving it busy would
              // give the user a screen with nothing they can press.
              committing.value = false;
            }
          },
        ),
      ),
      null => const _StartupShell(child: _StartupPendingScreen()),
    };
  }

  Future<StartupPhase> _run() async {
    final phase = await resolveStartupPhase();
    // Neither a pending selection nor pending maintenance is settled: nothing
    // has been activated and nothing has failed, so neither the post-activation
    // bootstrap nor the halt log applies yet.
    if (phase is StartupSelectionRequired ||
        phase is StartupMaintenanceRequired) {
      return phase;
    }
    return _settle(phase);
  }
}

/// Derived once per process: [ColorScheme.fromSeed] runs the Material tonal
/// palette derivation, and the shell below rebuilds on every phase change.
final ThemeData _startupLightTheme = ThemeData(useMaterial3: true);
final ThemeData _startupDarkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.dark,
  ),
);

/// A minimal app shell for the phases before the real app can be built.
///
/// It uses stock theming rather than the user's: the theme lives in profile
/// settings, and reading those is precisely what is not allowed yet.
class _StartupShell extends StatelessWidget {
  const _StartupShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _startupLightTheme,
      darkTheme: _startupDarkTheme,
      home: Scaffold(body: SafeArea(child: child)),
    );
  }
}

class _StartupPendingScreen extends StatelessWidget {
  const _StartupPendingScreen();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Explains why the browser will not open, and does not offer to open it anyway.
///
/// Every halt here means the process may not touch a profile. A "continue"
/// affordance would only be able to do the one thing that is unsafe, so the
/// screen states the situation instead of pretending there is a choice.
class StartupHaltScreen extends StatelessWidget {
  const StartupHaltScreen({
    required this.halted,
    this.onRetry,
    this.busy = false,
    super.key,
  });

  final StartupHalted halted;

  /// Arbitrates again. Offered only where asking a second time can plausibly
  /// answer differently — see [_retryable].
  final Future<void> Function()? onRetry;

  final bool busy;

  /// Whether a second attempt could reasonably succeed without anything else
  /// changing.
  ///
  /// `profileAccessBusy` is the clear yes: the holder is another isolate in this
  /// same process and it finishes. `arbitrationFailed` is a maybe — the channel
  /// may simply not have answered — and a button that does nothing is still
  /// better than a screen telling the user to reopen an app they are looking at.
  ///
  /// The other three are no. Maintenance and a missing profile do not resolve
  /// themselves, and `unavailable` explicitly means this process is on its way
  /// out; a retry there would only obscure the restart the screen is asking for.
  bool get _retryable =>
      halted.kind == StartupHaltKind.profileAccessBusy ||
      halted.kind == StartupHaltKind.arbitrationFailed;

  /// Everything worth putting in a bug report, as one block.
  String get _details => [
    'Startup halted: ${halted.kind.name}',
    halted.reason,
    if (halted.taskId != null) 'Task: ${halted.taskId}',
    if (halted.recoveryRequired) 'Recovery required',
  ].join('\n');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (icon, title, body) = switch (halted.kind) {
      StartupHaltKind.maintenance => (
        Icons.build_outlined,
        'Unfinished profile work',
        'A backup, restore or deletion from an earlier run did not finish. '
            'WebLibre must finish it before any profile can open.',
      ),
      StartupHaltKind.unavailable => (
        Icons.hourglass_empty,
        'Startup is not ready',
        'WebLibre needs to restart before it can choose a profile. '
            '$reopenToContinue',
      ),
      StartupHaltKind.profileAccessBusy => (
        Icons.lock_clock,
        'Profile is in use',
        'Another WebLibre task is still using this profile. Try again in a '
            'moment.',
      ),
      StartupHaltKind.noProfile => (
        Icons.person_off_outlined,
        'No usable profile',
        'WebLibre could not read an existing profile or create a new one. '
            'Storage may be full or unavailable.',
      ),
      StartupHaltKind.arbitrationFailed => (
        Icons.error_outline,
        'Cannot tell which profile to open',
        'WebLibre will not guess which profile to use. $reopenToContinue',
      ),
    };

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(body, textAlign: TextAlign.center),
              const SizedBox(height: 24),

              // The screen used to state the situation and stop there, including
              // where it said "try again in a moment" with nothing to press and
              // "close and reopen WebLibre" to a user holding an app that offers
              // no way to close itself.
              if (_retryable && onRetry != null)
                FilledButton.icon(
                  onPressed: busy ? null : () => unawaited(onRetry!()),
                  icon: const Icon(Icons.refresh),
                  label: Text(busy ? 'Trying again…' : 'Try again'),
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                // Not `exitApp`: that tears down databases, the engine and a
                // provider container, and none of those exist here — the whole
                // premise of a halt is that no profile was opened. Popping the
                // last route ends the task, which is what "close" means to the
                // user.
                onPressed: busy ? null : () => unawaited(SystemNavigator.pop()),
                icon: const Icon(Icons.close),
                label: const Text('Close WebLibre'),
              ),
              const SizedBox(height: 24),
              // Folded away rather than dropped. None of it means anything to a
              // user mid-launch, but it is the only diagnostic they can read out
              // in a bug report — and this screen has no logs behind it.
              _HaltDetails(halted: halted, details: _details),
            ],
          ),
        ),
      ),
    );
  }
}

class _HaltDetails extends StatelessWidget {
  const _HaltDetails({required this.halted, required this.details});

  final StartupHalted halted;

  /// The same text the copy button puts on the clipboard, so what the user
  /// pastes into a bug report is exactly what they were shown.
  final String details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      // The divider lines an ExpansionTile draws by default read as a broken
      // layout on an otherwise empty screen.
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text('Technical details', style: theme.textTheme.bodySmall),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SelectableText(
              details,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            // Selecting text on a phone, on a screen the user reached because
            // something went wrong, is not a reasonable thing to ask of them.
            child: TextButton.icon(
              onPressed: () =>
                  unawaited(Clipboard.setData(ClipboardData(text: details))),
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy details'),
            ),
          ),
        ],
      ),
    );
  }
}
