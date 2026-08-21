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

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:simple_intent_receiver/simple_intent_receiver.dart';
import 'package:uuid/uuid_value.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/startup/restart_authorization_store.dart';
import 'package:weblibre/features/share_intent/domain/services/sharing_intent.dart';
import 'package:weblibre/features/user/domain/repositories/profile.dart';
import 'package:weblibre/utils/exit_app.dart';

part 'profile_restart_request.g.dart';

/// Sent by `IntentReceiverActivity` when the user answers a profile-mismatch
/// dialog with "restart into the other profile".
const restartIntoProfileAction = 'eu.weblibre.action.RESTART_INTO_PROFILE';
const _profileIdExtra = 'eu.weblibre.extra.RESTART_PROFILE_ID';
const _authorizationExtra = 'eu.weblibre.extra.RESTART_AUTHORIZATION';

/// The profile id a restart request *claims*, or null for any other intent.
///
/// A claim and nothing more. `MainActivity` is exported, so this action and this
/// extra are things any app on the device can send; shape-checking the id says
/// only that the intent is addressed to this handler, never that it may be
/// honoured. [consumeRestartRequest] is what decides that.
///
/// The shape check is still worth doing here, because the id decides which
/// profile the next process binds to and that cannot be revised once the process
/// is up.
String? restartProfileIdClaim(Intent intent) {
  if (intent.action != restartIntoProfileAction) return null;

  final raw = intent.extra[_profileIdExtra];
  if (raw is! String || raw.isEmpty) return null;

  try {
    return UuidValue.withValidation(raw.toLowerCase()).uuid;
  } catch (_) {
    return null;
  }
}

/// The profile a restart request is *authorized* to name, or null.
///
/// Every restart request is checked against a one-shot record native wrote to
/// app-private storage before it sent the intent, and the record is consumed
/// here. Without that check the exported activity would accept a restart from
/// any app on the device: the browser closes, whatever the user was doing is
/// gone, and it reopens on a profile someone else chose.
///
/// Null covers "no authorization on record", "wrong token", "expired", "already
/// used" and "authorized for a different profile". They mean the same thing to
/// the caller — this request is not one this app made — and none of them may end
/// the process.
Future<String?> consumeRestartRequest(
  Intent intent, {
  RestartAuthorizationStore? store,
  DateTime? now,
}) async {
  final claimed = restartProfileIdClaim(intent);
  if (claimed == null) return null;

  final token = intent.extra[_authorizationExtra];
  final authorizations =
      store ?? RestartAuthorizationStore(filesystem.startupPaths);

  return authorizations.consume(
    token is String ? token : null,
    claimedProfileId: claimed,
    now: now,
  );
}

@Riverpod(keepAlive: true)
Raw<Stream<String>> restartProfileRequestStream(Ref ref) {
  // The shared source, so a mismatch-dialog request that arrived while the
  // picker was up is replayed here like any other launch.
  final intents = ref.watch(allIntentsProvider);
  final controller = StreamController<String>();

  // `asyncMap` rather than `map`: the authorization lives on disk, and reading
  // it is what separates a request this app made from one another app sent. Done
  // in order, so two requests cannot race over the single stored record.
  final subscription = intents
      .asyncMap(consumeRestartRequest)
      .where((profileId) => profileId != null)
      .cast<String>()
      .listen(controller.add, onError: controller.addError);

  ref.onDispose(() {
    unawaited(subscription.cancel());
    unawaited(controller.close());
  });

  return controller.stream;
}

/// Restarts the app onto the profile a mismatched shortcut belongs to.
///
/// The work happens here rather than in the activity that raised the dialog
/// because this isolate is the one holding the engine, the databases and the
/// Gecko runtime — it is the only place a clean shutdown can happen. The native
/// side has already recorded which launch to replay afterwards.
///
/// Must be watched during app initialization to be active.
@Riverpod(keepAlive: true)
void profileRestartRequestHandler(Ref ref) {
  final stream = ref.watch(restartProfileRequestStreamProvider);

  final subscription = stream.listen((profileId) async {
    logger.i(
      'Restarting into profile $profileId at the shortcut owner request',
    );

    try {
      // Checked before anything is armed. Arming is the point of no return —
      // the process is terminal from there on — so a target that no longer
      // exists has to fail while the browser can still simply carry on.
      final profiles = await ref.read(profileRepositoryProvider.future);
      if (!profiles.any((profile) => profile.id == profileId)) {
        logger.w('Refusing a restart into unknown profile $profileId');
        return;
      }

      await ref
          .read(profileRepositoryProvider.notifier)
          .switchProfile(profileId);
    } catch (error, stackTrace) {
      // Nothing is torn down yet, so the app simply carries on where it is.
      logger.e(
        'Could not arm a restart into $profileId',
        error: error,
        stackTrace: stackTrace,
      );
      return;
    }

    await exitApp(ref.container, restart: true);
  });

  ref.onDispose(subscription.cancel);
}
